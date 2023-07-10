# -*- coding: utf-8 -*-
"""
Created on Wed Apr 17 20:56:19 2019

Mie Scattering module for Chemical Holographic Imaging System (CHIS) library

@author: Shihao Ran
         STIM Laboratory
"""

# import packages
import numpy as np
import scipy as sp
import scipy.special
import math


def propagate_2D(res, fov, E, d):
    """
    Propagate a 2-D complex field by the free-space Green's Function
    According to the frequency components by calling the cal_kz function
    Convert the original field into Fourier Domain
    Then multiply each frequency components with the phase shift
    Then convert the propagated field back to spatial domain
    
    Parameters
    ----------
        res: int, 
            resolution of the simulation
        fov: int, 
            field of view
        E: complex, array_like,
            the field to be propagated
        d: float,
            propatation distance
    
    Returns
    -------
        E_prop: complex, array_like,
            the field after propagation
    """
    fx = np.fft.fftfreq(res, fov/res)
    fy = fx

    # create a meshgrid in the Fourier Domain
    [kx, ky] = np.meshgrid(fx, fy)
    # calculate the sum of kx ky components so we can calculate
    # cos_theta in the Fourier Domain later
    kxky = kx**2 + ky**2
    # create a mask where the sum of kx^2 + ky^2 is
    # bigger than 1 (where kz is not defined)
    mask = kxky > 1
    # mask out the sum
    kxky[mask] = 0
    # calculate kz
    k_z = np.sqrt(1 - kxky)
    #compute the phase mask for shifting each pixel of the field
    phaseMask = np.exp(1j * k_z * d)
    
    #Fourier transform of the field and do fft-shift to the Fourier image
    #so that the center of the Fourier transform is at the origin
    E_orig = E
    fE_orig = np.fft.fft2(E_orig)
    fE_shift = np.fft.fftshift(fE_orig)
    
    #apply phase shift to the field in Fourier domain
    fE_propagated = fE_shift * phaseMask
    
    #inverse shift the image in Fourier domain
    #then apply inverse Fourier transform the get the spatial image
    fE_inversae_shift = np.fft.ifftshift(fE_propagated)
    E_prop = np.fft.ifft2(fE_inversae_shift)
    
    #return the propagated field
    return E_prop

def get_working_dis(padding=0):
    """
    Calculate the working distance for the far field simulation
    
    Note: Idealy working distance should be approaching infinity
          since this is a simulation of the fourier optics
          the fourier plane of a near field image should be 
          placed at infinity
          here we just take the distance 10000 times layer than
          the sphere size
          Also, it needs to be scaled by the padding number as well
    
    Parameters
    ----------
        padding: int, 
            padding of the simulation
    
    Returns
    -------
        working_dis: int, 
            working distance
    """
    
    working_dis = 10000 * (2 * padding + 1)           
    
    return working_dis

def get_scale_factor(res, fov, working_dis):
    """
    calculate the scale factor for the far field simulation
    since the field is generated at infinity (idealy)
    the field intensity is super low
    this scale factor brings up the intensity
    
    Parameters
    ----------
        res: int,
            resolution of the simulation
        fov: int,
            field of view
        working_dis: int, 
            working distance
    
    Returns
    -------
        scale_factor: int,
            the scale factor to be multiplied by the field
    """
    
    scale_factor = working_dis * 2 * math.pi * res/fov

    return scale_factor


def get_order(a=1, lambDa=1):
    """
    Calculate the order of the integration based on radius of the sphere
    and the wavelength of the incident field

    Parameters
    ----------
        a: float,
            radius of the sphere
        lambDa: float,
            wavelength of the incident field

    Returns
    -------
        l: int, 1-D vector
            orders of the field
    """

    # calculate the maximal order based on the Bessel function decaying
    l_max = math.ceil(2*np.pi*a/lambDa + 4*(2*np.pi*a/lambDa)**(1/3) + 2)

    # create a order vector from the maxiaml order
    l = np.arange(0, l_max+1, 1)

    return l


