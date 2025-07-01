import os
import math
import time
import datetime
from torch import nn
import torch.nn.functional as F

import utility
from pytorch_ssim import SSIM
import cv2
from functools import reduce
from torch.utils.data import dataloader

import matplotlib
#matplotlib.use('Agg')
import matplotlib.pyplot as plt

import numpy as np
import scipy.misc as misc

import torch
import torch.optim as optim
import torch.optim.lr_scheduler as lrs

class timer():
    def __init__(self):
        self.acc = 0
        self.tic()

    def tic(self):
        self.t0 = time.time()

    def toc(self):
        return time.time() - self.t0

    def hold(self):
        self.acc += self.toc()

    def release(self):
        ret = self.acc
        self.acc = 0

        return ret

    def reset(self):
        self.acc = 0

class checkpoint():
    def __init__(self, args):
        self.args = args
        self.ok = True
        self.log = torch.Tensor()
        now = datetime.datetime.now().strftime('%Y-%m-%d-%H:%M:%S')
#-------use this-----------#
        if args.load == '.':   #arg.load='.'
            if args.save == '.':
                args.save = now
            self.dir = '../experiment/' + args.save #dir_now = '../experient/LLENet'
#-------use this-----------#
        else:
            self.dir = '../experiment/' + args.load
            if not os.path.exists(self.dir):
                args.load = '.'
            else:
                self.log = torch.load(self.dir + '/psnr_log.pt')
                print('Continue from epoch {}...'.format(len(self.log)))

        if args.reset:
            os.system('rm -rf ' + self.dir)
            args.load = '.'

        def _make_dir(path):
            if not os.path.exists(path):
                os.makedirs(path)

        _make_dir(self.dir)
        _make_dir(self.dir + '/model')
        _make_dir(self.dir + '/model2')
        _make_dir(self.dir + '/results')

        open_type = 'a' if os.path.exists(self.dir + '/log.txt') else 'w'
        self.log_file = open(self.dir + '/log.txt', open_type)
        with open(self.dir + '/config.txt', open_type) as f:
            f.write(now + '\n\n')
            for arg in vars(args):
                f.write('{}: {}\n'.format(arg, getattr(args, arg)))
            f.write('\n')

    def save(self, trainer, epoch, is_best=False):
        trainer.model.save(self.dir, epoch, is_best=is_best)
        trainer.model_re.save(self.dir, epoch, is_best=is_best)
        trainer.loss.save(self.dir)
        trainer.loss.plot_loss(self.dir, epoch)

        self.plot_psnr(epoch)
        torch.save(self.log, os.path.join(self.dir, 'psnr_log.pt'))
        torch.save(
            trainer.optimizer.state_dict(),
            os.path.join(self.dir, 'optimizer.pt')
        )

    def add_log(self, log):
        self.log = torch.cat([self.log, log])
        print('log:', self.log)

    def write_log(self, log, refresh=False):
        print(log)
        self.log_file.write(log + '\n')
        if refresh:
            self.log_file.close()
            self.log_file = open(self.dir + '/log.txt', 'a')

    def done(self):
        self.log_file.close()

    def plot_psnr(self, epoch):
        print('use_plot_psnr')
        epoch = epoch-1
        axis = np.linspace(1, epoch, epoch)
        label = 'SR on {}'.format(self.args.data_test)
        fig = plt.figure()
        plt.title(label)
        for idx_scale, scale in enumerate(self.args.scale):
            plt.plot(
                axis,
                self.log[:, idx_scale].numpy(),
                label='Scale {}'.format(scale)
            )
        plt.legend()
        plt.xlabel('Epochs')
        plt.ylabel('PSNR')
        plt.grid(True)
        plt.savefig('{}/test_{}.pdf'.format(self.dir, self.args.data_test))
        plt.close(fig)

    def save_results(self, filename, save_list, scale):
        print('use_save_results')
        filename = '{}/results/{}_x{}_'.format(self.dir, filename, scale) #dir_now = '../experient/LLENet'
        postfix = ('SR', 'LR', 'HR')
        for v, p in zip(save_list, postfix):
            normalized = v[0].data.mul(255 / self.args.rgb_range)
            ndarr = normalized.byte().permute(1, 2, 0).cpu().numpy() # exchange dimension
            misc.imsave('{}{}.png'.format(filename, p), ndarr)

