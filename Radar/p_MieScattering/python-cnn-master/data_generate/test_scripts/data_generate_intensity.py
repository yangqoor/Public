
# -*- coding: utf-8 -*-
"""
Created on Thu Jan 24 14:49:02 2019

@author: shihao

Generates data sets for CNN
"""

"""
4.5 single plane wave mie scattering at the surface of the sphere to
generate ground truth of B to verify the inverse model

either generates the ground truth for the 3 final values (a, real n and imag n)
or the B vector fot down stream process

Features are the intensity of the field instead of the amplitude and phase

Editor:
    Shihao Ran
    STIM Laboratory
"""

# numpy for most of the data saving and cumputation
import numpy as np
# matplotlib for ploting the images
from matplotlib import pyplot as plt
# pyquaternion for ratating the vectors
from pyquaternion import Quaternion
# scipy for input/output files
from scipy import special as sp
# math for calculations
import math
# import animation for plot animations
from matplotlib import animation as animation
# time for timing profiles
import time
# random for Monte Carlo Sampling
import random
import sys

class mieScattering:
    
    # parameters used to calculate the fields
    def __init__(self, k, k_j, n, res, a, ps, pp, numSample, NA_in, NA_out, option = 'Horizontal'):
        # n is the refractive index of the sphere. The n of the surrounding material is 1.0
        self.n = n
        # a is the radius of the sphere, for calculation precision perposes, 
        # a should not be larger than twice the wavelength
        self.a = a
        # number of Monte Carlo sampling, 1000 is fine, simulation time cost grows linearly with this variable
        self.numSample = numSample
        # field of view, the total length of the field, say 10 microns
        self.fov = 30
        # position of the sphere
        self.ps = np.asarray(ps)
        # position of the focal point
        self.pf = np.asarray([0, 0, 0])
        # padding for displaying the figure
        self.padding = 0
        # amplitude of the incoming electric field
        self.E0 = 1
        # in and out numerical aperture of the condenser
        # for refractive lens, NA_in = 0
        self.NA_in = NA_in
        self.NA_out = NA_out
        # corresponding angles (incident angle range)
        self.alpha1 = math.asin(self.NA_in)
        self.alpha2 = math.asin(self.NA_out)
        # scale factor used later for integrating all sampled vectors
        self.subA = 2 * np.pi * self.E0 * ((1 - np.cos(self.alpha2)) - (1 - np.cos(self.alpha1)))
        # convert coordinates to cartesian if necessary
        # x, y, z = self.sph2cart(self.theta, self.phi, 1)
        
        # specify the direction of the incoming light
        self.k = np.asarray(k)
        # specify the wavelength of the incident light
        self.lambDa = 2*np.pi
        # magnitude of the k vector
        self.magk = 2*np.pi/self.lambDa
        # kvector
        self.kVec = self.k * self.magk
        # resolution of the image, number of pixels in one dimension, say 150
        self.res = res
        # simulation resolution
        # in order to do fft and ifft, expand the image use padding
        self.simRes = self.res*(2*self.padding + 1)
        # initialize a plane to evaluate the field
        # halfgrid is the size of a half grid
        self.halfgrid = np.ceil(self.fov/2)*(2*self.padding +1)
        # range of x, y
        gx = np.linspace(-self.halfgrid, +self.halfgrid-1, self.simRes)
        gy = gx
        # option is the way the field is rendered
        # 'Horizontal' means the light is from inside of the screen to the outside
        # 'Vertical' means the light is from bottom of the screen to the top
        self.option = option
        
        if self.option == 'Horizontal':
            # if it is a horizontal plane
            [self.x, self.y] = np.meshgrid(gx, gy)
            
            # make it a plane at z = 0 on the Z axis
            self.z = np.zeros((self.simRes, self.simRes,)) + pp
            
        elif self.option == 'Vertical':
            # if it is a vertical plane
            [self.y, self.z] = np.meshgrid(gx, gy)
            
            # make it a plane at x = 0 on the X axis 
            self.x = np.zeros((self.simRes, self.simRes,))
        
        # initialize r vectors in the space
        self.rVecs = np.zeros((self.simRes, self.simRes, 3))
        # make x, y, z components
        self.rVecs[:,:,0] = self.x
        self.rVecs[:,:,1] = self.y
        self.rVecs[:,:,2] = self.z
        # compute the rvector relative to the sphere
        self.rVecs_ps = self.rVecs - self.ps
        # calculate the distance matrix
        self.rMag = np.sqrt(np.sum(self.rVecs_ps ** 2, 2))
        # calculate a bandpass filter
        self.bpf = self.BPF(self.halfgrid, self.simRes, self.NA_in, self.NA_out)
        # k vectors sampled from monte carlo sampling
        self.k_j = k_j

    def getrvecs(self):
        return self.rVecs_ps
    
    def sampled_kvectors_spherical_coordinates(self, NA_in, NA_out, NumSample, kd):
    #sample multiple planewaves at different angle to do simulation as a focused beam
        # return a list of planewave direction vectors Kd
        # and the corresponding scale factor if using uniform sampling
        # NA: numberical aperture of the lens which planewaves are focused from
        # NumSample: number of samples(planewaves)
        # kd: center planewave of the focused beam
        
        #allocatgge space for the field and initialize it to zero

        CenterKd = self.k                                       #defualt planewave coming in perpendicular to the surface
        kd = kd / np.linalg.norm(kd)                                #normalize the new planewave
        r = np.sqrt(CenterKd[0] ** 2 + CenterKd[1] ** 2 + CenterKd[2] ** 2)             #radiance of the hemisphere where the k vectors are sampled from
        
        if(kd[0] == CenterKd[0] and kd[1] == CenterKd[1] and kd[2] == CenterKd[2]):     #if new planewave is at the same direction as the default plane wave
            rotateAxis = CenterKd                                   #set rotation axis as defualt k vector
            RoAngle = 0                                             #set rotation axis as 0 degrees
        else:                                                       #if new plane wave is at different direction as the defualt planewave, rotation is needed
            rotateAxis = np.cross(CenterKd, kd)                     #find a axis which is perpendicular to both vectors to be rotation axis
            RoAngle = math.asin(kd[2] / r)                          #calculate the rotation angle
        beamRotate = Quaternion(axis=rotateAxis, angle=RoAngle)     #create a quaternion for rotation
        
        Kd = np.zeros((3, NumSample))                               #initialize the planewave list