def coeff_b(l, k, n=1, a=1):

    """
    Calculate the B vector with respect to the sphere properties

    Note that B vector is independent to scatter matrix and only
    relys on n and a

    Parameters
    ----------
        l: int, 1-D vector
            orders of the field
        k:  float,
            wavenumber of the incident field
        n: complex,
            refractive index (and attenuation coeff.) of the sphere
        a: float,
            radius of the sphere

    Returns
    -------
        B: 1-D array, complex B,
            coefficient vector
    """

    # calculate everything related to spherical Bessel function of the 1st kind
    jka = sp.special.spherical_jn(l, k * a)
    jka_p = sp.special.spherical_jn(l, k * a, derivative=True)
    jkna = sp.special.spherical_jn(l, k * n * a)
    jkna_p = sp.special.spherical_jn(l, k * n * a, derivative=True)

    # calculate everything related to spherical Bessel funtion of the 2nd kind
    yka = sp.special.spherical_yn(l, k * a)
    yka_p = sp.special.spherical_yn(l, k * a, derivative=True)

    # calculate spherical Hankel function of the 1st kind and its derivative
    hka = jka + yka * 1j
    hka_p = jka_p + yka_p * 1j

    # calculate different terms of B
    bi = jka * jkna_p * n
    ci = jkna * jka_p
    di = jkna * hka_p
    ei = hka * jkna_p * n

    # calculate B
    B = (bi - ci) / (di - ei)

    return B

def horizontal_canvas(res, fov, z, dimension=2):
    """
    get a horizontal render space (meshgrid) for the simulation
    x, y coordinates of the grid is specified by the resolution and FOV
    and the z coordinate is specified by the z parameter

    NOTE: by defualt, the sphere being simulated should be positioned
    at the origin. If not, do not use this function

    For 1-D canvas, the length of the line is half the resolution

    Parameters
    ----------
        res: int, 
            the resolution of the simulation
        fov: int, 
            the physical field of view of the simulation
        z: float, 
            z coordinate along the axial axis
        dimension: 1 or 2,
            the dimension of the simulation

    Returns
    -------
        rMag: 2-D array (res, res) or 1-D array (res/2, 1), float
            the magnitude of the position vector corresponds to each pixel
    """

    # get the maxiaml value of the grid (centering with 0)
    halfgrid = np.ceil(fov/2)

    if dimension == 2:
        # get x,y,z components of the position vector r
        gx = np.linspace(-halfgrid, halfgrid, res)
        gy = gx
        [x, y] = np.meshgrid(gx, gy)
        z = np.zeros((res, res)) + z

        # initialize r vectors
        rVecs = np.zeros((res, res, 3))
        # assign x,y,z components
        rVecs[...,0] = x
        rVecs[...,1] = y
        rVecs[...,2] = z

        # calculate the magnitude map of the whole plane
        rMag = np.sqrt(np.sum(rVecs**2, 2))

    elif dimension == 1:
        # locate the center pixel
        center = int(np.ceil(res/2))

        # range of x, y
        gx = np.linspace(-halfgrid, +halfgrid, res)[:center+1]
        gy = gx[0]

        # calculate the distance matrix
        rMag = np.sqrt(gx**2+gy**2+z**2)

    else:
        raise ValueError('The dimension of the canvas is invalid!')

    return rMag

def pad(res, fov, padding=0):
    """
    Pad the rendering plane to make the simulation bigger
    The padded image is 2*padding+1 times larger than the original image

    Parameters
    ----------
        res: int, 
            the resolution of the simulation
        fov: int, 
            the physical field of view of the simulation
        padding: int,
            padding coefficient

    Returns
    -------
        simRes: int,
            simulation resolution
        simFov: int, 
            simulation field of view
    """

    return int(res*(padding*2+1)), int(fov*(padding*2+1))

def asymptotic_hankel(x, l):
    """
    Calculate the asymptotic form of the Hankel function for all orders in
    order vector l

    Parameters
    ----------
        x: 2-D array, float
            input data
        l: 1-D array, int
            order vector

    Returns
    -------
        hl_sym: 3-D array with shape=(x.shape, l.shape)
            asymptotic form of the hankel values 
    """
    if np.isscalar(l):
        raise ValueError('Please set l as an order vector, not scalar!')
    
    # initialize the return
    if x.ndim == 1:
        hl_asym = np.zeros((x.shape[0], l.shape[0]),
                           dtype = np.complex128)

    elif x.ndim == 2:
        hl_asym = np.zeros((x.shape[0], x.shape[1], l.shape[0]),
                           dtype = np.complex128)

    # calculate the values for each order
    for i in l:
        hl_asym[..., i] = np.exp(1j*(x-i*math.pi/2))/(1j * x)

    return hl_asym

