from evaluation import eval_func_seg
import numpy as np
from glob import glob
import os


cwd = os.getcwd()
path_gt = os.path.join(cwd, '..', 'datasets/micro_bad/gt/')
temp_subdir = os.path.join(cwd, '..', 'results/micro_bad/WDIP/')

temp_subdir_list = glob(temp_subdir + '*_x.png')
temp_subdir_list.sort()
arr_temp = np.zeros((len(temp_subdir_list), 3))
for i in range(len(temp_subdir_list)):
    gt_temp = path_gt + temp_subdir_list[i].split('/')[-1].split('_')[0] + '.png'
    psnr, ssim, dice, pred_seg, gt_seg = eval_func_seg(temp_subdir_list[i], gt_temp, window=25)

    print("This is: ", psnr, ssim, dice)
    arr_temp[i, 0] = psnr
    arr_temp[i, 1] = ssim
    arr_temp[i, 2] = dice

np.save(temp_subdir + 'eval_array', arr_temp)



