# -*- coding: utf-8 -*-
"""
Created on Mon May  6 17:49:10 2019

Editor:
    Shihao Ran
    STIM Laboratory
"""

# -*- coding: utf-8 -*-
"""
Created on Tue Apr 30 15:40:48 2019

this script generates dataset with bandpass filtering
unlike data_generate_bandpass.py which generates bandpassed testing set only
this script regenerates the whole dataset with bandpass as the fourth feature
similar to data_generate_noisy_line.py


Editor:
    Shihao Ran
    STIM Laboratory
"""

# import necessary packages
import numpy as np
import scipy as sp
import scipy.special
import math
import matplotlib.pyplot as plt
import sys
import chis.MieScattering as ms
#%%
# Calculate the sphere scattering coefficients
def coeff_b(l, k, n, a):
    jka = sp.special.spherical_jn(l, k * a)
    jka_p = sp.special.spherical_jn(l, k * a, derivative=True)
    jkna = sp.special.spherical_jn(l, k * n * a)
    jkna_p = sp.special.spherical_jn(l, k * n * a, derivative=True)

    yka = sp.special.spherical_yn(l, k * a)
    yka_p = sp.special.spherical_yn(l, k * a, derivative=True)

    hka = jka + yka * 1j
    hka_p = jka_p + yka_p * 1j

    bi = jka * jkna_p * n
    ci = jkna * jka_p
    di = jkna * hka_p
    ei = hka * jkna_p * n

    # return ai * (bi - ci) / (di - ei)
    return (bi - ci) / (di - ei)

#%%
class planewave():
    #implement all features of a plane wave
    #   k, E, frequency (or wavelength in a vacuum)--l
    #   try to enforce that E and k have to be orthogonal

    #initialization function that sets these parameters when a plane wave is created
    def __init__ (self, k, E):

        #self.phi = phi
        self.k = k/np.linalg.norm(k)
        self.E = E

        #force E and k to be orthogonal
        if ( np.linalg.norm(k) > 1e-15 and np.linalg.norm(E) >1e-15):
            s = np.cross(k, E)              #compute an orthogonal side vector
            s = s / np.linalg.norm(s)       #normalize it
            Edir = np.cross(s, k)              #compute new E vector which is orthogonal
            self.k = k
            self.E = Edir / np.linalg.norm(Edir) * np.linalg.norm(E)

    def __str__(self):
        return str(self.k) + "\n" + str(self.E)     #for verify field vectors use print command

    #function that renders the plane wave given a set of coordinates
    def evaluate(self, X, Y, Z):
        k_dot_r = self.k[0] * X + self.k[1] * Y + self.k[2] * Z     #phase term k*r
        ex = np.exp(1j * k_dot_r)       #E field equation  = E0 * exp (i * (k * r)) here we simply set amplitude as 1
        Ef = self.E.reshape((3, 1, 1)) * ex
        return Ef

def idhf(simFov, simRes, y):
    """
    Inverse Discrete Hankel Transform of an 1D array
    param:
        simFov
        simRes
        y
    return:
        F
        F_x
    """

    X = int(simFov/2)
    n_s = int(simRes/2)

    # order of the bessel function
    order = 0
    # root of the bessel function
    jv_root = sp.special.jn_zeros(order, n_s)
    jv_M = jv_root[-1]
    jv_m = jv_root[:-1]
#    jv_mX = jv_m/X

#    F_term = np.interp(jv_mX, x, y)
    F_term = y[1:]
    # inverse DHT
    F = np.zeros(n_s, dtype=np.complex128)
    jv_k = jv_root[None,...]

    prefix = 2/(X**2)

    Jjj = jv_m[...,None]*jv_k/jv_M
    numerator = sp.special.jv(order, Jjj)
    denominator = sp.special.jv(order+1, jv_m[...,None])**2

    summation = np.sum(numerator / denominator * F_term[:-1][...,None], axis=0)

    F = prefix * summation

    F_x = jv_root*X/jv_M

    return F, F_x

