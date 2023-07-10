# -*- coding: utf-8 -*-
"""
Created on Mon May  6 14:55:41 2019

traditional Mie Scattering class

By calling .get_total_field method to get the total field

Editor:
    Shihao Ran
    STIM Laboratory
"""

import numpy as np
import math
import scipy as sp
import chis.MieScattering as ms
import chis.planewave as pw

class mieScattering:
    
    # parameters used to calculate the fields
    def __init__(self, k, k_j, n, res, a, ps, pp, padding, fov, numSample, NA_in, NA_out, option = 'Horizontal'):
        # n is the refractive index of the sphere. The n of the surrounding material is 1.0
        self.n = n
        # a is the radius of the sphere, for calculation precision perposes, 
        # a should not be larger than twice the wavelength
        self.a = a
        # number of Monte Carlo sampling, 1000 is fine, simulation time cost grows linearly with this variable
        self.numSample = numSample
        # field of view, the total length of the field, say 10 microns
        self.fov = fov
        # position of the sphere
        self.ps = np.asarray(ps)
        self.pp = pp
        # position of the focal point
        self.pf = np.asarray([0, 0, 0])
        # padding for displaying the figure
        self.padding = padding
        # amplitude of the incoming electric field
        self.E0 = 1
        self.E = np.asarray([1, 0, 0]) * self.E0
        # in and out numerical aperture of the condenser
        # for refractive lens, NA_in = 0
        self.NA_in = NA_in
        self.NA_out = NA_out
        # corresponding angles (incident angle range)
        self.alpha1 = math.asin(self.NA_in)
        self.alpha2 = math.asin(self.NA_out)
        # scale factor used later for integrating all sampled vectors
        self.subA = 2 * np.pi * self.E0 * ((1 - np.cos(self.alpha2)) - (1 - np.cos(self.alpha1)))
        # specify the direction of the incoming light
        self.k = np.asarray(k)
        # specify the wavelength of the incident light
        self.lambDa = 1
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
        gx = np.linspace(-self.halfgrid, +self.halfgrid, self.simRes)
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
                return np.sqrt(np.pi / (2*x)) * sp.special.jv(order + 0.5 + mode, x)
            
            elif np.asarray(x).ndim == 1:
                ans = np.zeros((len(x), len(order) + 1), dtype = np.complex128)
                for i in range(len(order)):
                    ans[:,i] = np.sqrt(np.pi / (2*x)) * sp.special.jv(i + 0.5 + mode, x)
                return ans
            
            else:
                ans = np.zeros((x.shape + (len(order),)), dtype = np.complex128)
                for i in range(len(order)):
                    ans[...,i] = np.sqrt(np.pi / (2*x)) * sp.special.jv(i + 0.5 + mode, x)
                return ans
            
            
            
    def sphhankel(self, order, x, mode):
    #general form of calculating spherical hankel functions of the first kind at x
        
        if np.isscalar(x):
            return np.sqrt(np.pi / (2*x)) * (sp.special.jv(order + 0.5 + mode, x) + 1j * sp.special.yv(order + 0.5 + mode, x))
    #
            
        elif np.asarray(x).ndim == 1:
            ans = np.zeros((len(x), len(order)), dtype = np.complex128)
            for i in range(len(order)):
                ans[:,i] = np.sqrt(np.pi / (2*x)) * (sp.special.jv(i + 0.5 + mode, x) + 1j * sp.special.yv(i + 0.5 + mode, x))
            return ans
        else:
            ans = np.zeros((x.shape + (len(order),)), dtype = np.complex128)
            for i in range(len(order)):
                ans[...,i] = np.sqrt(np.pi / (2*x)) * (sp.special.jv(i + 0.5 + mode, x) + 1j * sp.special.yv(i + 0.5 + mode, x))
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
#        hlr0 = hlkr_plcostheta * twolplus1_il
        
        
        Es = phase * np.sum(hlkr_plcostheta * pre_B, axis = 2)
        Ei = phase * np.sum(jlknr_plcostheta * A, axis = 2)

        # apply mask
        Emask = np.ones(((self.simRes, self.simRes)))
        Emask[rMag<self.a] = 0
        Es[rMag<self.a] = 0
        Ei[rMag>=self.a] = 0
        # calculate the focused field
        E_obj = pw.planewave(self.k, self.E)
        Ep = E_obj.evaluate(self.x, self.y, self.z)
        Ef = Ep[0,...]
        # initaliza total E field
        Etot = np.zeros((self.simRes, self.simRes), dtype = np.complex128)
        # add different parts into the total field
        Etot[rMag<self.a] = Ei[rMag<self.a]
