import os
import math
from decimal import Decimal
import torch.nn as nn

import loss
import utility
from utility import gradient
from utility import grayscale
# import IPython
import torch
from torch.autograd import Variable
from tqdm import tqdm
import scipy.io as sio
import matplotlib
import matplotlib.pyplot as plt
import pylab
from torchvision import transforms
from importlib import import_module
matplotlib.use('agg')
import os
import pytorch_ssim
from PIL import Image
import numpy as np
from skimage import exposure



class Trainer():
    def __init__(self, args, loader, my_model, my_model2, my_loss, ckp):  # loader = data.Data
        self.args = args
        self.save_dir = args.save_dir
        self.scale = args.scale  # sr scale
        self.S = args.stage
        self.ckp = ckp
        self.loader_train = loader.loader_train
        self.loader_test = loader.loader_test
        self.model = my_model
        self.model_re = my_model2
        self.loss = my_loss
        self.L1_loss = nn.L1Loss()
        self.device = torch.device('cpu' if args.cpu else 'cuda')
        self.k = 0
        self.alpha = args.alpha
        # self.w_ssim_l = args.w_ssim_l
        # self.w_ssim_r = args.w_ssim_r

        self.optimizer = utility.make_optimizer(args, self.model)
        self.scheduler = utility.make_scheduler(args, self.optimizer) #last epoch 0
        print('print ckp.dir',ckp.dir)
        if self.args.load != '.':
            self.optimizer.load_state_dict(
                torch.load(os.path.join(ckp.dir, 'optimizer.pt'))
            )
            for _ in range(len(ckp.log)):
                self.scheduler.step()


        self.optimizer_re = utility.make_optimizer_re(args, self.model_re) #lr=1e-4
        self.scheduler_re = utility.make_scheduler_re(args, self.optimizer_re)
        if self.args.load != '.':
            self.optimizer_re.load_state_dict(
                torch.load(os.path.join(ckp.dir, 'optimizer_re.pt'))
            )
            for _ in range(len(ckp.log)):
                self.scheduler_re.step()

        self.error_last = 1e8

    def df_prior(self, lr):
        # 扩散先验
        from model.utils import Diffusion, parse_args_and_config, diffusion_prior
        import torch.nn.functional as F
        config = parse_args_and_config(self.args)
        runner = Diffusion(self.args, config)
        df_model, betas = runner.sample(lr.shape[0])
        # x0, x1 = diffusion_prior(df_model, lr, self.args)
        # x0, x1 = diffusion_prior(lr, df_model, betas, config=config)
        # x0_hat = F.interpolate(x0, 
        #                         size=lr.shape[2:], 
        #                         mode='bilinear', 
        #                         align_corners=False
        #                         )
        # x1_hat = F.interpolate(x1,
        #                         size=lr.shape[2:],
        #                     mode='bilinear',
        #                     align_corners=False
        #                     )
        
        return df_model, betas, config
    

    def train(self):
        import pdb
        # pdb.set_trace()
        self.scheduler.step()
        #last epoch 1
        self.loss.step()
        self.scheduler_re.step()
        # print('e_epoch', self.scheduler.last_epoch)

        epoch = self.scheduler.last_epoch + 1
        learning_rate = self.scheduler.get_lr()[0]
        self.ckp.write_log(
            '[Epoch {}]\tLearning rate: {:.2e}'.format(epoch, Decimal(learning_rate))
        )
        learning_rate_re = self.scheduler_re.get_lr()[0]
        self.ckp.write_log(
            '[Epoch {}]\tLearning rate of rec: {:.2e}'.format(epoch, Decimal(learning_rate_re))
        )

        self.loss.start_log()
        self.model.train()
        self.model_re.train()
        self.count = 0

        timer_data, timer_model = utility.timer(), utility.timer()

        cnt = 0

        print(f'总量{len(self.loader_train)}, epochs {self.args.epochs}, batch_size {self.args.batch_size}')
        prev_lr_shape = None  # 初始化变量，用于保存上一次的 shape
        # for batch, (lr, hr, idx) in tqdm(enumerate(self.loader_train)):
        for batch, (lr, hr, idx) in enumerate(self.loader_train):

            loss_r = 0.
            loss_rec = 0.
            loss_l = 0.

            cnt = cnt + 1
            lr, hr = self.prepare(lr, hr)  # half+todev

            timer_data.hold()
            timer_model.tic()
            self.model.zero_grad()
            self.optimizer.zero_grad()
            self.model_re.zero_grad()
            self.optimizer_re.zero_grad()
            hr = hr / 255.0
            lr1 = lr / 255.0
            lr = lr / 255.0
            R0 = lr1
            hr_grey = 0.299 * hr[:, 0, :, :] + 0.587 * hr[:, 1, :, :] + 0.114 * hr[:, 2, :, :]
            lr_grey = 0.299 * R0[:, 0, :, :] + 0.587 * R0[:, 1, :, :] + 0.114 * R0[:, 2, :, :]
            alpha_l = ((hr_grey-lr_grey+0.0001)/(hr_grey+0.0001)).mean(dim=(1, 2))
            # alpha_l = torch.FloatTensor([0.95]).to(self.device)

            if prev_lr_shape is None:    # or lr.shape != prev_lr_shape: 
                # x0_hat, x1_hat = self.diffusion_prior(lr)
                df_model, betas, config = self.df_prior(lr)
            
            prev_lr_shape = lr.shape

            L0_l, R0_l, ListL_l, ListR_l = self.model(lr, df_model, betas, config)
            L0_h, R0_h, ListL_h, ListR_h = self.model(hr, df_model, betas, config)

            R_l_re, L_l_re, scale_R = self.model_re(ListR_l[-1].detach(), ListL_l[-1].detach(), alpha_l,lr)

            def mutual_i_input_loss(l,i):
                input_gray = grayscale(i)
                low_gradient_x = gradient(l,'x')
                input_gradient_x = gradient(input_gray,'x')
                input_g_x_max = torch.maximum(input_gradient_x,torch.FloatTensor([0.01]).to(self.device))
                x_loss = torch.abs(torch.div(low_gradient_x, input_g_x_max))
                low_gradient_y = gradient(l, 'y')
                input_gradient_y = gradient(input_gray, 'y')
                input_g_y_max = torch.maximum(input_gradient_y, torch.FloatTensor([0.01]).to(self.device))
                y_loss = torch.abs(torch.div(low_gradient_y, input_g_y_max))
                mut_loss = torch.mean(x_loss+y_loss)
                return mut_loss

            def ssim_loss(rl,rh):
                ssim = pytorch_ssim.SSIM(window_size=11)
                ssim_all = ssim(rl, rh)


                return 1-ssim_all

            def color_loss(rl, rh):
                color_r = rl+0.001
                color_i = rh
                r_color_u = torch.sum(color_r*color_i, dim=1)
                r_color_d1 = torch.sqrt(torch.sum(color_r*color_r, 1))
                r_color_d2 = torch.sqrt(torch.sum(color_i*color_i, 1))
                r_color = (r_color_u+0.001) / (r_color_d1 * r_color_d2+0.001)

                return torch.mean(1-r_color)

            # 计算各阶段损失
            for i in range(self.S):
                l_i_loss = 1*mutual_i_input_loss(ListL_l[i], lr) + 1*mutual_i_input_loss(ListL_h[i], hr)# L的梯度正则化项
                loss_r = loss_r + 1. * nn.MSELoss()(ListR_l[i], ListR_h[i])# R的数据保真项
                loss_l = loss_l + 1*l_i_loss
                loss_rec = loss_rec + 1. * nn.MSELoss()(ListR_h[i] * ListL_h[i], hr) + 1. * nn.MSELoss()(ListR_l[i] * ListL_l[i], lr)# 重建损失（保真项）
            loss = .1*loss_l + 1*loss_r + 1000*loss_rec# 组合损失（对应公式6的加权和）
            # l_i_loss = 1 * mutual_i_input_loss(ListL_l[-1], lr) + 1 * mutual_i_input_loss(ListL_h[-1], hr)
            # loss_r = 1. * nn.MSELoss()(ListR_l[-1], ListR_h[-1])
            # loss_l = 1*l_i_loss
            # loss_rec = 1. * nn.MSELoss()(ListR_h[-1] * ListL_h[-1], hr) + 1. * nn.MSELoss()(ListR_l[-1] * ListL_l[-1], lr)
            # loss = .1*loss_l + 1*loss_r + 1000*loss_rec

            loss_re_r = 1*ssim_loss(R_l_re, ListR_h[-1].detach())
            loss_re_l = 1*nn.MSELoss()(L_l_re, ListL_h[-1].detach())
            sr = R_l_re * L_l_re
            scale = ((hr_grey-lr_grey+0.0001)/(hr_grey+0.0001)).unsqueeze(dim=1)
            loss_scale = nn.MSELoss()(scale_R, scale)
            loss_re_rec = 10*self.loss(sr,hr)+1*color_loss(sr,hr)+0.1*nn.MSELoss()(sr,hr)
            loss_re = .05 * loss_re_l + .05 * loss_re_r + .1 * loss_scale + 20 * loss_re_rec
            # print(10*self.loss(sr, hr))
            # print(1*color_loss(sr,hr))
            # print(0.1*nn.MSELoss()(sr,hr))

            loss.backward(retain_graph=True)
            self.optimizer.step()
            loss_re.backward()
            self.optimizer_re.step()
            timer_model.hold()
            if (batch + 1) % self.args.print_every == 0:
                print('loss_l',.1*loss_l)
                print('loss_r',1*loss_r)
                print('loss_rec',1000*loss_rec)
                print('loss_re_l',.05*loss_re_l)
                print('loss_re_r',.05*loss_re_r)
                print('loss_scale',.1*loss_scale)
                print('loss_re_rec',20*loss_re_rec)

                self.ckp.write_log('[{}/{}]\t{}\t{:.1f}+{:.1f}s'.format(
                    (batch + 1) * self.args.batch_size,
                    len(self.loader_train.dataset),
                    self.loss.display_loss(batch),
                    timer_model.release(),
                    timer_data.release()))

            timer_data.tic()

        self.loss.end_log(len(self.loader_train))
        self.error_last = self.loss.log[-1, -1]


    def test(self):
        def show(img):
            img = torch.clamp((img / 255.), 0, 1)
            img = transforms.ToPILImage()(img)
            plt.axis('off')
            plt.imshow(img)

        def showl(img):
            img = torch.clamp((img / 255.), 0, 1)
            img = transforms.ToPILImage()(img)
            plt.axis('off')
            plt.imshow(img, cmap='gray')

        def save_im(im,epoch,filename,type):
            path = '../results/{}/'.format(self.save_dir)
            if not os.path.exists(path):
                os.makedirs(path)
            im = im.permute(1,2,0).numpy()
            im = Image.fromarray(im.astype('uint8'))
            im.save(path+'{}_{}_epoch_{}.png'.format(filename, type, epoch))


        epoch = self.scheduler.last_epoch + 1
        self.ckp.write_log('\nEvaluation:')
        self.ckp.add_log(torch.zeros(1, len(self.scale)))
        self.model.to(self.device)
        self.model_re.to(self.device)
        self.model.eval()
        self.model_re.eval()

        timer_test = utility.timer()
        with torch.no_grad():
            for idx_scale, scale in enumerate(self.scale):
                # print(scale)
                eval_acc = 0
                ssim = 0
                self.loader_test.dataset.set_scale(idx_scale)
                tqdm_test = tqdm(self.loader_test, ncols=80) #python进度条
                prev_lr_shape = None  # 初始化变量，用于保存上一次的 shape
                for idx_img, (lr, hr, filename) in enumerate(tqdm_test):
                    filename = filename[0]
                    no_eval = (hr.nelement() == 1)
                    if not no_eval:
                        lr, hr = self.prepare(lr, hr)
                    else:
                        lr, = self.prepare(lr)

                    hr_1 = hr / 255.0
                    lr1 = lr / 255.0
                    lr = lr / 255.0
                    lr_grey = 0.299 * lr1[:, 0, :, :] + 0.587 * lr1[:, 1, :, :] + 0.114 * lr1[:, 2, :, :]
                    # hr_grey = 0.68
                    # ad_lr = transforms.functional.adjust_gamma(lr, gamma=0.45)
                    # lvse = ad_lr*(2-ad_lr)
                    # hr_grey = 0.299 * lvse[:, 0, :, :] + 0.587 * lvse[:, 1, :, :] + 0.114 * lvse[:, 2, :, :]
                    hr_grey = 0.299 * hr_1[:, 0, :, :] + 0.587 * hr_1[:, 1, :, :] + 0.114 * hr_1[:, 2, :, :]
                    alpha = ((hr_grey-lr_grey+0.0001)/(hr_grey+0.0001)).mean(dim=(1, 2))
                    # alpha = torch.FloatTensor([self.alpha]).to(self.device)
                    # alpha_h = ((hr_grey + 0.0001) / (hr_grey + 0.0001))
                    if prev_lr_shape is None:    # or lr.shape != prev_lr_shape: 
                        # x0_hat, x1_hat = self.diffusion_prior(lr)
                        df_model, betas, config = self.df_prior(lr)
                
                    prev_lr_shape = lr.shape

                    L0_l, R0_l, ListL_l, ListR_l = self.model(lr, df_model, betas, config)
                    L0_h, R0_h, ListL_h, ListR_h = self.model(hr, df_model, betas, config)

                    R_l_re, L_l_re,scale_R = self.model_re(ListR_l[-1], ListL_l[-1], alpha,lr)
                    Is_l = R_l_re * L_l_re
                    # i = Is_l[0, :, :, :].permute(1, 2, 0)
                    # i=np.clip(i.cpu().numpy(),0,1)
                    # i = exposure.equalize_adapthist(i, clip_limit=0.005)
                    # Is_l[0, :, :, :] = torch.from_numpy(i).permute(2, 0, 1)
                    sr = utility.quantize(Is_l * 255., self.args.rgb_range)
                    Is_h = ListR_h[-1] * ListL_h[-1]
                    sr_h = utility.quantize(Is_h * 255., self.args.rgb_range)
                    show_sr = sr[0, :, :, :].cpu().clone()
                    save_im(show_sr, epoch, filename, 'sr')
                    show_sr_h = sr_h[0, :, :, :].cpu().clone()
                    # save_im(show_sr_h, epoch, filename, 'hr')
                    l = utility.quantize(ListL_l[-1] * 255., self.args.rgb_range)
                    r = utility.quantize(ListR_l[-1] * 255., self.args.rgb_range)
                    r1 = utility.quantize(R_l_re * 255., self.args.rgb_range)
                    l1 = utility.quantize(L_l_re * 255., self.args.rgb_range)
                    s = utility.quantize(scale_R * 255., self.args.rgb_range)
                    show_l = l[0, :, :, :].cpu().clone()
                    show_l1 = l1[0, :, :, :].cpu().clone()
                    show_r = r[0, :, :, :].cpu().clone()
                    show_r1 = r1[0, :, :, :].cpu().clone()
                    show_s = s[0, :,:,:].cpu().clone()
                    r_h = utility.quantize(ListR_h[-1] * 255., self.args.rgb_range)
                    l_h = utility.quantize(ListL_h[-1] * 255., self.args.rgb_range)
                    show_r_h = r_h[0, :, :, :].cpu().clone()
                    show_l_h = l_h[0, :, :, :].cpu().clone()

                    if filename=='1':

                        dir = '../results/{}/decomposition/'.format(self.save_dir)
                        if not os.path.exists(dir):
                            os.makedirs(dir)
                        showl(show_l)
                        plt.savefig(dir + 'l_{}epoch_{}.png'.format(filename, epoch), bbox_inches='tight', pad_inches=0)
                        showl(show_l1)
                        plt.savefig(dir + 'le_{}epoch_{}.png'.format(filename, epoch), bbox_inches='tight',
                                    pad_inches=0)
                        show(show_r)
                        plt.savefig(dir + 'r_{}epoch_{}.png'.format(filename, epoch), bbox_inches='tight', pad_inches=0)
                        show(show_r1)
                        plt.savefig(dir + 're_{}epoch_{}.png'.format(filename, epoch), bbox_inches='tight',
                                    pad_inches=0)
                        show(show_r_h)
                        plt.savefig(dir + 'rh_{}epoch_{}.png'.format(filename, epoch), bbox_inches='tight',
                                    pad_inches=0)
                        showl(show_l_h)
                        plt.savefig(dir + 'lh_{}epoch_{}.png'.format(filename, epoch), bbox_inches='tight',
                                    pad_inches=0)
                        # showl(show_s)
                        # plt.savefig(dir + 's_{}epoch_{}.png'.format(filename, epoch), bbox_inches='tight',
                        #             pad_inches=0)

                    save_list = [sr]
                    if not no_eval:
                        eval_acc += utility.calc_psnr(
                            sr, hr,
                        )
                        ssim += pytorch_ssim.SSIM()(sr/255.0, hr/255.0)
                        save_list.extend([lr, hr])

                    if self.args.save_results: #arg.save_results = store_true
                        self.ckp.save_results(filename, save_list, scale)

                self.ckp.log[-1, idx_scale] = eval_acc / len(self.loader_test)
                ssim = ssim/len(self.loader_test)
                file_handle = open('{}psnr.txt'.format(self.save_dir), mode='a')
                #\n 换行符
                # file_handle.write('r_{}_l_{}\n'.format(self.w_ssim_r, self.w_ssim_l))
                file_handle.write('epoch{}\n'.format(epoch))
                file_handle.write('PSNR:{}\nSSIM:{}\n\n'.format(self.ckp.log[-1, idx_scale], ssim))
                self.ckp.log[-1, idx_scale] = ssim
                best = self.ckp.log.max(0) #best=[values][indices]
                # print(best)
                self.ckp.write_log(
                    '[{} x{}]\tPSNR: {:.3f} (Best: {:.3f} @epoch {})'.format(
                        self.args.data_test,
                        scale,
                        self.ckp.log[-1, idx_scale],
                        best[0][idx_scale],
                        best[1][idx_scale] + 2
                    )
                )

        self.ckp.write_log(
            'Total time: {:.2f}s\n'.format(timer_test.toc()), refresh=True
        )
        if not self.args.test_only:
            # print('run ckp_save_best')
            # print('best:', best[1][0] + 1)
            # print('epoch:', epoch)
            if (best[1][0] + 2 == epoch):
                isbest = True
            else: isbest = False
            self.ckp.save(self, epoch, is_best=isbest)

    def prepare(self, *args):
        device = torch.device('cpu' if self.args.cpu else 'cuda:0')

        def _prepare(tensor):
            if self.args.precision == 'half':
                tensor = tensor.half()
            return tensor.to(device)

        return [_prepare(a) for a in args]

    def terminate(self):
        if self.args.test_only:
            self.test()
            return True
        else:
            epoch = self.scheduler.last_epoch + 1
            return epoch >= self.args.epochs #False

# pause a bit so that plots are updated



