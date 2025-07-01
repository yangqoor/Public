
from __future__ import print_function
import matplotlib.pyplot as plt
import argparse
import os
import numpy as np
import torch
import torch.optim
from utils.deconv_utils import *

dtype = torch.cuda.FloatTensor
# dtype = torch.cuda.DoubleTensor

class TVLoss(nn.Module):
    def __init__(self, tv_loss_weight=1):
        super(TVLoss, self).__init__()
        self.tv_loss_weight = tv_loss_weight
        # self.tv_h = TVop(mode='h').type(dtype)
        # self.tv_w = TVop(mode='w').type(dtype)
        # self.tv_2 = TVop(mode='s2').type(dtype)
        # self.tv_4 = TVop(mode='s4').type(dtype)

    def forward(self, x):
        batch_size = x.size()[0]
        h_x = x.size()[2]
        w_x = x.size()[3]
        count_h = self.tensor_size(x[:, :, 1:, :])
        count_w = self.tensor_size(x[:, :, :, 1:])
        # h_tv = torch.pow((x[:, :, 1:, :] - x[:, :, :h_x - 1, :]), 2).sum()
        # w_tv = torch.pow((x[:, :, :, 1:] - x[:, :, :, :w_x - 1]), 2).sum()
        h_tv = torch.abs((x[:, :, 1:, :] - x[:, :, :h_x - 1, :])).sum()
        w_tv = torch.abs((x[:, :, :, 1:] - x[:, :, :, :w_x - 1])).sum()

        # h_tv = (x[:, :, 1:, :] - x[:, :, :h_x - 1, :])
        # w_tv = torch.abs((x[:, :, :, 1:] - x[:, :, :, :w_x - 1])).sum()
        # h_tv = torch.abs(self.tv_h(x)).sum()
        # w_tv = torch.abs(self.tv_w(x)).sum()
        # tv_2 = torch.abs(self.tv_2(x)).sum()
        # tv_4 = torch.abs(self.tv_4(x)).sum() #(torch.sum(torch.abs(param))**2)/torch.sum(param**2)
        # h_tv = (torch.sum(torch.abs(self.tv_h(x)))**2)/torch.sum(self.tv_h(x)**2)
        # w_tv = (torch.sum(torch.abs(self.tv_w(x)))**2)/torch.sum(self.tv_w(x)**2)
        # tv_2 = (torch.sum(torch.abs(self.tv_2(x)))**2)/torch.sum(self.tv_2(x)**2)
        # tv_4 = (torch.sum(torch.abs(self.tv_4(x)))**2)/torch.sum(self.tv_4(x)**2)

        # h_tv = torch.pow(torch.sqrt(torch.abs(self.tv_h(x))).sum(),2)
        # w_tv = torch.pow(torch.sqrt(torch.abs(self.tv_w(x))).sum(),2)
        # tv_2 = torch.pow(torch.sqrt(torch.abs(self.tv_2(x))).sum(),2)
        # tv_4 = torch.pow(torch.sqrt(torch.abs(self.tv_4(x))).sum(),2)

        # h_tv = (torch.sum(torch.abs(self.tv_h(x)))**2)/torch.sum(self.tv_h(x)**2)
        # w_tv = (torch.sum(torch.abs(self.tv_w(x)))**2)/torch.sum(self.tv_w(x)**2)
        # tv_2 = (torch.sum(torch.abs(self.tv_2(x)))**2)/torch.sum(self.tv_2(x)**2)
        # tv_4 = (torch.sum(torch.abs(self.tv_4(x)))**2)/torch.sum(self.tv_4(x)**2)

        return self.tv_loss_weight * 2 * (h_tv / count_h + w_tv / count_w) / batch_size
        # return self.tv_loss_weight * 2 * (h_tv / count_h + w_tv / count_w + tv_2 / count_h + tv_4 / count_w) / batch_size
    @staticmethod
    def tensor_size(t):
        return t.size()[1] * t.size()[2] * t.size()[3]
