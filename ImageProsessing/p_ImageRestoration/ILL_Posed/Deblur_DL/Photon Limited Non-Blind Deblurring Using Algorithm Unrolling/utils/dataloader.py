import sys
sys.path.insert(0,'.')

import numpy as np
import matplotlib.pyplot as plt
from numpy.fft import fft2
from PIL.Image import fromarray, open
from os import listdir
from os.path import isfile, join
import torch
from torchvision.transforms import Compose, RandomCrop, Normalize, Grayscale, ToTensor
from torch.utils.data import Dataset, DataLoader
from utils.utils_deblur import gauss_kernel, pad, crop
from utils.utils_torch import conv_kernel
from torchvision.transforms import Compose, Resize, RandomResizedCrop, Grayscale, ToTensor, RandomVerticalFlip

np.random.seed(4)
torch.manual_seed(4)




class Flickr2K(Dataset):
	def __init__(self, train, transform_img, transform_blur):
		self.shuffle  = True
		self.train = train
		if self.train:
			self.root_dirs = ['data/training']
		else:
			self.root_dirs = ['data/val']

		self.list_files = []
		for directory in self.root_dirs:
			for f in listdir(directory):
				if isfile(join(directory,f)) and not (f == "README"):
					self.list_files.append(join(directory,f))

		self.transform_img = transform_img
		self.transform_blur = transform_blur
		
	def __len__(self):
		return len(self.list_files)

	def __getitem__(self, idx):
		if torch.is_tensor(idx):
			idx = idx.tolist()
		
		img_name = join(self.list_files[idx])
		img = open(img_name)

		if self.transform_img:
			x = self.transform_img(img)

		if self.transform_blur:
			y, kernel, M = self.transform_blur(x)

		sample = [x, y, kernel, M]
		return sample

class PoissBlur_List(object):
	# From the list of given scaling factors, kernels
	# Choose a random scaling size and kernel fft
	# and apply the corresponding transform to image 
	def __init__(self, kernel_list, M_range, N, biased_sampling=True):
		self.M1, self.M2 = M_range[0], M_range[1]
		self.kernel_list = kernel_list
		self.N = N
		self.biased_sampling= biased_sampling
	

	def __call__(self, x):
		if self.biased_sampling:
			M = self.M1 + (self.M2-self.M1)*(np.random.uniform()**1.5)
		else:
			M = np.random.uniform(self.M1, self.M2)
		idx = np.random.choice(np.arange(0,len(self.kernel_list)))
		kernel = self.kernel_list[idx]

		kernel = kernel/np.sum(np.ravel(kernel))
		kernel_torch = torch.from_numpy(np.expand_dims(kernel,0))
		Ax, k_pad = conv_kernel(kernel, x)
		
		Ax_min = torch.clamp(Ax,min=1e-6)
		y = torch.poisson(Ax_min*M)
		return y, kernel_torch, M


class PoissBlur_List(object):
	# From the list of given scaling factors, kernels
	# Choose a random scaling size and kernel fft
	# and apply the corresponding transform to image 
	def __init__(self, kernel_list, M_range, N, biased_sampling=True, noisy_kernel=False):
		self.M1, self.M2 = M_range[0], M_range[1]
		self.kernel_list = kernel_list
		self.N = N
		self.biased_sampling= biased_sampling
		self.noisy_kernel = noisy_kernel

	def __call__(self, x):
		if self.biased_sampling:
			M = self.M1 + (self.M2-self.M1)*(np.random.uniform()**1.5)
		else:
			M = np.random.uniform(self.M1, self.M2)
		idx = np.random.choice(np.arange(0,len(self.kernel_list)))
		kernel = self.kernel_list[idx]
		# pad kernel to a odd size
		h, w = np.shape(kernel)
		h1, w1 = 2*np.int32(np.ceil(h/2))+1, 2*np.int32(np.ceil(w/2))+1
		kernel = pad(kernel, [h1,w1])
		kernel = kernel/np.sum(np.ravel(kernel))
		
		kernel_torch = torch.from_numpy(np.expand_dims(kernel,0))
		Ax, k_pad = conv_kernel(kernel, x)
		
		Ax_min = torch.clamp(Ax,min=1e-6)
		y = torch.poisson(Ax_min*M)
		return y, kernel_torch, M  



# batch_size=1
# N_train = 256
# kernel1 = gauss_kernel(25, 0.01)
# kernel2 = gauss_kernel(25, 1.3)
# kernel_list = [kernel1, kernel2]
# M_list = [10, 20]

# transform_img_train =  Compose([RandomResizedCrop([N_train, N_train]), 
# 								Grayscale(), 
# 								ToTensor()])
# transform_blur_train = PoissBlur_List(kernel_list, [5,60], N_train, False)
# data_train = Flickr2K(True, transform_img_train, transform_blur_train)
# train_loader = DataLoader(data_train, batch_size=batch_size, shuffle=True, num_workers=0)

# for i, data in enumerate(train_loader):
# 	if i == 14:
# 		x, y, kernels, M = data	
# 		img1 = x
# 		img2 = y
# 		print('M:',M)
# 		plt.subplot(1,3,1)
# 		plt.imshow( np.squeeze(img1.numpy()), cmap='gray')
# 		plt.tight_layout()

# 		plt.subplot(1,3,2)
# 		plt.imshow( np.squeeze(img2.numpy()), cmap='gray')
# 		plt.tight_layout()

# 		plt.subplot(1,3,3)
# 		plt.imshow( np.squeeze(np.abs(kernels.numpy())), cmap='gray')
# 		plt.tight_layout()

# 		plt.show()

# 		break


# div2k = DIV2K(False, 
# 	transform_img = transform_img, 
# 	transform_blur = transform_blur)
# dataloader = DataLoader(div2k, batch_size = 4, shuffle=True, num_workers = 0)


# for i, data in enumerate(dataloader):
# 	x, y, H, M = data
# 	print(x.size(), y.size(), H.size(), M.size())
	
# 	x1, y1 = x[0,0,:,:], y[0,0,:,:]
	
# 	plt.subplot(1,2,1)
# 	plt.imshow(np.squeeze(x1.numpy()), cmap='gray')
# 	plt.tight_layout()

# 	plt.subplot(1,2,2)
# 	plt.imshow(np.squeeze(y1.numpy()), cmap='gray')
# 	plt.tight_layout()
# 	plt.show()
# 	break

