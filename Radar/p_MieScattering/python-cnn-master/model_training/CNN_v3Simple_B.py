# -*- coding: utf-8 -*-
"""
Created on Thu Jan 31 16:13:03 2019

CNN for predict the B vector from the simulated images

simple network structure version

contains two convolutional layers with max pooling

followed by two fully connected layers

ATTENTION: commend out the save model and file lines before running the script

Editor:
    Shihao Ran
    STIM Laboratory
"""

import numpy as np
from matplotlib import pyplot as plt

from keras.models import Sequential
from keras.layers import Convolution2D
from keras.layers import MaxPooling2D
from keras.layers import Flatten
from keras.layers import Dense
from sklearn.model_selection import train_test_split

image_res = 64
num_total_sample = 8000

regressor = Sequential()

regressor.add(Convolution2D(64, (3, 3), input_shape = (image_res, image_res, 1), activation = 'relu'))

regressor.add(MaxPooling2D(pool_size = (2, 2)))

regressor.add(Convolution2D(32, (3, 3), activation = 'relu'))

regressor.add(MaxPooling2D(pool_size = (2, 2)))

regressor.add(Flatten())

regressor.add(Dense(512, activation = 'relu'))

regressor.add(Dense(44))

regressor.compile('adam', loss = 'mean_squared_error')

X_data = np.load(r'D:\irimages\irholography\CNN\data_v7_padded\im_data_intensity.npy')
X_data = np.reshape(X_data, (image_res, image_res, 1, num_total_sample))
X_data = np.swapaxes(X_data, 0, -1)
X_data = np.swapaxes(X_data, -2, -1)

y_data_real = np.load(r'D:\irimages\irholography\CNN\data_v7_padded\B_data_real.npy')
y_data_imag = np.load(r'D:\irimages\irholography\CNN\data_v7_padded\B_data_imag.npy')

y_data = np.concatenate((y_data_real, y_data_imag), axis = 0)

y_data = np.reshape(y_data, (44, num_total_sample))
y_data = np.swapaxes(y_data, 0, 1)

X_train, X_test, y_train, y_test = train_test_split(X_data, y_data, test_size = 0.2)

regressor.fit(x = X_train, y = y_train, batch_size = 50,
              epochs = 25,
              validation_split = 0.2)

y_pred = regressor.predict(X_test)
#
regressor.save(r'D:\irimages\irholography\CNN\CNN_v9_bandpass\intensity_simple.h5')
###
np.save(r'D:\irimages\irholography\CNN\CNN_v9_bandpass\X_test.bin', X_test)
np.save(r'D:\irimages\irholography\CNN\CNN_v9_bandpass\y_test.bin', y_test)
