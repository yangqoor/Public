''' metric computation including PSNR and SSIM '''
import torch
import numpy as np

from utils.imtools import torch2np


def psnr(img1,img2, cut=30):
    PIXEL_MAX = 1

    # Cut the boundary for fair comparison.
    img1 = img1[cut:-cut,cut:-cut]
    img2 = img2[cut:-cut,cut:-cut]
    mse = np.mean((img1 - img2) ** 2)
    return 10 * np.log10(PIXEL_MAX **2 / mse)

def aver_psnr(img1,img2):
    ''' For images with same size and stored by a matrix'''
    PSNR = 0
    assert img1.size() == img2.size()
    for i in range(img1.size()[0]):
        PSNR += psnr(img1[i,...], img2[i,...])
    return PSNR / img1.size()[0]

def aver_psnr_ds(img1, img2, to_int = True):
    ''' For images with different size and stored by a list'''
    im_len = len(img1)
    assert len(img1) == len(img2)
    for i in range(im_len):
        img1[i] = np.squeeze(torch2np(img1[i]))
        img2[i] = np.squeeze(torch2np(img2[i]))

        img1[i][img1[i]<0] = 0
        img2[i][img2[i]<0] = 0
        img1[i][img1[i]>1] = 1
        img2[i][img2[i]>1] = 1

        if to_int:
            img1[i] = np.around(img1[i]*255).astype(int) / 255
            img2[i] = np.around(img2[i]*255).astype(int) / 255

    PSNR = 0
    for i in range(im_len):
        PSNR += psnr(img1[i], img2[i])
    return PSNR / len(img1)



import numpy
from scipy import signal


def aver_ssim(img1,img2):
    SSIM = 0
    assert img1.size() == img2.size()
    for i in range(img1.size()[0]):
        SSIM += ssim(img1[i,...], img2[i,...])
    return SSIM / img1.size()[0]

def aver_ssim_ds(img1, img2, to_int=True):
    ''' For images with different size and stored by a list'''
    im_len = len(img1)
    assert len(img1) == len(img2)
    for i in range(im_len):
        img1[i] = np.squeeze(torch2np(img1[i]))
        img2[i] = np.squeeze(torch2np(img2[i]))

        img1[i][img1[i]<0] = 0
        img2[i][img2[i]<0] = 0
        img1[i][img1[i]>1] = 1
        img2[i][img2[i]>1] = 1

        if to_int:
            img1[i] = np.around(img1[i]*255).astype(int) / 255
            img2[i] = np.around(img2[i]*255).astype(int) / 255

    SSIM = 0
    for i in range(im_len):
        SSIM += ssim(img1[i], img2[i])
    return SSIM / len(img1)

def ssim(img1, img2, cut=30, cs_map=False):
    img1 = img1[cut:-cut,cut:-cut]
    img2 = img2[cut:-cut,cut:-cut]
    if np.max(img1) < 2:
        img1 = img1 * 255
        img2 = img2 * 255

    img1 = img1.astype(numpy.float64)
    img2 = img2.astype(numpy.float64)
    size = 11
    sigma = 1.5
    window = fspecial_gauss(size, sigma)
    K1 = 0.01
    K2 = 0.03
    L = 255  # bitdepth of image
    C1 = (K1 * L) ** 2
    C2 = (K2 * L) ** 2
    mu1 = signal.fftconvolve(window, img1, mode='valid')
    mu2 = signal.fftconvolve(window, img2, mode='valid')
    mu1_sq = mu1 * mu1
    mu2_sq = mu2 * mu2
    mu1_mu2 = mu1 * mu2
    sigma1_sq = signal.fftconvolve(window, img1 * img1, mode='valid') - mu1_sq
    sigma2_sq = signal.fftconvolve(window, img2 * img2, mode='valid') - mu2_sq
    sigma12 = signal.fftconvolve(window, img1 * img2, mode='valid') - mu1_mu2
    if cs_map:
        return (((2 * mu1_mu2 + C1) * (2 * sigma12 + C2)) / ((mu1_sq + mu2_sq + C1) *
                                                             (sigma1_sq + sigma2_sq + C2)),
                (2.0 * sigma12 + C2) / (sigma1_sq + sigma2_sq + C2))
    else:
        ssim = ((2 * mu1_mu2 + C1) * (2 * sigma12 + C2)) / ((mu1_sq + mu2_sq + C1) *
                                                            (sigma1_sq + sigma2_sq + C2))
        return ssim.mean()

def fspecial_gauss(size, sigma):
    """Function to mimic the 'fspecial' gaussian MATLAB function
    """
    x, y = numpy.mgrid[-size // 2 + 1:size // 2 + 1, -size // 2 + 1:size // 2 + 1]
    g = numpy.exp(-((x ** 2 + y ** 2) / (2.0 * sigma ** 2)))
    return g / g.sum()

