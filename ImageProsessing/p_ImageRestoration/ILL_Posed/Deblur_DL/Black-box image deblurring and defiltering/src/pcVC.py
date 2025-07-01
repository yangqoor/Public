# -*- coding: utf-8 -*-
import numpy as np
import scipy.fft
import utils 


"""## Phase corrected Van Cittert"""
def pcVC(F, y, maxiter=100):
    TM = y.copy()
    
    for i in range(maxiter):
        H = scipy.fft.fftn(F(TM)) / (scipy.fft.fftn(TM)+2.2204e-16)
        TM = TM + np.real(scipy.fft.ifftn((scipy.fft.fftn(y)/(H+2.2204e-16)-scipy.fft.fftn(TM)) * np.absolute(H)))
    return TM


def pcVC_nsr(F, y, maxiter=100):
    # Use the same formulation as in the paper 
    nsr = utils.estimate_nsr(y)
    a = 100.0*nsr 
    TM = y.copy()
    
    for i in range(maxiter):
        H = scipy.fft.fftn(F(TM)) / (scipy.fft.fftn(TM)+2.2204e-16)
        Hconj = np.conjugate(H)
        TM = TM + np.real(scipy.fft.ifftn(Hconj/(np.absolute(H)+a) * (scipy.fft.fftn(y) - H*scipy.fft.fftn(TM))))
    return TM

