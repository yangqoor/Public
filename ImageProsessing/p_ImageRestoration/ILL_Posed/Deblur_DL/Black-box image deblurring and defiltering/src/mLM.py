# -*- coding: utf-8 -*-

import numpy as np
import scipy.fft
import utils 


def mLM(F, y, maxiter=100):
    nsr = utils.estimate_nsr(y)
    a = 100.0*nsr 

    lm = y.copy()
    
    for i in range(maxiter):
        Flm = F(lm)
        H = scipy.fft.fftn(Flm) / (scipy.fft.fftn(lm) + 1e-16)
        Hconj = np.conjugate(H)
        num = Hconj * (scipy.fft.fftn(y - Flm))
        denom = (Hconj * H + a)
        lm = lm + np.real(scipy.fft.ifftn(num/denom))

    return lm

