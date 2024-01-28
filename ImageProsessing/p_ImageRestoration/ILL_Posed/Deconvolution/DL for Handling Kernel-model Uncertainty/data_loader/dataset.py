import os
from matplotlib.image import imread
from torch.utils.data import Dataset
import numpy as np
import torch
from .kernels import center_ker
from utils.imtools import for_fft, rgb2gray, imshow
import utils.comfft as cf
from scipy.io import loadmat
from glob import glob
import re

class Test_NoiseKernel(Dataset):
    def __init__(self, test_sp_dir, test_bl_dir, test_ker_dir, tr_ker_dir ,taper = 'same'):

        self.bl_dir = test_bl_dir
        self.ker_dir= test_ker_dir
        self.sp_dir = test_sp_dir
        self.sp_file = sorted(glob(self.sp_dir + '*.png'))
        self.taper = taper
        self.ker_num = 8

        ker_mat = loadmat(tr_ker_dir)
        ker_mat = ker_mat['kernels']
        self.get_ker = lambda idx: ker_mat[0, idx]

    def  __len__(self):
        img_num = len(self.sp_file) * self.ker_num
        return img_num

    def __getitem__(self, item):
        '''load test item one by one'''
        i = item // self.ker_num
        j = item % self.ker_num

        sp = imread(os.path.join(self.sp_dir, 'im_%d.png'%(i+1)))
        bl_path = glob(os.path.join(self.bl_dir, 'im_%d_ker_%d*.png'%(i+1,j+1)))
        bl = imread(bl_path[0])

        ker_name = glob(os.path.join(self.ker_dir, 'k_%d_im_%d_*' % (j + 1, i + 1)))
        ker = imread(ker_name[0])
        ker = ker / np.sum(ker)

        tr_ker = self.get_ker(j)
        tr_ker_pad = np.full([50, 50], np.nan)
        tr_ker_pad[:tr_ker.shape[0], :tr_ker.shape[1]] = tr_ker

        tr_ker_mat = torch.FloatTensor(for_fft(tr_ker, shape=np.shape(sp)))
        tr_Fker = cf.fft(tr_ker_mat).unsqueeze(0)

        if self.taper == 'valid':
            from utils.imtools import pad_for_kernel, edgetaper
            bl = edgetaper(pad_for_kernel(bl, tr_ker, 'edge'), ker)
            bl = bl.astype(np.float32)


        ker_pad = np.full([50, 50], np.nan)
        ker_pad[:ker.shape[0], :ker.shape[1]] = ker


        ker_mat = torch.FloatTensor(for_fft(ker, shape=np.shape(sp)))
        Fker = cf.fft(ker_mat).unsqueeze(0)

        hy = (ker.shape[0] - 1) // 2
        hx = (ker.shape[0] - 1) - hy
        wy = (ker.shape[1] - 1) // 2
        wx = (ker.shape[1] - 1) - wy
        padding = np.array((hx, hy, wx, wy), dtype=np.int64)

        sp = torch.from_numpy(sp).unsqueeze(0)
        bl = torch.from_numpy(bl).unsqueeze(0)

        dic = {'bl': bl, 'sp': sp, 'Fker':Fker, 'padding': padding.copy(), 'ker': ker_pad.copy(), 'tr_ker':tr_ker_pad.copy(),
               'tr_Fker':tr_Fker, 'name': 'im_%d_ker_%d'%(i+1,j+1)}

        return dic

