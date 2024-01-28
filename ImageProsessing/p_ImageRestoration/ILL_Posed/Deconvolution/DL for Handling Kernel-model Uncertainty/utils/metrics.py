''' Metric Computation including PSNR and SSIM '''
import torch
import numpy as np
from scipy.interpolate import interp2d
from utils.imtools import rgb2gray, torch2np


def psnr(img1,img2):
    PIXEL_MAX = 1
    img1 = torch.clamp(img1,min = 0,max = 1)
    img2 = torch.clamp(img2,min = 0,max = 1)
    mse = torch.mean((img1.cpu() - img2.cpu()) ** 2).numpy()
    return 10 * np.log10(PIXEL_MAX **2 / mse)

def aver_psnr(img1,img2):
    ''' For images with same size and stored by a matrix'''
    PSNR = 0
    assert img1.size() == img2.size()
    for i in range(img1.size()[0]):
        PSNR += psnr(img1[i,...], img2[i,...])
    return PSNR / img1.size()[0]

def aver_psnr_ds(img1, img2):
    ''' For images with different size and stored by a list'''
    PSNR = 0
    for i in range(len(img1)):
        PSNR += psnr(img1[i], img2[i])
    return PSNR / len(img1)




def comp_upto_shift(I1 , I2, cut = 15):
    '''The same shift scheme by Levin'''
    I1[I1 < 0] = 0
    I1[I1 > 1] = 1
    I2[I2 > 1] = 1
    I2[I2 < 0] = 0
    maxshift = 5
    shifts = np.arange(-5 ,5.25 ,0.25)
    ssdem = np.zeros((len(shifts),len(shifts)))
    I2= I2[cut:-cut ,cut:-cut]
    I1= I1[cut-maxshift:-cut+maxshift ,cut- maxshift:-cut+maxshift]
    [N1, N2]=np.shape(I2)
    gx = np.arange(1-maxshift , N2+maxshift +1)
    gy = np.arange(1-maxshift , N1+maxshift +1)
    gx0 = np.arange(N2)+1
    gy0 = np.arange(N1)+1

    f = interp2d( gx , gy , I1 )

    for i in range ( 0 ,len(shifts)) :
        for j in range ( 0 ,len(shifts)) :
            gxn = gx0 + shifts[i]
            gyn = gy0 + shifts[j]

            tI1 = f(gxn , gyn)
            ssdem[i,j]=np .sum((tI1-I2) ** 2)
    ssde=min(ssdem.flatten())
    psnr = 20*np.log10(1/np.sqrt(ssde/(N1*N2)))

    return psnr

def bmp_psnr(img1, img2, cut=15, to_int = False):
    '''Using Best matching pixels to compute PSNR for the whole image'''
    img1 = torch.squeeze(img1).numpy()
    img2 = torch.squeeze(img2).numpy()
    if to_int:
        img1 = np.around(img1*255).astype(int) / 255
        img2 = np.around(img2*255).astype(int) / 255
    PSNR = comp_upto_shift(img1, img2, cut=cut)
    return PSNR

def aver_bmp_psnr(img1, img2, cut = 15, to_int = False):
    ''' For images with different size and stored by a list'''
    PSNR = 0
    for i in range(len(img1)):
        PSNR += bmp_psnr(img1[i], img2[i], cut=cut, to_int = to_int)
    return PSNR / len(img1)




### Parallel Computing of PSNR by Best Matching
from joblib import Parallel, delayed
import multiprocessing
num_cores = multiprocessing.cpu_count()

def comp_upto_shif_algn(I1 , I2, cut, ssim_compute = False):
    '''
    Compute the PSNR and SSIM for grayscale image aligned by best matching principle using same shift scheme by Levin \etal's code
        I1: Deblurred results
        I2: Sharp image
        cut: The boundary cut
    '''
    maxshift = 5
    shifts = np.arange(-5 ,5.25 ,0.25)
    ssdem = np.zeros((len(shifts),len(shifts)))
    I2 = I2[cut:-cut ,cut:-cut]
    I1 = I1[cut-maxshift:-cut+maxshift ,cut- maxshift:-cut+maxshift]
    [N1, N2] = np.shape(I2)
    gx = np.arange(1-maxshift , N2+maxshift +1)
    gy = np.arange(1-maxshift , N1+maxshift +1)
    gx0 = np.arange(N2)+1
    gy0 = np.arange(N1)+1
    f = interp2d(gx , gy , I1)
    for i in range(0 ,len(shifts)):
        for j in range(0 ,len(shifts)):
            gxn = gx0 + shifts[i]
            gyn = gy0 + shifts[j]
            tI1 = f(gxn , gyn)
            ssdem[i,j]=np.sum((tI1-I2) ** 2)
    ssde = min(ssdem.flatten())
    psnr_metric = 20*np.log10(1/np.sqrt(ssde/(N1*N2)))

    ssim_metric = None
    i, j = np.nonzero(ssdem == ssde)
    gxn = gx0+shifts[i]
    gyn = gy0+shifts[j]
    f = interp2d(gx , gy , I1)

    I1_matched = f(gxn, gyn)
    if ssim_compute:
        ssim_metric = ssim(I1_matched, I2)
    return psnr_metric, ssim_metric, I1_matched

