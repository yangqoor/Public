from evaluation import eval_func_err
import numpy as np
import os
from glob import glob

cwd = os.getcwd()
path_gt = os.path.join(cwd, '..', 'datasets/levin/gt/')
groundk = os.path.join(cwd, '..', 'datasets/levin/groundk/w01/')
temp_subdir = os.path.join(cwd, '..', 'results/levin/WDIP/')
eval_mode = 'DIP'

if eval_mode == 'DIP':
    temp_subdir_list = glob(temp_subdir + '*img_x.png')
    temp_subdir_list.sort()
    arr_temp = np.zeros((len(temp_subdir_list), 3))
    for i in range(len(temp_subdir_list)):
        gt_temp = path_gt + temp_subdir_list[i].split('/')[-1].split('_')[0] + '.png'
        deblur_gt_path = groundk + temp_subdir_list[i].split('/')[-1][:-6] + '.png'
        psnr, ssim, err = eval_func_err(temp_subdir_list[i], gt_temp, deblur_gt_path)

        print("This is: ", psnr, ssim, err)
        arr_temp[i, 0] = psnr
        arr_temp[i, 1] = ssim
        arr_temp[i, 2] = err

    np.save(temp_subdir + 'eval_array', arr_temp)

else:
    temp_subdir_list = glob(temp_subdir + '*_img.png')
    temp_subdir_list.sort()
    arr_temp = np.zeros((len(temp_subdir_list), 3))
    for i in range(len(temp_subdir_list)):
        gt_temp = path_gt + temp_subdir_list[i].split('/')[-1].split('_')[0] + '.png'
        psnr, ssim, err = eval_func_err(temp_subdir_list[i], gt_temp, groundk + temp_subdir_list[i].split('/')[-1])

        print("This is: ", psnr, ssim, err)
        arr_temp[i, 0] = psnr
        arr_temp[i, 1] = ssim
        arr_temp[i, 2] = err

    np.save(temp_subdir + 'eval_array', arr_temp)