def asymptotic_legendre(res, fov, l, dimension=2):
    """
    Calculate the asymptotic form of the Legendre Polynomial

    Parameters
    ----------
        res: int, 
            resolution of the simulation
        fov: int, 
            field of view
        l: 1-D array, int
            order vector
        dimension: 1 or 2
            dimension of the simulation

    Returns
    -------
        pl_cos_theta: 3-D array, float, (res, res, len(l))
            Legendre polynomial based on the angle theta
    """
    # get the frequency components
    if dimension == 2:
        fx = np.fft.fftfreq(res, fov/res)
        fy = fx

        # create a meshgrid in the Fourier Domain
        [kx, ky] = np.meshgrid(fx, fy)
        # calculate the sum of kx ky components so we can calculate
        # cos_theta in the Fourier Domain later
        kxky = kx**2 + ky**2

    elif dimension == 1:
        fx = np.fft.fftfreq(res, fov/res)[:int(res/2)+1]
        fy = fx[0]

        kxky = fx**2 + fy**2
    else:
        raise ValueError('The dimension of the simulation is invalid!')


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

    return pl_cos_theta

def near_filed_legendre(res, fov, z, k_dir, l, dimension=2):
    """
    calculate the legendre polynomial for near field simulation
    
    FIXME: this has only 2-D case
    
    Parameters
    ----------
        res: int, 
            resolution of the simulation
        fov: int, 
            field of view
        z: float
            the position of the visualization plane at z axis
        k_dir: 1-D vector
            propagation direction
        l: 1-D array, int
            order vector
        dimension: 1 or 2
            dimension of the simulation
            
    Returns
    -------
        plcos: 3-D array, float, (res, res, len(l))
            Legendre polynomial based on the angle theta
    
    """
    halfgrid = np.ceil(fov/2)
    # range of x, y
    gx = np.linspace(-halfgrid, +halfgrid, res)
    gy = gx
    [x, y] = np.meshgrid(gx, gy)     
    # make it a plane at z = 0 on the Z axis
    z = np.zeros((res, res,)) + z
    
    # initialize r vectors in the space
    rVecs = np.zeros((res, res, 3))
    # make x, y, z components
    rVecs[:,:,0] = x
    rVecs[:,:,1] = y
    rVecs[:,:,2] = z
    # compute the rvector relative to the sphere
    rVecs_ps = rVecs
    
    # calculate the distance matrix
    rMag = np.sqrt(np.sum(rVecs_ps ** 2, 2))
    
    # normalize the r vectors    
    rNorm = rVecs_ps / rMag[...,None]
    
    # compute cos(theta)
    cos_theta = np.dot(rNorm, k_dir)
    
    # compute the legendre polynomial
    plcos = sp.special.eval_legendre(l, cos_theta[..., None])
    
    return plcos


def scatter_matrix(res, fov, z, a, lambDa, k_dir, dimension=2,
                   option='far'):
    """
    calculate the scatter matrix
 
    Parameters
    ----------
        res: int, 
            resolution of the simulation
        fov: int, 
            field of view
        z: float
            the position of the visualization plane at z axis
        a: float
            radius of the sphere
        lambDa: float
            wavelength of the incident field
        k_dir: 1-D vector
            propagation direction
        dimension: 1 or 2
            dimension of the simulation
        option: for near field or far field simulation, near or far

    Returns
    -------
        scatter_matrix: 3-D array, complex, (res, res, len(l))
    """

    # the maximal order
    l = get_order(a, lambDa)

    # construct the evaluate plane
    rMag = horizontal_canvas(res, fov, z, dimension)
    kMag = 2 * np.pi / lambDa

    # calculate k dot r
    kr = kMag * rMag

    # if for far field simulation
    if option == 'far':
        # calculate the Legendre polynomial in frequency domain
        pl_cos_theta = asymptotic_legendre(res, fov, l, dimension)
        # calculate the asymptotic form of hankel funtions
        hlkr = asymptotic_hankel(kr, l)
    
    # if for near field simulation
    elif option == 'near':
        # calculate them normaly
        pl_cos_theta = near_filed_legendre(res, fov, z, k_dir, l, dimension)
        jkr = sp.special.spherical_jn(l, kr[..., None])
        ykr = sp.special.spherical_yn(l, kr[..., None])
        hlkr = jkr + ykr * 1j
    else:
        raise ValueError('Please specify far field or near field!')
    
    # calculate the prefix alpha term
    alpha = (2*l + 1) * 1j ** l
    # calculate the matrix besides B vector
    scatter = hlkr * pl_cos_theta * alpha

    return scatter

