# -*- coding: utf-8 -*-
"""
Created on Wed Mar 20 09:22:52 2019

data visualizatioin

plot out the training and testing images

Editor:
    Shihao Ran
    STIM Laboratory
"""

import numpy as np
import matplotlib.pyplot as plt
import sys
import chis.MieScattering as ms
from chis import animation

#%%
def bandpass_filtering(sphere_data, bpf):
    # apply bandpass filter to all the data sets
    
    # allocate space for the image data set
    bp_data_complex = np.zeros((num_test, res, res, 2))
    bp_data_intensity = np.zeros((num_test, res, res, 1))
    
    cnt = 0
    
    # merge the 2-channel dataset into one channel as complex images
    complex_im = sphere_data[..., 0] + sphere_data[..., 1] * 1j
    
    # for each image
    for i in range(num_test):
        
        # apply bandpass filtering
        filtered_im_complex = ms.apply_filter(simRes, simFov, complex_im[i, ...], bpf)
        
        # crop the field after bandpass filtering
        cropped_im_complex = ms.crop_field(res, filtered_im_complex)
        
        # saving them individually
        bp_data_complex[i, :, :, 0] = np.real(cropped_im_complex)
        bp_data_complex[i, :, :, 1] = np.imag(cropped_im_complex)
        
        bp_data_intensity[i, :, :, 0] = np.abs(cropped_im_complex) ** 2     
        
        # print progress
        cnt += 1
        sys.stdout.write('\r' + str(cnt / num_test * 100)  + ' %')
        sys.stdout.flush() # important
    
    return bp_data_complex, bp_data_intensity
    
#%%
# load data set

raw_im = np.load(r'D:\irimages\irholography\CNN\data_v9_far_field\raw_data\im_data010.npy')
raw_im = np.reshape(raw_im, (640, 640, 2, 400))

raw_im = np.swapaxes(raw_im, 0, -1)
raw_im = np.swapaxes(raw_im, -2, -1)

data_dir = r'D:\irimages\irholography\CNN\data_v9_far_field'

#%%
num_test = 400
lambDa = 1
NA_in = 0
NA_out = 0.25
res = 128
fov = 16
padding = 2
simRes, simFov = ms.pad(res, fov, padding)

# create a bandpass filter
bpf = ms.bandpass_filter(simRes, simFov, NA_in, NA_out, dimension=2)
# apply bandpass filtering to all the images
im_bp_comp, im_bp_inten = bandpass_filtering(raw_im, bpf)

#%%
# create an animation
animation.anime(im_bp_inten, 20, data_dir, 'intensityBP0.25', 'Real')
