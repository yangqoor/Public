from __future__ import print_function

import math
import os
import random

os.environ["CUDA_DEVICE_ORDER"] = "PCI_BUS_ID"  # see issue #152
os.environ["CUDA_VISIBLE_DEVICES"] = "0"

import matplotlib.pyplot as plt

import numpy as np
from networks.skip import skip
from networks.fcn import *
import cv2
import torch
import torch.optim
import glob
from skimage.io import imread
from skimage.io import imsave
import warnings
from tqdm import tqdm
from torch.optim.lr_scheduler import MultiStepLR
from utils.common_utils import *
from SSIM import SSIM
import torch.nn.functional as F


class argument():
    def __init__(self):
        self.num_iter = 5000
        self.num_pre = 500
        self.img_size = [256, 256]
        self.kernel_size = [21, 21]

        self.data_path = ""
        self.gt_path = ""
        self.save_path = ""

        # download from http://vllab.ucmerced.edu/wlai24/cvpr16_deblur_study/data/cvpr16_deblur_study_all_deblurred_results.zip
        self.compared_path = "cvpr16_deblur_study_all_deblurred_results/real"

        self.save_frequency = 100
        self.learning_rate_img = 0.01
        self.learning_rate_kernel = 0.0001
        self.reg_noise_std = 0.001
        self.param_noise_sigma = 1
        self.input_depth = 3  # input depth of image generator
        self.output_depth = 6  # output depth of image generator
        self.input_length = 200  # input length of kernel generator
        self.num_sampling = 1
        self.noise_sigma = 0.1
        self.lb = 1e-45


opt = argument()

# print(opt)

torch.backends.cudnn.enabled = True
torch.backends.cudnn.benchmark = True
dtype = torch.cuda.FloatTensor

warnings.filterwarnings("ignore")

files_source = glob.glob(os.path.join(opt.data_path, '*.jpg'))
files_source.sort()
save_path = opt.save_path
os.makedirs(save_path, exist_ok=True)


def add_noise(model, learning_rate):
    parameter_list = [x for x in model.parameters() if len(x.size()) == 4 or len(x.size()) == 2]

    for n in parameter_list:
        noise = torch.randn(n.size()) * opt.param_noise_sigma * learning_rate
        noise = noise.type(dtype)
        n.data = n.data + noise


def weights_init_uniform(m):
    classname = m.__class__.__name__
    # for every Linear layer in a model..
    if classname.find('Linear') != -1 or classname.find('Conv') != -1:
        # apply a uniform distribution to the weights and a bias=0
        torch.nn.init.xavier_uniform(m.weight)
        m.bias.data.fill_(0.01)
    if isinstance(m, nn.BatchNorm2d):
        nn.init.constant_(m.weight, 1)
        nn.init.constant_(m.bias, 0)


def get_negative_kl(out_x, out_k):
    image_E = out_x[:, 0:3, :, :]
    image_STD = out_x[:, 3:6, :, :]

    bias = 1e-6

    kernel = torch.from_numpy(np.array([-1, 1])).type(dtype).cuda()

    vertical_gradient_mean = F.conv2d(image_E, kernel.view(1, 1, 2, 1).repeat(3, 1, 1, 1), groups=3)
    vertical_penalty = torch.square(vertical_gradient_mean) + torch.square(image_STD[:, :, 1:, :]) + torch.square(
        image_STD[:, :, :-1, :])

    horizontal_gradient_mean = F.conv2d(image_E, kernel.view(1, 1, 1, 2).repeat(3, 1, 1, 1), groups=3)
    horizontal_penalty = torch.square(horizontal_gradient_mean) + torch.square(image_STD[:, :, :, 1:]) + torch.square(
        image_STD[:, :, :, :-1])

    epsilon_v = 1 / (vertical_penalty + bias)
    epsilon_h = 1 / (horizontal_penalty + bias)

    epsilon_v = epsilon_v.detach()
    epsilon_h = epsilon_h.detach()

    term_1 = torch.sum(2 * torch.log(torch.clamp_min(image_STD, opt.lb))) / 2
    term_2 = torch.sum(vertical_penalty * epsilon_v) / 4 + torch.sum(horizontal_penalty * epsilon_h) / 4

    # kernel normalization
    term_3 = torch.sum(torch.square(out_k)) / 2

    return term_1 / (out_x.shape[2] * out_x.shape[3] * 3) - term_2 / (
            (out_x.shape[2] - 1) * (out_x.shape[3] - 1) * 3) - term_3 * 10


