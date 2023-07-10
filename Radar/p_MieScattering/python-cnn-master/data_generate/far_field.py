# -*- coding: utf-8 -*-
"""
Created on Fri Mar 15 10:05:15 2019

this program generates the training data set for inversion Mie problem using CNN
the scattering matrix hlkr_asymptotic * plcos * alpha is precomputed
the evaluated plane is at the origin by doing inverse Fourier Transform of the
Far Field simulation of the sphere
all images are padded so they can be applied with different band pass filters later on

Editor:
    Shihao Ran
    STIM Laboratory
"""

import numpy as np
import sys
import chis.MieScattering as ms

#%%
def cal_feature_space(a_min, a_max,
                      nr_min, nr_max,
                      ni_min, ni_max, num):
# set the range of the features:
    # a_max: the maximal of the radius of the spheres
    # a_min: the minimal of the radius of the spheres
    # nr_max: the maximal of the refractive indices
    # nr_min: the minimal of the refractive indices
    # ni_max: the maximal of the attenuation coefficients
    # ni_min: the minimal of the attenuation coefficients
    # num: dimention of each feature
    a = np.linspace(a_min, a_max, num)
    nr = np.linspace(nr_min, nr_max, num)
    ni = np.linspace(ni_min, ni_max, num)
    
    return a, nr, ni

#%%
# set the size and resolution of both planes
fov = 16                    # field of view
res = 128                   # resolution
lambDa = 1                  # wavelength
k = 2 * math.pi / lambDa    # wavenumber
padding = 3                 # padding
# simulation resolution
# in order to do fft and ifft, expand the image use padding
simRes, simFov = ms.pad(res, fov, padding)
ps = [0, 0, 0]              # position of the sphere
k_dir = [0, 0, -1]          # propagation direction of the plane wave
E = [1, 0, 0]               # electric field vector
working_dis = ms.get_working_dis(padding)
# scale factor of the intensity
scale_factor = ms.get_scale_factor(simRes, simFov, working_dis)
# define feature space
num = 20
num_samples = num ** 3

a_min = 1.0
a_max = 2.0

nr_min = 1.1
nr_max = 2.0

ni_min = 0.01
ni_max = 0.05

a, nr, ni = cal_feature_space(a_min, a_max,
                              nr_min, nr_max,
                              ni_min, ni_max, num)

#get the maximal order of the integration
l = ms.get_order(a_max, lambDa)

# pre-calculate the scatter matrix and the incident field
scatter = ms.scatter_matrix(simRes, simFov, working_dis, a_max, lambDa,
                            k_dir)

# allocate space for data set
sphere_data = np.zeros((3, num, num, num))
B_data_real = np.zeros((l.shape[0], num, num, num))
B_data_imag = np.zeros((l.shape[0], num, num, num))

#%%
# generate data sets
# initialize a progress counter
cnt = 0

# the data set is too big to fit it as a whole in the memory
# therefore split them into sub sets for different sphere sizes
for h in range(num):
    # for each sphere size
    im_data = np.zeros((simRes, simRes, 2, num, num))
    # generate file name
    im_dir = r'D:\irimages\irholography\CNN\data_v10_far_field\im_data' + '%3.3d'% (h)
    
    for i in range(num):
        for j in range(num):
            # for each specific sphere
            n0 = nr[i] + ni[j] * 1j
            a0 = a[h]

            # calculate B vector
            B = ms.coeff_b(l, k, n0, a0)
            
            E_scatter_fft = np.sum(scatter * B, axis = 2) * scale_factor
            
            # shift the Forier transform of the scatttering field for visualization
            E_scatter_fftshift = np.fft.fftshift(E_scatter_fft)
            
            # convert back to spatial domain
            E_scatter_b4_shift = np.fft.ifft2(E_scatter_fft)
            
            # shift the scattering field in the spacial domain for visualization
            E_scatter = np.fft.fftshift(E_scatter_b4_shift)
            
            Et = E_scatter + 1
            
            # save real and imaginary part of the field
            im_data[:, :, 0, i, j] = np.real(Et)
            im_data[:, :, 1, i, j] = np.imag(Et)
            
            # save label
            sphere_data[:, i, j, h] = [nr[i], ni[j], a[h]]
            
            #save B vector
            B_data_real[:np.size(B), i, j, h] = np.real(B)
            B_data_imag[:np.size(B), i, j, h] = np.imag(B)
            
            # print progress
            cnt += 1
            sys.stdout.write('\r' + str(cnt / (num_samples) * 100)  + ' %')
            sys.stdout.flush() # important

    # save the data
    np.save(im_dir, im_data)
    
np.save(r'D:\irimages\irholography\CNN\data_v10_far_field\lable_data', sphere_data)
np.save(r'D:\irimages\irholography\CNN\data_v10_far_field\B_data_real', B_data_real)
np.save(r'D:\irimages\irholography\CNN\data_v10_far_field\B_data_imag', B_data_imag)