import torch.nn as nn
from models import init as deb_init, deblur_process as deb_net


class deblur(nn.Module):
    def __init__(self):
        super(deblur, self).__init__()
        self.netG0 = deb_init.deblur(maxit=15)
        self.netG1 = deb_net.deblur(maxit=15)
        self.netG2 = deb_net.deblur(maxit=15)
        self.netG3 = deb_net.deblur(maxit=15)

    def forward(self, x_init, blur, kernel, kernelT, reg, step):
        x = eval('self.netG{}'.format(step))(x_init=x_init, blur=blur, kernel=kernel, kernelT=kernelT, reg=reg)

        return x




