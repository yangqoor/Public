# -*- coding: utf-8 -*-
"""
Created on Mon Feb 25 09:27:17 2019

this program generates the training data set for inversion Mie problem using CNN
the scatter matrix is pre computed
the evaluated plane is at the origin by back propagation of the plane outside of the sphere
all images are padded so they can be applied with different band pass filters later on

Editor:
    Shihao Ran
    STIM Laboratory
"""

# numpy for most of the data saving and cumputation
import numpy as np
# import sys for printing progress
import sys
import chis.MieScattering as ms

# specify parameters for the forward model
# propagation direction vector k
k_dir = [0, 0, -1]
# position of the sphere
ps = [0, 0, 0]
# resolution of the cropped image
res = 128
# in and out numerical aperture of the bandpass optics
NA_in = 0
NA_out = 0
# wave length
lambDa = 1
# wavenumber
k = 2*np.pi / lambDa
# padding size
padding = 2
# field of view
fov = 16
simRes, simFov = ms.pad(res, fov, padding)
# set ranges of the features of the data set
# refractive index
n_r_min = 1.1
n_r_max = 2.0
# attenuation coefficient
n_i_min = 0.01
n_i_max = 0.05
# sphere radius
a_min = 5
a_max = 10

# the z position of the visiulization plane
z_max = a_max
# the maximal order
l = ms.get_order(a_max, lambDa)

# set the size of the features
nb_nr = 20
nb_ni = 20
nb_a = 20

# initialize features
nr = np.linspace(n_r_min, n_r_max, nb_nr)
ni = np.linspace(n_i_min, n_i_max, nb_ni)
a = np.linspace(a_min, a_max, nb_a)

# allocate space for data set
sphere_data = np.zeros((3, nb_nr, nb_ni, nb_a))
B_data_real = np.zeros((len(l), nb_nr, nb_ni, nb_a))
B_data_imag = np.zeros((len(l), nb_nr, nb_ni, nb_a))
 
scatter = ms.scatter_matrix(simRes, simFov, z_max, a_max, lambDa, k_dir, option='near')
    
# pre compute Ef, incident field at z-max
Ef = np.ones((simRes, simRes), dtype = np.complex128)
Ef *= np.exp(z_max * 1j)

# initialize progress indicator
cnt = 0

# the data set is too big to fit it as a whole in the memory
# therefore split them into sub sets for different sphere sizes
for h in range(nb_a):
    # for each sphere size
    im_data = np.zeros((simRes, simRes, 2, nb_nr, nb_ni))
    # generate file name
    im_dir = r'D:\irimages\irholography\CNN\data_v8_padded\im_data' + '%3.3d'% (h)
    
    for i in range(nb_nr):
        for j in range(nb_ni):
            # for each specific sphere
            n0 = nr[i] + ni[j] * 1j
            a0 = a[h]

            # calculate B vector
            B = ms.coeff_b(l, k, n0, a0)
            
            Es = np.sum(scatter * B, axis = 2)          
            
            Et = Es + Ef
            
            Eprop = ms.propagate_2D(simRes, simFov, Et, -z_max)
            
            # save real and imaginary part of the field
            im_data[:, :, 0, i, j] = np.real(Eprop)
            im_data[:, :, 1, i, j] = np.imag(Eprop)
            
            # save label
            sphere_data[:, i, j, h] = [nr[i], ni[j], a[h]]
            
            #save B vector
            B_data_real[:np.size(B), i, j, h] = np.real(B)
            B_data_imag[:np.size(B), i, j, h] = np.imag(B)
            
            # print progress
            cnt += 1
            sys.stdout.write('\r' + str(cnt / (nb_a*nb_ni*nb_nr) * 100)  + ' %')
            sys.stdout.flush() # important

    # save the data
    np.save(im_dir, im_data)
    
np.save(r'D:\irimages\irholography\CNN\data_v8_padded\lable_data', sphere_data)
np.save(r'D:\irimages\irholography\CNN\data_v8_padded\B_data_real', B_data_real)
np.save(r'D:\irimages\irholography\CNN\data_v8_padded\B_data_imag', B_data_imag)