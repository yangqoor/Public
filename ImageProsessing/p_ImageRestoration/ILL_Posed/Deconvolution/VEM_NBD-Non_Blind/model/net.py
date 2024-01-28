import torch
from torch import nn
from utils import comfft as cf

class BF_BatchNorm2d(nn.BatchNorm2d):
    def forward(self, x):
        self._check_input_dim(x)
        y = x.transpose(0,1)
        return_shape = y.shape
        y = y.contiguous().view(x.size(1), -1)

        sigma2 = y.var(dim=1)
        if self.training is not True:
            if self.track_running_stats is True:
                y = y / (self.running_var.view(-1, 1) ** .5 + self.eps)
            else:
                y = y / (sigma2.view(-1, 1) ** .5 + self.eps)
        else:
            if self.track_running_stats is True:
                with torch.no_grad():
                    self.running_var = (1-self.momentum)*self.running_var + self.momentum*sigma2
            y = y / (sigma2.view(-1,1)**.5 + self.eps)

        y = self.weight.view(-1, 1) * y
        return y.view(return_shape).transpose(0,1)

class NA(nn.Module):
    def __init__(self, in_chan=8, n_chan=32, init=False):
        super(NA, self).__init__()
        layers = []
        Conv = nn.Conv2d
        ReLU = nn.ReLU
        BN = nn.BatchNorm2d
        Pool = nn.AdaptiveAvgPool2d
        Linear = nn.Linear

        layers.append(Conv(in_channels=in_chan, out_channels=n_chan, kernel_size=3, padding=1, bias=True))
        layers.append(ReLU(inplace=True))

        layers.append(Conv(in_channels=n_chan, out_channels=n_chan, kernel_size=3, padding=1, stride=2,
                           bias=False))  # 128*128
        layers.append(BN(n_chan, momentum=0.95, track_running_stats=False))
        layers.append(ReLU(inplace=True))

        layers.append(Conv(in_channels=n_chan, out_channels=n_chan, kernel_size=3, padding=1, stride=2, bias=False))  # 64*64
        layers.append(BN(n_chan, momentum=0.95, track_running_stats=False))
        layers.append(ReLU(inplace=True))

        layers.append(
            Conv(in_channels=n_chan, out_channels=n_chan, kernel_size=3, padding=1, stride=2, bias=False))  # 32*32
        layers.append(BN(n_chan, momentum=0.95, track_running_stats=False))
        layers.append(ReLU(inplace=True))

        layers.append(
            Conv(in_channels=n_chan, out_channels=n_chan, kernel_size=3, padding=1, stride=2, bias=False))  # 16*16
        layers.append(ReLU(inplace=True))

        layers.append(Pool((8, 8)))

        self.update = False

        self.na = nn.Sequential(*layers)
        self.fc = nn.Sequential(Linear(64 * n_chan, 8))

        if init == True:
            self._init_weights()

    def forward(self, x):
        af_cnn = self.na(x)
        out = self.fc(af_cnn.view(x.shape[0], -1))
        out = out ** 2
        return out

    def _init_weights(self):
        import torch.nn.init as init
        for m in self.modules():
            if isinstance(m, nn.Conv2d):
                init.orthogonal_(m.weight)
                if m.bias is not None:
                    init.constant_(m.bias, 0)
            elif isinstance(m, nn.BatchNorm2d):
                init.constant_(m.weight, 1)
                init.constant_(m.bias, 0)
            elif isinstance(m, nn.Linear):
                pass
                # init.constant_(m.weight, 1 / 8)
                # if m.bias is not None:
                #     init.constant_(m.bias, 0)

from utils.wavelet import wv_norm
class FCN_ML(nn.Module):
        def __init__(self, vem_gamma2 = 0, filters = None, depth=3, input=8, output=8, middle = 64):
            super(FCN_ML, self).__init__()
            layer = []
            layer.append(nn.Linear(input, middle))
            layer.append(nn.LeakyReLU())
            for i in range(depth - 2):
                layer.append(nn.Linear(middle, middle))
                layer.append(nn.LeakyReLU())
            layer.append(nn.Linear(middle, output))

            self.fcn = nn.Sequential(*layer)
            self.wv_norm = wv_norm(filters)
            self.vem_gamma2 = vem_gamma2


        def forward(self, x):
            beta = torch.zeros(8).cuda()
            for i in range(8):
                beta[i] = (torch.mean(x[:, i, :, :] ** 2) + self.vem_gamma2 * self.wv_norm[i]) ** (1/2)

            out = self.fcn(beta.detach())
            out = out ** 2
            return out



def blurbyker(z, Fker):
    im_num = z.size(0)
    ker_z = torch.zeros_like(z)
    for i in range(im_num):
        Fdn = cf.fft(z[i, 0,])
        ker_z[i, 0,] = cf.ifft(cf.mul(Fker[i], Fdn))
    return ker_z
