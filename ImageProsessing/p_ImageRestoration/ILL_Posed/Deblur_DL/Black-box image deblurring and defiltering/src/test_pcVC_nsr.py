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


"""
Compare pcVC and pcVC_nsr (There should be no visible difference)
"""

img = Image.open('../images/barbara_face.png')
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

Hf = utils.psf2otf(h, (N,M)) if C == 1 else utils.psf2otf(h, (N,M,C))

if C == 1:
    f = lambda x: np.real(scipy.fft.ifft2(scipy.fft.fft2(x[:,:])*Hf))
else:
    f = lambda x: np.real(scipy.fft.ifftn(scipy.fft.fftn(x[:,:,:])*Hf))

F = lambda x: skimage.util.random_noise(f(x), mode='gaussian', mean = noise_mean, var = noise_var)

y = F(xs)

pcvc = pcVC.pcVC(F, y)
pcvc_nsr = pcVC.pcVC_nsr(F, y)

fig, axes = plt.subplots(1,3, figsize=(18,6))
axes[0].imshow(xs, cmap='gray', vmin=0.0, vmax=1.0)
axes[0].set_title('Original image')
axes[1].imshow(pcvc, cmap='gray', vmin=0.0, vmax=1.0)
axes[1].set_title('pcVC')
axes[2].imshow(pcvc_nsr, cmap='gray', vmin=0.0, vmax=1.0)
axes[2].set_title('pcVC with nsr regularization')
plt.show()