#        scaleFactor = np.zeros(NumSample)                          #initialize a list of scalefactors which are used to scale down the amplitude of planewaves later on along latitude domain
        
        #convert the axis from Cartesian to Spherical
        pha = math.acos(CenterKd[2] / r)                            #calculate polar angle pha from Z coordinate
        
        phaM = math.asin(NA_out / np.real(self.n))                  #calculate sample range of pha from numerical aperture
        
        inZ = np.cos(pha)                                           #lower boundary of sampling along Z axis
        outZ = np.cos(phaM)                                         #upper boundary of sampling along Z axis
        
        rangeZ = np.abs(inZ) - np.abs(outZ)                         #sampling range along Z axis
        
        
#        phaStep = phaM / NumSample                                  #set longitudinal sample resolution as maximal pha divided by number of samples
#        thetaStep = thetaM / NumSample                              #set latitudinal sample resolution as maximal theta divided by number of samples
        
        ###following is uniform sampling
#        for i in range(NumSample):                                  #sample along longitudinal (pha) domain
#            for j in range(NumSample):                              #sample along latitudinal (theta) domain
#                KdR = r                                             #sample hemisphere radiance will be all the same as r
#                KdTheta = theta + thetaStep * j                     #sample theta at each step in the sample range
#                KdPha = pha + phaStep * i                           #sample theta at each step in the sample range
#                Kd[0,j,i] = KdR * np.cos(KdTheta) * np.sin(KdPha)   #convert coordinates from spherical to Cartesian
#                Kd[1,j,i] = KdR * np.sin(KdTheta) * np.sin(KdPha)
#                Kd[2,j,i] = KdR * np.cos(KdPha)
#                Kd[:,j,i] = beamRotate.rotate(Kd[:,j,i])            #rotate k vectors by the quaternion generated
#                scaleFactor[j,i] = np.sin(KdPha)                    #calculate the scalefactors by the current polar angle pha
#        
        
        ###here comes Monte Carlo Sampling
        for i in range(NumSample):                                  
            KdR = r                                                 #the r coordinate of the vector under spherical system
            KdTheta = random.random() * 2 * np.pi                   #get a random value for theta coordinate under spherical system
            KdZ = random.random() * rangeZ + inZ                    #get a random value for Z coordinate under cartesian system
            KdPha = math.acos(KdZ)                                  #convert it back to spherical system
            Kd[0,i] = KdR * np.cos(KdTheta) * np.sin(KdPha)         #convert coordinates from spherical to Cartesian
            Kd[1,i] = KdR * np.sin(KdTheta) * np.sin(KdPha)         #the reason why we sample Z at cartesian is that we want the vectors to distribute randomly on that direction
            Kd[2,i] = KdR * np.cos(KdPha)                           #if we sample it on phi domain, they will be denser towards center
            Kd[:,i] = beamRotate.rotate(Kd[:,i])                    #rotate k vectors by the quaternion generated
        
