# -*- coding: utf-8 -*-
"""
Created on Tue Feb 26 14:37:26 2019

This newer version tests the sensitive regards the a and n CNN
Instead of B vector CNN

this program generates data sets for differnet bandpass filter settings and
test the sensitivity of the CNN to these filters
for intensity CNN and complex CNN

Editor:
    Shihao Ran
    STIM Laboratory
"""

# import packages
import matplotlib.pyplot as plt
import numpy as np
# import keras and sklearn packages
from keras.models import load_model
import sys
import chis.MieScattering as ms

#%%
def bandpass_filtering(bpf):
    # apply bandpass filter to all the data sets
    
    # allocate space for the image data set
    bp_data_complex = np.zeros((num_test, res, res, 2))
    bp_data_intensity = np.zeros((num_test, res, res, 1))
    
    cnt = 0
    # band pass and crop
    for h in range(num):
        sphere_dir = data_dir + '\X_test_%3.3d'% (h) + '.npy'
        sphere_data = np.load(sphere_dir)
        
        complex_im = sphere_data[..., 0] + sphere_data[..., 1] * 1j
        
        for i in range(num_test_in_group):
            filtered_im_complex = ms.apply_filter(res, fov, complex_im[i, ...], bpf)
            bp_data_complex[h * num_test_in_group + i, :, :, 0] = np.real(filtered_im_complex)
            bp_data_complex[h * num_test_in_group + i, :, :, 1] = np.imag(filtered_im_complex)
            
            bp_data_intensity[h * num_test_in_group + i, :, :, 0] = np.abs(filtered_im_complex) ** 2     
            
            # print progress
            cnt += 1
            sys.stdout.write('\r' + str(cnt / num_test * 100)  + ' %')
            sys.stdout.flush() # important
    
    return bp_data_complex, bp_data_intensity

def calculate_error(imdata, option = 'complex'):
    # make a prediction based on the input data set
    # calculate the relative error between the prediction and the testing ground truth
    # if the input data is intensity images, set the channel number to 1
    # otherwise it is complex images, set the channel number to 2
    
    # use different CNN to test depend on the data set type
    if option == 'intensity':
        y_pred = intensity_CNN.predict(imdata)
    else:
        y_pred = complex_CNN.predict(imdata)
    
    y_pred[:, 1] /= 100
    
    # calculate the relative error of the sum of the B vector
    y_off = np.abs(y_test - y_pred)
    
    y_off_perc = np.average(y_off / [2.0, 0.05, 2.0], axis = 0) * 100
    
    return y_off_perc

# specify parameters of the simulation
# resolution of the image before padding
res = 128
# padding number
padding = 3
# field of view
fov = 16
# wave length
lambDa = 1
# half of the grid size
halfgrid = np.ceil(fov / 2) * (padding * 2 + 1)
# center obscuration of the objective when calculating bandpass filter
NA_in = 0.0
# numerical aperture of the objective
NA_out = 1

# number of different numerical apertures to be tested
nb_NA = 10

# allocate a list of the NA
NA_list = np.linspace(0.05, NA_out, nb_NA)

# get the resolution after padding the image
simRes = res * (padding *2 + 1)
simFov = fov * (padding *2 + 1)
# dimention of the data set
num = 20

# total number of images in the data set
num_samples = num ** 3

test_size = 0.2
num_test = int(num_samples * test_size)
num_test_in_group = int(num_test / num)

# pre load y train and y test
#y_train = np.load(r'D:\irimages\irholography\CNN\data_v9_far_field\split_data\train\y_train.npy')
y_test = np.load(r'D:\irimages\irholography\CNN\data_v10_far_field\split_data\test\y_test.npy')

# pre load intensity and complex CNNs
complex_CNN = load_model(r'D:\irimages\irholography\CNN\CNN_v12_far_field_a_n\complex\complex_model30.h5')
intensity_CNN = load_model(r'D:\irimages\irholography\CNN\CNN_v12_far_field_a_n\intensity\intensity_model30.h5')

# parent directory of the data set
data_dir = r'D:\irimages\irholography\CNN\data_v10_far_field\split_data\test'

# allocate space for complex and intensity accuracy
complex_error = np.zeros((nb_NA, 3), dtype = np.float64)
intensity_error = np.zeros((nb_NA, 3), dtype = np.float64)

# for each NA to be tested
for NA_idx in range(nb_NA):
    
    # calculate the band pass filter
    bpf = ms.bandpass_filter(simRes, simFov, NA_in, NA_list[NA_idx])
    
    # print some info about the idx of NA
    print('Banbpassing the ' + str(NA_idx + 1) + 'th filter \n')
    im_data_complex, im_data_intensity = bandpass_filtering(bpf)

    print('Evaluating complex model \n')
    # handle complex model first
    complex_error[NA_idx, :] = calculate_error(im_data_complex, option = 'complex')
    
    print('Evaluating intensity model \n')
    # handle intensity model second
    intensity_error[NA_idx, :] = calculate_error(im_data_intensity, option = 'intensity')

# save the error file
np.save(r'D:\irimages\irholography\CNN\CNN_v12_far_field_a_n\complex_error2', complex_error)
np.save(r'D:\irimages\irholography\CNN\CNN_v12_far_field_a_n\intensity_error2', intensity_error)

#%%
# plot out the error
plt.figure()
plt.subplot(311)
plt.plot(NA_list, complex_error[:, 0], label = 'Complex CNN')
plt.plot(NA_list, intensity_error[:, 0], label = 'Intensity CNN')
plt.xlabel('NA')
plt.ylabel('Relative Error (Refractive Index)')
plt.legend()

plt.subplot(312)
plt.plot(NA_list, complex_error[:, 1], label = 'Complex CNN')
plt.plot(NA_list, intensity_error[:, 1], label = 'Intensity CNN')
plt.xlabel('NA')
plt.ylabel('Relative Error (Attenuation Coefficient)')
plt.legend()

plt.subplot(313)
plt.plot(NA_list, complex_error[:, 2], label = 'Complex CNN')
plt.plot(NA_list, intensity_error[:, 2], label = 'Intensity CNN')
plt.xlabel('NA')
plt.ylabel('Relative Error (Sphere Radius)')
plt.legend()
