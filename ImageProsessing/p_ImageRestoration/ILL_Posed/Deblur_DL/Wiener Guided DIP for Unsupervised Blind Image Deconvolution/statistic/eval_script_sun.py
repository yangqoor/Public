from evaluation import eval_func_sun
import numpy as np
import os
from glob import glob


cwd = os.getcwd()
path_gt = os.path.join(cwd, '..', 'datasets/sun/gt/')
temp_subdir = os.path.join(cwd, '..', 'results/sun/WDIP/')

temp_subdir_list = glob(temp_subdir + '*_x.png')
temp_subdir_list.sort()
arr_temp = np.zeros((len(temp_subdir_list), 2))
for i in range(len(temp_subdir_list)):
    gt_temp = path_gt + temp_subdir_list[i].split('/')[-1].split('_')[0] + '_gtk_latent_zoran.png'
    psnr, ssim_value = eval_func_sun(temp_subdir_list[i], gt_temp)

    print("This is: ", psnr, ssim_value)
    arr_temp[i, 0] = psnr
    arr_temp[i, 1] = ssim_value

np.save(temp_subdir + 'eval_array', arr_temp)