#        Kd = np.reshape(Kd, ((3, NumSample ** 2)))
#        scaleFactor = np.reshape(scaleFactor, ((NumSample ** 2)))   #reshape list of k vectors and scalefactors to an one dimentional list
        
        return Kd
    
    
    def Legendre(self, order, x):
    #calcula order l legendre polynomial
            #order: total order of the polynomial
            #x: array or vector or scalar for the polynomial
            #return an array or vector with all the orders calculated
            
        if np.isscalar(x):
        #if x is just a scalar value
        
            P = np.zeros((order+1, 1))
            P[0] = 1
            if order == 0:
                return P
            P[1] = x
            if order == 1:
                return P
            for j in range(1, order):
                P[j+1] = ((2*j+1)/(j+1)) *x *(P[j]) - ((j)/(j+1))*(P[j-1])
            return P
        
        elif np.asarray(x).ndim == 1:
        #if x is a vector
            P = np.zeros((len(x), order+1))
            P[:,0] = 1
            if order == 0:
                return P
            P[:, 1] = x
            if order == 1:
                return P
            for j in range(1, order):
                P[:,j+1] = ((2*j+1)/(j+1)) *x *(P[:, j]) - ((j)/(j+1))*(P[:, j-1])
            return P
        
        else:
        #if x is an array
            P = np.zeros((x.shape + (order+1,)))
            P[..., 0] = 1
            if order == 0:
                return P
            P[..., 1] = x
            if order == 1:
                return P
            for j in range(1, order):
                P[..., j+1] = ((2*j+1)/(j+1)) *x *(P[..., j]) - ((j)/(j+1))*(P[..., j-1])
            return P
        
        
    def sph2cart(self, az, el, r):
    #convert coordinates from spherical to cartesian
            #az: azimuthal angle, horizontal angle with x axis
            #el: polar angle, vertical angle with z axis
            #r: radial distance with origin
            
        rcos_theta = r * np.cos(el)
        x = rcos_theta * np.cos(az)
        y = rcos_theta * np.sin(az)
        z = r * np.sin(el)
        return x, y, z
    
    
    def sphbesselj(self, order, x, mode):
    #calculate the spherical bessel function of the 1st kind with order specified
        #order: the order to be calculated
        #x: the variable to be calculated
        #mode: 1 stands for prime, -1 stands for derivative, 0 stands for nothing
            if np.isscalar(x):
                return np.sqrt(np.pi / (2*x)) * sp.jv(order + 0.5 + mode, x)
            
            elif np.asarray(x).ndim == 1:
                ans = np.zeros((len(x), len(order) + 1), dtype = np.complex128)
                for i in range(len(order)):
                    ans[:,i] = np.sqrt(np.pi / (2*x)) * sp.jv(i + 0.5 + mode, x)
                return ans
            
            else:
                ans = np.zeros((x.shape + (len(order),)), dtype = np.complex128)
                for i in range(len(order)):
                    ans[...,i] = np.sqrt(np.pi / (2*x)) * sp.jv(i + 0.5 + mode, x)
                return ans
            
            
            
    def sphhankel(self, order, x, mode):
    #general form of calculating spherical hankel functions of the first kind at x
        
        if np.isscalar(x):
            return np.sqrt(np.pi / (2*x)) * (sp.jv(order + 0.5 + mode, x) + 1j * sp.yv(order + 0.5 + mode, x))
    #
            
        elif np.asarray(x).ndim == 1:
            ans = np.zeros((len(x), len(order)), dtype = np.complex128)
            for i in range(len(order)):
                ans[:,i] = np.sqrt(np.pi / (2*x)) * (sp.jv(i + 0.5 + mode, x) + 1j * sp.yv(i + 0.5 + mode, x))
            return ans
        else:
            ans = np.zeros((x.shape + (len(order),)), dtype = np.complex128)
            for i in range(len(order)):
                ans[...,i] = np.sqrt(np.pi / (2*x)) * (sp.jv(i + 0.5 + mode, x) + 1j * sp.yv(i + 0.5 + mode, x))
            return ans
        
    
    #derivative of the spherical bessel function of the first kind
    def derivSphBes(self, order, x):
        js_n = np.zeros(order.shape, dtype = np.complex128)
        js_n_m_1 = np.zeros(order.shape, dtype = np.complex128)
        js_n_p_1 = np.zeros(order.shape, dtype = np.complex128)
        
        js_n = self.sphbesselj(order, x, 0)
        js_n_m_1 = self.sphbesselj(order, x, -1)
        js_n_p_1 = self.sphbesselj(order, x, 1)
        
        j_p = 1/2 * (js_n_m_1 - (js_n + x * js_n_p_1) / x)
        return j_p
    
    #derivative of the spherical hankel function of the first kind
    def derivSphHan(self, order, x):
        sh_n = np.zeros(order.shape, dtype = np.complex128)
        sh_n_m_1 = np.zeros(order.shape, dtype = np.complex128)
        sh_n_p_1 = np.zeros(order.shape, dtype = np.complex128)
    
        sh_n = self.sphhankel(order, x, 0)
        sh_n_m_1 = self.sphhankel(order, x, -1)
        sh_n_p_1 = self.sphhankel(order, x, 1)
        
        h_p = 1/2 * (sh_n_m_1 - (sh_n + x * sh_n_p_1) / x)
        return h_p
    
        
    def calFocusedField(self, simRes, magk, rMag):
    #calculate a focused beam from the paramesters specified
        #the order of functions for calculating focused field

        orderEf = 100
        #il term
        ordVec = np.arange(0, orderEf+1, 1)
        il = 1j ** ordVec
        
        #legendre polynomial of the condenser
        plCosAlpha1 = self.Legendre(orderEf+1, np.cos(self.alpha1))
        plCosAlpha2 = self.Legendre(orderEf+1, np.cos(self.alpha2))
        
        #normalized k vector 
        kNorm = self.kVec / magk
        #compute rMag and rNorm and cosTheta at each pixel
        
        rMag = np.sqrt(np.sum(self.rVecs_ps**2, 2))
        rNorm = self.rVecs_ps / rMag[...,None]
        cosTheta = np.dot(rNorm, kNorm)

        #compute spherical bessel function at kr
        jlkr= self.sphbesselj(ordVec, magk*rMag, 0)
        
        #compute legendre polynomial of all r vector
        plCosTheta = self.Legendre(orderEf, cosTheta)
        
        #product of them
        jlkrPlCosTheta = jlkr * plCosTheta
        
        il = il.reshape((1, 1, orderEf+1))
        iljlkrplcost = jlkrPlCosTheta * il
        
        order = 0
        
        iljlkrplcost[:,:,order] *= (plCosAlpha1[order+1]-plCosAlpha2[order+1]-plCosAlpha1[0]+plCosAlpha2[0])
        
        order = 1
        
        iljlkrplcost[:,:,order] *= (plCosAlpha1[order+1]-plCosAlpha2[order+1]-plCosAlpha1[0]+plCosAlpha2[0])
            
        iljlkrplcost[:,:,2:] = iljlkrplcost[:,:,2:] * np.squeeze(plCosAlpha1[3:]-plCosAlpha2[3:]-plCosAlpha1[1:orderEf]+plCosAlpha2[1:orderEf])[None, None,...]
        
        #sum up all orders
        Ef = 2*np.pi*self.E0*np.sum(iljlkrplcost, axis = 2)
        
        return Ef
    
    def calFocusedField_old(self, simRes, magk, rMag):
    #calculate a focused beam from the paramesters specified
        #the order of functions for calculating focused field

        #order of the calculation for the focused field
        orderEf = 3
        #il term
        ordVec = np.arange(0, orderEf+1, 1)
        il = 1j ** ordVec
        
        #legendre polynomial of the condenser
        plCosAlpha1 = self.Legendre(orderEf+1, np.cos(self.alpha1))
        plCosAlpha2 = self.Legendre(orderEf+1, np.cos(self.alpha2))
        
        #initialize magnitude of r vector at each pixel
        rMag = np.zeros((simRes, simRes))
        #initialize angle between k vector to each r vector 
        cosTheta = np.zeros((rMag.shape))
        #initialize normalized r vector
        rNorm = np.zeros((self.rVecs.shape))
        #normalized k vector 
        kNorm = self.kVec / magk
        #compute rMag and rNorm and cosTheta at each pixel
        for i in range(simRes):
            for j in range(simRes):
                rMag[i, j] = np.sqrt(self.rVecs_ps[i, j, 0]**2+self.rVecs_ps[i, j, 1]**2+self.rVecs_ps[i, j, 2]**2)
                rNorm[i, j, :] = self.rVecs_ps[i, j, :] / rMag[i,j]
                cosTheta[i, j] = np.dot(kNorm, rNorm[i, j, :])
        
        #compute spherical bessel function at kr
        jlkr= self.sphbesselj(ordVec, magk*rMag, 0)
        
        #compute legendre polynomial of all r vector
        plCosTheta = self.Legendre(orderEf, cosTheta)
        
        #product of them
        jlkrPlCosTheta = jlkr * plCosTheta
        
        il = il.reshape((1, 1, orderEf+1))
        iljlkrplcos = jlkrPlCosTheta * il
        
        order = 0
        iljlkrplcos[:,:,order] = iljlkrplcos[:,:,order]*(plCosAlpha1[order+1]-plCosAlpha2[order+1]-plCosAlpha1[0]+plCosAlpha2[0])
        
        order = 1
        iljlkrplcos[:,:,order] = iljlkrplcos[:,:,order]*(plCosAlpha1[order+1]-plCosAlpha2[order+1]-plCosAlpha1[0]+plCosAlpha2[0])
        
        for order in range(2, orderEf):
            iljlkrplcos[:,:,order] = iljlkrplcos[:,:,order]*(plCosAlpha1[order+1]-plCosAlpha2[order+1]-plCosAlpha1[order-1]+plCosAlpha2[order-1])
        
        #sum up all orders
        Ef = 2*np.pi*self.E0*np.sum(iljlkrplcos, axis = 2)
        
        return Ef
    
    def scatterednInnerField(self, lambDa, magk, n, rMag):

        #calculate and return a focused field and the corresponding scattering field and internal field
        #maximal number of orders used to calculate Es and Ei
        numOrd = math.ceil(2*np.pi * self.a / lambDa + 4 * (2 * np.pi * self.a / lambDa) ** (1/3) + 2)
        #create an order vector
        ordVec = np.arange(0, numOrd+1, 1)
        #calculate the prefix term (2l + 1) * i ** l
        twolplus1 = 2 * ordVec + 1
        il = 1j ** ordVec
        twolplus1_il = twolplus1 * il
        #compute the arguments for spherical bessel functions, hankel functions and thier derivatives
        ka = magk * self.a
        kna = magk * n * self.a
        #number of samples
        
        
        #evaluate the spherical bessel functions of the first kind at ka
        jl_ka = self.sphbesselj(ordVec, ka, 0)
        
        #evaluate the derivative of the spherical bessel functions of the first kind at kna
        jl_kna_p = self.derivSphBes(ordVec, kna)
        
        #evaluate the spherical bessel functions of the first kind at kna
        
        jl_kna = self.sphbesselj(ordVec, kna, 0)
        
        #evaluate the derivative of the spherical bessel functions of the first kind of ka
        jl_ka_p = self.derivSphBes(ordVec, ka)
        
        #compute the numerator for B coefficients
        numB = jl_ka * jl_kna_p * n - jl_kna * jl_ka_p
        
        #evaluate the hankel functions of the first kind at ka
        hl_ka = self.sphhankel(ordVec, ka, 0)
        
        #evaluate the derivative of the hankel functions of the first kind at ka
        hl_ka_p = self.derivSphHan(ordVec, ka)
        
        #compute the denominator for coefficient A and B
        denAB = jl_kna * hl_ka_p - hl_ka * jl_kna_p * n
        
        #compute B
        B = np.asarray((numB / denAB), dtype = np.complex128)
        B_return = B
        B = np.reshape(B, (1, 1, numOrd + 1))
        
        pre_B = twolplus1_il * B
        
        #compute the numerator of the scattering coefficient A
        numA = jl_ka * hl_ka_p - jl_ka_p * hl_ka
        
        #compute A
        A = np.asarray(twolplus1_il * (numA / denAB), dtype = np.complex128)
        A = np.reshape(A, (1, 1, numOrd + 1))
        
        #normalize r vector 
        rNorm = self.rVecs_ps / rMag[..., None]
        #computer k*r term
        kr = magk * rMag
        
        #compute the spherical hankel function of the first kind for kr
        hl_kr = self.sphhankel(ordVec, kr, 0)
        
        #computer k*n*r term
        knr = kr * n
        
        #compute the spherical bessel function of the first kind for knr
        jl_knr = self.sphbesselj(ordVec, knr, 0)
        
        #compute the distance from the center of the sphere to the focal point/ origin
        #used for calculating phase shift later
        c = self.ps - self.pf
        
        #initialize Ei and Es field
        Ei = np.zeros((self.simRes, self.simRes), dtype = np.complex128)
        Es = np.zeros((self.simRes, self.simRes), dtype = np.complex128)
        
        #a list of sampled k vectors
