''' Test Codes '''
import torch
from torch.utils.data.dataloader import DataLoader
import os
from utils.imtools import imshow
from utils.metrics import aver_bmp_psnr_ssim_par, aver_bmp_psnr
from config import get_test_config
from model.net import kernel_error_model
from data_loader.dataset import Test_Lai_NoiseKernel, Test_Real_NoiseKernel, Test_NoiseKernel

class Tester():
    def __init__(self, args, net, test_dset, parallel = True):
        self.args = args
        self.net = net
        self.test_DLoader = {}
        self.parallel = parallel
        for key in test_dset.keys():
            self.test_DLoader[key] = DataLoader(test_dset[key], batch_size=1, shuffle=False,
            num_workers=0, pin_memory=True)

        self.load_model()
        self.test_input = {}

    def __call__(self):
        if self.args.save_img:
            for key in self.test_DLoader.keys():
                os.mkdir(self.args.test_save_dir + self.args.dataset_name + '_' + key + '/')


        if self.args.dataset_name == 'Lai':
            for key in self.test_DLoader.keys():
                self.test_lai(key, parallel=self.parallel, input=False)
        elif self.args.dataset_name == 'Lai_Real':
            for key in self.test_DLoader.keys():
                self.test_lai_real(key)
        else:
            for key in self.test_DLoader.keys():
                self.test(key, parallel=self.parallel, input=False)


    def test(self, name, parallel, input = False):
        if input:
            if name not in self.test_input.keys():
                bat_x = []
                bat_y = []
                for i, bat in enumerate(self.test_DLoader[name]):
                    bat_x.append(bat['bl'])
                    bat_y.append(bat['sp'])
                if parallel:
                    PSNR = aver_bmp_psnr_ssim_par(bat_x,bat_y, bd_cut=self.args.bd_cut, to_int = True)
                else:
                    PSNR = aver_bmp_psnr(bat_x,bat_y, cut=self.args.bd_cut, to_int=True)
                self.test_input[name] = PSNR

        bat_y = []
        bat_opt = []
        for i, bat in enumerate(self.test_DLoader[name]):
            bat_y.append(bat['sp'])
            opt_db = self.eval_net(bat['bl'].cuda(), bat['Fker'].cuda())
            bat_opt.append(opt_db[-1].cpu())
            if self.args.save_img:
                imshow(opt_db[-1].cpu(),dir=self.args.test_save_dir + self.args.dataset_name + '_' + name + '/', str = bat['name'][0])

        if self.args.compute_metrics:
            if parallel:
                PSNR, SSIM = aver_bmp_psnr_ssim_par(bat_opt,bat_y, bd_cut=self.args.bd_cut, to_int = True, ssim_compute=True)
            else:
                PSNR = aver_bmp_psnr(bat_opt,bat_y, cut=self.args.bd_cut, to_int=True)

            if input:
                print(['%s: In %2.3f, Out %2.3f' % (name, self.test_input[name], PSNR)])
            else:
                print(['%s: Out PSNR %2.3f, SSIM %2.3f' % (name, PSNR, SSIM)])

    def test_lai(self, name, parallel,input = False):
        if input:
            if name not in self.test_input.keys():
                bat_x = []
                bat_y = []
                for i, bat in enumerate(self.test_DLoader[name]):
                    bat_x.append(bat['bl'])
                    bat_y.append(bat['sp'])
                if parallel:
                    PSNR = aver_bmp_psnr_ssim_par(bat_x,bat_y, bd_cut=self.args.bd_cut, to_int = True, ssim_compute=False)
                else:
                    PSNR = aver_bmp_psnr(bat_x,bat_y, cut=self.args.bd_cut, to_int=True)
                self.test_input[name] = PSNR

        self.net.eval()
        bat_y = []
        bat_opt = []
        for i, bat in enumerate(self.test_DLoader[name]):
            bat_y.append(bat['sp'])
            opt_db_chn = torch.zeros_like(bat['sp'])
            for c in range(3):
                opt_db = self.eval_net(bat['bl'][:,:,:,:,c].cuda(), bat['Fker'].cuda())
                opt_db_chn[:,:,:,:,c] = opt_db[-1].cpu()
            bat_opt.append(opt_db_chn)

            if self.args.save_img:
                imshow(opt_db_chn.cpu(),dir=self.args.test_save_dir + self.args.dataset_name + '_' + name + '/', str = bat['name'][0])

        if self.args.compute_metrics:
            if parallel:
                PSNR,SSIM = aver_bmp_psnr_ssim_par(bat_opt,bat_y, bd_cut=self.args.bd_cut, to_int = True, ssim_compute=True)
            else:
                PSNR = aver_bmp_psnr(bat_opt,bat_y, cut=self.args.bd_cut, to_int=True)

            if input:
                print(['%s: In %2.3f, Out PSNR: %2.3f, SSIM:%2.3F' % (name, self.test_input[name], PSNR, SSIM)])
            else:
                print(['%s: Out PSNR: %2.3f, SSIM:%2.3F' % (name, PSNR, SSIM)])

    def test_lai_real(self, name):
        self.net.eval()
        bat_opt = []
        for i, bat in enumerate(self.test_DLoader[name]):
            opt_db_chn = torch.zeros_like(bat['bl'])
            for c in range(3):
                opt_db = self.eval_net(bat['bl'][:,:,:,:,c].cuda(), bat['Fker'].cuda())
                opt_db_chn[:,:,:,:,c] = opt_db[-1].cpu()
            bat_opt.append(opt_db_chn)
            if self.args.save_img:
                imshow(opt_db_chn,dir=self.args.test_save_dir + self.args.dataset_name + '_' + name + '/', str = bat['name'][0])

    @staticmethod
    def _ker_to_list(ker):
        import numpy as np
        ker = ker.numpy()
        Kker = [None] * ker.shape[0]
        for i in range(ker.shape[0]):
            x, y = np.where(~np.isnan(ker[i]))
            x_max = np.max(x)
            y_max = np.max(y)
            Kker[i] = ker[i, :x_max, :y_max]
        return Kker


    def load_model(self):
        ckp = torch.load(self.args.test_ckp_dir, map_location=lambda storage, loc: storage.cuda(self.args.gpu_idx))
        self.net.load_state_dict(ckp['model'])
        return ckp

    def eval_net(self, bl, *args):
        with torch.no_grad():
            self.net.eval()
            bl = bl.cuda()
            db = self.net(bl,*args)
        return db


if __name__ == "__main__":

    args = get_test_config()
    torch.cuda.set_device(args.gpu_idx)
    net = kernel_error_model(args).cuda()

    test_dset = {}
    if args.dataset_name =='Lai':
        for name in args.test_ker:
            test_dset[name] = Test_Lai_NoiseKernel(args.test_sp_dir, args.test_bl_dir, args.ker_dir[name],args.taper)
    elif args.dataset_name == 'Lai_Real':
        test_dset["lai_real"] = Test_Real_NoiseKernel(args.test_bl_dir, args.ker_dir["lai_real"],args.taper)
    else:
        for name in args.test_ker:
            test_dset[name] = Test_NoiseKernel(args.test_sp_dir, args.test_bl_dir, args.ker_dir[name], args.tr_ker_dir, args.taper)
    test = Tester(args, net, test_dset)
    test()
    print('[*] Finish!')


