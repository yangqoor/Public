# -*- coding: utf-8 -*-
"""
Created on Tue Feb 26 14:37:26 2019

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
from sklearn.model_selection import train_test_split
from keras.models import load_model

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
    
    return D_Et

def bandpass_filtering(bpf):
    # apply bandpass filter to all the data sets
    
    # allocate space for the image data set
    im_data_complex = np.zeros((res, res, 2, nb_nr, nb_ni, nb_a))
    im_data_intensity = np.zeros((res, res, 1, nb_nr, nb_ni, nb_a))
    
    # initialize a counter for printing progress
    cnt = 0
    
    # band pass and crop
    for h in range(nb_a):
        # for all the sphere sizes
        # load in the data set for this sphere size
        sphere_dir = data_dir + '\im_data%3.3d'% (h) + '.npy'
        sphere_data = np.load(sphere_dir)
        
        # reconstrut the complex field to calculate the intensity image
        complex_im = sphere_data[:,:,0,:,:] + sphere_data[:,:,1,:,:] * 1j
        intensity_im = np.abs(complex_im) ** 2
        
        # for different n values in this data set
        for i in range(nb_nr):
            for j in range(nb_ni):
                
                # apply bandpass filter to the complex field
                filtered_im_complex = apply_bpf(complex_im[:, :, i, j], bpf)
                
                # save the complex image as two channel images
                im_data_complex[:, :, 0, i, j, h] = np.real(filtered_im_complex)
                im_data_complex[:, :, 1, i, j, h] = np.imag(filtered_im_complex)
                
                # apply bandpass filter to the intensity image
                filtered_im_intensity = apply_bpf(intensity_im[:, :, i, j], bpf)
                # after bandpass the values are complex so calculate the intensity again
                im_data_intensity[:, :, 0, i, j, h] = np.abs(filtered_im_intensity) ** 2
                
                # print progress
                cnt += 1
                sys.stdout.write('\r' + str(cnt / nb_img * 100)  + ' %')
                sys.stdout.flush() # important
    
    return im_data_complex, im_data_intensity

def calculate_error(imdata, option = 'complex'):
    # make a prediction based on the input data set
    # calculate the relative error between the prediction and the testing ground truth
    # if the input data is intensity images, set the channel number to 1
    # otherwise it is complex images, set the channel number to 2
    if option == 'intensity':
        channel = 1
    else:
        channel = 2
    
    # pre process the input data
    X_data = np.reshape(imdata, (res, res, channel, nb_img))
    X_data = np.swapaxes(X_data, 0, -1)
    X_data = np.swapaxes(X_data, -2, -1)
    
    # split the data set to get the testing data
    # keep the random state same as when split the training data to make sure the testing data has not been seen by the CNN
    X_train, X_test, y_train, y_test = train_test_split(X_data, y_data, test_size = 0.2, random_state = 5)
    
    # use different CNN to test depend on the data set type
    if option == 'intensity':
        y_pred = intensity_CNN.predict(X_test)
    else:
        y_pred = complex_CNN.predict(X_test)
    
    # calculate the relative error of the sum of the B vector
    y_off = y_test - y_pred
    y_off_sum = np.sum(y_off, axis = 1)
    y_test_sum = np.sum(y_test, axis = 1)
    y_off_ratio = y_off_sum / y_test_sum
    y_off_perc = np.abs(np.average(y_off_ratio) * 100)
    
    return y_off_perc

# specify parameters of the simulation
# resolution of the image before padding
res = 128
# padding number
padding = 2
# field of view
fov = 30
# wave length
lambDa = 2 * np.pi
# half of the grid size
halfgrid = np.ceil(fov / 2) * (padding * 2 + 1)
# center obscuration of the objective when calculating bandpass filter
NA_in = 0.2
# numerical aperture of the objective
NA_out = 1.2

# number of different numerical apertures to be tested
nb_NA = 5

# allocate a list of the NA
NA_list = np.linspace(NA_in, NA_out, nb_NA)

# get the resolution after padding the image
simRes = res * (padding *2 + 1)

# dimention of the data set
nb_a = 20
nb_nr = 20
nb_ni = 20

# total number of images in the data set
nb_img = nb_a * nb_nr * nb_ni

## pre load y train and y test
#y_data_real = np.load(r'D:\irimages\irholography\CNN\data_v8_padded\B_data_real.npy')
#y_data_imag = np.load(r'D:\irimages\irholography\CNN\data_v8_padded\B_data_imag.npy')
#
## concatenate the imaginary part of the B vector to the end of the real part of B
#y_data = np.concatenate((y_data_real, y_data_imag), axis = 0)
## rearrange them
#y_data = np.reshape(y_data, (44, nb_img))
#y_data = np.swapaxes(y_data, 0, 1)
#
## pre load intensity and complex CNNs
#complex_CNN = load_model(r'D:\irimages\irholography\CNN\CNN_v10_padded_2\complex\complex.h5')
#intensity_CNN = load_model(r'D:\irimages\irholography\CNN\CNN_v10_padded_2\intensity\intensity.h5')
#
## parent directory of the data set
#data_dir = r'D:\irimages\irholography\CNN\data_v8_padded'

# allocate space for complex and intensity accuracy
complex_error = np.zeros((nb_NA), dtype = np.float64)
intensity_error = np.zeros((nb_NA), dtype = np.float64)

# for each NA to be tested
for NA_idx in range(nb_NA):
    
    # calculate the band pass filter
    bpf = BPF(halfgrid, simRes, NA_in, NA_list[NA_idx])
    
    # print some info about the idx of NA
    print('Banbpassing the ' + str(NA_idx + 1) + 'th filter \n')
    im_data_complex, im_data_intensity = bandpass_filtering(bpf)

    print('Evaluating complex model \n')
    # handle complex model first
    complex_error[NA_idx] = calculate_error(im_data_complex, option = 'complex')
    
    print('Evaluating intensity model \n')
    # handle intensity model second
    intensity_error[NA_idx] = calculate_error(im_data_intensity, option = 'intensity')

# save the error file
np.save(r'D:\irimages\irholography\CNN\CNN_v10_padded_2\complex_error', complex_error)
np.save(r'D:\irimages\irholography\CNN\CNN_v10_padded_2\intensity_error', intensity_error)

# plot out the error
plt.figure()
plt.plot(NA_list, complex_error, label = 'Complex CNN')
plt.plot(NA_list, intensity_error, label = 'Intensity CNN')
plt.xlabel('NA')
plt.ylabel('Relative Error (Vector Sum)')
plt.legend()