#        k_j = self.sampled_kvectors_spherical_coordinates(self.NA_in, self.NA_out, self.numSample, self.lightdirection)

        cos_theta = np.zeros((rMag.shape))
        cos_theta = np.dot(rNorm, self.k_j)
        # compute the mathmatical terms
        pl_costheta = self.Legendre(numOrd, cos_theta)
        hlkr_plcostheta = hl_kr * pl_costheta
        jlknr_plcostheta = jl_knr * pl_costheta
        # compute the phase shift
        phase = np.exp(1j * magk * np.dot(self.k_j, c))
        # add to the final field
        
        # left hand side, H matrix of the linear system
        hlr0 = hlkr_plcostheta * twolplus1_il
        
        
        Es = phase * np.sum(hlkr_plcostheta * pre_B, axis = 2)
        Ei = phase * np.sum(jlknr_plcostheta * A, axis = 2)
            
        # scale the value down
#        Es *= (self.subA / self.numSample)
#        Ei *= (self.subA / self.numSample)
        # apply mask
        Emask = np.ones(((self.simRes, self.simRes)))
        Emask[rMag<self.a] = 0
        Es[rMag<self.a] = 0
        Ei[rMag>=self.a] = 0
        # calculate the focused field
        Ef = np.ones((np.shape(Es)), dtype = np.complex128)
        Ef *= np.exp(self.a * 1j)
        # initaliza total E field
        Etot = np.zeros((self.simRes, self.simRes), dtype = np.complex128)
        # add different parts into the total field
        Etot[rMag<self.a] = Ei[rMag<self.a]
