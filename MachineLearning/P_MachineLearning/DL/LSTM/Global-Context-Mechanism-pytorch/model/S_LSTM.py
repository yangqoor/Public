"""
Implementation of S-LSTM in torch 2024.04.10 : Sentence-State LSTM for Text Representation https://arxiv.org/abs/1805.02474

Origin source code in Tensorflow: https://github.com/leuchine/S-LSTM/
"""

import torch
import torch.nn as nn
import torch.nn.functional as F


class SLSTMCell(nn.Module):
    def __init__(self,
                 vocabulary_size,
                 char_alphabet_size,
                 input_size,
                 hidden_size,
                 word_vector_size,
                 num_layers,
                 num_labels,
                 label2idx=None, pretrained_vector=None, use_char=False, use_extra_feature=False, **kwargs):
        super(SLSTMCell, self).__init__()
        self.layers = num_layers
        self.hidden_size = hidden_size
        self.input_size = input_size
        # load_pretrained_vector
        if pretrained_vector is not None:
            self.embedding_layer = nn.Embedding.from_pretrained(pretrained_vector, freeze=False)
        else:
            self.embedding_layer = nn.Embedding(vocabulary_size, word_vector_size)
        self.input_gate = nn.Linear(4 * hidden_size + input_size, hidden_size)
        self.left_gate = nn.Linear(4 * hidden_size + input_size, hidden_size)
        self.right_gate = nn.Linear(4 * hidden_size + input_size, hidden_size)
        self.forget_gate = nn.Linear(4 * hidden_size + input_size, hidden_size)
        self.sentence_gate = nn.Linear(4 * hidden_size + input_size, hidden_size)
        self.output_gate = nn.Linear(4 * hidden_size + input_size, hidden_size)
        self.u_gate = nn.Linear(4 * hidden_size + input_size, hidden_size)

        # gate for global state

        self.expand_word_vector = nn.Linear(input_size, hidden_size)
        self.forget_gate_g = nn.Linear(2 * hidden_size, hidden_size)
        self.forget_gate_i = nn.Linear(2 * hidden_size, hidden_size)
        self.output_gate_g = nn.Linear(2 * hidden_size, hidden_size)

        self.tmp = nn.Linear(hidden_size, hidden_size)

        self.classify_layer = nn.Linear(hidden_size, num_labels)

    def forward(self,
                sentence_ids=None,
                extra_word_feature=None,
                sentence_length=None,
                char_ids=None,
                extra_char_feature=None,
                masks=None,
                label_ids=None,
                label_ids_original=None):
        # (batch_size, max_len) -> (batch_size, max_len, word_dim)
        word_embeddings = self.embedding_layer(sentence_ids)
        # init_hidden_states = F.relu(self.tmp(word_embeddings))

        # convert mask from (batch_size, max_len) to (batch_size, max_len, word_dim)
        masks = masks.unsqueeze(2).repeat(1, 1, self.hidden_size)

        masks_softmax_score = masks * 1e25 - 1e25
        init_hidden_states = word_embeddings * masks
        # init_hidden_states = self.expand_word_vector(word_embeddings)

        init_hidden_states = init_hidden_states * masks
        init_cell_states = torch.clone(init_hidden_states)
        word_embeddings = word_embeddings * masks

        # create hidden_states for dummy nodes (batch_size, hidden_size)
        # (batch_size, hidden_size) for both these three variables
        hidden_states_g = torch.mean(init_hidden_states, dim=1)
        cell_states_g = torch.mean(init_hidden_states, dim=1)
        max_len = init_hidden_states.size(1)
        batch_size = masks.size(0)
        hidden_size = self.hidden_size
        for idx in range(self.layers):
            # update global state first
            # (batch_size, max_len, word_dim) -> (batch_size, word_dim)
            avg_h = torch.mean(init_hidden_states, dim=1)
            # (batch_size, 2 * hidden_size) -> (batch_size, hidden_size)
            f_g = F.sigmoid(self.forget_gate_g(torch.cat([hidden_states_g, avg_h], dim=-1)))
            # (batch_size, hidden_size) -> (batch_size, max_len, hidden_size)
            hidden_states_g_repeat = hidden_states_g.unsqueeze(1).repeat(1, max_len, 1)
            # (batch_size, max_len,  2 * hidden_size) -> (batch_size, max_len, hidden_size)
            f_g_i = F.sigmoid(self.forget_gate_i(torch.cat([hidden_states_g_repeat, init_hidden_states], dim=-1)))
            o_g = F.sigmoid(self.output_gate_g(torch.cat([hidden_states_g, avg_h], dim=-1)))
            # Performing softmax operation: adding mask score to each position
            f_g_total = torch.cat([f_g_i + masks_softmax_score, f_g.unsqueeze(1)], dim=1)
            f_g_total = F.softmax(f_g_total, dim=1)
            f_g = f_g_total[:, -1, :]
            f_g_i = f_g_total[:, :-1, :]
            # (batch_size, hidden_size) * (batch_size, hidden_size) + (batch_size, hidden_size)
            # -> (batch_size, hidden_size)
            c_g = f_g * cell_states_g + torch.sum(f_g_i * init_cell_states, dim=1)

            # update hidden_sates and cell states for global nodes

            def sum_together(tensors):
                fused_tensors = None
                for tensor_step in tensors:
                    if fused_tensors is not None:
                        fused_tensors += tensor_step
                    else:
                        fused_tensors = tensor_step
                return fused_tensors

            # update word node states
            device_idx = init_hidden_states.get_device()
            if device_idx == -1:
                device = torch.device('cpu')
            else:
                device = torch.device(f'cuda:{device_idx}')

            hidden_states_before = sum_together(
                [self._previous_states(init_hidden_states, i + 1, batch_size, hidden_size, device)
                 for i in range(max_len)])
            hidden_states_after = sum_together(
                [self._next_states(init_hidden_states, i + 1, batch_size, hidden_size, device) for
                 i in range(max_len)])

            cell_states_before = sum_together(
                [self._previous_states(init_cell_states, i + 1, batch_size, hidden_size, device)
                 for i in range(max_len)])
            cell_states_after = sum_together(
                [self._next_states(init_cell_states, i + 1, batch_size, hidden_size, device) for
                 i in range(max_len)])
            # hidden_states_before, cell_states_before = self._previous_states(init_hidden_states), self._previous_states(init_cell_states)
            # cell_states_before, cell_states_after = self._previous_states(init_cell_states)
            assert init_hidden_states.size() == hidden_states_after.size() == hidden_states_before.size()
            # fuse hidden states in current step with previous and next step
            # (batch_size, max_len, word_size) -> (batch_size, max_len, 3 * word_size)
            fused_hidden_states = torch.cat([hidden_states_before, init_hidden_states, hidden_states_after], dim=-1)

            # expand global states from (batch_size, word_size) to (batch_size, max_len, word_size)
            # for updating s-lstm states

            hidden_states_g_repeat_ = hidden_states_g.unsqueeze(1).repeat(1, max_len, 1)

            cell_states_g_repeat_ = cell_states_g.unsqueeze(1).repeat(1, max_len, 1)

            # fuse word embedding, fused_hidden_states and previous global states together
            # (batch_size, max_len, 3 * word_size + word_size + word_size) -> (batch_size, max_len, 5 * word_size)
            s_lstm_input = torch.cat([fused_hidden_states, word_embeddings, hidden_states_g_repeat_], dim=-1)
            # The size of the output ofr all gates is (batch_size, max_len, hidden_size)
            gate_i_lstm = F.sigmoid(self.input_gate(s_lstm_input))
            gate_l_lstm = F.sigmoid(self.left_gate(s_lstm_input))
            gate_r_lstm = F.sigmoid(self.right_gate(s_lstm_input))
            gate_f_lstm = F.sigmoid(self.forget_gate(s_lstm_input))
            gate_s_lstm = F.sigmoid(self.sentence_gate(s_lstm_input))
            gate_o_lstm = F.sigmoid(self.output_gate(s_lstm_input))
            gate_u_lstm = F.tanh(self.u_gate(s_lstm_input))

            # -> (batch_size, word_size)
            total_weights = F.softmax(
                torch.cat([gate_i_lstm + masks_softmax_score, gate_l_lstm + masks_softmax_score, gate_r_lstm
                           + masks_softmax_score, gate_f_lstm + masks_softmax_score, gate_s_lstm
                           + masks_softmax_score], dim=1), dim=1)
            # (batch_size, max_len, word_size)
            # total_weights_repeat = total_weights.unsqueeze(1).repeat(1, max_len, 1)
            # normalize i, l, r, f, s older implementation
            # gate_s_lstm = gate_s_lstm / total_weights_repeat
            # gate_r_lstm = gate_s_lstm / total_weights_repeat
            # gate_l_lstm = gate_l_lstm / total_weights_repeat
            # gate_f_lstm = gate_f_lstm / total_weights_repeat
            # gate_i_lstm = gate_i_lstm / total_weights_repeat
            seq_len = gate_i_lstm.size(1)
            gate_i_lstm = total_weights[:, :seq_len, :]
            gate_l_lstm = total_weights[:, seq_len:2 * seq_len, :]
            gate_r_lstm = total_weights[:, seq_len * 2:3 * seq_len, :]
            gate_f_lstm = total_weights[:, 3 * seq_len:4 * seq_len, :]
            gate_s_lstm = total_weights[:, 4 * seq_len:, :]

            # calculate cell states in current layers
            # the size of all tensors below is (batch_size, max_len, word_size)
            cell_states_ = gate_l_lstm * cell_states_before + gate_r_lstm * cell_states_after
            + gate_f_lstm * init_cell_states + gate_s_lstm * cell_states_g_repeat_ + gate_i_lstm * gate_u_lstm

            # new implementation following the source code
            # cell_states_ = gate_l_lstm * cell_states_before + gate_r_lstm * cell_states_after
            # + gate_f_lstm * word_embeddings + gate_s_lstm * cell_states_g_repeat_ + gate_i_lstm * init_cell_states

            hidden_states_ = gate_o_lstm * F.tanh(cell_states_)

            # update sates for words
            init_hidden_states = hidden_states_
            init_cell_states = cell_states_

            hidden_states_g = o_g * F.tanh(c_g)
            cell_states_g = c_g
        #
        logits = self.classify_layer(init_hidden_states + hidden_states_g.unsqueeze(1).repeat(1, seq_len, 1))
        return logits, None

    def _previous_states(self, hidden_states, step, batch_size, hidden_size, device):
        padding_ = torch.zeros(batch_size, step, hidden_size, device=device)
        displaced_hidden_states = hidden_states[:, :-step, :]
        hidden_states_before = torch.cat([padding_, displaced_hidden_states], dim=1)
        # hidden_states_after = hidden_states[:, 1:, :]
        # hidden_states_after = torch.cat([hidden_states_after, padding_], dim=1)
        return hidden_states_before

    def _next_states(self, hidden_states, step, batch_size, hidden_size, device):
        padding_ = torch.zeros(batch_size, step, hidden_size, device=device)
        displaced_hidden_states = hidden_states[:, step:, :]
        hidden_states_after = torch.cat([displaced_hidden_states, padding_], dim=1)
        # hidden_states_after = hidden_states[:, 1:, :]
        # hidden_states_after = torch.cat([hidden_states_after, padding_], dim=1)
        return hidden_states_after
