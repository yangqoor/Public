# -*- coding: utf-8 -*-
"""
Created on Mon May  6 18:22:35 2019

3D visualization of the predition results VS. the testing ground truth
Sphere index is randomly selected in the data set

Editor:
    Shihao Ran
    STIM Laboratory
"""

# import packages
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
import numpy as np

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
    ys_p = y_pred[i]
    
    # plot the B vectors
    ax.plot(xs, ys_t, zs=z, zdir='y', alpha=0.8)
    ax.plot(xs, ys_p, zs=z, zdir='y', alpha=0.8, linestyle='dashed')
    
ax.set_xlabel('Order')
ax.set_ylabel('Sphere Index')
ax.set_zlabel('B Coefficient')
ax.grid(False)

plt.show()