def get_sampling_expectation(out_x, out_k, initial_img_target, num_sampling, step, loss_function="mse"):
    image_E = out_x[:, 0:3, :, :]
    image_STD = out_x[:, 3:6, :, :]

    # print(torch.max(image_STD))
    # print(torch.min(image_STD))

    input_shape = image_E.shape
    target_shape = initial_img_target.shape

    image_mean = image_E.unsqueeze(1).repeat(1, num_sampling, 1, 1, 1)
    image_std = image_STD.unsqueeze(1).repeat(1, num_sampling, 1, 1, 1)

    if loss_function == "mse":

        image_mean = image_E.unsqueeze(1).repeat(1, num_sampling, 1, 1, 1)
        image_std = image_STD.unsqueeze(1).repeat(1, num_sampling, 1, 1, 1)

        eps_x = torch.randn_like(image_mean)
        sampling_x = (image_mean + image_std * eps_x).view(-1, 3, input_shape[2], input_shape[3])

        sampling_k = out_k.view(-1, 1, opt.kernel_size[0], opt.kernel_size[1]).repeat(3, 1, 1, 1)

        out_y = nn.functional.conv2d(sampling_x, sampling_k, groups=3).view(target_shape[0], -1, 3,
                                                                            target_shape[2],
                                                                            target_shape[3])

        # zero order derivative
        output = out_y.view(-1, 3, target_shape[2], target_shape[3])

        target = initial_img_target[:, 0:3, :, :].unsqueeze(1).repeat(1, num_sampling, 1, 1, 1).view(-1, 3,
                                                                                                     target_shape[2],
                                                                                                     target_shape[3])

        zero_order_expectation = -torch.sum(torch.square(output - target)) / (2 * num_sampling)

        # first order derivative
        kernel = torch.from_numpy(np.array([-1, 1])).type(dtype).cuda()
        v_output = F.conv2d(output, kernel.view(1, 1, 2, 1).repeat(3, 1, 1, 1), groups=3)
        h_output = F.conv2d(output, kernel.view(1, 1, 1, 2).repeat(3, 1, 1, 1), groups=3)

        v_target = F.conv2d(target, kernel.view(1, 1, 2, 1).repeat(3, 1, 1, 1), groups=3)
        h_target = F.conv2d(target, kernel.view(1, 1, 1, 2).repeat(3, 1, 1, 1), groups=3)

        first_order_expectation = -torch.sum(torch.square(v_output - v_target)) / (4 * num_sampling) \
                                  - torch.sum(torch.square(h_output - h_target)) / (4 * num_sampling)

        # second order derivative

        vv_output = F.conv2d(v_output, kernel.view(1, 1, 2, 1).repeat(3, 1, 1, 1), groups=3)
        vh_output = F.conv2d(v_output, kernel.view(1, 1, 1, 2).repeat(3, 1, 1, 1), groups=3)
        hh_output = F.conv2d(h_output, kernel.view(1, 1, 1, 2).repeat(3, 1, 1, 1), groups=3)
        hv_output = F.conv2d(h_output, kernel.view(1, 1, 2, 1).repeat(3, 1, 1, 1), groups=3)

        vv_target = F.conv2d(v_target, kernel.view(1, 1, 2, 1).repeat(3, 1, 1, 1), groups=3)
        vh_target = F.conv2d(v_target, kernel.view(1, 1, 1, 2).repeat(3, 1, 1, 1), groups=3)
        hh_target = F.conv2d(h_target, kernel.view(1, 1, 1, 2).repeat(3, 1, 1, 1), groups=3)
        hv_target = F.conv2d(h_target, kernel.view(1, 1, 2, 1).repeat(3, 1, 1, 1), groups=3)

        second_order_expectation = -torch.sum(torch.square(vv_output - vv_target)) / (8 * num_sampling) \
                                   - torch.sum(torch.square(vh_output - vh_target)) / (8 * num_sampling) \
                                   - torch.sum(torch.square(hh_output - hh_target)) / (8 * num_sampling) \
                                   - torch.sum(torch.square(hv_output - hv_target)) / (8 * num_sampling)

        # loss on gradient instead of on the image
        kernel = torch.from_numpy(np.array([-1, 1])).type(dtype).cuda()

        v_x = F.conv2d(sampling_x, kernel.view(1, 1, 2, 1).repeat(3, 1, 1, 1), groups=3)
        v_target = F.conv2d(target, kernel.view(1, 1, 2, 1).repeat(3, 1, 1, 1), groups=3)
        v_out = nn.functional.conv2d(v_x, sampling_k, groups=3)

        h_x = F.conv2d(sampling_x, kernel.view(1, 1, 1, 2).repeat(3, 1, 1, 1), groups=3)
        h_target = F.conv2d(target, kernel.view(1, 1, 1, 2).repeat(3, 1, 1, 1), groups=3)
        h_out = nn.functional.conv2d(h_x, sampling_k, groups=3)

        gradient_expectation = -torch.sum(torch.square(v_out - v_target)) / (4 * num_sampling) - torch.sum(
            torch.square(h_out - h_target)) / (4 * num_sampling)

        sampling_expectation = zero_order_expectation + first_order_expectation + second_order_expectation + gradient_expectation

        return sampling_expectation / (out_x.shape[2] * out_x.shape[3] * 3)


    else:

        sampling_x = image_mean.view(-1, 3, input_shape[2], input_shape[3])

        sampling_k = out_k.view(-1, 1, opt.kernel_size[0], opt.kernel_size[1]).repeat(3, 1, 1, 1)

        out_y = nn.functional.conv2d(sampling_x, sampling_k, groups=3)

        # zero order derivative
        output = out_y

        target = initial_img_target[:, 0:3, :, :]

        sampling_expectation = -(1 - ssim(output, target))
        return sampling_expectation


