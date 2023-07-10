# -*- coding: utf-8 -*-
"""
Created on Wed Feb 13 16:35:23 2019

add noise to the testing data set

the noise is generated in the frequency domain so it can be band-limited

amplitude of the noise is specified by the standard deviation of the Gaussian distribution

Editor:
    Shihao Ran
    STIM Laboratory
"""


import numpy as np
from matplotlib import pyplot as plt

# noise generate function
def band_noise(S, amp, low_factor, high_factor):
    # S is the input signal
    # amp is the amplitude of the noise or the standard deviation of the Gaussian noise
    # low, high factor is the limits of the bandpass filter
    
    # allocate space for the noise
    eta = np.zeros(S.shape, dtype = np.complex128)
    
    # for each image in the data set
    for i in range(S.shape[0]):
        # for each channel in the image
        # real and imaginary part
        for j in range(2):
            
            # Gaussian noise in frequency domain
            eta_f = np.random.normal(0, amp, S.shape[1:-1])
            eta_f = np.reshape(eta_f, (S.shape[1] * S.shape[2]))
            
            # calculate the number of values in the signal
            N = eta_f.shape[0]
            
            # calculate the factor indices
            lfi = N * low_factor / 2
            hfi = N * high_factor / 2
            
            lf0 = int(lfi)
            lf1 = N-int(lfi)
            
            hf0 = int(hfi)
            hf1 = N - int(hfi)
        
            # apply the bandpass filter
            eta_f[0:lf0] = 0
            eta_f[hf0:hf1] = 0
            eta_f[lf1:N] = 0

            # inverse FFT to generate noise in the real domain
            eta_if = np.fft.ifft(eta_f)
            eta_if = np.reshape(eta_if, S.shape[1:-1])
            eta[i, :, :, j] = eta_if
   
    return S + eta, eta


amp = 40
low = 0.9
high = 1

X_test_w_noise, noise = band_noise(sample1, amp, low, high)

plt.figure()
plt.subplot(131)
plt.imshow(np.real(noise[:,0]))
plt.title('Noise')
plt.colorbar()

plt.subplot(132)
plt.imshow(np.real(sample1[:,0]))
plt.title('Raw Image')
plt.colorbar()

plt.subplot(133)
plt.imshow(np.real(X_test_w_noise[:,0]))
plt.title('Noise + Image')
plt.colorbar()