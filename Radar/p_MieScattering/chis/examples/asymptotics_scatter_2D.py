# -*- coding: utf-8 -*-
"""
Created on Sat Mar  9 14:02:59 2019

Calculate the scattering field of a sphere

The position of the visualization plane is at the plane where right 
across the center of the sphere at the origin

To avoid back progation, the simulation is done by,
First,  create a far field model in the Fourier domain, which can be done by:
    
    1. Replace the Hankel function of the first kind by its asymptotic form
    2. Transform Legendre polynomial into Fourier Domain

Then, apply an inverse Fourier transform to the far field model to get the
near field scattering field

Editor:
    Shihao Ran
    STIM Laboratory
"""

import numpy as np
import math
import matplotlib.pyplot as plt
import chis.MieScattering as ms

#%%
# set parameters
fov = 16                    # field of view
res = 128                   # resolution
a = 1                       # radius of the spere
lambDa = 1                  # wavelength
n = 1.5 + 1j*0.01            # refractive index
k = 2 * math.pi / lambDa    # wavenumber
padding = 1                 # padding

simRes, simFov = ms.pad(res, fov, padding)
working_dis = 10000 * (2 * padding + 1)           # working distance
scale_factor = working_dis * 2 * math.pi * res/fov            # scale factor of the intensity
NA_in = 0.3
NA_out = 0.6

ps = [0, 0, 0]              # position of the sphere
k_dir = [0, 0, -1]          # propagation direction of the plane wave
E = [1, 0, 0]               # electric field vector
E0 = 1
#%%
# get far field
E_far = ms.far_field(simRes, simFov, working_dis, a, n, lambDa, scale_factor)

# get near field
E_near = ms.far2near(E_far) + E0

# get bandpass filter
bpf = ms.bandpass_filter(simRes, simFov, NA_in, NA_out)

# get bandpassed image
E_bp = ms.apply_filter(simRes, simFov, E_near, bpf)

# crop the image
E_crop = ms.crop_field(res, E_bp)

# Fourier axis
fx_axis = np.fft.fftshift(np.fft.fftfreq(simRes, simFov/simRes))

#%%
plt.figure()
plt.set_cmap('RdYlBu')
plt.subplot(121)
plt.imshow(np.real(E_bp), extent = [-simFov/2, simFov/2, -simFov/2, simFov/2])
plt.title('Bandpass Image, Real')
plt.colorbar()

plt.subplot(122)
plt.imshow(np.real(E_crop), extent=[-fov/2, fov/2, -fov/2, fov/2])
plt.title('Cropped Image, Real')
plt.colorbar()

