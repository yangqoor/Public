# -*- coding: utf-8 -*-

import numpy as np
import skimage
import skimage.color
import scipy.signal
import scipy.fft


"""## Some helper functions (psf2otf, zero padding, estimate noise, ...)"""

def zero_pad(image, shape, position='corner'):
    shape = np.asarray(shape, dtype=int)
    imshape = np.asarray(image.shape, dtype=int)

    if np.alltrue(imshape == shape):
        return image

    if np.any(shape <= 0):
        raise ValueError("ZERO_PAD: null or negative shape given")

    dshape = shape - imshape
    if np.any(dshape < 0):
        raise ValueError("ZERO_PAD: target size smaller than source one")

    pad_img = np.zeros(shape, dtype=image.dtype)

    idx, idy = np.indices(imshape)

    if position == 'center':
        if np.any(dshape % 2 != 0):
            raise ValueError("ZERO_PAD: source and target shapes "
                             "have different parity.")
        offx, offy = dshape // 2
    else:
        offx, offy = (0, 0)

    pad_img[idx + offx, idy + offy] = image

    return pad_img


def psf2otf(psf, shape):
    if np.all(psf == 0):
        return np.zeros_like(psf)

    pad = False

    if len(shape) == 3:
        pad = True
        orig_shape = shape
        shape = (shape[0], shape[1])

    inshape = psf.shape
    psf = zero_pad(psf, shape, position='corner')

    for axis, axis_size in enumerate(inshape):
        psf = np.roll(psf, -int(axis_size / 2), axis=axis)

    if pad:
        psf2 = np.zeros(orig_shape)
        psf2[:,:,0] = psf
    else:
        psf2 = psf

    otf = scipy.fft.fftn(psf2)

    n_ops = np.sum(psf.size * np.log2(psf.shape))
    otf = np.real_if_close(otf, tol=n_ops)

    return otf


def estimate_noise(I):
    H = I.shape[0]
    W = I.shape[1]
    M = np.array([[1, -2, 1], [-2, 4, -2], [1, -2, 1]])
    S = np.sum(np.sum(np.abs(scipy.signal.convolve2d(I, M))))
    S = S*np.sqrt(0.5*np.pi)/(6.0*(W-2.0)*(H-2.0))
    return S


def estimate_nsr(I):
    I = skimage.color.rgb2gray(skimage.color.rgba2rgb(I)) if len(I.shape) == 3 else I
    en = estimate_noise(I)
    nsr = en**2 / np.var(I[:])
    return nsr


def reflect(I):
    if len(I.shape) == 3:
        Is = I[::-1, ::-1, :]
    else:
        Is = I[::-1, ::-1]
    return Is