#        Etot[rMag<self.a] = 0
        Etot[rMag>=self.a] = Es[rMag>=self.a] + Ef[rMag>=self.a]

        return Etot, B_return, Es
    
    def BPF(self, halfgrid, simRes, NA_in, NA_out):
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
        idex1, idex2 = np.where(magf < NA_in / self.lambDa)
        BPF[idex1, idex2] = 0
        #block higher frequency
        idex1, idex2 = np.where(magf > NA_out / self.lambDa)
        BPF[idex1, idex2] = 0
        
        return BPF
    
#    def imgAtDetec(self, Etot, Ef):
#        #2D fft to the total field
#        Et_d = np.fft.fft2(Etot)
#        Ef_d = np.fft.fft2(Ef)
#        
#        #apply bandpass filter to the fourier domain
#        Et_d *= self.bpf
#        Ef_d *= self.bpf
#        
#        #invert FFT back to spatial domain
#        Et_bpf = np.fft.ifft2(Et_d)
#        Ef_bpf = np.fft.ifft2(Ef_d)
#        
#        #initialize cropping
#        cropsize = self.padding * self.res
#        startIdx = int(np.fix(self.simRes /2 + 1) - np.floor(cropsize/2))
#        endIdx = int(startIdx + cropsize - 1)
        
        #save the field
    #    np.save(r'D:\irimages\irholography\New_QCL\BimSimPython\Et15YoZ.npy', Et_bpf)
        
        #uncomment these lines to crop the image
