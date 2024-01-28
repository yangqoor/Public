import numpy as np
from utils.imtools import fspecial, cconv_np, imshow
from scipy.ndimage.morphology import binary_dilation,generate_binary_structure
from scipy.ndimage.measurements import center_of_mass

def gen_nker(ker, v_g = 0.01, gaus_var = 0.8):
    ''' Our kernel generation method '''
    kh, kv = np.shape(ker)
    nz = v_g*np.random.randn(kh, kv)
    if v_g == 0:
        f = fspecial('gaussian', [5, 5], gaus_var)
        nz_ker = cconv_np(ker, f)
        nz_ker = nz_ker / np.sum(nz_ker)
        return nz_ker

    ## Blurry Some Part of kernel
    W_v = (ker>0)
    struct = generate_binary_structure(2, 1)
    W_v = binary_dilation(W_v, struct)
    nz_W_v = nz * W_v
    nz_ker = ker + nz_W_v

    ## Omit some part
    if np.random.randint(2):
        Omt = np.random.binomial(1, 0.5, size=[kh, kv])
        Omt[nz_ker == np.max(nz_ker)] = 1
        nz_ker = nz_ker * Omt

    b_s = np.random.randint(1, 5,size = 2)
    b_v = np.random.uniform(0.05,gaus_var)
    f = fspecial('gaussian',b_s, b_v)
    nz_ker = cconv_np(nz_ker, f)

    ## Add uniform noises
    W_rand = np.random.binomial(1, 0.03, size=[kh, kv])
    nz_ker += W_rand * np.random.randn(kh, kv) * 0.002
    if np.sum(nz_ker) ==0:
        print('np.sum(nz_ker)==0')
        nz_ker = ker + nz_W_v
        return nz_ker / np.sum(nz_ker)
    nz_ker[nz_ker<1e-5] = 0
    nz_ker = nz_ker / np.sum(nz_ker)

    return nz_ker

def center_ker(ker, tr_ker=None):
    if tr_ker is None:
        tkrh = 0
        tkrv = 0
    else:
        ctkh, ctkv = center_of_mass(tr_ker)
        tkh, tkv = np.shape(tr_ker)
        tkh2 = tkh / 2
        tkv2 = tkv / 2
        tkrh = tkh2 - ctkh - 1
        tkrv = tkv2 - ctkv - 1


    ckh, ckv = center_of_mass(ker)
    kh, kv = np.shape(ker)
    kh2 = kh / 2
    kv2 = kv / 2


    rh = int(round((kh2 - ckh -1) - tkrh))
    rv = int(round((kv2 - ckv -1) - tkrv))

    ker_roll = np.roll(ker, (rh, rv), (0,1))
    return ker_roll