def quantize(img, rgb_range):
    pixel_range = 255 / rgb_range
    return img.mul(pixel_range).clamp(0, 255).round().div(pixel_range)

def calc_psnr(sr, hr):
    if sr.shape[1] == 3:
        sr_Y = 0.257*sr[:,0,:,:]+0.564*sr[:,1,:,:]+0.098*sr[:,2,:,:]+16
        sr_Y = sr_Y.round()
        hr_Y = 0.257*hr[:,0,:,:]+0.564*hr[:,1,:,:]+0.098*hr[:,2,:,:]+16
        hr_Y = hr_Y.round()

        diff = (sr_Y - hr_Y).div_(255)
        rmse = math.sqrt(torch.mean(diff ** 2.))
        return 20 * math.log10(1./ rmse)

    else:
        print('Wrong shape!')




def make_optimizer(args, my_model):
    trainable = filter(lambda x: x.requires_grad, my_model.parameters()) #过滤函数 传入每一个需要梯度下降的参数

    if args.optimizer == 'SGD':
        optimizer_function = optim.SGD
        kwargs = {'momentum': args.momentum}
    elif args.optimizer == 'ADAM':
        optimizer_function = optim.Adam
        kwargs = {
            'betas': (args.beta1, args.beta2),
            'eps': args.epsilon
        }
    elif args.optimizer == 'RMSprop':
        optimizer_function = optim.RMSprop
        kwargs = {'eps': args.epsilon}

    kwargs['lr'] = args.lr
    kwargs['weight_decay'] = args.weight_decay
    
    return optimizer_function(trainable, **kwargs) #kwargs 传入键值对


def make_optimizer_re(args, my_model):
    trainable = filter(lambda x: x.requires_grad, my_model.parameters())

    if args.optimizer == 'SGD':
        optimizer_function = optim.SGD
        kwargs = {'momentum': args.momentum}
    elif args.optimizer == 'ADAM':
        optimizer_function = optim.Adam
        kwargs = {
            'betas': (args.beta1, args.beta2),
            'eps': args.epsilon
        }
    elif args.optimizer == 'RMSprop':
        optimizer_function = optim.RMSprop
        kwargs = {'eps': args.epsilon}

    kwargs['lr'] = args.lr_re
    kwargs['weight_decay'] = args.weight_decay

    return optimizer_function(trainable, **kwargs)

def make_optimizer_alpha(args, alpha):
    print(alpha.requires_grad)
    trainable = [alpha]

    if args.optimizer == 'SGD':
        optimizer_function = optim.SGD
        kwargs = {'momentum': args.momentum}
    elif args.optimizer == 'ADAM':
        optimizer_function = optim.Adam
        kwargs = {
            'betas': (args.beta1, args.beta2),
            'eps': args.epsilon
        }
    elif args.optimizer == 'RMSprop':
        optimizer_function = optim.RMSprop
        kwargs = {'eps': args.epsilon}

    kwargs['lr'] = args.lr_alpha
    kwargs['weight_decay'] = args.weight_decay

    return optimizer_function(trainable, **kwargs)



    return optimizer_function(trainable, **kwargs)


def make_scheduler(args, my_optimizer):
    scheduler = lrs.MultiStepLR(
        my_optimizer,
        milestones=[2,3],
        gamma=.1,
        last_epoch=-1
    )
    return scheduler

def make_scheduler_re(args, my_optimizer):
    scheduler = lrs.MultiStepLR(
        my_optimizer,
        milestones=[60,70],
        gamma=.01,
        last_epoch=-1
    )

    return scheduler

def make_scheduler_al(args, my_optimizer):
    scheduler = lrs.StepLR(
        my_optimizer,
        step_size=15,
        gamma=.1,
        last_epoch=-1)

    return scheduler



def gradient_no_abs(input, direction):
    smooth_kernel_x = torch.reshape(torch.FloatTensor([[0,0],[-1,1]]),[1,1,2,2]).to(torch.device('cuda'))
    smooth_kernel_y = torch.transpose(smooth_kernel_x, dim0=2,dim1=3)
    if direction == 'x':
        kernel = smooth_kernel_x
    elif direction == 'y':
        kernel = smooth_kernel_y
    gradient_orig = F.conv2d(input=input,weight=kernel, stride=1, padding=1)
    grad_min = torch.min(gradient_orig)
    grad_max = torch.max(gradient_orig)
    grad_norm = torch.div((gradient_orig-grad_min), (grad_max-grad_min+0.0001))
    return grad_norm