class Test_Lai_NoiseKernel(Dataset):
    def __init__(self, test_sp_dir, test_bl_dir, test_ker_dir,taper = 'same'):

        self.bl_dir = test_bl_dir
        self.ker_dir= test_ker_dir
        self.sp_dir = test_sp_dir
        self.sp_file = sorted(glob(self.sp_dir + '*.png'))
        self.ker_file = sorted(glob(self.ker_dir + '*.png'))
        self.taper = taper
        self.ker_num = 4

    def  __len__(self):
        img_num = len(self.ker_file)
        return img_num

    def __getitem__(self, item):
        '''load test item one by one'''
        ker_name = self.ker_file[item]
        sp_name = re.findall(r'psf_([\s\S]*)_kernel',ker_name)[0]
        tr_ker_name = re.findall(r'_kernel_([\s\S]*)_1',ker_name)[0]

        sp = imread(self.sp_dir+sp_name+'.png')[:,:,:3]

        bl = imread(self.bl_dir + sp_name+'_kernel_'+tr_ker_name+'.png')

        ker = rgb2gray(imread(ker_name))
        ker = ker / np.sum(ker)
        ker = np.rot90(ker,2)


        tr_ker = rgb2gray(imread('./data/Lai_NK/kernels/kernel_'+tr_ker_name+'.png'))
        tr_ker = tr_ker / np.sum(tr_ker)

        ker = center_ker(ker,tr_ker)

        tr_ker_pad = np.full([110, 110], np.nan)
        tr_ker_pad[:tr_ker.shape[0], :tr_ker.shape[1]] = tr_ker

        if self.taper == 'valid':
            from utils.imtools import pad_for_kernel, edgetaper
            bl_pad = np.zeros_like(sp)
            for chn in range(3):
                bl_pad[:,:,chn] = edgetaper(pad_for_kernel(bl[:,:,chn], tr_ker, 'edge'), ker).astype(np.float32)
            bl = bl_pad


        ker_mat = torch.FloatTensor(for_fft(tr_ker, shape=np.shape(sp[:,:,0])))
        tr_Fker = cf.fft(ker_mat).unsqueeze(0)

        ker_pad = np.full([110, 110], np.nan)
        ker_pad[:ker.shape[0], :ker.shape[1]] = ker


        ker_mat = torch.FloatTensor(for_fft(ker, shape=np.shape(sp[:,:,0])))
        Fker = cf.fft(ker_mat).unsqueeze(0)

        hy = (ker.shape[0] - 1) // 2
        hx = (ker.shape[0] - 1) - hy
        wy = (ker.shape[1] - 1) // 2
        wx = (ker.shape[1] - 1) - wy
        padding = np.array((hx, hy, wx, wy), dtype=np.int64)

        sp = torch.from_numpy(sp).unsqueeze(0)
        bl = torch.from_numpy(bl).unsqueeze(0)

        dic = {'bl': bl, 'sp': sp, 'Fker':Fker, 'padding': padding.copy(), 'ker': ker_pad.copy(),
               'tr_ker':tr_ker_pad.copy(), 'tr_Fker':tr_Fker, 'name':sp_name + '_' + tr_ker_name}

        return dic

class Test_Real_NoiseKernel(Dataset):
    def __init__(self, test_bl_dir, test_ker_dir,taper = 'same'):

        self.bl_dir = test_bl_dir
        self.ker_dir= test_ker_dir
        self.ker_file = sorted(glob(self.ker_dir + '*.png'))
        self.taper = taper

    def  __len__(self):
        img_num = len(self.ker_file)
        return img_num

    def __getitem__(self, item):
        '''load test item one by one'''
        ker_name = self.ker_file[item]
        sp_name = re.findall(r'(?<=s\/).+(?=_[\d*])',ker_name)[0]
        name = re.findall(r'(?<=s\/).+(?=.png)',ker_name)[0]
        bl = imread(self.bl_dir + sp_name +'.jpg').astype(np.float32)/255


        ker = imread(ker_name)
        if ker.ndim == 3: ker = rgb2gray(ker)
        ker = ker / np.sum(ker)
        # ker = np.rot90(ker,2)

        if self.taper == 'valid':
            from utils.imtools import pad_for_kernel, edgetaper
            bl_pad = []
            for chn in range(3):
                bl_pad.append(edgetaper(pad_for_kernel(bl[:,:,chn], ker, 'edge'), ker).astype(np.float32))
            bl = np.stack(bl_pad, axis=2)

        ker_pad = np.full([110, 110], np.nan)
        ker_pad[:ker.shape[0], :ker.shape[1]] = ker


        ker_mat = torch.FloatTensor(for_fft(ker, shape=np.shape(bl[:,:,0])))
        Fker = cf.fft(ker_mat).unsqueeze(0)

        bl = torch.from_numpy(bl).unsqueeze(0)
        imshow(bl,'im%d_pad'%item)

        dic = {'bl': bl,  'Fker':Fker,  'ker': ker_pad.copy(),  'name':name}
        return dic
