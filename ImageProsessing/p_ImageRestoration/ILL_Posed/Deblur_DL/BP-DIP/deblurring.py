###
# code for deblurring, originates from DIPs super-resolution code
###
from __future__ import print_function
import matplotlib.pyplot as plt
import os
import cv2
import self as self
import numpy as np
import math
from models import *
from utils.sr_utils import *
from skimage.metrics import peak_signal_noise_ratio as compare_psnr
from skimage.metrics import structural_similarity as compare_ssim
import bm3d

import torch
import torch.optim
import torch.nn.functional as F

torch.backends.cudnn.enabled = True
torch.backends.cudnn.benchmark = True
dtype = torch.cuda.FloatTensor

#os.environ['CUDA_VISIBLE_DEVICES'] = '2'
self.device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")

def filter(filter_type):
    if filter_type == 'uniform_filter':
        flt = uniform_filter()
    elif filter_type == 'radial_filter':
        flt = radial_filter()
    elif filter_type == 'gaus_filter':
        flt = gaus_filter()

    return flt

def radial_filter():
    flt = torch.empty(1, 1, 15, 15).to(self.device)
    for ii in range(15):
        for jj in range(15):
            x1 = ii - 7
            x2 = jj - 7
            flt[0, 0, ii, jj] = 1 / (1 + x1 ** 2 + x2 ** 2)
    flt = flt / flt.sum()

    return flt

def gaus_filter(kernel_size=15, sigma=1.6):
    # Create a x, y coordinate grid of shape (kernel_size, kernel_size, 2)
    x_coord = torch.arange(kernel_size).to(self.device)
    x_grid = x_coord.repeat(kernel_size).view(kernel_size, kernel_size)
    y_grid = x_grid.t()
    xy_grid = torch.stack([x_grid, y_grid], dim=-1).float()

    mean = (kernel_size - 1) / 2.
    variance = sigma ** 2.

    # Calculate the 2-dimensional gaussian kernel which is
    # the product of two gaussian distributions for two different
    # variables (in this case called x and y)
    gaussian_kernel = (1. / (2. * math.pi * variance)) * torch.exp(
        -torch.sum((xy_grid - mean) ** 2., dim=-1) / \
        (2 * variance))
    # Make sure sum of values in gaussian kernel equals 1.
    gaussian_kernel = gaussian_kernel / torch.sum(gaussian_kernel)
    # Reshape to 2d depthwise convolutional weight
    gaussian_kernel = gaussian_kernel.view(1, 1, kernel_size, kernel_size)

    return gaussian_kernel

def uniform_filter():
    flt = torch.ones(1, 1, 9, 9).to(self.device)
    flt = flt / flt.sum()

    return flt

def blur(img, filter_type):
    ### image blurring, using uniform filter size of 9x9
    flt = filter(filter_type)
    pad_size = int(flt.shape[-1] / 2)
    img_padded = torch.nn.functional.pad(img, [pad_size, pad_size, pad_size, pad_size], mode='circular')
    img_out = torch.zeros_like(img).to(self.device)
    for ch in range(img.shape[1]):
        img_out[:, ch:ch + 1, :, :] = torch.nn.functional.conv2d(img_padded[:, ch:ch + 1, :, :], flt)
    # if the filter in asymmetric, need to turn upside down filter (since conv2d is actually correlation)

    return img_out

def pad_shift_filter(signal, filter):
    pad_x = signal.shape[2] - filter.shape[2]
    pad_y = signal.shape[3] - filter.shape[3]
    expanded_kernel = F.pad(filter, [0, pad_y, 0, pad_x])
    expanded_kernel_np = expanded_kernel.cpu().numpy()
    expanded_kernel_shift = np.roll(expanded_kernel_np, -int(filter.shape[2] / 2), axis=2)
    expanded_kernel_shift = np.roll(expanded_kernel_shift, -int(filter.shape[2] / 2), axis=3)
    expanded_kernel_shift = torch.from_numpy(expanded_kernel_shift).float()

    return expanded_kernel_shift

