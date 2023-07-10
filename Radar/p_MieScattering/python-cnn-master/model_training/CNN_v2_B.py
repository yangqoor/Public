# -*- coding: utf-8 -*-
"""
Created on Thu Jan 31 16:13:03 2019

CNN for predict the B vector from the simulated images
more sophasticated model with five convolutional layers with max pooling
two fully connected layers with more nuerons

Editor:
    Shihao Ran
    STIM Laboratory
"""

# import numpy and matplotlib
import numpy as np

# import keras and sklearn packages
from keras.models import Sequential
from keras.layers import Convolution2D
from keras.layers import MaxPooling2D
from keras.layers import Flatten
from keras.layers import Dense
from keras.callbacks import TensorBoard

# specify the image resolution and the number of images in the data set
image_res = 128
num_total_sample = 8000
channels = 1

# initialize the network
regressor = Sequential()

# add the first convolutional layer with the input shape identical to the image data
regressor.add(Convolution2D(128, (3, 3), input_shape = (image_res, image_res, channels), activation = 'relu'))
# follow with a max pooling layer to decrease the feature map
regressor.add(MaxPooling2D(pool_size = (2, 2)))

# repeat adding convolutional layers and max pooling layers to make the network refine the features
regressor.add(Convolution2D(64, (3, 3), activation = 'relu'))
regressor.add(MaxPooling2D(pool_size = (2, 2)))

regressor.add(Convolution2D(64, (3, 3), activation = 'relu'))
regressor.add(MaxPooling2D(pool_size = (2, 2)))

regressor.add(Convolution2D(64, (3, 3), activation = 'relu'))
regressor.add(MaxPooling2D(pool_size = (2, 2)))

regressor.add(Convolution2D(32, (3, 3), activation = 'relu'))
regressor.add(MaxPooling2D(pool_size = (2, 2)))

# add a flatten function to convert the feature map to a feature vector
regressor.add(Flatten())

# add two fully connected layers to output the results
regressor.add(Dense(518, activation = 'relu'))
regressor.add(Dense(44))

# compile the network with the specified loss function
regressor.compile('adam', loss = 'mean_squared_error')
# load data set
data_dir = r'D:\irimages\irholography\CNN\data_v8_padded\cropped'
tensorboard = TensorBoard(log_dir= data_dir + '\logs')
X_train = np.load(data_dir + '\X_train_intensity.npy')
X_test = np.load(data_dir + '\X_test_intensity.npy')

y_train = np.load(r'D:\irimages\irholography\CNN\data_v8_padded\y_train.npy')
y_test = np.load(r'D:\irimages\irholography\CNN\data_v8_padded\y_test.npy')

# train the network with the traning data set with a 0.2 validation ratio
regressor.fit(x = X_train, y = y_train, batch_size = 100,
              epochs = 30,
              validation_split = 0.2)
              #verbose=3, callbacks=[tensorboard])

# predict the results from the testing set
y_pred = regressor.predict(X_test)

regressor.save(r'D:\irimages\irholography\CNN\CNN_v10_padded_2\intensity\intensity.h5')