def near_field(res, fov, a, n, lambDa, z, k_dir):
    """
    Calculate the 2-D near field image

    Parameters
    ----------
        res: int, 
            resolution of the simulation
        fov: int, 
            field of view
        a: float
            radius of the sphere
        lambDa: float
            wavelength of the incident field
        z: float
            the position of the visualization plane at z axis
        k_dir: 1-D vector
            propagation direction
            
    Returns
    -------
        E_near:  2-D array, complex
            complex near field image
    """
    l = get_order(a, lambDa)
    
    k = 2*np.pi/lambDa
    
    B = coeff_b(l, k, n, a)
    
    scatter_near = scatter_matrix(res, fov, z, a, lambDa, 2, 'near', k_dir)
    
    E_near = np.sum(scatter_near * B, axis=-1)
    
    return E_near



def far_field(res, fov, z, a, n, lambDa, k_dir, scale, dimension=2):
    """
    Calculate the far field image

    Parameters
    ----------
        res: int, 
            resolution of the simulation
        fov: int, 
            field of view
        z: float
            the position of the visualization plane at z axis
        a: float
            radius of the sphere
        lambDa: float
            wavelength of the incident field
        scale: float
            scale factor
        dimension: 1 or 2
            dimension of the simulation

    Returns:
        E_far:  2-D or 1-D array, complex
    """

    # the maximal order
    l = get_order(a, lambDa)

    # the wavenumber
    k = 2*np.pi/lambDa

    # calculate B coefficient
    B = coeff_b(l, k, n, a)

    # calculate the matrix besides B vector
    scatter = scatter_matrix(res, fov, z, a, lambDa, k_dir, dimension)

    # calculate every order of the integration
    Sum = scatter * B
    # integrate through all the orders to get 
    # the farfield in the Fourier Domain
    E_far_shifted = np.sum(Sum, axis = -1) * scale

    if dimension == 2:
        # shift the Forier transform of 
        # the scatttering field for visualization
        E_far = np.fft.ifftshift(E_far_shifted)
    elif dimension == 1:
        E_far = E_far_shifted

    return E_far

def far2near(far_field):
    """
    Calculate the near field simulation from the far field image

    Parameters
    ----------
        far_field: 2-D array, complex
            the far field simulation

    Returns
    -------
        near_field: 2-D array, complex
            the near field image
    """

    near_field = np.fft.ifftshift(np.fft.ifft2(np.fft.fftshift(far_field)))

    return near_field

def bandpass_filter(res, fov, NA_in, NA_out, dimension=2):
    """
    Create a bandpass filter in the Fourier domain based on the
    back numberical aperture (NA) of the objective

    A bandpass filter in the Foureir domain is essentially a
    cocentric circle with inner and outer radius specified
    by center obscuration and back aperture
    Anything blocked by the objective will be masked as zeros

    Parameters
    ----------
        res: int, 
            resolution of the simulation
        fov: int, 
            field of view
        NA_in: float,
            center obscuration of the objective
        NA_out: float,
            back aperture of the objective
        dimension: 1 or 2
            dimension of the simulation

    Returns
    -------
        bpf: 2-D or 1-D array, int (1/0)
            bandpass filter
    """

    # create a meshgrid in the Fourier domain
    fx = np.fft.fftfreq(res, fov/res)
    [kx, ky] = np.meshgrid(fx, fx)
    kxky = np.sqrt(kx**2 + ky**2)

    # initialize the filter
    bpf = np.zeros((res, res))

    # compute the mask
    mask_out = kxky <= NA_out
    mask_in = kxky >= NA_in

    # combine the masks
    mask = np.logical_and(mask_out, mask_in)

    # mask the filter
    bpf[mask] = 1

    # return according to the dimension
    if dimension == 2:
        bpf_return = bpf
    elif dimension == 1:
        bpf_return = bpf[0, :int(res/2)+1]
    else:
        raise ValueError('The dimension of the simulation is invalid!')

    return bpf_return

