# -*- coding: utf-8 -*-
"""
Created on Thu Jan 24 13:26:39 2019

@author: shihao

Heavy version of CNN trained in large dataset
This program is for prediction of a and real n, imag n
Save net work function is provided in the comments
Prediction visualization is provided in the bottom as well

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

image_res = 128
num_total_sample = 15625

regressor = Sequential()

regressor.add(Convolution2D(128, (3, 3), input_shape = (image_res, image_res, 2), activation = 'relu'))

regressor.add(MaxPooling2D(pool_size = (2, 2)))

regressor.add(Convolution2D(64, (3, 3), activation = 'relu'))

regressor.add(MaxPooling2D(pool_size = (2, 2)))

regressor.add(Convolution2D(64, (3, 3), activation = 'relu'))

regressor.add(MaxPooling2D(pool_size = (2, 2)))

regressor.add(Convolution2D(64, (3, 3), activation = 'relu'))

regressor.add(MaxPooling2D(pool_size = (2, 2)))

regressor.add(Convolution2D(32, (3, 3), activation = 'relu'))

regressor.add(MaxPooling2D(pool_size = (2, 2)))

regressor.add(Flatten())

regressor.add(Dense(256, activation = 'relu'))

regressor.add(Dense(3))

regressor.compile('adam', loss = 'mean_squared_error')

X_data = np.load(r'D:\irimages\irholography\CNN\data_v2\im_data.bin.npy')
X_data = np.reshape(X_data, (image_res, image_res, 2, num_total_sample))
X_data = np.swapaxes(X_data, 0, -1)
X_data = np.swapaxes(X_data, -2, -1)

y_data = np.load(r'D:\irimages\irholography\CNN\data_v2\lable_data.bin.npy')
y_data = np.reshape(y_data, (3, num_total_sample))
y_data = np.swapaxes(y_data, 0, 1)

X_train, X_test, y_train, y_test = train_test_split(X_data, y_data, test_size = 0.2)

regressor.fit(x = X_train, y = y_train, batch_size = 50,
              epochs = 30,
              validation_split = 0.2)

y_pred = regressor.predict(X_test)

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