def gradient(x, d):
    smooth_kernel_x = torch.reshape(torch.FloatTensor([[0, 0], [-1, 1]]), [1, 1, 2, 2]).to(torch.device('cuda'))
    smooth_kernel_y = torch.transpose(smooth_kernel_x, dim1=2, dim0=3)
    if d=='x':
        kernel = smooth_kernel_x
    if d=='y':
        kernel = smooth_kernel_y
    gradient_orig = torch.abs(F.conv2d(input=x,weight=kernel, stride=1, padding=1))
    grad_min = torch.min(gradient_orig)
    grad_max = torch.max(gradient_orig)
    grad_norm = torch.div((gradient_orig-grad_min), (grad_max-grad_min+0.0001))
    return grad_norm

def grayscale(i):
    R = i[:,0,:,:]
    G = i[:,1,:,:]
    B = i[:,2,:,:]
    Gray = 0.29900 * R + 0.58700 * G + 0.11400 * B
    return Gray.unsqueeze(dim=1)

def calc_ssim(sr, hr):
    ssim = SSIM()(sr,hr)
    return ssim



def validation(sr, hr, device):
    sr.to(device)
    hr.to(device)
    psnr = calc_psnr(sr, hr)
    ssim = calc_ssim(sr,hr)
    b,_,_,_ = sr.shape

    avr_psnr = psnr/b
    avr_ssim = ssim/b
    return avr_psnr, avr_ssim




def save_image(sr, idx):
    sr_images = torch.split(sr, 1, dim=0)
    batch = len(sr_images)

    for i in range(batch):
        utility.save_image(sr_images[idx], './results/{}'.format(idx[i]+'.png'))

def print_log(epoch,num_epochs, one_epoch_time, train_psnr, val_psnr, val_ssim):
    print('({0:.0f}s) Epoch [{1}/{2}], Train_PSNR:{3:.2f}, Val_PSNR:{4:.2f}, Val_SSIM:{5:.4f}'
          .format(one_epoch_time, epoch, num_epochs, train_psnr, val_psnr, val_ssim))

    # --- Write the training log --- #
    with open('/output/finetune_log.txt', 'a') as f:
        print('Date: {0}s, Time_Cost: {1:.0f}, Epoch [{2}/{3}], Train_PSNR:{4:.2f}, Val_PSNR:{5:.2f}, Val_SSIM:{6:.4f}'
              .format(time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()),
                      one_epoch_time, epoch, num_epochs, train_psnr, val_psnr, val_ssim))

def generate_test_images(net, TestData, num_epochs, chosen_epoch,device):
    epoch = 0
    net.eval()
    test_data_dir = '/data/nnice1216/unlabeled1/'
    test_data_loader = dataloader.DataLoader(TestData(test_data_dir), batch_size=1, shuffle=False, num_workers=8)

    with torch.no_grad():
        for epoch in range(num_epochs):

            if epoch not in chosen_epoch:
                continue

            net.load_state_dict(torch.load('/code/dehazeproject/haze_current_temp_{}'.format(epoch)))

            output_dir = '/output/image_epoch{}/'.format(epoch)
            if not os.path.exists(output_dir):
                os.makedirs(output_dir)
            for batch_id, val_data in enumerate(test_data_loader):
                if batch_id > 150:
                    break
                lr, idx = val_data
                print(batch_id, 'BEGIN!')

                B, _, H, W = lr.shape
                lr.to(device)
                sr = net(lr)
                ts = torch.squeeze(sr.clamp(0, 1).cpu())

                utility.save_image(ts, output_dir + idx[0].split('.')[0] + '_MyModel_{}.png'.format(batch_id))
                print(idx[0].split('.')[0] + 'DONE!')


def load_model(model, model_dir, device, gpus):
    net = model
    net.to(device)
    if gpus > 1:
        net = nn.DataParallel(net, range(gpus))
    net.load_state_dict(torch.load(model_dir))
    return net