def idhf(res, fov, y):
    """
    Inverse Discrete Hankel Transform of an 1D array

    Parameters
    ----------
        res: int, 
            resolution of the simulation
        fov: int, 
            field of view
        y: 1-D array, complex
            data to be transformed

    Returns
    -------
        F: 1-D array, complex
            transformed data
        F_x: 1-D array, float
            sample index
    """

    X = int(fov/2)
    n_s = int(res/2)

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

def apply_filter(res, fov, E, bpf):
    """
    Apply the filter to the field
    the field in the real domain is transformed into Fourier domain
    then multiplied by the filter in the Fourier domain so that
    the frequency components that are outside of the filter are filtered out
    Then the filtered field is transformed back into the real domain

    Parameters
    ----------
        E: 2-D array, compelx or real
            input field
        bpf: 2-D array, 1 or 0
            the bandpass filter to be applied

    Returns
    -------
        E_filtered: 2-D array, complex or real
            filtered field in the real domain
    """

    if E.ndim == 2:
        # apply Fourier transform to the input field
        E_fft = np.fft.fft2(E)

        # apply the filter
        E_fft_filtered = E_fft * bpf

        # convert the field back
        E_filtered = np.fft.ifft2(E_fft_filtered)

        return E_filtered

    elif E.ndim == 1:
        # apply the filter to the 1-D simulation
        E_dht_filtered = E * bpf

        # apply inverse hankel transform
        E_filtered, E_x = idhf(res, fov, E_dht_filtered)

        return E_filtered, E_x

def crop_field(res, E):
    """
    Crop the field into the specified resolution and field of view

    Parameters
    ----------
        res: int
            the resolution be crop the field to
        E: 2-D array, complex or real
            input field

    Returns
    -------
        E_crop: 2-D array, (res, res)
            cropped field
    """

    # get the size before and after cropping
    imsize = E.shape[0]
    cropsize = res

    # compute the starting and ending index of the axis
    startIdx = int(np.fix(imsize /2) - np.floor(cropsize/2))
    endIdx = int(startIdx + cropsize - 1)

    # crop the field
    E_crop = E[startIdx:endIdx+1, startIdx:endIdx+1]

    return E_crop

def get_phase_shift(res, fov, k, d):
    """
    calculate a 2-D phase shift mask with distance d
    
    Parameters
    ----------
        res: int, 
            resolution of the simulation
        fov: int, 
            field of view
        k: float,
            wavenumber
        d: float,
            propagation distance
        
    Returns
    -------
        phase: 2-D array, complex
            phase shift map
    """
    # calculate the fourier frequencies
    fx = np.fft.fftfreq(res, fov/res)
    fy = np.fft.fftfreq(res, fov/res)
    
    # calculate kz
    kx, ky = np.meshgrid(fx, fy)
    kxky = kx ** 2 + ky ** 2
    mask = kxky > k**2
    kxky[mask] = 0
    kz = np.sqrt(k**2 - kxky)
    kz[mask] = 0
    
    # calculate phase term
    phase = np.exp(1j * kz * d)
    
    return phase

def normalize(E):
    """
    normalize the 1-D field after inverse discrete Hankel Transform
    
    Parameters
    ----------
        E: complex, 1-D vector
            the input field
    
    Returns
    -------
        E_norm: complex, 1-D vector
            the normalized field with 0 mean and 1 variance
    """
    
    E_norm = (E-np.mean(E))/np.std(E)
    
    return E_norm