# -*- coding: utf-8 -*-

import numpy as np
import scipy.fft
import utils


"""## Modified Wiener"""

def mW(F, y, maxiter=100):
    nsr = utils.estimate_nsr(y)
    #a = 100.0*nsr
    a = nsr
    
    W = y.copy()
    FW = F(W)
    H = scipy.fft.fftn(FW) / (scipy.fft.fftn(W) + 1e-16)

    for i in range(1, maxiter+1):
        H = H*(i-1)/i + scipy.fft.fftn(FW) / (scipy.fft.fftn(W) + 1e-16)/i
        Hconj = np.conjugate(H)
        W = np.real(scipy.fft.ifftn(Hconj/(Hconj*H + a)*scipy.fft.fftn(y)))
        FW = F(W)

    return W

