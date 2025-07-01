import torch.nn as nn
from models.block import *

####################
# Useful blocks
####################
class ResBlock(nn.Module):
    def __init__(
            self, conv, n_feats, kernel_size, padding=1,
            bias=True, bn=False, act=nn.ReLU(True), res_scale=1):

        super(ResBlock, self).__init__()
        m = []
        for i in range(2):
            m.append(conv(n_feats, n_feats, kernel_size, padding=padding, bias=bias))
            if bn: m.append(nn.BatchNorm2d(n_feats))
            if i == 0: m.append(act)

        self.body = nn.Sequential(*m)
        self.res_scale = res_scale

    def forward(self, x):
        res = self.body(x).mul(self.res_scale)
        res = res + x

        return res

class outlier(nn.Module):
    def __init__(self, n_colors, out_nc, num_channels, num_blocks):
        super(outlier, self).__init__()

        # define head
        self.head = default_conv(in_channels=n_colors, out_channels=num_channels,
                                 kernel_size=3, padding=1, bias=False, init_scale=0.1)
        self.body = nn.ModuleList(
            [ResBlock(default_conv,
                      n_feats=num_channels, kernel_size=3, act=nn.ReLU(True), res_scale=1
                      ) for _ in range(num_blocks)]
        )

        self.end = default_conv(in_channels=num_channels, out_channels=out_nc,
                                kernel_size=3, padding=1, bias=False, init_scale=0.1)

    def forward(self, x):
        output = self.head(x)
        head_f = output
        for mbody in self.body:
            output = mbody(output)
        output = self.end(output + head_f)
        return output