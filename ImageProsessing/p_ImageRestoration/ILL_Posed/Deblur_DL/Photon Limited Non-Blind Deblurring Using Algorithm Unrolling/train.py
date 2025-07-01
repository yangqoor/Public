import numpy as np
from numpy.fft import fft2, ifft2, ifftshift
import matplotlib.pyplot as plt
from scipy.io import savemat, loadmat
from tqdm import tqdm
import argparse

import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
from torchvision.transforms import Compose, Resize, RandomCrop, Grayscale, ToTensor, RandomVerticalFlip
from torchvision.transforms import RandomResizedCrop, Grayscale, ToTensor, RandomVerticalFlip

from utils.utils_deblur import gauss_kernel
from utils.dataloader import Flickr2K, PoissBlur_List
from models.network_p4ip import P4IP_Net

LEARNING_RATE = 1e-4
NUM_EPOCHS = 101
BATCH_SIZE = 5
N_TRAIN = 128 
N_VAL = 256



"""
Initiate a model, and transfer to gpu
"""
device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
model = P4IP_Net()
model.to(device)
print("Number of GPUS available: ", torch.cuda.device_count())

"""
Setting up training data - blur kernels and photon levels
"""

# Adding Gaussian kernels
kernel_list = []
counts = [1,1,1,1,1,1,1,1,1,1]
idx= 0
for sigma in np.linspace(0.1, 2.5, 10):
	for count in range(counts[idx]):
		kernel_list.append(gauss_kernel(64,sigma))
	idx +=1	
# Adding Blur Kernels
struct = loadmat('data/motion_kernels.mat')
motion_kernels = struct['PSF_list'][0]
for idx in range(len(motion_kernels)):
	kernel = motion_kernels[idx]
	kernel = np.clip(kernel,0,np.inf)
	kernel = kernel/np.sum(kernel.ravel())
	kernel_list.append(kernel)

"""
Transform image and blur operations
"""

transform_img_train =  Compose([Resize([N_VAL,N_VAL]),
								RandomCrop([N_TRAIN,N_TRAIN]), 
								Grayscale(), 
								RandomVerticalFlip(), 
								ToTensor()])
transform_blur_train = PoissBlur_List(kernel_list, [1,60], N_TRAIN, True)
transform_img_val =  Compose([Resize([N_VAL,N_VAL]), 
								Grayscale(), 
								ToTensor()])
transform_blur_val = PoissBlur_List(kernel_list, [1,60], N_VAL, False)

# Dataloaders
data_train = Flickr2K(True, transform_img_train, transform_blur_train)
data_val = Flickr2K(False, transform_img_val, transform_blur_val)
train_loader = DataLoader(data_train, batch_size=BATCH_SIZE, shuffle=False, num_workers=0)
val_loader = DataLoader(data_val, batch_size=BATCH_SIZE, shuffle=False, num_workers=0)

"""
Setting up training with :
	1. L1 Loss
	2. AdamOptimizer 
"""
criterion_list  = [torch.nn.L1Loss()]
wt_list = [1.0]
criterion_l2  = torch.nn.MSELoss()
optimizer = optim.Adam(model.parameters(), lr=LEARNING_RATE)

"""
Training starts here
"""

for epoch in range(NUM_EPOCHS):
		
	epoch_loss = 0
	model.train()

	"""
	Training Epoch
	"""
	with tqdm(total=len(data_train), desc=f'Epoch {epoch + 1}/{NUM_EPOCHS}', unit='its') as pbar:
		for i, data in enumerate(train_loader):
			"""
			Get training data - [true image, noisy_blurred, kernel, photon level]
			"""
			x, y, kernels, M = data
			M = M.view( x.size(0), 1, 1, 1)
			x, y, kernels, M = x.to(device), y.to(device), kernels.to(device), M.to(device)
				
			"""
			Forward Pass => calculating loss => computing gradients => Adam optimizer update
			"""
			# Forward Pass
			optimizer.zero_grad()
			x = x.type(torch.cuda.FloatTensor)
			out_list = model(y, kernels, M)
			out = out_list[-1]
			# Calculating training loss
			loss = 0
			for idx in range(len(wt_list)):
				loss += wt_list[idx]*criterion_list[idx](out.float(), x.float())

			# Backprop 
			loss.backward()

			# Adam optimizer step
			optimizer.step()

			epoch_loss += loss.item()
			pbar.update(BATCH_SIZE)
			pbar.set_postfix(**{'loss (batch)': loss.item()})
	epoch_loss = epoch_loss*BATCH_SIZE/len(data_train)
	print('Epoch: {}, Training Loss: {}, Current Learning Rate: {}'.format(epoch+1,epoch_loss,LEARNING_RATE))


	"""
	Validation Epoch
	"""
	val_loss, mse = 0, 0
	model.eval()
	with torch.no_grad(): # Don't maintain computation graph since no backprop reqd., saves GPU memory
		for i, data in enumerate(val_loader):
			"""
			Getting validation pair
			"""
			x, y, kernels, M = data
			x, y, kernels, M = x.type(torch.DoubleTensor).to(device), y.to(device), kernels.to(device), M.to(device)
			M = M.view( x.size(0), 1, 1, 1)
			
			"""
			Forward Pass
			"""
			out_list = model(y, kernels, M)
			out = out_list[-1]
	
			"""
			Calculating L2 loss and training loss on the validation set
			"""
			loss = 0
			for idx in range(len(wt_list)):
				loss += wt_list[idx]*criterion_list[idx](out.float(), x.float())
			loss_l2 = criterion_l2(out, x)
			val_loss += loss.item()
			mse += loss_l2.item()

	val_loss = val_loss*BATCH_SIZE/len(data_val)
	mse = mse*BATCH_SIZE/len(data_val)
	psnr = -10*np.log10(mse)
	
	"""
	Writing the epoch loss, validation loss to tensorboard for visualization
	"""
	print('Validation PSNR: %0.3f, Validation Loss: %0.6f'%(psnr, val_loss))	
	for param_group in optimizer.param_groups:
		LEARNING_RATE = param_group['lr']
	if epoch % 10 ==0:
		torch.save(model.state_dict(), 'model_zoo/p4ip_net_%depoch.pth'%(epoch))




