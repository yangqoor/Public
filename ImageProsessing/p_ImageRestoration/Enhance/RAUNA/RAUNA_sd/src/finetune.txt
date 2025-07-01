import argparse

import copy

import torch
import numpy as np
import os
import cv2
import data
import model2
import utility
import torch.nn.functional as F
from torchvision import transforms
from decimal import Decimal #float calculation
from tqdm import tqdm
import matplotlib.pyplot as plt
# import bm3d
from torch import nn
import pytorch_ssim
from skimage import exposure
from PIL import Image
import loss_spa
import matplotlib.pyplot as plt
from torch.utils.data import dataloader
class Finetune():
    def __init__(self,args,model_decomposition, model_reconstruction, ft_loss, ft_loader,ckp):
        self.args = args
        self.device = torch.device('cpu' if args.cpu else 'cuda')
        self.alpha = torch.tensor([args.alpha], requires_grad=True, device=self.device)
        self.ga = args.finetune_gamma
        self.model_re = model_reconstruction
        self.model_de = model_decomposition
        self.pre_re = args.pre_train_re
        self.pre_de = args.pre_train_de
        self.loader_ft = ft_loader.loader_ft
        self.loader_val = ft_loader.loader_val
        self.scale = args.scale  # sr scale
        # self.loader_valid = ft_loader.loader_valid
        # self.epochs = args.ft_epochs
        self.loss_ft = ft_loss
        self.ckp = ckp
        self.adj_b = args.adjust_brightness

        self.gpus = args.n_GPUs
        self.count = 0


        self.optimizer_ft_al = utility.make_optimizer_alpha(args, self.alpha)
        self.scheduler_ft_al = utility.make_scheduler_al(args, self.optimizer_ft_al)
        # self.optimizer_ft_de = utility.make_optimizer(args, self.model_de)  # lr=1e-4
        # self.optimizer_ft_re = torch.optim.Adam(
        #     [{'params': model2.renet.Lenet().scale.parameters(), 'lr': args.lr_re},
        #      {'params': model2.renet.Renet().scale.parameters(), 'lr': args.lr_re}]
        # )
        self.optimizer_ft_re = utility.make_optimizer_re(args, self.model_re)  # lr=1e-4
        # self.scheduler_ft_de = utility.make_scheduler(args, self.optimizer_ft_de)
        self.scheduler_ft_re = utility.make_scheduler_re(args, self.optimizer_ft_re)

        if self.args.load != '.':
            self.optimizer_ft_re.load_state_dict(
                torch.load(os.path.join(ckp.dir, 'optimizer_re.pt'))
            )
            for _ in range(len(ckp.log)):
                self.scheduler_ft_re.step()

    def finetune(self):

        def ssim_loss(rl, rh):
            ssim = pytorch_ssim.SSIM(window_size=11)
            c = rl.shape[2]
            if c == 3:
                ssim_all = ssim(rl[:, 0, :, :].unsqueeze(dim=1), rh[:, 0, :, :].unsqueeze(dim=1)) \
                           + ssim(rl[:, 1, :, :].unsqueeze(dim=1), rh[:, 1, :, :].unsqueeze(dim=1)) \
                           + ssim(rl[:, 2, :, :].unsqueeze(dim=1), rh[:, 2, :, :].unsqueeze(dim=1))
            else:
                ssim_all = ssim(rl, rh)

            return 1 - ssim_all / c

        def col_loss(im):
            batch, _, _, _ = im.shape
            loss = 0
            for i in range(batch):
                r = im[i, 0, :, :].mean()
                g = im[i, 1, :, :].mean()
                b = im[i, 2, :, :].mean()
                loss += (r - g) ** 2 + (r - b) ** 2 + (g - b) ** 2
            return loss / batch

        def color_loss(rl, rh):
            color_r = rl
            color_i = rh
            r_color_u = torch.sum(color_r * color_i, dim=1)
            r_color_d1 = torch.sqrt(torch.sum(color_r * color_r, 1))
            r_color_d2 = torch.sqrt(torch.sum(color_i * color_i, 1))
            r_color = (r_color_u + 0.0001) / (r_color_d1 * r_color_d2 + 0.0001)

            return torch.mean(1 - r_color)

        # self.scheduler_ft_de.step()

        self.scheduler_ft_re.step()
        self.scheduler_ft_al.step()
        self.loss_ft.step()

        epoch = self.scheduler_ft_re.last_epoch + 1
        # learning_rate_ft_de = self.scheduler_ft_de.get_lr()[0]
        learning_rate_ft_re = self.scheduler_ft_re.get_lr()[0]
        learning_rate_ft_al = self.scheduler_ft_al.get_lr()[0]
        # self.ckp.write_log('[Epoch {}]\tLearning rate of rec: {:.2e}'.format(epoch, Decimal(learning_rate_ft_de)))
        self.ckp.write_log('[Epoch {}]\tLearning rate of rec: {:.2e}'.format(epoch, Decimal(learning_rate_ft_re)))
        self.ckp.write_log('[Epoch {}]\tLearning rate of rec: {:.2e}'.format(epoch, Decimal(learning_rate_ft_al)))
        self.loss_ft.start_log()

        self.model_de.model = utility.load_model(self.model_de.model, self.pre_de, self.device, self.gpus)
        # self.model_de.load_state_dict(torch.load(self.pre_de))
        self.model_re.model = utility.load_model(self.model_re.model, self.pre_re, self.device, self.gpus)
        # model_de_o = copy.deepcopy(self.model_de)
        # model_de_o.eval()
        model_re_o = copy.deepcopy(self.model_re)
        model_re_o.eval()
        # model_re_o = copy.deepcopy(self.model_re)
        self.model_re.train()
        self.model_de.eval()
        timer_data, timer_model = utility.timer(), utility.timer()
        cnt = 0

        self.count = 0
        for batch, (unlabel_lr, unlabel_gt, idx) in enumerate(self.loader_ft):
            # --------load data -------#
            # label_lr, label_gt = label_train_data
            cnt = cnt + 1
            # TODO: HE of Unlabel data
            unlabel_lr, unlabel_gt = self.prepare(unlabel_lr, unlabel_gt)
            unlabel_lr = unlabel_lr.to(self.device)
            # unlabel_gt = unlabel_gt.to(self.device)
            # label_lr = label_lr.to(self.device)
            # label_gt = label_gt.to(self.device)
            # unlabel_gt = unlabel_gt/255.0
            unlabel_lr = unlabel_lr / 255.0
            timer_data.hold()
            timer_model.tic()
            self.model_re.zero_grad()
            # self.model_de.zero_grad()
            # self.optimizer_ft_de.zero_grad()
            self.optimizer_ft_re.zero_grad()
            self.optimizer_ft_al.zero_grad()
            # lr_label, hr_label = self.prepare(label_lr, label_gt)

            # L0_l, R0_l, ListL_l, ListR_l = self.model_de(lr, idx_scale)
            # r_label = ListR_l[-1].detach()
            # l_label = ListL_l[-1].detach()
            # R_re, L_re = self.model_re(r_label, l_label, self.alpha)
            # # R_l_re_o, L_l_re_o = model_re_o(r_label, l_label, self.alpha)

            L0_l_un, R0_l_un, ListL_l_un, ListR_l_un = self.model_de(unlabel_lr)
            # L0_l_un_o, R0_l_un_o, ListL_l_un_o, ListR_l_un_o = model_de_o(unlabel_lr)
            r_un = ListR_l_un[-1]
            l_un = ListL_l_un[-1]
            # r_un_o = ListR_l_un_o[-1]
            # l_un_o = ListL_l_un_o[-1]
            # i_un = r_un * l_un
            # i_un = torch.clamp(i_un,0,1)
            # self.alpha = torch.tensor([self.alpha], dtype=torch.float32)
            # print(self.alpha)

            R_re_un, L_re_un = self.model_re(r_un.detach(), l_un.detach(), self.alpha)
            R_re_un_o, L_re_un_o = model_re_o(r_un, l_un, self.alpha)


            # Ori_loss = nn.MSELoss()(5 * R_re_un_o, 5 * R_re_un) + \
            #            nn.MSELoss()(5 * L_re_un_o, 5 * L_re_un)
            # nn.MSELoss()(r_un_o, r_un) + \
            # nn.MSELoss()(l_un_o, l_un)
            # Rec_loss = nn.MSELoss()(i_un, unlabel_lr)

            sr_un = R_re_un * L_re_un
            sr_o = R_re_un_o * L_re_un_o-0.2
            sr_o = 1-(1-sr_o)**2
            Ori_loss = color_loss(sr_un, sr_o)

            ########### prior image
            im = transforms.functional.adjust_brightness(unlabel_lr, brightness_factor=self.adj_b)
            # im = transforms.functional.adjust_gamma(im, 0.5)
            # im = im * (2 - im)
            # im = unlabel_lr.clone()
            img = im.cpu()
            # print('image{}'.format(img.shape))
            im_noise = img[0, :, :, :].permute(1, 2, 0)
            im_noise = bm3d.bm3d(im_noise * 255.0, sigma_psd=10)
            # im_noise = 255 - (255 - im_noise) ** 2 / 255
            # im_clahe = np.clip(im_noise / 255.0,0,1)
            im_clahe = exposure.equalize_adapthist(np.clip(im_noise / 255.0, 0, 1), clip_limit=0.05)
            im[0, :, :, :] = torch.from_numpy(im_clahe).permute(2, 0, 1)
            # im[0, :, :, :] = im_noise.permute(2, 0, 1)
            unlabel_ga = torch.clamp(im, 0, 1).to(self.device)

            # CLAHE_loss = 2 * nn.L1Loss()(25 * sr_un, 25 * unlabel_ga) + 2 * self.loss_ft(25 * sr_un,
            #                                                                              25 * unlabel_ga) + 5 * ssim_loss(
            #     25 * sr_un, 25 * unlabel_ga)
            # print(self.loss_ft(25*sr_un, 25*unlabel_ga) , nn.MSELoss()(25*sr_un, 25*unlabel_ga) , ssim_loss(25*sr_un, 25*unlabel_ga))
            # Col_loss = col_loss(sr_un)
            CLAHE_loss =1*nn.MSELoss()(sr_un, unlabel_ga)
            SPALoss = loss_spa.L_spa()
            spa_loss = torch.mean(SPALoss(unlabel_lr,sr_un))
            print(spa_loss)
            loss = 0.9 * CLAHE_loss + 0.1*spa_loss
            print(loss)

            loss.backward()
            self.optimizer_ft_al.step()
            self.optimizer_ft_re.step()
            # self.optimizer_ft_de.step()

            timer_model.hold()
            if (batch + 1) % self.args.print_every == 0:
                self.ckp.write_log('[{}/{}]\t{}\t{:.1f}+{:.1f}s'.format(
                    (batch + 1) * self.args.ft_batch,
                    len(self.loader_ft.dataset),
                    self.loss_ft.display_loss(batch),
                    timer_model.release(),
                    timer_data.release()))
            timer_data.tic()
        self.loss_ft.end_log(len(self.loader_ft))
        self.error_last = self.loss_ft.log[-1, -1]

    def validation(self):
        def save_im(im,epoch,filename,type):
            path = '../0917/'
            if not os.path.exists(path):
                os.makedirs(path)
            im = im.permute(1,2,0).numpy()
            im = Image.fromarray(im.astype('uint8'))
            im.save(path+'{}_{}_epoch_{}.png'.format(filename, type, epoch))

        epoch = self.scheduler_ft_re.last_epoch + 1
        self.ckp.write_log('\nEvaluation:')
        self.ckp.add_log(torch.zeros(1, len(self.scale)))
        self.model_de.to(self.device)
        self.model_re.to(self.device)
        self.model_de.eval()
        self.model_re.eval()

        timer_val = utility.timer()
        with torch.no_grad():
            for idx_scale, scale in enumerate(self.scale):
                # print(scale)
                # eval_acc = 0
                avr_psnr = 0
                avr_ssim = 0
                self.loader_val.dataset.set_scale(idx_scale)
                tqdm_test = tqdm(self.loader_val, ncols=80)  # python进度条
                for idx_img, (lr, hr, filename) in enumerate(tqdm_test):
                    filename = filename[0]
                    # print(filename)
                    no_eval = (hr.nelement() == 1)
                    if not no_eval:
                        lr, hr = self.prepare(lr, hr)
                    else:
                        lr, = self.prepare(lr)
                    lr = lr / 255.0
                    alpha = torch.tensor([self.alpha], dtype=torch.float32)
                    L0_l, R0_l, ListL_l, ListR_l = self.model_de(lr)

                    R_l_re, L_l_re = self.model_re(ListR_l[-1], ListL_l[-1], alpha)
                    Is_l = R_l_re * L_l_re
                    sr = utility.quantize(Is_l * 255., self.args.rgb_range)
                    show_sr = sr[0, :, :, :].cpu().clone()
                    save_im(show_sr, epoch, filename, 'sr')

                    val_psnr, val_ssim = utility.validation(sr, hr, self.device)
                    avr_psnr += val_psnr
                    avr_ssim += val_ssim

                avr_psnr = avr_psnr/len(self.loader_val)
                avr_ssim = avr_ssim/len(self.loader_val)
                # self.ckp.log[-1, idx_scale] = avr_psnr / len(self.loader_test)
                file_handle = open('0917_psnr.txt', mode='a')
                #\n 换行符
                file_handle.write('img{}'.format(filename))
                file_handle.write('Epoch_{0}\nPSNR:{1:.3f}\nSSIM:{2:.3f}\n\n'.format(epoch, avr_psnr, avr_ssim))
                print('Epoch_{0}\nPSNR:{1:.3f}\nSSIM:{2:.3f}\n'.format(epoch, avr_psnr, avr_ssim))
                self.ckp.log[-1, idx_scale] = avr_psnr
                best = self.ckp.log.max(0)

                # # print(best)
                self.ckp.write_log(
                    'Best: {:.3f} @epoch {}\n\n'.format(
                        best[0][idx_scale],
                        best[1][idx_scale] + 2
                    )
                )

            self.ckp.write_log(
                'Total time: {:.2f}s\n'.format(timer_val.toc()), refresh=True
            )

            # print('run ckp_save_best')
            # path = '../experiment/LLENet/model_finetune/'
            # if not os.path.exists(path):
            #     os.makedirs(path)
            path = '../experiment/LLENet/model2_finetune/'
            if not os.path.exists(path):
                os.makedirs(path)
            path_best = '../experiment/LLENet/model2_finetune/model_best.pt'
            path_re = '../experiment/LLENet/model2_finetune/model_latest.pt'
            torch.save(
                self.model_re.model.state_dict(),
                path_re,
            )
            if (best[1][0] + 2 == epoch):
                torch.save(
                    self.model_re.model.state_dict(),
                    path_best,
                )
                file_handle = open(path + 'best_alpha.txt', mode='a')
                # \n 换行符
                file_handle.write('img{}'.format(filename))
                file_handle.write(
                    'Epoch_{0}\nalpha:{1}\nPSNR:{2}\nSSIM:{3}\n\n'.format(epoch, self.alpha, avr_psnr, avr_ssim))

            # self.ckp.save(self, epoch, is_best=(best[1][0] + 1 == epoch))
            # path = '../experiment/LLENet/model2 _finetune/model_latest.pt'
            # def _make_dir(path):
            #     if not os.path.exists(path):
            #         os.makedirs(path)
            # torch.save(
            #     self.model_re.model.state_dict(),
            #     path,
            # )

            # TODO: CALC PSNR

            # utility.print_log(epoch+1, self.epochs, timer_finetune, train_psnr, val_psnr, val_ssim)
            # print('idx:{0},psnr:{1:.3f},ssim{2:.3f}'.format(idx, val_psnr, val_ssim))
            # print('Epoch_{0}\nPSNR:{1:.3f}\nSSIM:{2:.3f}'.format(epoch, avr_psnr/self.count,avr_ssim/self.count))
            # file_handle = open('0809_psnr.txt', mode='a')
            # \n 换行符
            # file_handle.write('0809\n')

            # TestData = self.loss_ft
            # utility.generate_test_images(self.model_re, TestData, self.epochs, (0, self.epochs-1))


    def prepare(self, *args):
        device = torch.device('cpu' if self.args.cpu else 'cuda')

        def _prepare(tensor):
            if self.args.precision == 'half':
                tensor = tensor.half()
            return tensor.to(device)

        return [_prepare(a) for a in args]

    def terminate(self):
        epoch = self.scheduler_ft_re.last_epoch + 1
        return epoch >= self.args.ft_epochs #False














