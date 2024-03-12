"""
Fast Single Image Haze Removal Using Dark Channel Prior
Final Project of "INF01050 - Computational Photography" class, 2016, at UFRGS.

Carlo S. Sartori
"""

import DarkChannel;
import AtmLight;
import Transmission;
import Refine;
import Radiance;
import numpy;

"""
Main References 
[1] Single Image Haze Removal Using Dark Channel Prior (2009)
    http://kaiminghe.com/cvpr09/index.html
    
[2] Guided Image Filtering (2010)
    http://kaiminghe.com/eccv10/index.html
        
"""

def dehaze(imgar, a=None, t=None, rt=None, tmin=0.1, ps=15, w=0.95, px=1e-3, r=40, eps=1e-3, m=False):
    """
    Application of the dehazing algorithm, as described in section (4) of the reference paper
    http://kaiminghe.com/cvpr09/index.html
    
    Parameters
    -----------
    imgar:    an H*W RGB hazed image
    a:        the atmospheric light RGB array of imgar (default=None, will be calculated internally)
    t:        the transmission matrix H*W of imgar (default=None, will be calculated internally)
    rt:       the raw transmission matrix H*W of imgar, to be refined (default=None, will be calculated internally)
    tmin:     the minimum value the transmission can take (default=0.1)
    ps:       the patch size for dark channel estimation (default=15)
    w:        the omega weight, ammount of haze to be kept (default=0.95)
    px:       the percentage of brightest pixels to be considered when estimating atmospheric light (default=1e-3, i.e. 0.1%)
    r:        the radius of the guided filter in pixels (default=40)
    eps:      the epsilon parameter for guided filter (default=1e-3)
    m:        print out messages along processing

    Return
    -----------
    The dehazed image version of imgar, dehazed (a H*W RGB matrix).
    """ 
	
    jdark = DarkChannel.estimate(imgar, ps)
    #return jdark
    #if no atmospheric given
    if a == None:
        a = AtmLight.estimate(imgar, jdark)
        if(m == True):
            print 'Atmospheric Light estimated.'
    
    #if no raw transmission and complete transmission given
    if rt == None and t == None:
        rt = Transmission.estimate(imgar, a, w)
        #threshold of raw transmission
        rt = numpy.maximum(rt, tmin)
        if(m == True):
            print 'Transmission estimated.'
    
    #if no complete transmission given, refine the raw using guided filter
    if t == None:
        t = Refine.guided_filter(imgar, rt)
        if(m == True):
           print 'Transmission refined.'
    
    #recover the scene radiance
    dehazed = Radiance.recover(imgar, a, t, tmin)
    if(m == True):        
       print 'Radiance recovered.'
    
    return dehazed
