# -*- coding: utf-8 -*-
"""
generate dataset for CNN training using traditional Mie scattering class

ATTENTION: traditional Mie scattering is quite slow

Editor:
    Shihao Ran
    STIM Laboratory
"""

# numpy for most of the data saving and cumputation
import numpy as np
import sys
from chis import traditional_mie
import chis.MieScattering as ms
    

k = [0, 0, -1]
res = 128
numSample = 1
NA_in = 0
NA_out = 0
numFrames = 70
option = 'Horizontal'
parentDir = r'D:\irimages\irholography\CNN\data_v2'

k_j = k
padding = 0
fov = 12

n_r_min = 1.1
n_r_max = 2.0

n_i_min = 0.01
n_i_max = 0.05

a_min = 5
a_max = 10

nb_nr = 25
nb_ni = 25
nb_a = 25

nr = np.linspace(n_r_min, n_r_max, nb_nr)
ni = np.linspace(n_i_min, n_i_max, nb_ni)
a = np.linspace(a_min, a_max, nb_a)

l = ms.get_order(a_max)

im_data = np.zeros((res, res, 2, nb_nr, nb_ni, nb_a))
sphere_data = np.zeros((3, nb_nr, nb_ni, nb_a))
B_data_real = np.zeros((len(l), nb_nr, nb_ni, nb_a))
B_data_imag = np.zeros((len(l), nb_nr, nb_ni, nb_a))

cnt = 0
for i in range(nb_nr):
    for j in range(nb_ni):
        for h in range(nb_a):
            
            n0 = nr[i] + ni[j] * 1j
            a0 = a[h]
            #position of the visualization plane, along z axis
            pp = a0
            ps0 = [0, 0, 0]
            Et_0, B, Es, r = traditional_mie.getTotalField(k, k_j, n0, res, a0, ps0, pp, padding, fov, numSample, NA_in, NA_out, option)
            
            im_data[:, :, 0, i, j, h] = np.real(Es)
            im_data[:, :, 1, i, j, h] = np.imag(Es)
            
            sphere_data[:, i, j, h] = [nr[i], ni[j], a[h]]
            
            B_data_real[:np.size(B), i, j, h] = np.real(B)
            B_data_imag[:np.size(B), i, j, h] = np.imag(B)
            
            cnt += 1
            
            sys.stdout.write('\r' + str(round(cnt / 15625 * 100, 2))  + ' %')
            sys.stdout.flush() # important

#np.save(r'D:\irimages\irholography\CNN\data_v5_B\im_data.bin', im_data)
#np.save(r'D:\irimages\irholography\CNN\data_v5_B\lable_data.bin', sphere_data)
#np.save(r'D:\irimages\irholography\CNN\data_v5_B\B_data_real.bin', B_data_real)
#np.save(r'D:\irimages\irholography\CNN\data_v5_B\B_data_imag.bin', B_data_imag)