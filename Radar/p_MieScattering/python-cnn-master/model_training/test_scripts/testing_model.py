# -*- coding: utf-8 -*-
"""
Created on Wed Mar 27 18:43:30 2019

this is a testing script to test the cnn performance with different
test data sets
please modify the test data path before you run this script

Editor:
    Shihao Ran
    STIM Laboratory
"""
# import keras and sklearn packages
from keras.models import Sequential
from keras.layers import Convolution2D
from keras.layers import MaxPooling2D
from keras.layers import Flatten
from keras.layers import Dense
from keras.layers import Dropout
from keras.layers.normalization import BatchNormalization
from sklearn.model_selection import train_test_split
from keras.models import load_model
import numpy as np
import matplotlib.pyplot as plt

#%%
#import data set here
X_test = np.load(r'D:\irimages\irholography\CNN\data_v9_far_field\split_data\test\cropped_X_test_intensity.npy')
y_test = np.load(r'D:\irimages\irholography\CNN\data_v9_far_field\split_data\test\y_test.npy')

#%%
# load your model here
regressor = load_model(r'D:\irimages\irholography\CNN\CNN_v11_far_field_a_n\intensity\up_scaled_intensity.h5')

#%%
# get the prediction from the network
y_pred = regressor.predict(X_test)

# down scale it
y_pred[:, 1] /= 100

#%%
# plot your predition here
plt.figure()
plt.subplot(3,1,1)
plt.plot(y_test[::10,0], label = 'Ground Truth')
plt.plot(y_pred[::10,0], linestyle='dashed', label = 'Prediction')
plt.legend()
plt.title('Real Part')

plt.subplot(3,1,2)
plt.plot(y_test[::10,1], label = 'Ground Truth')
plt.plot(y_pred[::10,1], linestyle='dashed', label = 'Prediction')
plt.legend()
plt.title('Imaginary Part')

plt.subplot(3,1,3)
plt.plot(y_test[::10,2], label = 'Ground Truth')
plt.plot(y_pred[::10,2], linestyle='dashed', label = 'Prediction')
plt.legend()
plt.title('Radius')