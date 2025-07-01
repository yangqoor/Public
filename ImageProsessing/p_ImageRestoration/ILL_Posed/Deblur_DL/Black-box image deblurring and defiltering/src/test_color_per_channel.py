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
Dealing with color images channel by channel
I.e. for a given color image, apply the defiltering scheme 
once for each channel. 
"""

img = Image.open('../images/parrots.png')
xs = np.asarray(img)
xs = skimage.img_as_float(xs)

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

Hf = utils.psf2otf(h, (N,M))

f = lambda x: np.real(scipy.fft.ifft2(scipy.fft.fft2(x[:,:])*Hf))
F = lambda x: skimage.util.random_noise(f(x), mode='gaussian', mean = noise_mean, var = noise_var)

yr = F(xs[:,:,0])
yg = F(xs[:,:,1])
yb = F(xs[:,:,2])
y = np.dstack((yr, yg, yb))

pcvcr = pcVC.pcVC(F, yr)
pcvcg = pcVC.pcVC(F, yg)
pcvcb = pcVC.pcVC(F, yb)
pcvc = np.dstack((pcvcr, pcvcg, pcvcb))

mlmr = mLM.mLM(F, yr)
mlmg = mLM.mLM(F, yg)
mlmb = mLM.mLM(F, yb)
mlm = np.dstack((mlmr, mlmg, mlmb))

mwr = mW.mW(F, yr)
mwg = mW.mW(F, yg)
mwb = mW.mW(F, yb)
mw = np.dstack((mwr, mwg, mwb))

alr = aL.aL(F, yr)
alg = aL.aL(F, yg)
alb = aL.aL(F, yb)
al = np.dstack((alr, alg, alb))

mrlr = mRL.mRL(F, yr)
mrlg = mRL.mRL(F, yg)
mrlb = mRL.mRL(F, yb)
mrl = np.dstack((mrlr, mrlg, mrlb))

fig1, axes1 = plt.subplots(1,2, figsize=(18,6))
axes1[0].imshow(xs)
axes1[0].set_title('Original image')
axes1[1].imshow(y)
axes1[1].set_title('Observed image')

fig2, axes2 = plt.subplots(1,3, figsize=(18,6))
axes2[0].imshow(pcvc)
axes2[0].set_title('pcVC')
axes2[1].imshow(mlm)
axes2[1].set_title('mLM')
axes2[2].imshow(mw)
axes2[2].set_title('mW')

fig3, axes3 = plt.subplots(1,3, figsize=(18,6))
axes3[0].imshow(xs)
axes3[0].set_title('Original image')
axes3[1].imshow(al)
axes3[1].set_title('aL')
axes3[2].imshow(mrl)
axes3[2].set_title('mRL')
plt.show()

