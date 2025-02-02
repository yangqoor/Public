import logging
from abc import ABC
from typing import Union, Tuple

import torch
import torch.nn as nn
from torch.nn import MultiheadAttention
from transformers import AutoModel, BertModel
from transformers.models.bert import BertPreTrainedModel
from transformers.models.albert import AlbertPreTrainedModel
from torch.nn.utils.rnn import pad_packed_sequence, pack_padded_sequence

from model.context_mechanism import GlobalContext, GlobalContextOld, SAN


TAGGER = {
    'LSTM': nn.LSTM,
    'GRU': nn.GRU
}
CONTEXT = {
    'global': GlobalContext,
    'self-attention': SAN,
    'cross-ner': '',
}

logger = logging.getLogger('__main__')


class TransformerModel(nn.Module):
    def __init__(self, config, tagger_layer=None, tagger_hidden_size=None, context_layer=None,
                 use_crf=False, fix_pretrained_model=False, pretrained_model_name=None):
        super(TransformerModel, self).__init__()
        self.pretrained_model = AutoModel.from_pretrained(pretrained_model_name, config)
        self.input_size = config.hidden_size
        self.hidden_size = tagger_hidden_size
        self.num_labels = config.num_lables
        self.use_crf = use_crf
        self.use_tagger_layer = True if tagger_layer else False
        self.use_context_layer = True if context_layer else False
        if tagger_layer:
            try:
                self.tagger_layer = TAGGER[tagger_layer](self.input_size, self.hidden_size,
                                                         batch_first=True, bidirectional=True)
            except KeyError:
                logger.info(f" {tagger_layer} layer doesn't existed in tagger layers.")
            if context_layer:
                try:
                    self.context_layer = CONTEXT[context_layer](self.hidden_size)
                except KeyError:
                    logger.info(f" {context_layer} layer doesn't existed in context layers")

        if fix_pretrained_model:
            for layer in self.pretrained_model.parameters():
                layer.requires_grad = False

        if use_crf:
            self.crf = ''
        output_size = self.num_labels
        last_input_size = self.hidden_size if tagger_hidden_size else self.input_size
        self.linear_map = nn.Linear(last_input_size, output_size)

    def forward(self, x):
        output = self.pretrained_model(x)
        tagger_input = output[0]
        if self.use_tagger_layer:
            output, _ = self.tagger_layer(tagger_input)
            if self.use_context_layer:
                forward_global_cell = output[:, -1, :]
                backward_global_cell = output[:, 0, :]
                output = self.context_layer(output, forward_global_cell, backward_global_cell)
        output = self.linear_map(output)
        if self.use_crf:
            pass
        return output


class BertForSeqTask(nn.Module):

    def __init__(self, model_name, bert_config):

        super(BertForSeqTask, self).__init__()
        self.bert = AutoModel.from_pretrained(model_name)
        tagger_config = bert_config.tagger_config
        self.use_tagger = bert_config.use_tagger
        self.use_context = bert_config.use_context
        self.use_crf = bert_config.use_crf
        self.num_labels = bert_config.num_labels
        self.drop_out = bert_config.hidden_dropout_prob
        # if bert_config.fix_bert:
        self.tagger_size = tagger_config['hidden_size']
        if bert_config.fix_pretrained:
            for parameters in self.bert.parameters():
                parameters.requires_grad = False

        if bert_config.use_tagger:
            if tagger_config['bidirectional']:
                hidden_dim = tagger_config['hidden_size'] // 2
            else:
                hidden_dim = tagger_config['hidden_size']
            self.tagger = TAGGER[tagger_config['tagger_name']](tagger_config['input_size'],
                                                               hidden_size=int(hidden_dim),
                                                               bidirectional=True,
                                                               batch_first=True)
            self.classifier = nn.Linear(tagger_config['hidden_size'], self.num_labels)
        else:
            self.classifier = nn.Linear(bert_config.hidden_size, bert_config.num_labels)
        if self.use_context:
            self.context_name = tagger_config['context_mechanism']
            input_dim = tagger_config['hidden_size'] if bert_config.use_tagger else bert_config.hidden_size
            if tagger_config['context_mechanism'] == 'global':
                self.context_mechanism = CONTEXT[tagger_config['context_mechanism']](input_dim)
            if tagger_config['context_mechanism'] == 'self-attention':
                self.num_heads = 5
                self.context_mechanism = CONTEXT[tagger_config['context_mechanism']](input_dim, self.num_heads)
                # self.classifier = nn.Linear(input_dim * 2, self.num_labels)
        self.num_layers = 1

        if self.use_crf:
            pass
        # input_size = bert_config.hidden_size
        # self.classifier = nn.Linear(input_size, self.num_labels)

    def forward(self, input_ids=None,
                attention_mask=None,
                token_type_ids=None,
                position_ids=None,
                head_mask=None,
                inputs_embeds=None,
                labels=None,
                output_attentions=None,
                output_hidden_states=None,
                return_dict=None):
        # (loss[Optional], logit, hidden_states[Optional], output_attentions[Optional])
        outputs = self.bert(input_ids,
                            attention_mask=attention_mask,
                            token_type_ids=token_type_ids,
                            position_ids=position_ids,
                            head_mask=head_mask,
                            inputs_embeds=inputs_embeds,
                            output_attentions=output_attentions,
                            output_hidden_states=output_hidden_states,
                            return_dict=return_dict)
        sequence_output = outputs[0]
        gate_weight = None
        batch_size = input_ids.size(0)
        seq_lengths = torch.sum(labels != -100, dim=1)
        if self.use_tagger:

            # rnn_input = pack_padded_sequence(sequence_output, lengths=seq_lengths.cpu(), enforce_sorted=False, batch_first=True)
            sequence_output, (h_n, c_n) = self.tagger(sequence_output)
            # sequence_output, _ = pad_packed_sequence(rnn_out, batch_first=True)

            # print(seq_lengths.size())
            # forward_global = torch.index_select(sequence_output, 1, seq_lengths)
            forward_global = sequence_output[torch.arange(batch_size), seq_lengths - 1]
            # forward_global = sequence_output[:, seq_lengths, :]
            # print(forward_global.size())
            # forward_global = sequence_output[:, -1, :]
            backward_global = sequence_output[:, 0, :]
            # print(backward_global.size())
            # forward_global = h_n[0, :, :]
            # forward_global, backward_global = forward_output[:, -1, :], backward_output[:, 0, :]
        else:
            backward_global = sequence_output[:, 0, :]
            forward_global = sequence_output[torch.arange(batch_size), seq_lengths-1]
        if self.use_context:
            if self.context_name == 'global':
                sequence_output, gate_weight = self.context_mechanism(sequence_output, forward_global, backward_global)
            if self.context_name == 'self-attention':
                # sequence_output = torch.cat([sequence_output] * self.num_heads, dim=2)
                sequence_output, gate_weight = self.context_mechanism(sequence_output, src_mask=attention_mask)

        if self.use_crf:
            pass
        logits = self.classifier(sequence_output)
        loss = None
        if labels is not None:
            loss_fn = nn.CrossEntropyLoss()
            # logits, _ = torch.max(logits, dim=-1)
            loss = loss_fn(logits.view(-1, self.num_labels), labels.view(-1))
        if not return_dict:
            output = (logits,) + outputs[2:]
            return ((loss,) + output), gate_weight if loss is not None else output
