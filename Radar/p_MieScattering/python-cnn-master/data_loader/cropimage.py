# -*- coding: utf-8 -*-
"""
Created on Tue Feb 19 09:40:27 2019

load sequential data into memory and crop the image so it can be saved into
a whole data cube in memory

Editor:
    Shihao Ran
    STIM Laboratory
"""

import numpy as np
from matplotlib import pyplot as plt
import sys

def cropImage(Etot, res, padding):
# crop the image with padding to the resolution specified
    # Etot: the original field to be cropped
    # res: the resolution to be cropped to
    # padding: the padding of the input field

    # calculate the resolution after padding    
    simRes = res * (2 * padding + 1)
    
    # initialize cropping
    cropsize = res
    
    # compute the start index and end index on the of the final image
    startIdx = int(np.fix(simRes /2) - np.floor(cropsize/2))
    endIdx = int(startIdx + cropsize - 1)
    
    # allocate space for the new image
    D_Et = np.zeros((cropsize, cropsize), dtype = np.complex128)
    
    # crop the original field
    D_Et = Etot[startIdx:endIdx+1, startIdx:endIdx+1]

    return D_Et


def crop_data(res, padding, fov, test_size = 0.2, option = 'train'):
# load the original individual data sets
# crop them individually
# then concatenate them into one data cube
    # res: resolution AFTER cropping
    # padding: padding of the original images
    # fov: fov BEFORE padding
    # test_size: the ratio of testing set when split the data set
    # option: specify if this data set is training set or testing set
    
    # number of samples in the data set is calculated
    # depend on if it is training set or testing set
    if option == 'train':
        total_num = np.int(num_samples * (1-test_size))
    elif option == 'test':
        total_num = np.int((num_samples * test_size))
    else:
        print('Error: Invalid data set type!')
        return
    
    # allocate space for the merged data set
    im_cropped_complex = np.zeros((total_num, res, res, 2))
    im_cropped_intensity = np.zeros((total_num, res, res, 1))
    y_total_data = np.zeros((total_num, 3))
    
    # initialize a counter for printing progress
    cnt = 0
    
    # crop each data set and contatenate them
    for h in range(num):
        
        # print progress
        cnt += 1
        sys.stdout.write('\r Cropping ' + str(cnt) + 'th ' + option + ' set!')
        sys.stdout.flush()                                      # important
        
        # specify the file name
        X_dir = data_dir + '\\' + option + r'\X_'+ option +'_%3.3d'% (h) + '.npy'
        y_dir = data_dir + '\\' + option + r'\y_'+ option +'_%3.3d'% (h) + '.npy'
        
        # load the data set
        X_data = np.load(X_dir)
        y_data = np.load(y_dir)
        
        # put two channels together to represent the complex field
        complex_X = X_data[..., 0] + X_data[..., 1] * 1j
        
        # compute the number of samples in this data set
        group_num = np.int(total_num/num)
        
        # for each sample
        for i in range(group_num):
            
            # crop the image
            cropped_X_complex = cropImage(complex_X[i, ...], res, padding)
            
            # seperate the real and complex part as two channels
            im_cropped_complex[h * group_num + i, :, :, 0] = np.real(cropped_X_complex)
            im_cropped_complex[h * group_num + i, :, :, 1] = np.imag(cropped_X_complex)
            
            # calculate the intensity from the complex field
            im_cropped_intensity[h * group_num + i, :, :, 0] = np.abs(cropped_X_complex) ** 2
        
        # append the labels
        y_total_data[h * group_num: (h+1) * group_num, ...] = y_data 
    
    # save the merged data set
    np.save(save_dir + '\\' + option + r'\cropped_X_'+option+'_complex', im_cropped_complex)
    np.save(save_dir + '\\' + option + r'\cropped_X_'+option+'_intensity', im_cropped_intensity)
    np.save(save_dir + '\\' + option + r'\y_'+option, y_total_data)

    return

# specify parameters of the simulation
res = 128
padding = 3
fov = 16

test_size = 0.2

# parent directory of the data set
data_dir = r'C:\copyofdata\split_data'
save_dir = r'D:\irimages\irholography\CNN\data_v10_far_field\split_data'
# dimention of the data set
num = 20
num_samples = num ** 3

crop_data(res, padding, fov)
crop_data(res, padding, fov, option = 'test')