# -*- coding: utf-8 -*-
"""
Created on Sat Mar 16 15:15:54 2019

bandpass sanity check

Editor:
    Shihao Ran
    STIM Laboratory
"""

# import packages
import matplotlib.pyplot as plt
import numpy as np
import math

def BPF(fov, simRes, NA_in, NA_out):
    #create a bandpass filter
    #change coordinates into frequency domain
        
    df = 1/(fov)
    
    iv, iu = np.meshgrid(np.arange(0, simRes, 1), np.arange(0, simRes, 1))
    
    u = np.zeros(iu.shape)
    v = np.zeros(iv.shape)
    
    #initialize the filter as All Pass
    BPF = np.ones(iv.shape)
    
    idex1, idex2 = np.where(iu <= simRes/2)
    u[idex1, idex2] = iu[idex1, idex2]
    
    idex1, idex2 = np.where(iu > simRes/2)
    u[idex1, idex2] = iu[idex1, idex2] - simRes +1
    
    u *= df
    
    idex1, idex2 = np.where(iv <= simRes/2)
    v[idex1, idex2] = iv[idex1, idex2]
    
    idex1, idex2 = np.where(iv > simRes/2)
    v[idex1, idex2] = iv[idex1, idex2] - simRes +1
    
    v *= df
    
    magf = np.sqrt(u ** 2 + v ** 2)
    
    #block lower frequency
    idex1, idex2 = np.where(magf < NA_in / lambDa)
    BPF[idex1, idex2] = 0
    #block higher frequency
    idex1, idex2 = np.where(magf > NA_out / lambDa)
    BPF[idex1, idex2] = 0
    
    return BPF

def new_bpf(simFov, simRes, NA_in, NA_out):
    # basically, a bandpass filter is just a circular mask
    # with inner and outer diamater specified by the 
    # in and out NA
    f_x = np.fft.fftfreq(simRes, simFov/simRes)
    
    fx, fy = np.meshgrid(f_x, f_x)
    
    fxfy = np.sqrt(fx ** 2 + fy ** 2)
    
    bpf_test = np.zeros((simRes, simRes))
    
    mask_out = fxfy <= NA_out
    mask_in = fxfy > NA_in
    
    mask = np.logical_and(mask_out, mask_in)
    
    bpf_test[mask] = 1
    
    return bpf_test
    
def apply_bpf(Etot, bpf):
    # apply the bandpass filter to the input field
    
    #2D fft to the input field
    Et_d = np.fft.fft2(Etot)
    
    #apply bandpass filter in the fourier domain
    Et_d *= bpf
    
    #invert FFT back to spatial domain
    Et_bpf = np.fft.ifft2(Et_d)
    
    #initialize cropping
    cropsize = res
    startIdx = int(np.fix(simRes /2 + 1) - np.floor(cropsize/2))
    endIdx = int(startIdx + cropsize - 1)
    
    D_Et = np.zeros((cropsize, cropsize), dtype = np.complex128)
    D_Et = Et_bpf[startIdx:endIdx+1, startIdx:endIdx+1]
    
    return D_Et, Et_d

#%%
# set the size and resolution of both planes
fov = 16                    # field of view
res = 128                   # resolution
a = 1                       # radius of the spere
lambDa = 1                  # wavelength
n = 1.5 + 0.03j            # refractive index
k = 2 * math.pi / lambDa    # wavenumber
padding = 0                 # padding
simRes = res * (2*padding + 1)
simFov = fov * (2*padding + 1)
working_dis = 1000          # working distance
scale_factor = working_dis * 2 * math.pi * res/fov            # scale factor of the intensity
NA_in = 0.2
NA_out = 0.8

#%%
bpf = BPF(simFov, simRes, NA_in, NA_out)
bpf_new = new_bpf(simFov, simRes, NA_in, NA_out)
E_bp, Et_f = apply_bpf(Et, bpf_new)
fx = np.fft.fftfreq(simRes, simFov/simRes)
fx = np.fft.fftshift(fx)

E_fft = np.fft.fftshift(np.fft.ifft2(Et))
#%%

plt.figure()
plt.set_cmap('RdYlBu')

plt.subplot(221)
plt.imshow(np.real(Et), extent=[-simFov/2, simFov/2, -simFov/2, simFov/2])
plt.colorbar()
plt.title('Original Field')

plt.subplot(222)
plt.imshow(np.real(Et_f), extent=[fx[0], fx[-1], fx[0], fx[-1]])
plt.colorbar()
plt.title('Forier Transformed')

plt.subplot(223)
plt.imshow(np.fft.fftshift(bpf_new), extent=[fx[0], fx[-1], fx[0], fx[-1]])
plt.colorbar()
plt.title('Bandpass Filter')

plt.subplot(224)
plt.imshow(np.real(E_bp), extent=[-simFov/2, simFov/2, -simFov/2, simFov/2])
plt.colorbar()
plt.title('Bandpassed Field')



