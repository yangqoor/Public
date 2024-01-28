from glob import glob

from matplotlib.image import imread
import os

from utils.metrics import aver_psnr_ds, aver_ssim_ds


test_sigma = [2.55, 7.65, 12.75]
dataset_name = ['Set12', 'Sun', 'Levin']


for dset in dataset_name:
    sp_dir = './data/{}/sharp/'.format(dset)
    for sigma in test_sigma:
        rc_dir = './deblurred_results/FCNN/' + dset + '_' + str(sigma) + '/'

        sp_file = sorted(glob(sp_dir + '*.png'))
        rc_file = sorted(glob(rc_dir + '*.png'))

        im_num = len(rc_file)
        sp = []
        rc = []
        for item in range(im_num):
            ker_num = 8
            i = item // ker_num
            j = item % ker_num

            sp.append(imread(os.path.join(sp_dir, 'im_%d.png'%(i+1))))
            rc.append(imread(os.path.join(rc_dir, 'im_%d_ker_%d.png'%(i+1, j+1))))

        print('---dataset:%s, sigma:%s---'%(dset,str(sigma)))
        print('PSNR', '%2.2f' % aver_psnr_ds(sp, rc))
        print('SSIM', '%2.3f' % aver_ssim_ds(sp, rc))


    
    





