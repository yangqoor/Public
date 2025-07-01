import numpy as np
import torch
import argparse
import cv2
import matplotlib.pyplot as plt
from PIL import Image
from utils.utils_test import rggb_to_rgb, p4ip_wrapper_pad
from utils.utils_test import img_register, gray_world_whitebalance, change_whitebalance
from utils.utils_torch import conv_fft, img_to_tens, scalar_to_tens
from utils.utils_deblur import pad, crop
from skimage.metrics import structural_similarity as ssim
import cv2 as cv2

from models.network_p4ip import P4IP_Net

parser = argparse.ArgumentParser(description='Test on Real Data')
parser.add_argument('--idx', type=int, default=10, help='index of real data file [0,29]')
args = parser.parse_args()

DIR = '../P4IP/Python/data/real_data/'
# DIR = 'data/real_data/'
MODEL_FILE = 'model_zoo/p4ip_100epoch.pth'
IDX = args.idx
IDX_CLEAN = int(IDX/3)

# Load data-files
y = np.load(DIR+'/lux5/cut'+str(IDX)+'.npy') 			# Noisy image
k = np.load(DIR+'/lux5/kernel'+str(IDX)+'.npy') 			# blur kernel
# Clipping negative values and normalization of kernel
y = np.clip(y.astype(np.float32),0,np.inf); k = np.clip(k.astype(np.float32),0,np.inf)
k /= np.sum(np.ravel(k))
k = pad(k , [65,65])
if IDX in [15,20,24]:
	MODE = 'RGGB'
else:
	MODE = 'BGGR'


"""
Load the network
"""
device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
p4ip = P4IP_Net(); p4ip.load_state_dict(torch.load(MODEL_FILE)); 
p4ip.to(device); p4ip.eval()


"""
Prepare the variables for input to network
"""
y_list = []
y_list.append(y[0::2, 0::2])
y_list.append(y[0::2, 1::2])
y_list.append(y[1::2, 0::2])
y_list.append(y[1::2, 1::2])
H, W = np.shape(y)
M_list = []
for y in y_list:
	M_hat = np.mean(np.ravel(y))/0.33
	M_list.append(M_hat)

with torch.no_grad():	
	rggb = []
	for y, M in zip(y_list, M_list):
		x_rec = p4ip_wrapper_pad(y, k, M, p4ip)
		x_rec = x_rec*M
		rggb.append(x_rec)	
	x_p4ip = rggb_to_rgb(rggb, H, W, MODE)
	y = rggb_to_rgb(y_list, H, W, MODE)

MODE = 'BGGR' if IDX in [15,20,24] else 'RGGB'
x_p4ip = rggb_to_rgb(rggb, H, W, MODE); x_p4ip = gray_world_whitebalance(x_p4ip)/2.0
y = rggb_to_rgb(y_list, H, W, MODE); y = gray_world_whitebalance(y)/2.0

"""
Evaluation of reconstruction method starts here
"""
# Step 0: Load the ground-truth
IDX_CLEAN = int(IDX/3)
x_gt = cv2.imread(DIR+'lux5_clean/'+str(IDX_CLEAN)+'.png') # clean image
x_gt = np.flip(x_gt, 2) ## Flip because cv2 loads in BGR format instead of RGB
# Step 1: Register the ground-truth image to the reconstruction
x_p4ip_norm = (x_p4ip-np.min(x_p4ip))/(np.max(x_p4ip)-np.min(x_p4ip))
im_register, _ =  img_register(x_gt, (x_p4ip_norm*255).astype(np.uint8))
# Step 2: Once the ground-truth is registered, change the whitebalance of reconstruction so match that of the ground-truth
# After this step our image isready for comparison
im_estimated, im_register = change_whitebalance(x_p4ip, im_register.astype(np.float32)) 
y, _ = change_whitebalance(y, im_register.astype(np.float32)) 
# Step 3 (Final): Actually evaluate the PSNR and SSIM
err = im_register-im_estimated
err_mean = np.sqrt(np.mean(err**2))
psnr=-20*np.log10(err_mean/255.0)
ssim_val = ssim(im_register, im_estimated,  multichannel = True ,data_range=255)
print('PSNR: %0.2f, SSIM: %0.3f'%(psnr,ssim_val))


plt.figure(figsize=(10,6))
plt.subplot(1,3,1); plt.imshow(im_register/255.0); plt.axis('off')
plt.title('True Image, After Registration')

plt.subplot(1,3,2); plt.imshow(y/255.0); plt.axis('off')
plt.title('Noisy Blurred Image')

plt.subplot(1,3,3); plt.imshow(im_estimated/255.0); plt.axis('off')
plt.title('Reconstructed Image')
plt.savefig('results/demo_real.png', bbox_inches='tight', pad_inches=0.05)
plt.show()
