"""
Fast Single Image Haze Removal Using Dark Channel Prior
Final Project of "INF01050 - Computational Photography" class, 2016, at UFRGS.

Carlo S. Sartori
"""

import numpy;

def guided_filter(imgar, p, r=40, eps=1e-3):
    """
    Filter refinement under the guidance of an image. O(N) implementation.
    According to the reference paper http://research.microsoft.com/en-us/um/people/kahe/eccv10/
    
    Parameters
    -----------
    imgar:    an H*W RGB image used as guidance.
    p:        the H*W filter to be guided
    r:        the radius of the guided filter (in pixels, default=40)
    eps:      the epsilon parameter (default=1e-3)  

    Return
    -----------
    The guided filter p'.
    """
    #H: height, W: width, C:colors
    H, W, C = imgar.shape 
    #S is a matrix with the sizes of each local patch (window wk)
    S = __boxfilter__(numpy.ones((H, W)), r)
    
    #the mean value of each channel in imgar
    mean_i = numpy.zeros((C, H, W))
    
    for c in range(0, C):
        mean_i[c] = __boxfilter__(imgar[:,:, c], r)/S
    
    #the mean of the guided filter p
    mean_p = __boxfilter__(p, r)/S
    
    #the correlation of (imgar, p) corr_ip in each channel
    mean_ip = numpy.zeros((C, H, W))
    for c in range(0, C):
        mean_ip[c] = __boxfilter__(imgar[:,:,c]*p, r)/S
    
    #covariance of (imgar, p) cov_ip in each channel
    cov_ip = numpy.zeros((C, H, W))
    for c in range(0, C):
        cov_ip[c] = mean_ip[c] - mean_i[c]*mean_p
    
    #variance of imgar in each local patch (window wk), used to build the matrix sigma_k in eq.(14)
    #The variance in each window is a 3x3 symmetric matrix with variance as its values:
    #           rr, rg, rb
    #   sigma = rg, gg, gb
    #           rb, gb, bb
    var_i = numpy.zeros((C, C, H, W))
    #variance of (Red, Red)
    var_i[0, 0] = __boxfilter__(imgar[:,:,0]*imgar[:,:,0], r)/S - mean_i[0]*mean_i[0]
    #variance of (Red, Green)
    var_i[0, 1] = __boxfilter__(imgar[:,:,0]*imgar[:,:,1], r)/S - mean_i[0]*mean_i[1]
    #variance of (Red, Blue)
    var_i[0, 2] = __boxfilter__(imgar[:,:,0]*imgar[:,:,2], r)/S - mean_i[0]*mean_i[2]
    #variance of (Green, Green)
    var_i[1, 1] = __boxfilter__(imgar[:,:,1]*imgar[:,:,1], r)/S - mean_i[1]*mean_i[1]
    #variance of (Green, Blue)
    var_i[1, 2] = __boxfilter__(imgar[:,:,1]*imgar[:,:,2], r)/S - mean_i[1]*mean_i[2]
    #variance of (Blue, Blue)
    var_i[2, 2] = __boxfilter__(imgar[:,:,2]*imgar[:,:,2], r)/S - mean_i[2]*mean_i[2]
    
    a=numpy.zeros((H,W,C))
    
    for i in range(0, H):
        for j in range(0, W):
            sigma = numpy.array([ [var_i[0, 0, i, j], var_i[0, 1, i, j], var_i[0, 2, i, j]], 
                                  [var_i[0, 1, i, j], var_i[1, 1, i, j], var_i[1, 2, i, j]],
                                  [var_i[0, 2, i, j], var_i[1, 2, i, j], var_i[2, 2, i, j]]])
            
            #covariance of (imgar, p) in pixel (i,j) for the 3 channels
            cov_ip_ij = numpy.array([ cov_ip[0, i, j], cov_ip[1, i, j], cov_ip[2, i, j]])
            
            a[i, j] = numpy.dot(cov_ip_ij, numpy.linalg.inv(sigma + eps*numpy.identity(3))) #eq.(14)
    
    b = mean_p - a[:,:,0]*mean_i[0,:,:] - a[:,:,1]*mean_i[1,:,:] - a[:,:,2]*mean_i[2,:,:] #eq.(15)
    
    #the filter p'  eq.(16)
    pp = ( __boxfilter__(a[:,:,0], r)*imgar[:,:,0]
          +__boxfilter__(a[:,:,1], r)*imgar[:,:,1]
          +__boxfilter__(a[:,:,2], r)*imgar[:,:,2]
          +__boxfilter__(b, r) )/S
    
    return pp


def __boxfilter__(m, r):
    """
    Fast box filtering implementation, O(1) time.

    Parameters
    ----------
    m:  a 2-D matrix data normalized to [0.0, 1.0]
    r:  radius of the window considered

    Return
    -----------
    The filtered matrix m'.
    """
    #H: height, W: width
    H, W = m.shape
    #the output matrix m'
    mp = numpy.zeros(m.shape) 
    
    #cumulative sum over y axis
    ysum = numpy.cumsum(m, axis=0) 
    #copy the accumulated values of the windows in y
    mp[0:r+1, : ] = ysum[r:(2*r)+1, : ]
    #differences in y axis
    mp[r+1:H-r, : ] = ysum[(2*r)+1: , : ] - ysum[ :H-(2*r)-1, : ]
    mp[(-r): , : ] = numpy.tile(ysum[-1, : ], (r, 1)) - ysum[H-(2*r)-1:H-r-1, : ]

    #cumulative sum over x axis
    xsum = numpy.cumsum(mp, axis=1)
    #copy the accumulated values of the windows in x
    mp[ : , 0:r+1] = xsum[ : , r:(2*r)+1]
    #difference over x axis
    mp[ : , r+1:W-r] = xsum[ : , (2*r)+1: ] - xsum[ : , :W-(2*r)-1]
    mp[ : , -r: ] = numpy.tile(xsum[ : , -1][:, None], (1, r)) - xsum[ : , W-(2*r)-1:W-r-1]

    return mp