#%%
def cal_line_scatter_matrix(l, k, k_dir, res, fov, working_dis, scale_factor):
# calculate the scattering field through far field simulation

    # construct the evaluate plane

    # simulation resolution
    # in order to do fft and ifft, expand the image use padding
    simRes = res*(2*padding + 1)
    simFov = fov*(2*padding + 1)
    center = int(simRes/2)
    # halfgrid is the size of a half grid
    halfgrid = np.ceil(simFov/2)
    # range of x, y
    gx = np.linspace(-halfgrid, +halfgrid, simRes)[:center+1]
    gy = gx[0]
    # make it a plane at z = 0 (plus the working distance) on the Z axis
    z = working_dis

    # calculate the distance matrix
    rMag = np.sqrt(gx**2+gy**2+z**2)
    kMag = 2 * np.pi / lambDa
    # calculate k dot r
    kr = kMag * rMag

    # calculate the asymptotic form of hankel funtions
    hlkr_asym = np.zeros((kr.shape[0], l.shape[0]), dtype = np.complex128)
    for i in l:
        hlkr_asym[..., i] = np.exp(1j*(kr-i*math.pi/2))/(1j * kr)

    # calculate the legendre polynomial
    # get the frequency components
    fx = np.fft.fftfreq(simRes, simFov/simRes)[:center+1]
    fy = fx[0]

    # calculate the sum of kx ky components so we can calculate
    # cos_theta in the Fourier Domain later
    kxky = fx ** 2 + fy ** 2
    # create a mask where the sum of kx^2 + ky^2 is
    # bigger than 1 (where kz is not defined)
    mask = kxky > 1
    # mask out the sum
    kxky[mask] = 0
    # calculate cos theta in Fourier domain
    cos_theta = np.sqrt(1 - kxky)
    cos_theta[mask] = 0
    # calculate the Legendre Polynomial term
    pl_cos_theta = sp.special.eval_legendre(l, cos_theta[..., None])
    # mask out the light that is propagating outside of the objective
    pl_cos_theta[mask] = 0

    # calculate the prefix alpha term
    alpha =(2*l + 1) * 1j ** l

    # calculate the matrix besides B vector
    scatter_matrix = hlkr_asym * pl_cos_theta * alpha

    return scatter_matrix

def BPF(halfgrid, simRes, NA_in, NA_out):
    #create a bandpass filter
        #change coordinates into frequency domain

    df = 1/(halfgrid*2)

    iv, iu = np.meshgrid(np.arange(0, simRes, 1), np.arange(0, simRes, 1))

    u = np.zeros(iu.shape)
    v = np.zeros(iv.shape)

    #initialize the filter as All Pass
    BPF = np.ones(iv.shape)

    idex1, idex2 = np.where(iu <= simRes/2)
    u[idex1, idex2] = iu[idex1, idex2]

    idex1, idex2 = np.where(iu > simRes/2)
    u[idex1, idex2] = iu[idex1, idex2] - simRes +1

    u *= df

    idex1, idex2 = np.where(iv <= simRes/2)
    v[idex1, idex2] = iv[idex1, idex2]

    idex1, idex2 = np.where(iv > simRes/2)
    v[idex1, idex2] = iv[idex1, idex2] - simRes +1

    v *= df

    magf = np.sqrt(u ** 2 + v ** 2)

    #block lower frequency
    idex1, idex2 = np.where(magf < NA_in / lambDa)
    BPF[idex1, idex2] = 0
    #block higher frequency
    idex1, idex2 = np.where(magf > NA_out / lambDa)
    BPF[idex1, idex2] = 0

    return BPF

def imgAtDetec(Etot, bpf):
    #2D fft to the total field
    Et_d = np.fft.fft2(Etot)
#    Ef_d = np.fft.fft2(Ef)

    #apply bandpass filter to the fourier domain
    Et_d *= bpf
#    Ef_d *= bpf

    #invert FFT back to spatial domain
    Et_bpf = np.fft.ifft2(Et_d)
#    Ef_bpf = np.fft.ifft2(Ef_d)

    #initialize cropping
    cropsize = res
    startIdx = int(np.fix(simRes /2) - np.floor(cropsize/2))
    endIdx = int(startIdx + cropsize - 1)

    D_Et = np.zeros((cropsize, cropsize), dtype = np.complex128)
    D_Et = Et_bpf[startIdx:endIdx+1, startIdx:endIdx+1]
#    D_Ef = np.zeros((cropsize, cropsize), dtype = np.complex128)
#    D_Ef = Ef_bpf[startIdx:endIdx, startIdx:endIdx]

    return D_Et

#%%
def cal_feature_space(a_min, a_max,
                      nr_min, nr_max,
                      ni_min, ni_max,
                      noise_pc_min, noise_pc_max,
                      num, num_bp):
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
    noise_pc = np.linspace(noise_pc_min, noise_pc_max, num_bp)

    return a, nr, ni, noise_pc

#%%
def get_order(a, lambDa):
    #calculate the order of the integration based on size of the sphere and the
    #wavelength
    # a: radius of the sphere
    # lambDa: wavelength of the incident field

    l_max = math.ceil(2*np.pi * a / lambDa + 4 * (2 * np.pi * a / lambDa) ** (1/3) + 2)
    l = np.arange(0, l_max+1, 1)

    return l

def perc_noise(S, perc):
    # S is the input signal
    # amp is the amplitude of the noise or the standard deviation of the Gaussian noise
    
    amp = perc*0.25
    # Gaussian noise in frequency domain
    eta_r = np.random.normal(0, amp, S.shape)
    eta_i = np.random.normal(0, amp, S.shape)
    
    S_noise = S + eta_r + 1j*eta_i
   
    return S_noise

