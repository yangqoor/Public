import argparse
from glob import glob

from matplotlib.image import imread
import os

from utils.metrics import aver_bmp_psnr_ssim_par

parser = argparse.ArgumentParser(description='compute PSNR')
parser.add_argument('--parallel', default=True, help='Parallel computation of the PSNR')
parser.add_argument('--dataset_name', default='Lai' ,choices=['Levin', 'Sun', 'Lai', 'Lai_Real'])
parser.add_argument('-s', '--sigma', default = '0', choices=['0' ,'2.55'])

args = parser.parse_args()

if args.dataset_name == 'Sun':
    test_ker = ['cho', 'xu', 'michaeli']
    bd_cut = 28
elif args.dataset_name == 'Levin':
    test_ker = ['cho', 'levin', 'pan', 'sun']
    bd_cut = 15
elif args.dataset_name == 'Lai':
    test_ker = ['xu10', 'xu13', 'sun', 'perrone']
    bd_cut = 15
else:
    raise NotImplementedError


if args.sigma == '0':
    taper = 'same'
elif args.sigma == '2.55':
    taper = 'valid'
else:
    raise NotImplementedError

for ker_name in test_ker:
    if args.dataset_name != 'Lai':
        sp_dir = './data/{0}_NK/sharp/'.format(args.dataset_name)
        rc_dir = './deblurred_results/noise_{0}_{1}/{2}_{3}/'.format(args.sigma, taper, args.dataset_name, ker_name)
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
    elif args.dataset_name == 'Lai':
        sp_dir = './data/Lai_NK/sharp/'
        rc_dir = './deblurred_results/noise_{0}_{1}/{2}_{3}/'.format(args.sigma, taper, args.dataset_name, ker_name)
        sp_file = sorted(glob(sp_dir + '*.png'))
        rc_file = sorted(glob(rc_dir + '*.png'))
        sp = []
        rc = []
        im_num = len(rc_file)
        for item in range(im_num):
            sp_name = os.path.split(rc_file[item])[1][:-7] + '.png'
            sp.append(imread(sp_dir + sp_name)[:,:,:3])
            rc.append(imread(rc_file[item])[:,:,:3])
    PSNR, SSIM = aver_bmp_psnr_ssim_par(rc, sp, bd_cut=bd_cut)
    print(['%s: Out PSNR %2.3f, SSIM %2.3f' % (ker_name, PSNR, SSIM)])

    
    





