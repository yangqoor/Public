# -*- coding: utf-8 -*-

import numpy as np
from PIL import Image
import skimage
import skimage.color
import scipy.signal
import scipy.fft
import matplotlib.pyplot as plt

import utils
import pcVC
import mLM
import mW
import aL
import mRL 


"""
Experiments with a grayscale image and noisy motion blur
"""

img = Image.open('../images/barbara_face.png')
xs = np.asarray(img)
xs = skimage.img_as_float(xs)


"""
Definition of the filter (noisy motion blur). 
Gaussian noise is used, and kernel2 is used for the motion blur. 
"""

noise_mean = 0
noise_var = 0.00001
img = Image.open('../kernels/testkernel2.bmp')
h = np.asarray(img)
h = skimage.color.rgb2gray(h) if len(h.shape) == 3 else h
h = skimage.img_as_float(h)
h = h / np.sum(h[:])
N = xs.shape[0]
M = xs.shape[1]
C = 1 if len(xs.shape)!=3 else xs.shape[2]

Hf = utils.psf2otf(h, (N,M)) if C == 1 else utils.psf2otf(h, (N,M,C))

if C == 1:
    f = lambda x: np.real(scipy.fft.ifft2(scipy.fft.fft2(x[:,:])*Hf))
else:
    f = lambda x: np.real(scipy.fft.ifftn(scipy.fft.fftn(x[:,:,:])*Hf))

F = lambda x: skimage.util.random_noise(f(x), mode='gaussian', mean = noise_mean, var = noise_var)

y = F(xs)


"""
Show the input and the blurred input image
"""

fig1, axes1 = plt.subplots(1,2, figsize=(18,6))
axes1[0].imshow(xs, cmap='gray', vmin=0.0, vmax=1.0)
axes1[0].set_title('Original image')
axes1[1].imshow(y, cmap='gray', vmin=0.0, vmax=1.0)
axes1[1].set_title('Observed image')


"""
Input, phase corrected VC and LM 
"""

pcvc = pcVC.pcVC(F, y)
mlm = mLM.mLM(F, y)
mw = mW.mW(F, y)
al = aL.aL(F, y)
mrl = mRL.mRL(F, y)

fig2, axes2 = plt.subplots(1,3, figsize=(18,6))
axes2[0].imshow(pcvc, cmap='gray', vmin=0.0, vmax=1.0)
axes2[0].set_title('pcVC')
axes2[1].imshow(mlm, cmap='gray', vmin=0.0, vmax=1.0)
axes2[1].set_title('mLM')
axes2[2].imshow(mw, cmap='gray', vmin=0.0, vmax=1.0)
axes2[2].set_title('mW')

fig3, axes3 = plt.subplots(1,3, figsize=(18,6))
axes3[0].imshow(xs, cmap='gray', vmin=0.0, vmax=1.0)
axes3[0].set_title('Original image')
axes3[1].imshow(al, cmap='gray', vmin=0.0, vmax=1.0)
axes3[1].set_title('aL')
axes3[2].imshow(mrl, cmap='gray', vmin=0.0, vmax=1.0)
axes3[2].set_title('mRL')
plt.show()
