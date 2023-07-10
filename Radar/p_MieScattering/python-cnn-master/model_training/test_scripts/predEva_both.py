# -*- coding: utf-8 -*-
"""
Created on Sat Jan 26 16:29:20 2019

accuracy evaluation of the prediction VS. the test data set
print out the percentage of the relative error sum along the B vector (second case)
or the relative average error for n and a (first case)

Editor:
    Shihao Ran
    STIM Laboratory
"""
import numpy as np


#evaluation for a and n
y_off_complex = np.abs(y_pred_complex - y_test)

y_r_off_complex = np.mean(y_off_complex / y_test, axis=0) * 100

y_off_intensity = np.abs(y_pred_intensity - y_test)
y_r_off_intensity = np.mean(y_off_intensity / y_test, axis=0) * 100

print('Complex Model:')
print('Refractive Index (Real) Error: ' + str(y_r_off_complex[0]) + ' %')
print('Refractive Index (Imaginary) Error: ' + str(y_r_off_complex[1]) + ' %')
print('Redius of the Sphere Error: ' + str(y_r_off_complex[2]) + ' %')

print('Intensity Model')
print('Refractive Index (Real) Error: ' + str(y_r_off_intensity[0]) + ' %')
print('Refractive Index (Imaginary) Error: ' + str(y_r_off_intensity[1]) + ' %')
print('Redius of the Sphere Error: ' + str(y_r_off_intensity[2]) + ' %')


#evaluation for B

#y_off = y_test - y_pred_w_noise
#y_off = y_test - y_pred
#y_off_sum = np.sum(y_off, axis = 1)
#
#y_test_sum = np.sum(y_test, axis = 1)
#
#y_off_ratio = y_off_sum / y_test_sum
#
#y_off_perc = np.abs(np.average(y_off_ratio) * 100)
#
#print('Relative B Error (Vector Sum): ' + str(y_off_perc) + ' %')