def torch_fourier_conv(f, k):
    ### fft of h*x
    expanded_kernel_shift = pad_shift_filter(f, k)
    fft_hx = torch.empty([f.shape[0], f.shape[1], f.shape[2], f.shape[3], 2])
    for i in range(3):
        fft_x = torch.rfft(f[:, i:i + 1, :, :], 2, onesided=False, normalized=False).to(self.device)
        fft_kernel = torch.rfft(expanded_kernel_shift, 2, onesided=False, normalized=False).to(self.device)
        real = fft_x[:, :, :, :, 0] * fft_kernel[:, :, :, :, 0] - \
               fft_x[:, :, :, :, 1] * fft_kernel[:, :, :, :, 1]
        im = fft_x[:, :, :, :, 0] * fft_kernel[:, :, :, :, 1] + \
             fft_x[:, :, :, :, 1] * fft_kernel[:, :, :, :, 0]
        fft_conv = torch.stack([real, im], -1)  # (a+bj)*(c+dj) = (ac-bd)+(ad+bc)j
        fft_hx[:, i, :, :, :] = fft_conv

    return fft_kernel, fft_hx

def mse(input, target, size_average=True):
    L = (input - target) ** 2
    return torch.mean(L).to(self.device) if size_average else torch.sum(L)

def BP_loss(x_hat, y, sigma, filter_type):
    eps = 0.01
    h = filter(filter_type)
    fft_kernel, fft_hx = torch_fourier_conv(x_hat, h)
    fft_y = torch.rfft(y, 2, onesided=False, normalized=False).cpu()
    dip_loss = (fft_y - fft_hx).to(self.device)

    bp = fft_kernel[:, :, :, :, 0] ** 2 + fft_kernel[:, :, :, :, 1] ** 2
    '''
    bp_sort_vec = bp.cpu().numpy().flatten()
    bp_sort = np.sort(bp_sort_vec)
    import matplotlib.pyplot as plt
    plt.plot(bp_sort)
    plt.yscale('log')
    plt.show()
    '''
    bp += eps * (sigma ** 2) + (10 ** -3)
    bp = 1 / (torch.sqrt(bp))
    bp_dup = torch.repeat_interleave(bp.unsqueeze(-1), 2, -1).to(self.device)
    loss_mat = bp_dup * dip_loss

    return torch.mean(loss_mat ** 2)

# H = lambda I: blur(I)

# not relevant, parameters are not actually used in sr code
imsize = -1
factor = 4 # 8
enforse_div32 = ''
# not relevant

