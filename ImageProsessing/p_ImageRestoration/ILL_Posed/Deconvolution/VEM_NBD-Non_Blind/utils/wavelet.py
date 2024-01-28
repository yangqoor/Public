''' wavelet toolbox for multilevel wavelet decomposition and reconstruction '''
import numpy as np
def GenerateFilter(frame = 1):
    if frame == 0:
        # D = [np.array([0,1/2,1/2]),np.array([0,1/2,-1/2])]
        D = np.array([[0,1/2,1/2],[0,1/2,-1/2]])
    elif frame == 1:
        D = np.array([[1/4,1/2,1/4],[1/4*np.sqrt(2),0,-1/4*np.sqrt(2)],[-1/4,1/2,-1/4]])
    elif frame == 3:
        D = np.array([[1/16,4/16,6/16,4/16,1/16],
                      [1/8,2/8,0/8,-2/8,-1/8],
                      [-1/16*np.sqrt(6),0,2/16*np.sqrt(6),0,-1/16*np.sqrt(6)],
                      [-1/8,2/8,0,-2/8,1/8],
                      [1/16,-4/16,6/16,-4/16,1/16]])
    return D

def DecFilterML(D,level = 1,dim = 2):
    nD = len(D)
    lD = len(D[1])
    Dec = {}
    for i in range(nD):
        Dec[1,i] = np.flip(D[i],0)

    for lv in range(2,level+1):
        step = 2**(lv-1)
        for i in range(1,nD+1):
            H0 = np.zeros(shape=[(lD-1)*step+1])
            H0[0:step * (lD - 1) + 1:step] = Dec[1,i-1]
            Dec[lv,i-1] = np.convolve(Dec[lv-1,0],H0,mode='full')

    if dim == 1:
        return Dec
    elif dim == 2:
        Dec2 = {}
        for lv in range(1,level+1):
            for i in range(0,nD):
                for j in range(0,nD):
                    Dec2[lv, i, j] = np.kron(np.reshape(Dec[lv,i],(-1,1)),np.reshape(Dec[lv,j],(1,-1)))
        return Dec2
    elif dim == 3:
        Dec3 = {}
        for lv in range(1,level+1):
            for i in range(0,nD):
                for j in range(0,nD):
                    for k in range(0,nD):
                        tmp = np.kron(np.reshape(Dec[lv,i],(-1,1,1)),np.reshape(Dec[lv,j],(1,-1,1)))
                        Dec3[lv,i,j,k] = np.kron(tmp,np.reshape(Dec[lv,k],(1,1,-1)))

        return Dec3

def RecFilterML(D,level = 1,dim = 2):
    nD = len(D)
    lD = len(D[1])
    Rec = {}
    for lv in range(1,level+1):
        if lv == 1:
            for i in range(0,nD):
                Rec[1,i] = D[i]
        else:
            step = 2**(lv-1)
            for i in range(0,nD):
                H0 = np.zeros(shape=[(lD-1)*step+1])
                H0[0:step*(lD - 1)+1:step] = Rec[1,i]
                Rec[lv,i] = np.convolve(Rec[lv-1,0],H0,mode='full')

    if dim == 1:
        return Rec
    elif dim == 2:
        Rec2 = {}
        for lv in range(1, level + 1):
            for i in range(0, nD):
                for j in range(0, nD):
                    Rec2[lv,i,j] = np.kron(np.reshape(Rec[lv,i],(1,-1)),np.reshape(Rec[lv,j],(-1,1))).T
        return Rec2
    elif dim == 3:
        Rec3 = {}
        for lv in range(1,level+1):
            for i in range(0,nD):
                for j in range(0,nD):
                    for k in range(0,nD):
                        tmp = np.kron(np.reshape(Rec[lv,i],(-1,1,1)),np.reshape(Rec[lv,j],(1,-1,1)))
                        Rec3[lv,i,j,k]  = np.kron(tmp,np.reshape(Rec[lv,k],(1,1,-1)))
        return Rec3

def generate_wavelet(frame=1, dim = 2, highpass = True):
    D = GenerateFilter(frame)
    if dim == 2:
        Dec = DecFilterML(D)
        Rec = RecFilterML(D)
        if highpass == True:
            del Dec[1,0,0]
            del Rec[1,0,0]
    elif dim == 3:
        Dec = DecFilterML(D, dim=3)
        Rec = RecFilterML(D, dim=3)
        if highpass == True:
            del Dec[1,0,0,0]
            del Rec[1,0,0,0]
    return Dec, Rec

def get_grad_filter():
    Dec = {}
    Dec[0, 0, 0] = np.array([[1, -1]])
    Dec[0, 0, 1] = np.array([[1], [-1]])
    return Dec

def get_four_filter():
    Dec = {}
    Dec[0, 0, 0] = np.array([[1, -1]])
    Dec[0, 0, 1] = np.array([[1], [-1]])
    Dec[0, 1, 0] = np.array([[1, 0],[0,-1]])
    Dec[0, 1, 1] = np.array([[-1,0],[0,1]])
    return Dec
def wv_norm(Dec, dtype=np.float32):
    chan = len(Dec)
    WvNorm = np.zeros(chan,dtype=dtype)
    j = 0
    for d in Dec:
        norm = np.sum(np.abs(Dec[d]))
        WvNorm[j] = norm
        j += 1
    return WvNorm

from .imtools import for_fft
def Fwv(Dec, shape=(256,256)):
    chan_num = len(Dec)
    W = np.zeros((chan_num, *shape), dtype = np.float32)
    i = 0
    for d in Dec:
        W[i,] = for_fft(Dec[d], shape=shape)
        i += 1

    W = torch.from_numpy(W)
    Fw = torch.zeros((chan_num, *shape, 2))
    for i in range(chan_num):
        Fw[i,] = torch.rfft(W[i,], signal_ndim = 2, onesided = False)
    return Fw

import torch
from .imtools import cconv_torch
def wv_dec(x, Dec = None, weights = None):
    with torch.no_grad():
        img_num = x.size()[0]
        img_shape = x.size()[2:]
        if Dec is None:
            Dec, _ = generate_wavelet(1,dim=2)

        w = torch.ones(len(Dec)).cuda()
        if weights is not None:
            if isinstance(weights,list) == True:
                w = torch.FloatTensor(weights)
                w = w.view(len(Dec), 1, 1, 1).cuda()
            else:
                norm = torch.from_numpy(wv_norm(Dec))
                w = torch.ones(len(Dec)) * weights / norm
                w = w.view(len(Dec), 1, 1, 1).cuda()

        chan = len(Dec)
        z = torch.zeros((img_num, chan, *img_shape)).cuda()
        for i in range(img_num):
            x_s = x[i,]
            j = 0
            for idx in Dec:
                z[i,j,] = cconv_torch(x_s[0,],Dec[idx]) * w[j]
                j += 1
    return z

def wv_rec(x, Rec = None):
    with torch.no_grad():
        img_num = x.size()[0]
        img_shape = x.size()[2:]
        if Rec is None:
            _, Rec = generate_wavelet(1,dim=2)

        z = torch.zeros((img_num, 1, *img_shape)).cuda()
        for i in range(img_num):
            x_s = x[i,]
            j = 0
            for idx in Rec:
                z[i,0,] += cconv_torch(x_s[j,],Rec[idx])
                j += 1
    return z