def get_target(y):
    # up_padded_y = F.pad(y, (0, 0, 1, 0), mode='replicate')
    # left_padded_y = F.pad(y, (1, 0, 0, 0), mode='replicate')
    #
    # kernel = torch.from_numpy(np.array([-1, 1])).type(dtype).cuda()
    #
    # v_gradient = F.conv2d(up_padded_y, kernel.view(1, 1, 2, 1), bias=None)
    # h_gradient = F.conv2d(left_padded_y, kernel.view(1, 1, 1, 2), bias=None)

    initial_img_E = y
    initial_img_logSTD = torch.zeros_like(initial_img_E)

    initial_img_target = torch.cat([initial_img_E, initial_img_logSTD], 1)

    initial_kernel_E = torch.ones(opt.kernel_size[0] * opt.kernel_size[1]).cuda()
    initial_kernel_E /= initial_kernel_E.shape[0]
    initial_kernel_target = initial_kernel_E

    return initial_img_target, initial_kernel_target


def get_network():
    net = skip(opt.input_depth, opt.output_depth,
               num_channels_down=[128, 128, 128, 128, 128],
               num_channels_up=[128, 128, 128, 128, 128],
               num_channels_skip=[16, 16, 16, 16, 16],
               upsample_mode='bilinear',
               need_sigmoid=True, need_tanh=False, need_bias=True, pad='reflection', act_fun='LeakyReLU')

    net = net.type(dtype)

    net_kernel = fcn_relu6(opt.input_length, opt.kernel_size[0] * opt.kernel_size[1])
    net_kernel = net_kernel.type(dtype)

    # net.apply(weights_init_uniform)
    # net_kernel.apply(weights_init_uniform)

    return net, net_kernel


