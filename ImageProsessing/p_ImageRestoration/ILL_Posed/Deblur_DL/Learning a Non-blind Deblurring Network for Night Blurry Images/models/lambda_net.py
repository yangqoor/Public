import torch.nn as nn
import torch
import torch.nn.functional as F

def default_conv(in_channels, out_channels, kernel_size, stride, padding, bias=False, init_scale=0.1):
    basic_conv = nn.Conv2d(in_channels, out_channels, kernel_size, stride, padding=padding, bias=bias)
    nn.init.kaiming_normal_(basic_conv.weight.data, a=0, mode='fan_in')
    basic_conv.weight.data *= init_scale
    if basic_conv.bias is not None:
        basic_conv.bias.data.zero_()
    return basic_conv

def default_Linear(in_channels, out_channels, bias=False):
    basic_Linear = nn.Linear(in_channels, out_channels, bias=bias)
    nn.init.kaiming_normal_(basic_Linear.weight.data, a=0, mode='fan_in')
    basic_Linear.weight.data *= 0.1
    if basic_Linear.bias is not None:
        basic_Linear.bias.data.zero_()
    return basic_Linear

class lnet(nn.Module):
    def __init__(self):
        super(lnet, self).__init__()
        self.conv1 = default_conv(1, 64, 3, 1, 1)
        self.diconv2 = default_conv(64, 64, 4, 2, 1)
        self.pool = nn.AdaptiveAvgPool2d((128, 128))
        ################
        self.diconv3_pi = default_conv(64, 32, 3, 1, 1)
        self.diconv4_tensor = default_conv(32, 32, 3, 1, 1)
        self.conv5_Wz = default_conv(32, 32, 3, 1, 1)
        self.conv5_Uz = default_conv(32, 32, 3, 1, 1)
        self.conv5_Wr = default_conv(32, 32, 3, 1, 1)
        self.conv5_Ur = default_conv(32, 32, 3, 1, 1)
        self.conv5_W = default_conv(32, 32, 3, 1, 1)
        self.conv5_U = default_conv(32, 32, 3, 1, 1)
        self.diconv6_pi = default_conv(32, 32, 4, 2, 1)
        self.diconv7_pi = default_conv(32, 32, 4, 2, 1)
        self.diconv8_pi = default_conv(32, 16, 4, 2, 1)
        self.diconv9_pi = default_conv(16, 16, 4, 2, 1)
        self.line1 = default_Linear(16 * 8 * 8, 1)
        self.lrelu = nn.LeakyReLU(negative_slope=0.2, inplace=True)

    def forward(self, x, obs):
        h = self.lrelu(self.conv1(x))
        h = self.pool(self.diconv2(h))
        #######
        x_t = self.lrelu(self.diconv3_pi(h))
        h_t1 =  self.lrelu(self.diconv4_tensor(obs))
        z_t = torch.sigmoid(self.conv5_Wz(x_t) + self.conv5_Uz(h_t1))
        r_t = torch.sigmoid(self.conv5_Wr(x_t) + self.conv5_Ur(h_t1))
        h_tilde_t = F.tanh(self.conv5_W(x_t) + self.conv5_U(r_t * h_t1))
        h_t = (1 - z_t) * h_t1 + z_t * h_tilde_t

        h_P = self.diconv7_pi(self.diconv6_pi(h_t))
        h_P = self.diconv9_pi(self.diconv8_pi(h_P))
        h_P = h_P.view(h_P.size(0), -1)
        pout = self.lrelu(self.line1(h_P))
        return pout, h_t
