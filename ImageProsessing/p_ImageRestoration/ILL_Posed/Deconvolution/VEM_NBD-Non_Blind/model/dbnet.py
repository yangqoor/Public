from utils import comfft as cf
from utils.wavelet import generate_wavelet, wv_norm, Fwv, wv_dec
import torch
from torch import nn
from model.net import BF_BatchNorm2d, blurbyker, FCN_ML


class vem_deblur_model(nn.Module):
    def __init__(self, args):
        super(vem_deblur_model, self).__init__()
        self.args = args

        self.dec2d, _ = generate_wavelet(1, dim=2)
        norm = torch.from_numpy(wv_norm(self.dec2d))
        self.beta = []
        for i in range(len(args.beta)):
            self.beta.append(torch.ones(len(self.dec2d)) * args.beta[i] / norm)

        self.net = nn.ModuleList()
        self.net = self.net.append(E_step_x(self.beta[0]))
        for i in range(args.layers):
            self.net = self.net.append(E_step_z(depth=args.deep, in_chan=(i + 1)))
            self.net = self.net.append(M_step_beta())
            self.net = self.net.append(E_step_x(self.beta[i+1]))

    def forward(self, y, Fker, update_beta = True):
        db = [None] * (self.args.layers + 1)
        dn = [None] * (self.args.layers)
        beta = [None] * (self.args.layers + 1)

        db[0] = self.net[0](y, Fker, z = None, beta=None)

        for i in range(self.args.layers):
            input = torch.cat([db[j] for j in range(0, i + 1)], dim=1)
            dn[i] = self.net[3*i+1](input)
            if update_beta:
                beta[i+1] = self.net[3*i+2](y, Fker, x = db[i], z = dn[i])
            else:
                beta[i+1] = self.beta[i+1]
            db[i+1] = self.net[3*i+3](y, Fker, beta=beta[i+1], z = dn[i])
        return db, dn





class E_step_x(nn.Module):
    def __init__(self, beta):
        super(E_step_x,self).__init__()
        self.dec2d, _ = generate_wavelet(frame=1)
        self.chn_num = len(self.dec2d)
        self.beta = beta

    def forward(self, y, Fker, beta=None, z=None):
        im_num = y.shape[0]
        if z is None: z = torch.zeros_like(y)
        if beta is None: beta = torch.stack([self.beta.view(self.chn_num, 1, 1, 1).cuda()] * im_num, dim=0)

        xhat = torch.zeros_like(y)

        for i in range(im_num):
            shape = y[i,0,].size()[-2:]
            Fw = Fwv(self.dec2d, shape=shape).cuda()

            Fker_conj = cf.conj(Fker[i]).cuda()
            Fw_conj = cf.conj(Fw).cuda()

            Fy = cf.fft(y[i,0,])
            Fz = cf.fft(z[i,0,]).cuda()

            Fx_num = cf.mul(Fker_conj, Fy) + torch.sum(beta[i] * cf.mul(Fw_conj, cf.mul(Fw, Fz)), dim=0)
            Fx_den = cf.abs_square(Fker[i], keepdim=True) + torch.sum(beta[i] * cf.mul(Fw_conj, Fw), dim=0)
            Fx = cf.div(Fx_num, Fx_den)
            xhat[i,0,] = cf.ifft(Fx)
        return xhat

class E_step_z(nn.Module):
    ''' E_step_z with Residue Learning'''
    def __init__(self, depth=17, n_channels=64, in_chan=1, out_chan=1):
        super(E_step_z, self).__init__()
        kernel_size = 3
        padding = 1
        layers = []
        self.in_chan = in_chan

        layers.append(nn.Conv2d(in_channels=in_chan, out_channels=n_channels, kernel_size=kernel_size, padding=padding, bias=True))
        layers.append(nn.ReLU(inplace=True))
        for _ in range(depth-2):
            layers.append(nn.Conv2d(in_channels=n_channels, out_channels=n_channels, kernel_size=kernel_size, padding=padding, bias=False))
            layers.append(BF_BatchNorm2d(n_channels, eps=0.0001, momentum = 0.95, track_running_stats=False))
            layers.append(nn.ReLU(inplace=True))
        layers.append(nn.Conv2d(in_channels=n_channels, out_channels=out_chan, kernel_size=kernel_size, padding=padding, bias=False))
        self.dncnn = nn.Sequential(*layers)
        self._initialize_weights()

    def forward(self, x):
        out = self.dncnn(x)
        return x[:,-1:,:,:] - out

    def _initialize_weights(self):
        import torch.nn.init as init
        for m in self.modules():
            if isinstance(m, nn.Conv2d):
                init.orthogonal_(m.weight)
                if m.bias is not None:
                    init.constant_(m.bias, 0)
            elif isinstance(m, nn.BatchNorm2d):
                init.constant_(m.weight, 1)
                init.constant_(m.bias, 0)

class M_step_beta(nn.Module):
    def __init__(self):
        super(M_step_beta,self).__init__()
        self.vem_gamma2 = 1e-4
        self.dec2d, _ = generate_wavelet(1, dim=2)
        self.wv_num = len(self.dec2d)
        self.na = FCN_ML(vem_gamma2 = self.vem_gamma2, filters = self.dec2d)

    def forward(self, y, Fker, x, z):
        im_num = y.shape[0]
        with torch.no_grad():
            ker_x = blurbyker(x, Fker)
            rb = y - ker_x
            x_z_gd = wv_dec(x - z)
            lambda2 = torch.zeros((im_num, self.wv_num, 1, 1, 1)).cuda()
            sigma2 = torch.zeros((im_num)).cuda()
            for i in range(im_num):
                sigma2[i] = torch.mean(rb[i,] ** 2) + self.vem_gamma2 * torch.ones(1).cuda()
        lambda2[:, :, 0, 0, 0] = self.na(x_z_gd)
        beta = sigma2.view(-1, 1, 1, 1, 1) / lambda2
        return beta
