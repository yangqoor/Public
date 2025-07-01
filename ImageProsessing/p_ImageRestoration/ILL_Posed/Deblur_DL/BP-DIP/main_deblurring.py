import torch
import cv2 as cv
import numpy as np
import random
from models.unet import UNet
import csv
import os
import deblurring
from skimage.metrics import peak_signal_noise_ratio as compare_psnr

# random seed
seed_num = 123
torch.manual_seed(seed_num)
torch.cuda.manual_seed(seed_num)
np.random.seed(seed_num)
random.seed(seed_num)
torch.backends.cudnn.enabled = False
torch.backends.cudnn.deterministic = True

# parameters to set
loss_type = 'bp' #bp/dip
filter_type ='gaus_filter' #uniform/radial/gaus
noise_lvl = 0.3 #0.3,2,4
noise_type = filter_type + '_' + str(noise_lvl)
#add_det = '_tv' #add more details regarding the run
add_det = ''

#directory = './results/deblur_images/' + noise_type + '_' + loss_type + add_det + '_images' + '/' #when saving deblurred images
directory = './results/deblur_with_ssim_bm3d/' + noise_type + '_' + loss_type + add_det + '/'
print(directory)
if not os.path.exists(directory):
    os.mkdir(directory)
imgs_dir = 'data_set14/'
files = [f for f in os.listdir(imgs_dir) if os.path.isfile(os.path.join(imgs_dir, f))]
GT_imgs = [f for f in files if '.png' in f]
GT_imgs.sort(reverse=False)

final_psnr_file = open(directory + 'final_psnr_log_%s.csv' % loss_type, 'a')
PSNR_fileWriter = csv.writer(final_psnr_file)
final_bm3d_file = open(directory + 'final_bm3d_log_%s.csv' % loss_type, 'a')
bm3d_fileWriter = csv.writer(final_bm3d_file)

for img in GT_imgs:
#for img in ['bridge.png']:

    print(img)
    I = cv.imread(imgs_dir + img)
    I = np.float32(I)
    I = np.moveaxis(I, 2, 0) / 255.

    I_DIP, network, z, psnr_history, ssim_history, psnr_bm3d, ssim_bm3d, blurred_img = deblurring.dip_deblur(
        img, noise_lvl, filter_type, loss_type, directory)

    final_psnr = compare_psnr(I[[2, 1, 0], :, :], I_DIP)
    print('psnr = %.4f' % (final_psnr))

    row_str = ['%f' % final_psnr]
    PSNR_fileWriter.writerow(row_str)

    row_str = ['%f %f' % (psnr_bm3d, ssim_bm3d)]
    bm3d_fileWriter.writerow(row_str)

    ### for deciding number of iterations bvased on average psnr
    with open(directory + 'psnr_history_%s.txt' % loss_type, 'a') as f:
        for item in psnr_history:
            f.write("%s\n" % item)

    with open(directory + 'ssim_history_%s.txt' % loss_type, 'a') as f:
        for item in ssim_history:
            f.write("%s\n" % item)

final_psnr_file.close()
final_bm3d_file.close()
