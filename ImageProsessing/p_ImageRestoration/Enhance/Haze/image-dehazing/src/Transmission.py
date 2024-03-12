"""
Fast Single Image Haze Removal Using Dark Channel Prior
Final Project of "INF01050 - Computational Photography" class, 2016, at UFRGS.

Carlo S. Sartori
"""

import numpy;
import DarkChannel;


def estimate(imgar, A, w=0.95):
    """
    Transmission estimation. According to section (4.1) equation (11) in the reference paper
    http://kaiminghe.com/cvpr09/index.html
    
    Parameters
    -----------
    imgar:    an H*W RGB hazed image
    A:        the atmospheric light of imgar
    w:        the omega weight parameter, the amount of haze to be removed (default=0.95)

    Return
    -----------
    The transmission estimated in imgar, t (a H*W matrix).
    """ 
    #the normalized haze image
    nimg = numpy.zeros(imgar.shape)
    
    #calculate the normalized haze image 
    for c in range(0, imgar.shape[2]):
        nimg[:,:,c] = imgar[:,:,c]/A[c]
    
    #estimate the dark channel of the normalized haze image
    njdark = DarkChannel.estimate(nimg)
    
    #calculates the transmisson t
    t = 1-w*njdark+0.25
    
    return t
