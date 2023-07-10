# -*- coding: utf-8 -*-
"""
Created on Sat Jan 26 14:53:15 2019

Load and pre process for the training and testing data

Editor:
    Shihao Ran
    STIM Laboratory
"""

import numpy as np
from sklearn.model_selection import train_test_split

image_res = 128
num = 20
num_total_sample = num ** 3
channel = 2

X_data = np.load(r'D:\irimages\irholography\CNN\data_v8_padded\bandpassed0.9\im_data_complex_0.9.npy')
X_data = np.reshape(X_data, (image_res, image_res, channel, num_total_sample))
X_data = np.swapaxes(X_data, 0, -1)
X_data = np.swapaxes(X_data, -2, -1)

y_data_real = np.load(r'D:\irimages\irholography\CNN\data_v8_padded\B_data_real.npy')
y_data_imag = np.load(r'D:\irimages\irholography\CNN\data_v8_padded\B_data_imag.npy')

y_data = np.concatenate((y_data_real, y_data_imag), axis = 0)

y_data = np.reshape(y_data, (44, num_total_sample))
y_data = np.swapaxes(y_data, 0, 1)

X_train, X_test, y_train, y_test = train_test_split(X_data, y_data, test_size = 0.2, random_state = 5)

np.save(r'D:\irimages\irholography\CNN\data_v8_padded\bandpassed0.9\X_test_complex', X_test)
#np.save(r'D:\irimages\irholography\CNN\data_v8_padded\y_test', y_test)

np.save(r'D:\irimages\irholography\CNN\data_v8_padded\bandpassed0.9\X_train_complex', X_train)
#np.save(r'D:\irimages\irholography\CNN\data_v8_padded\y_train', y_train)
