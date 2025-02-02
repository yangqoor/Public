import torch
import torch.nn as nn
import torch.nn.functional as f
from torch.nn.utils.rnn import pack_padded_sequence, pad_packed_sequence

from model.crf import CRF
from model.context_mechanism import GlobalContext, SAN

RNNMapping = {
    'LSTM': nn.LSTM,
    'GRU': nn.GRU
}

CONTEXT = {
    'global': GlobalContext,
    'self-attention': SAN,
    'cross-ner': '',
}


class RNNNet(nn.Module):
    def __init__(self,
                 vocabulary_size,
                 char_alphabet_size,
                 input_size,
                 hidden_size,
                 word_vector_size,
                 num_layers,
                 num_labels,
                 context_name='global',
                 use_extra_features=False,
                 pretrained_vector=None,
                 use_crf=False,
                 use_context=False,
                 rnn_type='LSTM',
                 use_char=False,
                 char_embedding_dim=None,
                 char_hidden_dim=None,
                 kernel_size=None):
        super(RNNNet, self).__init__()
        self.use_char = use_char
        self.use_extra_features= use_extra_features
        if pretrained_vector is not None:
            self.embedding_layer = nn.Embedding.from_pretrained(pretrained_vector, freeze=False)
        else:
            self.embedding_layer = nn.Embedding(vocabulary_size, word_vector_size)
        if use_char:
            self.char_cnn = CharCNN(char_alphabet_size, char_embedding_dim, char_hidden_dim, kernel_size)
        self.rnn = RNNMapping[rnn_type](input_size=input_size,
                                        hidden_size=hidden_size//2,
                                        num_layers=num_layers,
                                        bidirectional=True,
                                        )
        if use_context:
            # self.context_mechanism = GlobalContext(hidden_size)
            self.context_name = context_name
            if context_name == 'global':
                self.context_mechanism = CONTEXT[context_name](hidden_size)
            if context_name == 'self-attention':
                self.num_heads = 5
                self.context_mechanism = CONTEXT[context_name](hidden_size, self.num_heads)

            # self.context_mechanism = GlobalContextOld(hidden_size, weight_mechanism=MySequential)
        if use_crf:
            self.crf = CRF(hidden_size, num_labels)
        self.use_context = use_context
        self.use_crf = use_crf
        self.classify_layer = nn.Linear(hidden_size, num_labels)
        self.dropout = nn.Dropout(p=0.1)

    def _build_features(self,
                sentence_ids=None,
                label_ids=None,
                extra_word_feature=None,
                sentence_length=None,
                char_ids=None,
                extra_char_feature=None,
                word_length=None,
                label_ids_original=None):
        """
        word_ids: (batch_size, max_sent_length)
        char_ids: (batch_size, max_sent_length, max_word_length)
        """
        masks = sentence_ids.gt(0)
        word_embed = self.embedding_layer(sentence_ids)

        if self.use_char:
            batch_size = char_ids.size(0)
            sent_len = char_ids.size(1)
            char_len = char_ids.size(-1)
            char_ids = char_ids.reshape(-1, char_len)
            char_embed = self.char_cnn(char_ids)
            char_embed = char_embed.reshape(batch_size, sent_len, -1)
            input_ = torch.cat((word_embed, char_embed, extra_word_feature, extra_char_feature), dim=-1)
        elif self.use_extra_features:
            input_ = torch.cat((word_embed, extra_word_feature, extra_char_feature), dim=-1)
        else:
            input_ = word_embed

        input_ = pack_padded_sequence(input_, lengths=sentence_length.cpu(), enforce_sorted=False, batch_first=True)
        rnn_out, (h_n, c_n) = self.rnn(input_)
        rnn_out, _ = pad_packed_sequence(rnn_out, batch_first=True)
        return rnn_out, masks, (h_n, c_n)

    def forward(self,
                sentence_ids=None,
                extra_word_feature=None,
                sentence_length=None,
                char_ids=None,
                extra_char_feature=None,
                masks=None,
                label_ids=None,
                label_ids_original=None):
        gate_weight = None
        rnn_out, masks_, (h_n, c_n) = self._build_features(sentence_ids=sentence_ids, extra_word_feature=extra_word_feature,
                                       sentence_length=sentence_length, char_ids=char_ids,
                                       extra_char_feature=extra_char_feature)
        if self.use_context:
            if self.context_name == 'global':

                forward_global = rnn_out[:, -1, :]
                batch_size = sentence_ids.size(0)
                backward_global = rnn_out[:, 0, :]
                # forward_global = rnn_out[torch.arange(batch_size), sentence_length - 1]
                # forward_global = h_n[0]
                # backward_global = h_n[1]
                rnn_out, gate_weight = self.context_mechanism(rnn_out, forward_global, backward_global)
                # rnn_out, gate_weight = self.context_mechanism(rnn_out, backward_global, forward_global)
            elif self.context_name == 'self-attention':
                masks = masks.to(torch.bool)
                sequence_output, gate_weight = self.context_mechanism(rnn_out, src_mask=masks)

        if self.use_crf:
            scores, tag_seq = self.crf(rnn_out, masks_)
        else:
            tag_seq = self.classify_layer(rnn_out)
        return tag_seq, gate_weight

    def loss(self,
             sentence_ids=None,
             extra_word_feature=None,
             sentence_length=None,
             char_ids=None,
             extra_char_feature=None,
             masks=None,
             label_ids=None,
             label_ids_original=None):


        rnn_out, masks_ = self._build_features(sentence_ids=sentence_ids,
                                       extra_word_feature=extra_word_feature,
                                       sentence_length=sentence_length,
                                       char_ids=char_ids,
                                       extra_char_feature=extra_char_feature)
        if self.use_context:
            forward_global = rnn_out[:, -1, :]
            backward_global = rnn_out[:, 0, :]
            rnn_out, gate_weight = self.context_mechanism(rnn_out, forward_global, backward_global)
        loss = self.crf.loss(rnn_out, label_ids, masks_)
        return loss


class CharCNN(nn.Module):
    """

    """
    def __init__(self, alphabet_size, embedding_dim, char_dim, kernerl_size=3):
        super(CharCNN, self).__init__()
        # kernel_w char dim || kernel_h windows size
        self.embedding_layer = nn.Embedding(alphabet_size, embedding_dim)
        self.char_drop = nn.Dropout()
        self.char_cnn = nn.Conv1d(embedding_dim, char_dim, kernerl_size, padding=1)

    def forward(self, char_input):
        # char_input (batch_size, max_word_length) -> (batch_size, max_word_length, embed_dim)
        char_input = self.embedding_layer(char_input)
        # -> (batch_size, embed_dim, max_word_length)
        char_input_embedding = char_input.transpose(2, 1).contiguous()
        char_input_embedding = self.char_drop(char_input_embedding)
        # -> (batch_size, hidden_dim, length)
        char_cnn_out = self.char_cnn(char_input_embedding)
        # -> (batch_size, hidden_dim, max_word_length)
        char_cnn_out = self.char_drop(char_cnn_out)
        char_cnn_out = f.max_pool1d(char_cnn_out, char_cnn_out.size(2))
        # -> (batch_size, max_word_length, hidden_dim)
        # char_cnn_out = f.max_pool1d(char_cnn_out, char_cnn_out.size(2))
        return char_cnn_out