#        D_Et = np.zeros((cropsize, cropsize), dtype = np.complex128)
#        D_Et = Et_bpf[startIdx:endIdx, startIdx:endIdx]
#        D_Ef = np.zeros((cropsize, cropsize), dtype = np.complex128)
#        D_Ef = Ef_bpf[startIdx:endIdx, startIdx:endIdx]
    
#        return Et_bpf, Ef_bpf
        
def getTotalField(k, k_j, n, res, a, ps, pp, numSample, NA_in, NA_out, option):
    #root function to get the final field by call other children functions
    
    #initialize a mie scattering object
    MSI = mieScattering(k, k_j, n, res, a, ps, pp, numSample, NA_in, NA_out, option)  
    #get the field at the focal plane
    Etot, B, Es = MSI.scatterednInnerField(MSI.lambDa, MSI.magk, MSI.n, MSI.rMag)
    #apply a bandpass filter to simulate the field on the detector
#    D_Et, D_Ef = MSI.imgAtDetec(Etot, Ef)

    return Etot, B, Es
    

k = [0, 0, -1]
res = 128
numSample = 1
NA_in = 0
NA_out = 0
numFrames = 70
option = 'Horizontal'
parentDir = r'D:\irimages\irholography\CNN\data_v2'

k_j = k


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

