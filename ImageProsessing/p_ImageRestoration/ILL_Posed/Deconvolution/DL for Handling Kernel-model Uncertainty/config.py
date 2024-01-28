import argparse

class get_test_config():
    def __init__(self):
        # Parse from command line
        self.parser = argparse.ArgumentParser(description='non-blind image deconvolution in the presence of kernel/model uncertainty')
        self.parser.add_argument('--gpu_idx', type=int, default=0, help='idx of gpu')
        self.parser.add_argument('--parallel', default=True, help='Parallel computation of the PSNR')

        # Problem Settings
        self.parser.add_argument('--dataset_name', default='Levin',choices=['Levin', 'Sun', 'Lai', 'Lai_Real'])
        self.parser.add_argument('-s', '--sigma', default = '0', choices=['0','2.55'])

        # Training Parameters
        self.parser.add_argument('--layers', type=int, default=4, help='net layers')
        self.parser.add_argument('--deep', type=int, default=17, help='one module deep')
        self.parser.add_argument('--save_img', default=False, help='save images into file')
        self.parser.add_argument('--compute_metrics', default=False, help='save images into file')
        self.parser.parse_args(namespace=self)

        # Predefined parameters
        if self.sigma == '0':
            self.taper = 'same'
            self.lmd = [0.005, 0.1, 0.1, 0.1, 0.1]
            self.test_ckp_dir = 'pretrained/noise_0pp'

        elif self.sigma == '2.55':
            self.taper = 'valid'
            self.lmd = [0.005, 0.5, 0.5, 0.5, 0.5]
            self.test_ckp_dir = 'pretrained/noise_1pp'

        # Data Preparation
        self.ker_dir = {}
        self.ker_dir['cho'] = './data/{0}_NK/BD_cho_and_lee_tog_2009/kernel_estimates/'.format(self.dataset_name)
        self.ker_dir['fergus'] = './data/{0}_NK/BD_fergus_tog_2006/kernel_estimates/'.format(self.dataset_name)
        self.ker_dir['levin'] = './data/{0}_NK/BD_levin_cvpr_2011/kernel_estimates/'.format(self.dataset_name)
        self.ker_dir['pan'] = './data/{0}_NK/BD_pan_cvpr_2016/kernel_estimates/'.format(self.dataset_name)
        self.ker_dir['sun'] = './data/{0}_NK/BD_sun_iccp_2013/kernel_estimates/'.format(self.dataset_name)
        self.ker_dir['xu'] = './data/{0}_NK/BD_Xu_eccv_2010/kernel_estimates/'.format(self.dataset_name)
        self.ker_dir['michaeli'] = './data/{0}_NK/BD_Michaeli_eccv_2014/kernel_estimates/'.format(self.dataset_name)
        self.ker_dir['xu10'] = './data/{0}_NK/BD_xu_eccv_2010/kernel_estimates/'.format(self.dataset_name)
        self.ker_dir['xu13'] = './data/{0}_NK/BD_xu_cvpr_2013/kernel_estimates/'.format(self.dataset_name)
        self.ker_dir['perrone'] = './data/{0}_NK/BD_perrone_cvpr_2014/kernel_estimates/'.format(self.dataset_name)
        self.ker_dir['lai_real'] = './data/Lai_NK/real/kernels/'
        self.test_sp_dir = './data/{0}_NK/sharp/'.format(self.dataset_name)

        # Select Blind Deconvolution Kernels by the kernels.
        if self.dataset_name == 'Sun':
            self.test_bl_dir = './data/Sun_NK/sigma_{0}_ker_levin/'.format(self.sigma)
            self.test_ker = ['cho', 'michaeli','xu']
            self.tr_ker_dir = './data/kernels/Levin09_v7.mat'
            self.bd_cut = 28
        elif self.dataset_name == 'Levin':
            self.test_bl_dir = './data/Levin_NK/sigma_{0}_ker_levin/'.format(self.sigma)
            self.test_ker = ['cho','levin','pan','sun']
            self.tr_ker_dir = './data/kernels/Levin09_v7.mat'
            self.bd_cut = 15
        elif self.dataset_name == 'Lai':
            self.test_bl_dir = './data/Lai_NK/sigma_{0}_ker_lai/'.format(self.sigma)
            self.test_ker = ['xu10','xu13','sun','perrone']
            self.bd_cut = 15
        elif self.dataset_name == 'Lai_Real':
            self.test_bl_dir = './data/Lai_NK/real/blurry/'


        if self.taper == 'valid':
            if self.dataset_name != 'Lai_Real':
                self.test_bl_dir = self.test_bl_dir[:-1] + '_valid/'
        elif self.taper == 'taper':
            self.test_bl_dir = self.test_bl_dir[:-1] + '_taper/'

        self.img_num = None

        if self.save_img:
            self.test_save_dir = './deblurred_results/noise_{0}_{1}/'.format(self.sigma,self.taper)