#        Etot[rMag<self.a] = 0
#        Etot[rMag<self.a] = Es[rMag<self.a] + Ef[rMag<self.a]
        Etot[rMag>=self.a] = Es[rMag>=self.a] + Ef[rMag>=self.a]

        return Etot, B, Emask
    
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
    
    def imgAtDetec(self, Etot, Ef):
        #2D fft to the total field
        Et_d = np.fft.fft2(Etot)
        Ef_d = np.fft.fft2(Ef)
        
        #apply bandpass filter to the fourier domain
        Et_d *= self.bpf
        Ef_d *= self.bpf
        
        #invert FFT back to spatial domain
        Et_bpf = np.fft.ifft2(Et_d)
        Ef_bpf = np.fft.ifft2(Ef_d)
        
        #initialize cropping
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
    
        return Et_bpf, Ef_bpf
    
def getTotalField(k, k_j, n, res, a, ps, pp, padding, fov, numSample, NA_in, NA_out, option):
    """
    root function to get the total field by call other children functions
    
    Parameters
    ----------
        k: vector_like
            propagation direction of the incident field
            e.g.: k = [0, 0, -1] means the incident field is propagating along
            -Z direction
                  
        k_j: vector_like, 
                NOTE: this parameter is deprecated
                when calculating Mie scattering for a focused beam 
                k_j is the list of Monte Carlo sampled k vectors specified by 
                the inner and outter NA of the condenser. Here is it deprecated
                since the simulation is only for a single planewave
                In most cases k_j is identical to k
                
        n: complex, 
            refractive index of the sphere
        
        res: int, 
            resolution of the simulation
        
        a: float, 
            radius of the sphere
        
        ps: vector_like, 
            position of the sphere
        
        pp: float, 
                position of the horizontal visualization plane along z axis
                NOTE: this parameter is not used if the option is set to "Vertical"
                when the simulation is set to vertical plane, the position
                of the plane is forced to be x=0
        
        padding: int, 
            ratio of extra pixels to be padded on EACH SIDE of the simulation
                 
        fov: int, 
            field of view
        
        numSample: int,
            number of samples for Monte Carlo Sampling, also deprecated
        
        NA_in: float,
            [0, 1), center obscuration of the condenser
        
        NA_out: float,
            (0, 1], back aperture of the condenser
    
        option: string,
            'Horizontal' or 'Vertical'
            Orientation of the visualization plane
    
    Returns
    -------
        Etot: complex, array_like,
            the total field
        Bt: complex, 1-D array,
            B coefficient
        Emask: array_like,
            only contains 0 or 1, 1 means intersection with the sphere
            0 means outside of the sphere
        rVecs: array_like,
            position vectors of the visualization plane
    
    """
    
    #initialize a mie scattering object
    MSI = mieScattering(k, k_j, n, res, a, ps, pp, padding, fov, numSample, NA_in, NA_out, option)  
    #get the field at the focal plane
    Etot, Bt, Emask= MSI.scatterednInnerField(MSI.lambDa, MSI.magk, MSI.n, MSI.rMag)
    #apply a bandpass filter to simulate the field on the detector
#    D_Et, D_Ef = MSI.imgAtDetec(Etot, Ef)
    rVecs = MSI.getrvecs()

    return Etot, Bt, Emask, rVecs