im_data = np.zeros((res, res, nb_nr, nb_ni, nb_a))
sphere_data = np.zeros((3, nb_nr, nb_ni, nb_a))
B_data_real = np.zeros((22, nb_nr, nb_ni, nb_a))
B_data_imag = np.zeros((22, nb_nr, nb_ni, nb_a))

cnt = 0
for i in range(nb_nr):
    for j in range(nb_ni):
        for h in range(nb_a):
            
            n0 = nr[i] + ni[j] * 1j
            a0 = a[h]
            #position of the visualization plane, along z axis
            pp = a0
            ps0 = [0, 0, 0]
            Et_0, B, Es = getTotalField(k, k_j, n0, res, a0, ps0, pp, numSample, NA_in, NA_out, option)
            
            im_data[:, :, i, j, h] = np.abs(Et_0) ** 2
#            
            sphere_data[:, i, j, h] = [nr[i], ni[j], a[h]]
            
            B_data_real[:np.size(B), i, j, h] = np.real(B)
            B_data_imag[:np.size(B), i, j, h] = np.imag(B)
            
            cnt += 1
            
            sys.stdout.write('\r' + str(cnt / 15625 * 100)  + ' %')
            sys.stdout.flush() # important

np.save(r'D:\irimages\irholography\CNN\data_v6_B\im_data.bin', im_data)
np.save(r'D:\irimages\irholography\CNN\data_v6_B\lable_data.bin', sphere_data)
np.save(r'D:\irimages\irholography\CNN\data_v6_B\B_data_real.bin', B_data_real)
np.save(r'D:\irimages\irholography\CNN\data_v6_B\B_data_imag.bin', B_data_imag)