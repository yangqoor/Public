from torch import nn
from torch.optim.lr_scheduler import MultiStepLR
import torch.optim as optim
from tqdm import tqdm

from config import get_train_config
from torch.utils.data.dataloader import DataLoader

from data_loader.dataset import Train_Dataset, Test_Dataset
from head import log
from model.dbnet import vem_deblur_model
import re
import numpy as np
import torch

from utils.metrics import aver_psnr_ds, aver_ssim_ds

class Trainer():
    def __init__(self, args, net, train_dset, val_dset):
        self.args = args
        self.net = net
        self.lr = args.lr
        self.epoch = args.epoch
        self.shuffle = args.shuffle
        self.bat_size = args.bat_size
        self.train_dset = train_dset
        self.val_dset = val_dset

        self.val_DLoader = {}
        for name in val_dset.keys():
            self.val_DLoader[name] = DataLoader(val_dset[name], batch_size=1, shuffle=False,
            num_workers=0, pin_memory=True)

        self.train_DLoader = DataLoader(train_dset, batch_size=self.args.bat_size, shuffle=self.shuffle,
            num_workers=self.args.num_workers, pin_memory=False)
        self.bat_num = len(self.train_DLoader)

        self.ckp_dir = args.ckp_dir
        self.mse_loss = nn.MSELoss()


    def _set_optim(self):
        for p in list(self.net.net.parameters()):
            p.requires_grad = True

        optimdict = filter(lambda p: p.requires_grad, self.net.parameters())
        optimizer = optim.Adam(optimdict, lr=self.lr)
        scheduler = MultiStepLR(optimizer, milestones=[350, 450], gamma=0.2)  # learning rates
        return optimizer, scheduler


    def __call__(self):
        self.optimizer, self.scheduler = self._set_optim()
        start = 0

        # Resume Training
        if self.args.resume:
            start = self.resume_tr()
            start += 1

        for epoch in range(start, self.epoch):
            self.scheduler.step(epoch)

            # One epoch training
            print(epoch)
            with tqdm(total=len(self.train_DLoader), ncols=100, position=0, leave=True) as t:
                for n_count, bat in enumerate(self.train_DLoader):
                    self.net.train()
                    self.optimizer.zero_grad()

                    bat_x, bat_y, Fker, ker = bat['bl'].cuda(), bat['sp'].cuda(), bat['Fker'], bat['ker']
                    ker, Fker = self._Fker_ker_for_input(ker,Fker)
                    bat_db, bat_dn = self.net(bat_x, Fker=Fker)

                    loss = self.loss(bat_db, bat_y)
                    loss.backward()
                    self.optimizer.step()

                    # Do Validation in several runs.
                    if (epoch % 50 == 0 and n_count == self.bat_num - 1) \
                            or (self.args.debug and n_count % 100 == 0):
                        [self.val(name) for name in self.val_dset.keys()]


                    t.set_postfix(loss='%1.3e' % loss.detach().cpu().numpy())
                    t.update()

            # Save nets
            if epoch % self.args.save_freq == 0 or epoch == self.epoch - 1:
                self.save_ckp(epoch)
        return 0

    def loss(self, db, sp):
        layer = len(db)
        loss = 0
        for i in range(1,layer-1):
            loss += self.mse_loss(db[i], sp) * 0.8
        loss += self.mse_loss(db[layer-1], sp)
        return loss

    def save_ckp(self, epoch):
        filename = self.ckp_dir + 'epoch%d' % epoch
        state = {'model'    : self.net.state_dict(),
                 'optimizer': self.optimizer.state_dict(),
                 'scheduler': self.scheduler.state_dict()}
        torch.save(state, filename)

    def resume_tr(self):
        ckp = self.load_model(self.args)
        self.optimizer.load_state_dict(ckp['optimizer'])
        return int(re.findall('\d+', self.args.val_ckp_dir)[-1])


    def val(self, name):
        bat_x = []
        bat_y = []
        bat_opt = []
        for i, bat in enumerate(self.val_DLoader[name]):
            bat_x.append(bat['bl'])
            bat_y.append(bat['sp'])
            opt_db, opt_dn = self.eval_net(bat['bl'].cuda(), bat['Fker'].cuda())
            bat_opt.append(opt_db[-1].cpu())

        print('-------%s-------' % (name))
        print('INP_PSNR', '%2.2f' % aver_psnr_ds(bat_x, bat_y))
        print('OUT_PSNR', '%2.2f' % aver_psnr_ds(bat_opt, bat_y))
        print('INP_SSIM', '%2.3f' % aver_ssim_ds(bat_x, bat_y))
        print('OUT_SSIM', '%2.3f' % aver_ssim_ds(bat_opt, bat_y))

    @staticmethod
    def _Fker_ker_for_input(ker, Fker):
        FFker = [None] * Fker.size(0)
        for i in range(Fker.size(0)):
            FFker[i] = Fker[i,].cuda()
        Kker = [None] * ker.shape[0]
        for i in range(ker.shape[0]):
            x, y = np.where(~np.isnan(ker[i]))
            x_max = np.max(x)
            y_max = np.max(y)
            Kker[i] = ker[i, :x_max, :y_max]
        return Kker, FFker

    def eval_net(self, bl, *args):
        with torch.no_grad():
            self.net.eval()
            bl = bl.cuda()
            db = self.net(bl,*args)
        return db

    def load_model(self, args):
        ckp = torch.load(args.test_ckp_dir, map_location=lambda storage, loc: storage.cuda(args.gpu_idx))
        self.net.load_state_dict(ckp['model'])
        return ckp

if __name__ == '__main__':

    args = get_train_config()
    log(args)
    net = vem_deblur_model(args).cuda()

    train_dset = Train_Dataset(args, args.train_sp_dir, args.sigma, args.train_ker_dir)
    val_dset = {}
    for name in args.val_bl_sigma:
        val_dset[str(name)] = Test_Dataset(args.val_sp_dir, args.val_bl_dir[str(name)], args.val_ker_dir)

    # trainer
    train = Trainer(args, net, train_dset=train_dset, val_dset=val_dset)
    train()

    print('[*] Finish!')




