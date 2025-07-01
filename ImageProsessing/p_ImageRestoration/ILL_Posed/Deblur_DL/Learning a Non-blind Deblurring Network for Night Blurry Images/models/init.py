import torch.nn as nn
import torch.nn.functional as F
from torch.autograd import Variable

class deblur(nn.Module):
    def __init__(self, maxit):
        super(deblur, self).__init__()
        self.maxit = maxit

    def func_Ax(self, x, size, k, kt, outlier, reg):
        x = x.reshape(size)
        n_size = x.size()[0]
        k_size = k.size()[2]
        padding = int(k_size / 2)
        x1 = x.transpose(1, 0)  # x1: C x N x H x W
        # k: N x 1 x Ksize x Ksize

        output1 = outlier*(F.conv2d(x1, kt, padding=padding, groups=n_size).transpose(1, 0))  # Ax
        output1 = F.conv2d(output1.transpose(1, 0), k, padding=padding, groups=n_size).transpose(1, 0)
        for i in range(0, n_size):
            output1[i,:] += reg[i]*x[i,:]
        return output1.flatten(1)

    def conjugate_gradient(self, x, b, size, k, kt, outlier, reg):
        r = b - self.func_Ax(x, size=size, k=k, kt=kt, outlier=outlier, reg=reg)
        p = r
        rsold = (r*r).sum()
        for iter in range(0, self.maxit):
            Ap = self.func_Ax(p, size=size, k=k, kt=kt, outlier=outlier, reg=reg)
            alpha = rsold / (p*Ap).sum()
            x = x + alpha * p
            r = r - alpha * Ap
            rsnew = (r * r).sum()
            p = r + rsnew / rsold * p
            rsold = rsnew
        return x

    def deconv_L2(self, x, blur, kernel, kernelT, outlier, imgu, reg):
        n_size = x.size()[0]
        k_size = kernel.size()[2]
        padding = int(k_size / 2)
        w_blur = outlier*blur
        blur1 = w_blur.transpose(1, 0)
        vk = Variable(kernel.data.clone())

        b = F.conv2d(blur1, vk, padding=padding, groups=n_size)
        b = b.transpose(1, 0)
        for i in range(0, n_size):
            b[i, :] += reg[i] * imgu[i, :]
        b = b.flatten(1)
        ####
        old_size = x.size()
        x = x.flatten(1)
        x = self.conjugate_gradient(x, b, size=old_size, k=kernel, kt=kernelT, outlier=outlier, reg=reg)
        return x.reshape(old_size)


    def forward(self, x_init, blur, kernel, kernelT, reg):
        mask = blur.data.clone().fill_(0)
        _, _, h, w = blur.size()
        mask[:, :, 36:h-38, 36:w-38] = 1
        ############
        imgu = x_init.data.clone().fill_(0)
        outlier = Variable(blur.data.clone()).fill_(1)
        outlier = outlier*mask
        x_init = self.deconv_L2(x_init, blur, kernel, kernelT, outlier, imgu, reg=reg)

        return x_init