def get_input():
    net_input_kernel_saved = get_noise(opt.input_length, 'noise', (1, 1)).type(dtype)
    net_input_kernel_saved.squeeze_()

    net_input_saved = get_noise(opt.input_depth, 'noise', (opt.img_size[0], opt.img_size[1])).type(dtype)

    return net_input_kernel_saved, net_input_saved


def clip_gradient(optimizer, grad_clip=1.0):
    """
    Clips gradients computed during backpropagation to avoid explosion of gradients.

    :param optimizer: optimizer with the gradients to be clipped
    :param grad_clip: clip value
    """
    for group in optimizer.param_groups:
        for param in group["params"]:
            if param.grad is not None:
                param.grad.data.clamp_(-grad_clip, grad_clip)


def clip_image_gradient(optimizer, grad_clip=1.0):
    """
    Clips gradients computed during backpropagation to avoid explosion of gradients.

    :param optimizer: optimizer with the gradients to be clipped
    :param grad_clip: clip value
    """
    for param in optimizer.param_groups[0]["params"]:
        if param.grad is not None:
            param.grad.data.clamp_(-grad_clip, grad_clip)


# start #image
for f in files_source:

    '''
    Data initializing
    '''

    torch.random.manual_seed(0)
    np.random.seed(0)
    random.seed(0)

    if not os.path.isdir(os.path.join(opt.save_path, f.split("/")[-1].split(".")[0])):
        os.mkdir(os.path.join(opt.save_path, f.split("/")[-1].split(".")[0]))

    new_save_path = os.path.join(opt.save_path, f.split("/")[-1].split(".")[0])

    path_to_image = f
    imgname = os.path.basename(f)
    imgname = os.path.splitext(imgname)[0]

    path = opt.compared_path

    image_list = glob.glob(os.path.join(path, imgname, '*.png'))

    for image in image_list:
        if "psf" in image:
            im = cv2.imread(os.path.join(path, imgname, image))
            opt.kernel_size = [im.shape[0], im.shape[1]]
            print(opt.kernel_size)
            break

    imgs = get_color_image(path_to_image, -1)  # load image and convert to np.
    # gt = get_color_image(gt_path, -1)

    y = np_to_torch(imgs).type(dtype).cuda()

    initial_img_target, initial_kernel_target = get_target(y)

    padh, padw = opt.kernel_size[0] - 1, opt.kernel_size[1] - 1
    img_size = imgs.shape
    current_noise_sigma = opt.noise_sigma

    opt.img_size[0], opt.img_size[1] = y.shape[2] + padh, y.shape[3] + padw

    # Losses
    mse = torch.nn.MSELoss().type(dtype)
    ssim = SSIM().type(dtype)

    torch.cuda.empty_cache()

    '''
    Load the pretrained model and saved noise maps
    '''

    net, net_kernel = get_network()

    net_input_kernel_saved, net_input_saved = get_input()
    # np.save("net_input_saved.npy", net_input_saved.data.cpu().numpy())
    # np.save("net_input_kernel_saved.npy", net_input_kernel_saved.data.cpu().numpy())

    # net_input_saved = torch.from_numpy(np.load("net_input_saved.npy")).cuda().detach().clone()
    # net_input_kernel_saved = torch.from_numpy(np.load("net_input_kernel_saved.npy")).cuda().detach().clone()

    optimizer = torch.optim.Adam(
        [{'params': net.parameters()}, {'params': net_kernel.parameters(), 'lr': opt.learning_rate_kernel}],
        lr=opt.learning_rate_img)
    scheduler = MultiStepLR(optimizer, milestones=[2000, 3000, 4000], gamma=0.5)  # learning rates

    for step in tqdm(range(opt.num_pre)):
        scheduler.step(step)

        # net_input = net_input_saved + opt.reg_noise_std * torch.zeros(net_input_saved.shape).type_as(
        #     net_input_saved.data).normal_()
        net_input = net_input_saved
        net_input_kernel = net_input_kernel_saved
        ######################################################################################################

        # image optimization

        optimizer.zero_grad()

        out_x = net(net_input)
        out_k = net_kernel(net_input_kernel)

        total_loss = mse(
            out_x[:, :, padh // 2: out_x.shape[2] - padh // 2, padw // 2:  out_x.shape[3] - padw // 2],
            initial_img_target) + mse(out_k, initial_kernel_target)

        print("pre_loss:" + str(total_loss.item()))

        total_loss.backward()
        # clip_image_gradient(optimizer)
        optimizer.step()

    for step in tqdm(range(opt.num_iter)):

        scheduler.step(step)

        # net_input = net_input_saved + opt.reg_noise_std * torch.zeros(net_input_saved.shape).type_as(
        #     net_input_saved.data).normal_()
        net_input = net_input_saved
        net_input_kernel = net_input_kernel_saved
        ######################################################################################################

        # image optimization

        optimizer.zero_grad()

        out_x = net(net_input)
        out_k = net_kernel(net_input_kernel)

        if step < 2000:
            negative_kl = get_negative_kl(out_x, out_k)
            sampling_expectation = get_sampling_expectation(out_x, out_k, initial_img_target, opt.num_sampling, step,
                                                            loss_function="mse")

            elob = negative_kl * current_noise_sigma + sampling_expectation

            # replace the elob with:
            # elob = sampling_expectation
            # for VDIP-Std

            total_loss = -elob

            print("negative_kl: " + str(negative_kl.item()))
            print("sampling_expectation: " + str(sampling_expectation.item()))
            print("elob: " + str(elob.item()))
            print()

        else:
            sampling_expectation = get_sampling_expectation(out_x, out_k, initial_img_target, opt.num_sampling, step,
                                                            loss_function="ssim")

            total_loss = -sampling_expectation

            print("sampling_expectation: " + str(sampling_expectation.item()))

        # nan can get after the output is good enough, it might because the gradient is too small and overflow
        # if (math.isnan(negative_kl.item())):
        #     break

        if (step + 1) % 1000 == 0:
            current_noise_sigma *= 0.1

        # if current_noise_sigma <= 0.0001:
        #    current_noise_sigma = 0.0001

        # current_noise_sigma = opt.noise_sigma - opt.noise_sigma / 1000 * (step + 1)

        total_loss.backward()
        # clip_image_gradient(optimizer)
        optimizer.step()

        if (step + 1) % opt.save_frequency == 0:
            # print('Iteration %05d' %(step+1))

            with torch.no_grad():
                net_input = net_input_saved
                # net_input = net_input_saved + opt.reg_noise_std * torch.zeros(net_input_saved.shape).type_as(
                #     net_input_saved.data).normal_()
                net_input_kernel = net_input_kernel_saved

                out_x = net(net_input)
                out_k = net_kernel(net_input_kernel)[:opt.kernel_size[0] * opt.kernel_size[1]]

                sampling_k = out_k.view(-1, 1, opt.kernel_size[0], opt.kernel_size[1])

                out_k_m = out_k.view(-1, 1, opt.kernel_size[0], opt.kernel_size[1])

                out_y = nn.functional.conv2d(out_x[:, 0:3, :, :], out_k_m.repeat(3, 1, 1, 1), groups=3)

                # save kernel
                save_path = os.path.join(new_save_path, '%d_k.png' % (step + 1))
                out_k_np = torch_to_np(out_k_m).transpose(1, 2, 0)
                out_k_np = out_k_np.squeeze()
                out_k_np /= np.max(out_k_np)
                imsave(save_path, out_k_np)

                # save sharp gradient map
                out_x_np = torch_to_np(out_x).transpose(1, 2, 0)

                save_path = os.path.join(new_save_path, '%d_x.png' % (step + 1))
                # imsave(save_path, out_x_np[..., 0:3])
                imsave(save_path,
                       out_x_np[padh // 2: out_x.shape[2] - padh // 2, padw // 2:  out_x.shape[3] - padw // 2, 0:3])
