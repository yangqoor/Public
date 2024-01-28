from torch.utils.data.dataloader import DataLoader
import torch
from config import get_test_config
from data_loader.dataset import Test_Dataset
from model.dbnet import vem_deblur_model
from utils.metrics import aver_ssim_ds, aver_psnr_ds
from utils.imtools import imshow
import os

class Tester():
    def __init__(self, args, net, test_dset):
        self.args = args
        self.net = net
        self.test_DLoader = {}

        for name in test_dset.keys():
            self.test_DLoader[name] = DataLoader(test_dset[name], batch_size=1, shuffle=False,
            num_workers=0, pin_memory=True)

        self.load_model()

        if self.args.save_img:
            for name in self.test_DLoader.keys():
                os.mkdir(self.args.test_save_dir + name + '/')


    def __call__(self):
        self.net.eval()

        for name in self.test_DLoader.keys():
            bat_x = []
            bat_y = []
            bat_opt = []
            for i, bat in enumerate(self.test_DLoader[name]):
                bat_x.append(bat['bl'])
                bat_y.append(bat['sp'])
                opt_db, opt_dn = self.eval_net(bat['bl'].cuda(), bat['Fker'].cuda())
                bat_opt.append(opt_db[-1].cpu())

            print('-------%s-------'%(name))
            print('INP_PSNR', '%2.2f' % aver_psnr_ds(bat_x, bat_y))
            print('OUT_PSNR', '%2.2f' % aver_psnr_ds(bat_opt, bat_y))
            print('INP_SSIM', '%2.3f' % aver_ssim_ds(bat_x, bat_y))
            print('OUT_SSIM', '%2.3f' % aver_ssim_ds(bat_opt, bat_y))

            if self.args.save_img:
                for i in range(len(self.test_DLoader[name])):
                    m = i // 8 + 1
                    n = i % 8 + 1
                    print(m,n)
                    imshow(bat_opt[i], str='im_%d_ker_%d' % (m, n), dir=self.args.test_save_dir + name + '/')


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




if __name__ == "__main__":
    args = get_test_config()
    torch.cuda.set_device(args.gpu_idx)
    net = vem_deblur_model(args).cuda()

    test_dset = {}
    for dset in args.dataset_name:
        for sigma in args.test_sigma:
            test_dset[dset + '_' + str(sigma)] = Test_Dataset(args.test_sp_dir[dset], args.test_bl_dir[dset + '_' + str(sigma)], args.ker_dir)

    test = Tester(args, net, test_dset)
    test()
    print('[*] Finish!')
