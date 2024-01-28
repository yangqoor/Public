import argparse
class get_train_config():
    def __init__(self):
        # Parse from command line
        self.parser = argparse.ArgumentParser(description='Non blind Deconvolution')
        self.parser.add_argument('--log', default=False, help='write output to file rather than print into the screen')
        self.parser.add_argument('--gpu_idx', type=int, default=1, help='idx of gpu')
        self.parser.add_argument('--resume', default=True, help='resume training')
        self.parser.add_argument('--suffix', type=str, default='vem_fcn', help='suffix_of_model name')
        self.parser.add_argument('--debug', default=False, help='debug mode')
        self.parser.add_argument('--num_workers', default=3, help='threads of dataloader')

        # Problem Settings
        self.parser.add_argument('-s', '--sigma', nargs='+', default=[1,14], help='noise level, e.g 2.55, 7.65, 12.75. For noise-blind case e.g [1,14]')

        # Training Parameters
        self.parser.add_argument('--epoch', type=int, default=100, help='# of fine_epoch ')
        self.parser.add_argument('--bat_size', type=int, default=2, help='batch size')
        self.parser.add_argument('--layers', type=int, default=4, help='net layers')
        self.parser.add_argument('--deep', type=int, default=17, help='one module deep')
        self.parser.add_argument('--beta', default=[0.005, 1, 1, 1, 1], help='regularization coef.')
        self.parser.add_argument('--lr', type=float, default=1e-3, help='prir lr')
        self.parser.add_argument('--save_freq', type=int, default=2, help='the frequency of saving epoch')
        self.parser.add_argument('--shuffle', default=True, help='shuffle when training')
        self.parser.add_argument('--tapper', default=False, help='Use tapper images as training')
        self.parser.parse_args(namespace=self)


        # Predefined parameters
        self.sigma = [float(self.sigma[0]), float(self.sigma[1])]

        self.conv_mode = 'wrap'


        # Info
        self.task_info = 'sigma_' + str(self.sigma)
        self.info = self.task_info + '_' + self.suffix

        # Result saving locations
        self.img_dir = 'result/' + self.info + '/img/'
        self.ckp_dir = 'result/' + self.info + '/ckp/'

        self.train_sp_dir  = './data/BSDS_All1473/*.png'  # training data directory
        self.train_ker_dir = './data/kernels/srtf_ker_v7.mat'
        self.val_ker_dir   = './data/kernels/Levin09_v7.mat'
        self.val_sp_dir    = './data/Set12/sharp/'  # dir of sharp image for validation
        self.val_bl_sigma  = [2.55, 7.65, 12.75]
        self.val_bl_dir = {}
        for sigma in self.val_bl_sigma:
            self.val_bl_dir[str(sigma)] = './data/Set12/sigma_' + str(sigma) + '_ker_levin_taper/BlurryNoiseDset/'

        self.val_save_img_dir = 'result/' + self.info + '/img/'
        if self.resume:
            self.test_ckp_dir = 'pretrained/vem_model'


        if self.debug:
            self.log = False
            self.epoch = 2
            self.aug_times = 1
            self.file_num = 100
            self.bat_num = 2


class get_test_config():
    def __init__(self):
        # Parse from command line
        self.parser = argparse.ArgumentParser(description='Non blind Deconvolution')
        self.parser.add_argument('--gpu_idx', type=int, default=0, help='idx of gpu')

        # Training Parameters
        self.parser.add_argument('--layers', type=int, default=4, help='net layers')
        self.parser.add_argument('--deep', type=int, default=17, help='one module deep')
        self.parser.add_argument('--save_img', default=False, help='save images into file')
        self.parser.parse_args(namespace=self)


        self.beta = [0.005, 1, 1, 1, 1]

        # Result saving locations
        self.dataset_name = ['Set12', 'Sun', 'Levin']
        self.test_sigma = [2.55, 5.1, 7.65, 10.2, 12.75]
        self.test_ckp_dir = './pretrained/vem'
        self.test_bl_dir = {}
        self.test_sp_dir = {}

        self.ker_dir = './data/kernels/Levin09_v7.mat'

        for dset in self.dataset_name:
            self.test_sp_dir[dset] = './data/{}/sharp/'.format(dset)
            for sigma in self.test_sigma:
                self.test_bl_dir[dset + '_' + str(sigma)]  = './data/'+ dset +'/sigma_' + str(sigma) + '_ker_levin_taper/BlurryNoiseDset/'

        self.test_save_dir = 'deblurred_results/'

        ## For Poisson Images
        # self.dataset_name = ['Pois_Set12']
        # self.test_sigma = [51,128,255,512,1024]
        # for dset in self.dataset_name:
        #     self.test_sp_dir[dset] = './data/Set12/sharp/'
        #     for sigma in self.test_sigma:
        #         self.test_bl_dir[dset + '_' + str(sigma)]  = './data/'+ dset +'/pois_' + str(sigma) + \
        #                                       '_ker_levin_taper/BlurryNoiseDset/'





