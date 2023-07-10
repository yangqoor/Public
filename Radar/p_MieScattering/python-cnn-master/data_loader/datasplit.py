# -*- coding: utf-8 -*-
"""
Created on Fri Mar 15 13:34:06 2019

Split the training and testing data set from the 20 big data sets:
    For each data set:
        1. use train_test_split to get the indices
        2. crop the training images
        3. save the traning images and keep the testing images
        4. split the label set

Editor:
    Shihao Ran
    STIM Laboratory
"""

import numpy as np
from sklearn.model_selection import train_test_split
import sys

# specify the data directory
data_dir = r'D:\irimages\irholography\CNN\data_v10_far_field\raw_data'
# specify the split data directory
save_dir = r'C:\copyofdata\split_data'

# load the labels
label = np.load(data_dir + '\lable_data.npy')

# number of individual data sets
num = 20
res = 128
padding = 3
simRes = res * (2 * padding + 1)
cnt = 0
# for each data set
for h in range(num):
    
    # print progress
    cnt += 1
    sys.stdout.write('\r Splitting ' + str(cnt) + 'th data set!\n')
    sys.stdout.flush() # important
    
    # get the corresponding label set
    label_h = label[..., h]
    
    # reshape the label set
    label_h = np.reshape(label_h, (3, num ** 2))
    label_h = np.swapaxes(label_h, 0, 1)
    
    # specify the direction of this image data set
    im_dir = data_dir + '\im_data' + '%3.3d'% (h) + '.npy'
    
    # load it into memory
    im_data = np.load(im_dir)
    
    # reshape it
    im_data = np.reshape(im_data, (simRes, simRes, 2, num ** 2))
    im_data = np.swapaxes(im_data, 0, -1)
    im_data = np.swapaxes(im_data, -2, -1)

    # split the training and testing set
    X_train, X_test, y_train, y_test = train_test_split(im_data,
                                                        label_h,
                                                        test_size = 0.2)
    
    # save the training and testing set individually
    X_train_dir = save_dir + r'\train\X_train_%3.3d'% (h)
    y_train_dir = save_dir + r'\train\y_train_%3.3d'% (h)
    X_test_dir = save_dir + r'\test\X_test_%3.3d'% (h)
    y_test_dir = save_dir + r'\test\y_test_%3.3d'% (h)
    np.save(X_train_dir, X_train)
    np.save(y_train_dir, y_train)
    np.save(X_test_dir, X_test)
    np.save(y_test_dir, y_test)
        