def dip_deblur(img_name, noise_lvl, filter_type, loss_type, directory):
    learning_rate = 0.01
    OPTIMIZER = 'adam'
    if loss_type == 'dip':
        num_iter = 10000
    elif loss_type == 'bp':
        num_iter = 7000
    reg_noise_std = 0.03
    PLOT = False

    path_to_image = 'data_set14/' + img_name
    ### Load image and baselines ###
    imgs = load_LR_HR_imgs_sr(path_to_image, imsize, factor, enforse_div32)
    if imgs['HR_np'].shape[0] == 1:
        imgs['HR_np'] = cv2.cvtColor(np.moveaxis(imgs['HR_np'], 0, 2), cv2.COLOR_GRAY2RGB)
        imgs['HR_np'] = np.moveaxis(imgs['HR_np'], 2, 0)

    ### Set up parameters and net ###
    input_depth = 32
    INPUT = 'noise'
    pad = 'reflection'
    OPT_OVER = 'net'

    net_input = get_noise(input_depth, INPUT, (imgs['HR_pil'].size[1], imgs['HR_pil'].size[0])).type(dtype).detach()

    NET_TYPE = 'skip'  # UNet, ResNet
    net = get_net(input_depth, NET_TYPE, pad,
                  skip_n33d=128,
                  skip_n33u=128,
                  skip_n11=4,
                  num_scales=5,
                  upsample_mode='bilinear').type(dtype)

    tmp_img = torch.tensor(imgs['HR_np']).unsqueeze(0).to(self.device)
    img_blurred = blur(tmp_img, filter_type)
    noise_lvl = np.sqrt(noise_lvl) / 255
    e = torch.randn(img_blurred.shape).to(self.device) * noise_lvl  # noise with normal distribution
    y = img_blurred + e

    ### bm3d ###
    psf = filter(filter_type).cpu().numpy()
    psf = np.squeeze(psf)
    y_bm3d = y.cpu().numpy()
    y_bm3d = np.moveaxis(y_bm3d, 1, -1)
    y_bm3d = np.squeeze(y_bm3d)
    img_bm3d = bm3d.bm3d_deblurring(y_bm3d, noise_lvl, psf, 'np')
    img_bm3d = np.moveaxis(img_bm3d, -1, 0)
    psnr_bm3d = compare_psnr(imgs['HR_np'], img_bm3d)
    ssim_bm3d = compare_ssim(np.moveaxis(imgs['HR_np'], 0, -1), np.moveaxis(img_bm3d, 0, -1), multichannel=True)

    ### Define closure and optimize ###
    def closure():
        global i, psnr_history, psnr_history_short, ssim_history_short

        if reg_noise_std > 0:
            net_input = net_input_saved + (noise.normal_() * reg_noise_std)

        x_hat = net(net_input)
        if loss_type == 'dip':
            tv_weight = 0 # or 0 if no tv (1e-5 radial/gaus or 1e-6 if tv is on with uniform filter)
            fourier_k, fourier_conv = torch_fourier_conv(x_hat, filter(filter_type))
            fft_y = torch.rfft(y, 2, onesided=False, normalized=False).cpu()
            total_loss = mse(fourier_conv, fft_y).to(self.device)
        elif loss_type == 'bp':
            tv_weight = 1e-3 # 1e-3 or 0 if no tv
            total_loss = BP_loss(x_hat, y, noise_lvl, filter_type).to(self.device)

        if tv_weight > 0:
            mul_factor = 0
            #print(total_loss)
            #print(tv_weight * tv_loss(x_hat, mul_factor).to(self.device))
            total_loss = total_loss + tv_weight * tv_loss(x_hat, mul_factor).to(self.device)

        total_loss.backward()

        # Log
        orig_img = imgs['HR_np']
        x_hat_np = torch_to_np(x_hat)
        psnr = compare_psnr(orig_img, x_hat_np)
        ssim = compare_ssim(np.moveaxis(orig_img, 0, -1), np.moveaxis(x_hat_np, 0, -1), multichannel=True)

        # History
        psnr_history.append([psnr])
        if i % 100 == 0:
            psnr_history_short.append([psnr])
            ssim_history_short.append([ssim])
            print('Iteration %05d     PSNR %.3f     SSIM %.3f' % (i, psnr, ssim), '\r')

        if PLOT and i % 100 == 0:
            x_hat_np = torch_to_np(x_hat)
            plot_image_grid([imgs['HR_np'], x_hat_np], factor=13, nrow=3)
            print('Iteration %05d     PSNR %.3f' % (i, psnr), '\r')
            print('Iteration %05d     SSIM %.3f' % (i, ssim), '\r')
        i += 1

        return total_loss

    global psnr_history, psnr_history_short, ssim_history_short
    psnr_history = []
    psnr_history_short = []
    ssim_history_short = []
    net_input_saved = net_input.detach().clone()
    noise = net_input.detach().clone()

    global i
    i = 0
    p = get_params(OPT_OVER, net, net_input)
    optimize(OPTIMIZER, p, closure, learning_rate, num_iter)

    # get final result (constructed image)
    constructed_img = np.clip(torch_to_np(net(net_input)), 0, 1)

    return constructed_img, net, net_input, psnr_history_short, ssim_history_short, psnr_bm3d, ssim_bm3d, y