def comp_upto_shif_algn_color(I1 , I2, cut, ssim_compute = False):
    '''
    Compute the PSNR and SSIM for color image aligned by best matching principle using same shift scheme by Levin \etal's code
        I1: Deblurred results
        I2: Sharp image
        cut: The boundary cut
    '''
    maxshift = 5
    shifts = np.arange(-5 ,5.25 ,0.25)
    ssdem = np.zeros((len(shifts),len(shifts)))

    # The best matching is done in grayscale image for color image.
    I1_gray = rgb2gray(I1)
    I2_gray = rgb2gray(I2)
    I2 = I2[cut:-cut ,cut:-cut,:]
    I1 = I1[cut-maxshift:-cut+maxshift ,cut- maxshift:-cut+maxshift,:]

    N1, N2, C = np.shape(I2)
    I2_gray = I2_gray[cut:-cut ,cut:-cut]
    I1_gray = I1_gray[cut-maxshift:-cut+maxshift ,cut- maxshift:-cut+maxshift]


    gx = np.arange(1-maxshift , N2+maxshift +1)
    gy = np.arange(1-maxshift , N1+maxshift +1)
    gx0 = np.arange(N2)+1
    gy0 = np.arange(N1)+1
    f = interp2d(gx , gy , I1_gray)
    for i in range(0 ,len(shifts)) :
        for j in range(0 ,len(shifts)) :
            gxn = gx0 + shifts[i]
            gyn = gy0 + shifts[j]
            tI1 = f(gxn , gyn)
            ssdem[i,j] = np.sum((tI1-I2_gray) ** 2)
    ssde = min(ssdem.flatten())

    # Use the best matching in color mode:
    i, j = np.nonzero(ssdem == ssde)
    gxn = gx0 + shifts[i]
    gyn = gy0 + shifts[j]

    I1_matched = np.zeros_like(I2)
    for chn in range(C):
        f = interp2d(gx , gy , I1[:,:,chn])
        I1_matched[:,:,chn] = f(gxn , gyn)

    ssde = np.sum((I1_matched-I2)**2)
    psnr_metric = 20*np.log10(1/np.sqrt(ssde/(N1*N2*C)))

    ssim_metric = None

    # ssim is also computed in grayscale.
    if ssim_compute:
        ssim_metric = ssim(rgb2gray(I1_matched), I2_gray)
    return psnr_metric, ssim_metric, I1_matched

def aver_bmp_psnr_ssim_par(img1, img2, bd_cut = 15, to_int = True, ssim_compute = True, show_aligned = False):
    ''' Parallel computing is applied for images'''
    im_len = len(img1)
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

    if len(img1[0].shape) == 3:
        Results  = Parallel(n_jobs=num_cores)(delayed(comp_upto_shif_algn_color)(img1[i], img2[i],
             cut = bd_cut, ssim_compute= ssim_compute) for i in range(im_len))
    else:
        Results  = Parallel(n_jobs=num_cores)(delayed(comp_upto_shif_algn)(img1[i], img2[i],
             cut = bd_cut, ssim_compute= ssim_compute) for i in range(im_len))

    PSNR = np.zeros((im_len,1))
    for ii in range(im_len):
        PSNR[ii] = Results[ii][0]

    output = []
    PSNR_mean = np.mean(PSNR)
    output += [PSNR_mean]
    if ssim_compute:
        SSIM = np.zeros((im_len, 1))
        for ii in range(im_len):
            SSIM[ii] = Results[ii][1]
        SSIM_mean = np.mean(SSIM)
        output += [SSIM_mean]
    if show_aligned:
        I1_matched = [None] * im_len
        for ii in range(im_len):
            I1_matched[ii] = Results[ii][2]
        output += [I1_matched]
    return output



import numpy
from scipy import signal

def ssim(img1, img2, cs_map=False):
    if isinstance(img1, torch.Tensor):
        img1 = img1.squeeze()
        img2 = img2.squeeze()
        img1 = img1.cpu().numpy()
        img2 = img2.cpu().numpy()
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
    """Function to mimic the 'fspecial' gaussian MATLAB function"""
    x, y = numpy.mgrid[-size // 2 + 1:size // 2 + 1, -size // 2 + 1:size // 2 + 1]
    g = numpy.exp(-((x ** 2 + y ** 2) / (2.0 * sigma ** 2)))
    return g / g.sum()

