import numpy as np
from numpy.linalg import norm
from numpy.fft import fft2, ifft2, ifftshift
import matplotlib.pyplot as plt
from PIL import Image
from scipy.io import savemat, loadmat
import torch
from utils.utils_deblur import psf2otf
from utils.utils_torch import img_to_tens, scalar_to_tens
from models.network_p4ip import P4IP_Net

ALPHA = 20.0 	# Photon level
K_IDX = 11		# blur kernel index - choose from [0,11]


device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
np.random.seed(20)
H, W = 256, 256
# # Load Model
MODEL_FILE = 'model_zoo/p4ip_100epoch.pth'
p4ip_net = P4IP_Net()
p4ip_net.load_state_dict(torch.load(MODEL_FILE, map_location=device))
p4ip_net.to(device)
p4ip_net.eval()

# Load test image
x = np.asarray(Image.open('data/Images/camera.png'))
x = x/255.0
if x.ndim > 2:
	x = np.mean(x,axis=2)
	# Reshape to form [N,N] image
x_im = Image.fromarray(x).resize((W,H))
x = np.asarray(x_im)




"""
Choose kernel from list of kernels
"""
struct = loadmat('data/kernels_12.mat')
kernel_list = struct['kernels'][0]
kernel = kernel_list[K_IDX]
kernel = kernel/np.sum(kernel.ravel())


"""
Prepare the A, At operator, blurred poisson corrupted image
"""
k_pad, k_fft = psf2otf(kernel, [H, W])
y_n = np.real(ifft2(fft2(x)*k_fft))
y = np.random.poisson(np.maximum(ALPHA*y_n,0))
y = np.asarray(y,dtype=np.float32)

"""
Prepare the variables for input to network
"""
kt = img_to_tens(kernel).to(device)
yt = img_to_tens(y).to(device)
alpha_t = scalar_to_tens(ALPHA).to(device)
x_rec_list= p4ip_net(yt, kt, alpha_t)
x_rec = x_rec_list[-1]
x_rec = x_rec.cpu().detach().numpy()
x_net = np.clip(x_rec[0,0,:,:],0,1)


mse = norm(y/ALPHA-x,'fro')/(np.sqrt(H*W))
psnr_y = -20*np.log10(mse)
mse = norm(y_n-x,'fro')/(np.sqrt(H*W))
psnr_y_n = -20*np.log10(mse)

mse = norm(x_net-x,'fro')/(np.sqrt(H*W))
psnr_net = -20*np.log10(mse)
print('Photon Level: ',ALPHA,', KERNEL INDEX: ',K_IDX)
print('PSNR: ',psnr_net)
plt.figure(figsize=(14,14))
plt.subplot(2,2,1)
plt.imshow(y, cmap='gray')
plt.axis('off')
plt.title('Blurred Noisy Image (PSNR: %0.2f dB) '%(psnr_y), fontsize=18)

plt.subplot(2,2,2)
plt.imshow(y_n, cmap='gray')
plt.axis('off')
plt.title('Blurred Image (PSNR: %0.2f dB) '%(psnr_y_n), fontsize=18)

plt.subplot(2,2,3)
plt.imshow(x, cmap='gray')
plt.axis('off')
plt.title('True Image', fontsize=18)

plt.subplot(2,2,4)
plt.imshow(x_net, cmap='gray')
plt.axis('off')
plt.title('Ours (PSNR: %0.2f dB) '%(psnr_net), fontsize=18) 

plt.savefig('results/demo_synthetic.png', bbox_inches='tight', pad_inches=0.05)

plt.show()

