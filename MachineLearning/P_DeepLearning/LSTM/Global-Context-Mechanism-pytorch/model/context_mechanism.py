import torch
import torch.nn as nn
import torch.nn.functional as F


class GlobalContext(nn.Module):
    def __init__(self, hidden_size, dropout_rate=0.1):
        super(GlobalContext, self).__init__()
        self.input_size = hidden_size
        self.dropout_rate = dropout_rate
        self.gate = Gate(input_size=hidden_size * 2, output_size=hidden_size)
        self.dropout = nn.Dropout(p=self.dropout_rate)

    def forward(self, x, forward_global_cell, backward_global_cell):
        max_len = x.size(1)

        forward_info = forward_global_cell[:, :self.input_size//2].unsqueeze(1).repeat(1, max_len, 1)
        backward_info = backward_global_cell[:, self.input_size//2:].unsqueeze(1).repeat(1, max_len, 1)

        # global_info = torch.cat([forward_info, backward_info], dim=-1)
        global_info = torch.cat([backward_info, forward_info], dim=-1)
        # i_g, i_c = self.gate(global_info)

        i_g, i_c = self.gate(torch.cat([global_info, x], dim=-1))
        global_info = self.dropout(global_info)
        output = global_info * i_g + x * i_c
        # output = global_info + x
        return output, (i_g, i_c)


class Gate(nn.Module):
    def __init__(self, input_size, output_size=None):
        super(Gate, self).__init__()
        if output_size is None:
            output_size = input_size
        self.gate_ = nn.Linear(input_size, output_size)
        self.gate_g = nn.Linear(input_size, output_size)
        self.dropout = nn.Dropout()

    def forward(self, x):
        x = self.dropout(x)
        i_g = torch.sigmoid(self.gate_(x))
        i_c = torch.sigmoid(self.gate_g(x))
        return i_g, i_c


class GlobalContextOld(nn.Module):
    def __init__(self, input_size, is_bidirectional=True, use_gpu=True, dropout_rate=0.3):
        super(GlobalContextOld, self).__init__()
        self.input_size = input_size
        self.dropout_rate = dropout_rate
        self.weight_mechanism = MySequential
        self.dropout = nn.Dropout(p=self.dropout_rate)

        self.forward_weight_mechanism = self.weight_mechanism(self.input_size)
        self.backward_weight_mechanism = self.weight_mechanism(self.input_size)
        self.current_weight_mechanism = self.weight_mechanism(self.input_size)
        # self.feature_mapping = nn.Linear(self.input_size * 3, 5 * self.input_size)
        # self.feature_selection = nn.Linear(5 * self.input_size, self.input_size * 2)

    def forward(self, x, forward_global_cell, backward_global_cell):
        max_len = x.size(1)
        # print(forwad_gloabl.shape)
        # print(backward_global.shape)
        # forward_info = x[:, 0, :].unsqueeze(1).repeat(1, max_len, 1)
        # backward_info = x[:, -1, :].unsqueeze(1).repeat(1, max_len, 1)
        forward_info = forward_global_cell[:, :self.input_size//2].unsqueeze(1).repeat(1, max_len, 1)
        backward_info = backward_global_cell[:, self.input_size//2:].unsqueeze(1).repeat(1, max_len, 1)

        # print(backward_info.shape)
        # print(backward_info.shape)
        # print(x.shape)
        global_info = torch.cat([forward_info, x, backward_info], dim=-1)
        # global_info = self.feature_mapping(global_info)
        # global_info = f.relu(global_info)
        # global_info = self.feature_selection(global_info)
        # global_info = self.dropout(global_info)

        # weight has shape (batch_size, max_seq_len, 1)
        # print(global_info.shape)
        forward_weight = self.forward_weight_mechanism(global_info)
        current_weight = self.current_weight_mechanism(global_info)
        backward_weight = self.backward_weight_mechanism(global_info)
        # forward_weight = self.forward_weight_mechanism(x)
        # current_weight = self.current_weight_mechanism(x)
        # backward_weight = self.backward_weight_mechanism(x)

        # global info has shape (batch_size, max_seq_len, d_model)
        forward_global_info = torch.mul(forward_info, forward_weight)
        current_info = torch.mul(x, current_weight)
        backward_global_info = torch.mul(backward_info, backward_weight)
        global_info_ = torch.cat([forward_global_info, backward_global_info], dim=-1)
        # output = current_info + global_info_
        # output = current_info + torch.cat([forward_info, backward_info], dim=-1)
        output = global_info_ + current_info
        return output, torch.cat([backward_weight, current_weight, forward_weight])


class MySequential(nn.Module):
    def __init__(self, input_size):
        super(MySequential, self).__init__()
        self.input_size = input_size
        self.sequential = nn.Sequential(nn.Dropout(p=0.1),
                                        nn.Linear(self.input_size * 2, self.input_size),  # 2/3
                                        nn.Tanh(),
                                        nn.Linear(self.input_size, self.input_size // 2),
                                        nn.Tanh(),
                                        nn.Linear(self.input_size // 2, 1),
                                        )

    def forward(self, x):
        return self.sequential(x)


class SAN(nn.Module):
    def __init__(self, d_model, nhead, dropout=0.1):
        super(SAN, self).__init__()
        self.d_model = d_model
        self.nhead = nhead
        self.self_attn = nn.MultiheadAttention(d_model, nhead, dropout=dropout, batch_first=True)
        self.dropout = nn.Dropout(p=dropout)
        self.norm = nn.LayerNorm(d_model)

    def forward(self, src, src_mask=None, src_key_padding_mask=None):
        """
        :param src:
        :param src_mask:
        :param src_key_padding_mask:
        :return:
        """
        src2, _ = self.self_attn(src, src, src, attn_mask=src_mask, key_padding_mask=src_key_padding_mask)
        # print(src2.size())
        # print(src.size())
        # src = src + self.dropout(src2)
        src = src + src2
        # src = torch.cat((src, src2), dim=-1)
        # print(src.shape())
        # apply layer normalization
        src = self.norm(src)
        return src, []
