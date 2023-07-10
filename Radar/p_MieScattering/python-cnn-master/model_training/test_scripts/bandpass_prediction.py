# -*- coding: utf-8 -*-
"""
Created on Tue Feb 26 11:03:29 2019

Used the trained CNN to predict the bandpassed testing data set

Editor:
    Shihao Ran
    STIM Laboratory
"""
# import packages
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
import numpy as np
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
from keras.callbacks import TensorBoard

X_test_bandpass = np.load(r'D:\irimages\irholography\CNN\data_v8_padded\bandpassed0.9\X_test_complex.npy')

regressor = load_model(r'D:\irimages\irholography\CNN\CNN_v10_padded_2\complex\complex.h5')

y_pred_bandpass = regressor.predict(X_test_bandpass)


# initialize a 3D plot
fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')

# specify colors representing each sphere that will be visualizing
for c, z in zip(['c', 'r', 'g', 'b', 'y'], [5, 4, 3, 2, 1]):
    # for each sphere
    # xs is the order number that has been calculated in the forward model
    # equals to the size of B vector
    xs = np.arange(44)
    # randomly select a sphere in the testing data set
    i = np.random.randint(0, np.shape(y_test)[0])
    # pull out that sphere in both testing and prediction data set
    ys_t = y_test[i]
    #uncommend if the predition is based on noised testing data
#    ys_p = y_pred_w_noise[i]
    ys_p = y_pred_bandpass[i]
    
    # plot the B vectors
    ax.plot(xs, ys_t, zs=z, zdir='y', alpha=0.8)
    ax.plot(xs, ys_p, zs=z, zdir='y', alpha=0.8, linestyle='dashed')
    
ax.set_xlabel('Order')
ax.set_ylabel('Sphere Index')
ax.set_zlabel('B Coefficient')
ax.grid(False)

plt.show()

#y_off = y_test - y_pred_w_noise
y_off = y_test - y_pred_bandpass
y_off_sum = np.sum(y_off, axis = 1)

y_test_sum = np.sum(y_test, axis = 1)

y_off_ratio = y_off_sum / y_test_sum

y_off_perc = np.abs(np.average(y_off_ratio) * 100)

print('Relative B Error (Vector Sum): ' + str(y_off_perc) + ' %')

