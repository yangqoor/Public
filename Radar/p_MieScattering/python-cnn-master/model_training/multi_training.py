# -*- coding: utf-8 -*-
"""
Created on Mon Apr  1 13:32:48 2019

this is a program runs the training process of the CNN multiple times
to get the distribution of the performance related to the CNN structure

Editor:
    Shihao Ran
    STIM Laboratory
"""


#%%
# import necessary packages
import numpy as np

from keras.models import Sequential
from keras.layers import Convolution2D
from keras.layers import MaxPooling2D
from keras.layers import Flatten
from keras.layers import Dense


#%%
# define data size
image_res = 128
num = 20
num_samples = num ** 3
test_size = 0.2
num_test_samples = np.int(num_samples * test_size)
num_training = 30
#%%
# define CNN structure

def create_cnn(option):
    """
    create a 5-layer CNN based on the type
    parameter:
        option: 'complex' or 'intensity'
            if it is a complex CNN, the input images will have two channels
            otherwise just one channel for intensity images
    return:
        regressor: a sequential CNN model
    """
    
    if option == 'complex':
        channel = 2
    else:
        channel = 1
    
    regressor = Sequential()
    
    regressor.add(Convolution2D(128, (3, 3), input_shape = (image_res, image_res, channel), activation = 'relu'))
    
    regressor.add(MaxPooling2D(pool_size = (2, 2)))
    
    regressor.add(Convolution2D(64, (3, 3), activation = 'relu'))
    
    regressor.add(MaxPooling2D(pool_size = (2, 2)))
    
    regressor.add(Convolution2D(64, (3, 3), activation = 'relu'))
    
    regressor.add(MaxPooling2D(pool_size = (2, 2)))
    
    regressor.add(Flatten())
    
    regressor.add(Dense(128, activation = 'relu'))
    
    regressor.add(Dense(3))
    
    regressor.compile('adam', loss = 'mean_squared_error')
    
    return regressor
#%%
# load data set

X_train_complex = np.load(r'D:\irimages\irholography\CNN\data_v10_far_field\split_data\train\cropped_X_train_complex.npy')
X_test_complex = np.load(r'D:\irimages\irholography\CNN\data_v10_far_field\split_data\test\cropped_X_test_complex.npy')

X_train_intensity = np.load(r'D:\irimages\irholography\CNN\data_v10_far_field\split_data\train\cropped_X_train_intensity.npy')
X_test_intensity = np.load(r'D:\irimages\irholography\CNN\data_v10_far_field\split_data\test\cropped_X_test_intensity.npy')

y_train = np.load(r'D:\irimages\irholography\CNN\data_v10_far_field\split_data\train\y_train.npy')

y_test = np.load(r'D:\irimages\irholography\CNN\data_v10_far_field\split_data\test\y_test.npy')

model_save_dir = r'D:\irimages\irholography\CNN\CNN_v12_far_field_a_n\multi_training'

#%%
# scale the attenuation coefficient feature

y_train[:, 1] *= 100

#%%
def multi_training(num_training, option):

    # initialize error list
    rmse = np.zeros((num_training, num_test_samples, 3))
    
    r_rmse = np.zeros((num_training, 3))

    # train the network
    for i in range(num_training):
        # for each loop
        
        # initialize CNN model
        cnn = create_cnn(option)
        
        # load training and testing data
        if option == 'complex':
            X_train = X_train_complex
            X_test = X_test_complex
        else:
            X_train = X_train_intensity
            X_test = X_test_intensity
            
        # train the complex cnn
        print('Training the ' + str(i+1) + 'th '+option+' model!')
        cnn.fit(x=X_train, y=y_train, batch_size=50,
                epochs=25, validation_split=0.2)
        
        # save both models
        cnn.save(model_save_dir + '\\'+ option + '_model' + str(i+1) +'.h5')
        
        # get the predictions
        y_pred = cnn.predict(X_test)
        
        # down scale the predictions
        y_pred[:, 1] /= 100
        
        #evaluation for a and n
        y_off = np.abs(y_pred - y_test)
        y_r_off = np.mean(y_off / [2, 0.05, 2], axis=0) * 100

        rmse[i, ...] = y_off
        r_rmse[i, :] = y_r_off
        
    return rmse, r_rmse

#%%
complex_rmse, complex_r_rmse = multi_training(num_training, 'complex')
intensity_rmse, intensity_r_rmse = multi_training(num_training, 'intensity')

np.save(model_save_dir + '\\complex_multi_rmse1', complex_rmse)
np.save(model_save_dir + '\\intensity_multi_rmse1', intensity_rmse)
np.save(model_save_dir + '\\complex_multi_r_rmse1', complex_r_rmse)
np.save(model_save_dir + '\\intensity_multi_r_rmse1', intensity_r_rmse)