def get_bpf(simFov, simRes, NA_in, NA_out):
    """
    get the bandpass filter based on the in and out Numerical Aperture
    basically, a bandpass filter is just a circular mask
    with inner and outer diamater specified by the in and out NA
    
    params:
        simFov: simulated field of view
        simRes: simulated resolution
        NA_in: center obscuration of the objective
        NA_out: outer back aperture of the objective
    
    return:
        bpf_test: the bandpass filter
    """
    
    # get the axis in the fourier domain
    f_x = np.fft.fftfreq(simRes, simFov/simRes)
    
    # create a meshgrid
    fx, fy = np.meshgrid(f_x, f_x)
    
    # compute the map
    fxfy = np.sqrt(fx ** 2 + fy ** 2)
    
    # initialize the filter
    bpf_test = np.zeros((simRes, simRes))
    
    # draw the filter
    mask_out = fxfy <= NA_out
    mask_in = fxfy >= NA_in
    
    mask = np.logical_and(mask_out, mask_in)
    
    bpf_test[mask] = 1
    
    return bpf_test

#%%
# set the size and resolution of both planes
fov = 32                    # field of view
res = 256                   # resolution

lambDa = 1                  # wavelength

k = 2 * math.pi / lambDa    # wavenumber
padding = 2                 # padding
working_dis = 10000 * (2 * padding + 1)          # working distance

# scale factor of the intensity
scale_factor = working_dis * 2 * math.pi * res/fov

# simulation resolution
# in order to do fft and ifft, expand the image use padding
simRes = res*(2*padding + 1)
simFov = fov*(2*padding + 1)

line_size = int(simRes/2)

ps = [0, 0, 0]              # position of the sphere
k_dir = [0, 0, -1]          # propagation direction of the plane wave
E = [1, 0, 0]               # electric field vector

# define feature space

num = 10
num_bp = 100
num_samples = num ** 3 * num_bp

a_min = 1.1
a_max = 2.0

nr_min = 1.1
nr_max = 2.0

ni_min = 0.01
ni_max = 0.05

bp_min = 0.02
bp_max = 1.01

a, nr, ni, bp = cal_feature_space(a_min, a_max,
                                  nr_min, nr_max,
                                  ni_min, ni_max,
                                  bp_min, bp_max,
                                  num, num_bp)

#get the maximal order of the integration
l = get_order(a_max, lambDa)

# pre-calculate the scatter matrix and the incident field
scatter_matrix = cal_line_scatter_matrix(l, k, k_dir, res, fov,
                                         working_dis, scale_factor)

# allocate space for data set
sphere_data = np.zeros((3, num, num, num, num_bp))
im_data = np.zeros((line_size, 2, num, num, num, num_bp))
im_dir = r'D:\irimages\irholography\CNN\data_v12_far_line\more_bandpass_HD\im_data'

# get all the bandpass filters
bpfs = []
for b in range(num_bp):
                
    bp0 = bp[b]

    bpf = get_bpf(simFov, simRes, 0, bp0)
    bpf_line = bpf[0, :int(simRes/2)+1]
    
    bpf_line0 = ms.bandpass_filter(simRes, simFov, 0, bp0, dimention=1)
    
    bpfs.append(bpf_line)

cnt = 0
for h in range(num):
    for i in range(num):
        for j in range(num):
            
            a0 = a[h]
            n0 = nr[i] + 1j*ni[j]
            
            B = coeff_b(l, k, n0, a0)

            # integrate through all the orders to get the farfield in the Fourier Domain
            E_scatter_fft = np.sum(scatter_matrix * B, axis = -1) * scale_factor
            
            for b in range(num_bp):
        
                # convert back to spatial domain
                E_near_line, E_near_x = idhf(simFov, simRes, E_scatter_fft*bpfs[b])
    
                E_near_line = (E_near_line-np.mean(E_near_line))/np.std(E_near_line)
    
                # shift the scattering field in the spacial domain for visualization
                Et = E_near_line + 1
    
                im_data[:, 0, i, j, h, b] = np.real(Et)
                im_data[:, 1, i, j, h, b] = np.imag(Et)
    
                sphere_data[:, i, j, h, b] = [nr[i], ni[j], a[h]]
    
                            # print progress
                cnt += 1
                sys.stdout.write('\r' + str(round(cnt / (num_samples) * 100, 2))  + ' %')
                sys.stdout.flush() # important

# save the data
np.save(im_dir, im_data)
np.save(r'D:\irimages\irholography\CNN\data_v12_far_line\more_bandpass_HD\label_data', sphere_data)