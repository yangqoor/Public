# -*- coding: utf-8 -*-
"""
Created on Tue Feb 19 09:40:27 2019

load sequential data into memory and apply a bandpass filter to the images

then crop the image smaller so the total training set won't reach memory limit

Editor:
    Shihao Ran
    STIM Laboratory
"""

import numpy as np
from matplotlib import pyplot as plt
import sys

def BPF(halfgrid, simRes, NA_in, NA_out):
    #create a bandpass filter
        #change coordinates into frequency domain
        
    df = 1/(halfgrid*2)
    
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
    
def apply_bpf(Etot, bpf):
    #2D fft to the total field
    Et_d = np.fft.fft2(Etot)
    
    #apply bandpass filter to the fourier domain
    Et_d *= bpf
    
    #invert FFT back to spatial domain
    Et_bpf = np.fft.ifft2(Et_d)
    
    #initialize cropping
    cropsize = res
    startIdx = int(np.fix(simRes /2) - np.floor(cropsize/2))
    endIdx = int(startIdx + cropsize - 1)
    
    D_Et = np.zeros((cropsize, cropsize), dtype = np.complex128)
    D_Et = Et_bpf[startIdx:endIdx+1, startIdx:endIdx+1]

    return D_Et

# specify parameters of the simulation
res = 128
padding = 2
fov = 16
lambDa = 2 * np.pi
halfgrid = np.ceil(fov / 2) * (padding * 2 + 1)
NA_in = 0.0
NA_out = 0.6

# get the resolution after padding the image
simRes = res * (padding *2 + 1)

# calculate the band pass filter
bpf = BPF(halfgrid, simRes, NA_in, NA_out)

# dimention of the data set
num = 20
num_samples = num ** 3
test_size = 0.2
num_test = int(num_samples * test_size)
num_test_in_group = int(num_test / num)

# parent directory of the data set
data_dir = r'D:\irimages\irholography\CNN\data_v9_far_field\split_data\test'

# allocate space for the image data set
bp_data_complex = np.zeros((num_test, res, res, 2))
bp_data_intensity = np.zeros((num_test, res, res, 1))

cnt = 0
# band pass and crop
for h in range(num):
    sphere_dir = data_dir + '\X_test_%3.3d'% (h) + '.npy'
    sphere_data = np.load(sphere_dir)
    
    complex_im = sphere_data[..., 0] + sphere_data[..., 1] * 1j
    intensity_im = np.abs(complex_im) ** 2
    
    for i in range(num_test_in_group):
        filtered_im_complex = apply_bpf(complex_im[i, ...], bpf)
        bp_data_complex[h * num_test_in_group + i, :, :, 0] = np.real(filtered_im_complex)
        bp_data_complex[h * num_test_in_group + i, :, :, 1] = np.imag(filtered_im_complex)
        
        bp_data_intensity[h * num_test_in_group + i, :, :, 0] = np.abs(filtered_im_complex) ** 2
        
        # print progress
        cnt += 1
        sys.stdout.write('\r' + str(cnt / num_test * 100)  + ' %')
        sys.stdout.flush() # important

np.save(data_dir + '\im_data_complex_0.6', bp_data_complex)
np.save(data_dir + '\im_data_intensity_0.6', bp_data_intensity)


