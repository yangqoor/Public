import os
import re
from glob import glob
from matplotlib.image import imread
import numpy as np
import torch
from scipy.io import loadmat
from torch.utils.data import Dataset

from data_loader.kernels import get_blur
from utils.imtools import for_fft
from utils import comfft as cf

class Test_Dataset(Dataset):
    def __init__(self, test_sp_dir, test_bl_dir, test_ker_dir):

        self.bl_dir = test_bl_dir
        self.sp_dir = test_sp_dir
        self.ker_dir = test_ker_dir
        self.sp_file = sorted(glob(self.sp_dir + '*.png'))

        ker_mat = loadmat(test_ker_dir)
        ker_mat = ker_mat['kernels']
        self.get_ker = lambda idx: ker_mat[0, idx]
        self.ker_num = len(ker_mat[0])


    def  __len__(self):
        img_num = len(self.sp_file) * self.ker_num
        return img_num

    def __getitem__(self, item):
        i = item // self.ker_num
        j = item % self.ker_num
        sp = imread(os.path.join(self.sp_dir, 'im_%d.png'%(i+1)))
        bl = imread(os.path.join(self.bl_dir, 'im_%d_ker_%d.png'%(i+1,j+1)))

        ker = self.get_ker(j)
        ker_pad = np.full([50, 50], np.nan)
        ker_pad[:ker.shape[0], :ker.shape[1]] = ker

        ker_mat = torch.FloatTensor(for_fft(ker, shape=np.shape(sp)))
        Fker = cf.fft(ker_mat)

        sp = torch.from_numpy(sp).unsqueeze(0)
        bl = torch.from_numpy(bl).unsqueeze(0)
        dic = {'bl': bl, 'sp': sp, 'Fker':Fker, 'ker': ker_pad.copy()}
        return dic

class Train_Dataset(Dataset):
    def __init__(self, args, train_sp_dir, sigma, train_ker_dir):
        self.args = args
        self.train_ker_dir = args.train_ker_dir
        self.sigma  = sigma

        self.conv_mode = args.conv_mode
        self.tapper = args.tapper

        self.sp_file = sorted(glob(train_sp_dir))

        ker_mat = loadmat(train_ker_dir)
        ker_mat = ker_mat['kernels']
        self.get_ker = lambda idx: ker_mat[0, idx]
        self.ker_num = len(ker_mat[0])


    def  __len__(self):
        if self.args.debug: self.sp_file = self.sp_file[0:self.args.file_num]
        img_num = len(self.sp_file)
        return img_num

    def __getitem__(self, i):
        sp = imread(os.path.join(self.sp_file[i]))

        if np.max(sp) > 2:
            sp = sp / 255.0

        sp = self.data_aug(sp) # data augmentation
        idx = np.random.randint(0, self.ker_num)
        ker = self.get_ker(idx)

        bl = get_blur(sp, ker=ker, std = self.sigma, tapper=self.tapper, conv_mode=self.conv_mode)

        ker_mat = torch.FloatTensor(for_fft(ker, shape=np.shape(sp)))
        Fker = cf.fft(ker_mat).unsqueeze(0)

        ker_pad = np.full([50, 50], np.nan)
        ker_pad[:ker.shape[0], :ker.shape[1]] = ker

        sp = torch.from_numpy(sp).unsqueeze(0)
        bl = torch.from_numpy(bl).unsqueeze(0)

        dic = {'bl': bl, 'sp': sp, 'Fker':Fker, 'ker': ker_pad.copy()}
        return dic

    @staticmethod
    def data_aug(img, mode=0):
        ''' data augmentation '''
        if mode == 0:
            return img
        elif mode == 1:
            return np.flipud(img)
        elif mode == 2:
            return np.rot90(img)
        elif mode == 3:
            return np.flipud(np.rot90(img))
        elif mode == 4:
            return np.rot90(img, k=2)
        elif mode == 5:
            return np.flipud(np.rot90(img, k=2))
        elif mode == 6:
            return np.rot90(img, k=3)
        elif mode == 7:
            return np.flipud(np.rot90(img, k=3))

