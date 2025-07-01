from __future__ import print_function
import argparse
import os
from networks.skip import skip
from networks.fcn import *
import glob
from skimage.io import imsave
import warnings
from tqdm import tqdm
from torch.optim.lr_scheduler import MultiStepLR
from utils.common_utils import *
from utils.SSIM import SSIM
import yaml
from utils.deconv_utils import wienerF_otf, shifter_kernel, shifter_Kinput, guass_gen

parser = argparse.ArgumentParser()
parser.add_argument('--num_iter', type=int, default=5000, help='number of epochs of training')
parser.add_argument('--img_size', type=int, default=[256, 256], help='size of each image dimension')
parser.add_argument('--kernel_size', type=int, default=[21, 21], help='size of blur kernel [height, width]')
parser.add_argument('--data_path', type=str, default="datasets/levin/blur/", help='path to blurry image')
parser.add_argument('--save_path', type=str, default="results/levin/", help='path to save results')
parser.add_argument('--ksize_path', type=str, default="kernel_estimates/levin_kernel.yaml", help='path to save results')
parser.add_argument('--save_frequency', type=int, default=100, help='lfrequency to save results')
parser.add_argument('--loss_switch', type=int, default=1000, help='lfrequency to save results')
parser.add_argument('--dataset_name', type=str, default='levin', help='iteration when framework is activated')
parser.add_argument('--channels', type=int, default=1, help='Number of colour channels')
parser.add_argument('--seed', type=int, default=100, help='seed chosen')
parser.add_argument('--Gsize', type=float, default=10, help='size of the standard gaussian to be subsampled')
parser.add_argument('--wa', type=float, default=1e-3, help='weight for deconv-img and gen-img compparison')
parser.add_argument('--wb', type=float, default=1e-4, help='weight for kernel comparison')
parser.add_argument('--wk', type=float, default=1e-3, help='weight for L2 norm of inner-loop kernel')
opt = parser.parse_args()
#print(opt)

###Set random seeds
torch.manual_seed(opt.seed)
import random
random.seed(opt.seed)
np.random.seed(opt.seed)

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
warnings.filterwarnings("ignore")

files_source = glob.glob(os.path.join(opt.data_path, '*.png'))
files_source.sort()
save_path = opt.save_path
os.makedirs(save_path, exist_ok=True)

# start #image
for f in files_source:
    INPUT = 'noise'
    pad = 'reflection'
    LR = 0.01
    num_iter = opt.num_iter
    reg_noise_std = 0.001

    path_to_image = f
    imgname = os.path.basename(f)
    imgname = os.path.splitext(imgname)[0]

    k_name = imgname
    if opt.dataset_name == 'real':
        opt.kernel_size = [51, 51]
    else:
        stream = open(opt.ksize_path, 'r')
        dict_ksize = yaml.load(stream, Loader=yaml.FullLoader)
        if opt.dataset_name == 'sun':
            k_name = os.path.basename(f).split('_')[1]

        for key in dict_ksize:
            if k_name.find(key) != -1:
                opt.kernel_size = dict_ksize[key]
    print(opt.kernel_size)

    if opt.channels == 1:
        _, imgs = get_image(path_to_image, -1)  # load image and convert to np.
        y = np_to_torch(imgs).to(device)
        img_size = imgs.shape
    if opt.channels == 3:
        img, y, cb, cr = readimg(path_to_image)
        y = np.float32(y / 255.0)
        y = np.expand_dims(y, 0)
        img_size = y.shape
        y = np_to_torch(y).to(device)

    print(imgname)
    #######################################################################
    padw, padh = opt.kernel_size[0]-1, opt.kernel_size[1]-1
    opt.img_size[0], opt.img_size[1] = img_size[1]+padw, img_size[2]+padh

    path_save_f = opt.save_path #+ imgname + '/'

    '''
    x_net:
    '''
    input_depth = 8
    net_input = get_noise(input_depth, INPUT, (opt.img_size[0], opt.img_size[1])).to(device)
    net = skip( input_depth, 1,
                num_channels_down = [128, 128, 128, 128, 128],
                num_channels_up   = [128, 128, 128, 128, 128],
                num_channels_skip = [16, 16, 16, 16, 16],
                upsample_mode='bilinear',
                need_sigmoid=True, need_bias=True, pad=pad, act_fun='LeakyReLU', drop=True)
    net = net.to(device)

    '''
    k_net:
    '''
    n_k = 200
    net_input_kernel = get_noise(n_k, INPUT, (1, 1)).to(device)
    net_input_kernel.squeeze_()

    net_kernel = fcn(n_k, opt.kernel_size[0]*opt.kernel_size[1])
    net_kernel = net_kernel.to(device)

    # Losses
    mse = torch.nn.MSELoss().to(device)
    ssim = SSIM().to(device)

    # Optimizer
    optimizer = torch.optim.Adam([{'params':net.parameters()},{'params':net_kernel.parameters(),'lr':1e-4}], lr=LR)
    scheduler = MultiStepLR(optimizer, milestones=[2000, 3000, 4000], gamma=0.5)  # learning rates

    # Noise input to networks
    net_input_saved = net_input.detach().clone()
    net_input_kernel_saved = net_input_kernel.detach().clone()

    # Initialization for outer-loop
    net_input = net_input_saved + reg_noise_std * torch.zeros(net_input_saved.shape).type_as(
        net_input_saved.data).normal_()
    out_x = net(net_input)
    out_k = net_kernel(net_input_kernel)
    out_k_m = out_k.view(-1, 1, opt.kernel_size[0], opt.kernel_size[1])
    out_y = nn.functional.conv2d(out_x, out_k_m, padding=0, bias=None)

    # Initialization for Inner-Loop Generation
    gauss = guass_gen(k_size=(opt.kernel_size[0], opt.kernel_size[1]), var=3, samp_size=(opt.Gsize, opt.Gsize))
    psf_gauss = torch.from_numpy(gauss)[None, None, :].to(device).type(torch.float32)

    temp_ker = psf_gauss
    temp_ker.requires_grad = True
    param_img = [temp_ker]
    optimizerVar = torch.optim.Adam(param_img, lr=1e-6)
    k_sch = int(padh/10)
    schedulerVar = MultiStepLR(optimizerVar, milestones=[k_sch*70, k_sch*(70 + 50), k_sch*(70 + 2*50)], gamma=10)
    psf_temp = torch.abs(param_img[0]) / torch.sum(torch.abs(param_img[0]))
    img_deconv = wienerF_otf(y, psf_temp, device)

    ### start SelfDeblur
    for step in tqdm(range(num_iter)):

        #DIP-Optimization
        L_mse_G_outk_gen, k_num, mov_ker, tar_ker = shifter_kernel(torch.flip(psf_temp, [3, 2]).detach(), out_k_m, int(padh / 2))
        mov_img, tar_img = shifter_Kinput(img_deconv.detach(),
                                          out_x[:, :, padh // 2:padh // 2 + img_size[1], padw // 2:padw // 2 + img_size[2]],
                                          k_num, maxshift=int(padh / 2))
        L_mse_X_outx_gen = mse(mov_img.detach(), tar_img)
        L_mse_X_outx_gen_SSIM = 1 - ssim(mov_img.detach(), tar_img)

        L_MSE = mse(out_y, y)
        L_SSIM = 1 - ssim(out_y, y)

        if step < opt.loss_switch:
            total_loss = L_MSE + opt.wa * L_mse_X_outx_gen + opt.wb * L_mse_G_outk_gen
        else:
            total_loss = L_SSIM + opt.wa * L_mse_X_outx_gen_SSIM + opt.wb * L_mse_G_outk_gen

        total_loss.backward()
        optimizer.step()
        scheduler.step(step)
        optimizer.zero_grad()

        #Wiener-Deconvolution Optimization
        net_input = net_input_saved + reg_noise_std * torch.zeros(net_input_saved.shape).type_as(net_input_saved.data).normal_()
        out_x = net(net_input)
        out_k = net_kernel(net_input_kernel)
        out_k_m = out_k.view(-1, 1, opt.kernel_size[0], opt.kernel_size[1])
        out_y = nn.functional.conv2d(out_x, out_k_m, padding=0, bias=None)

        L_mse_G_outk_G, k_num, mov_ker, tar_ker = shifter_kernel(torch.flip(psf_temp, [3, 2]), out_k_m.detach(), int(padh / 2))
        mov_img, tar_img = shifter_Kinput(img_deconv,
                                          out_x[:, :, padh // 2:padh // 2 + img_size[1], padw // 2:padw // 2 + img_size[2]].detach(),
                                          k_num, maxshift=int(padh / 2))
        L_mse_X_outx_G = mse(mov_img, tar_img.detach())
        L_mse_X_outx_G_SSIM = 1 - ssim(mov_img, tar_img.detach())
        L_Kreg = torch.sum(psf_temp ** 2)

        if step < opt.loss_switch:
            L_G = opt.wa * L_mse_X_outx_G + opt.wb * L_mse_G_outk_G + opt.wk * L_Kreg
        else:
            L_G = opt.wa * L_mse_X_outx_G_SSIM + opt.wb * L_mse_G_outk_G + opt.wk*L_Kreg

        L_G.backward()
        optimizerVar.step()
        optimizerVar.zero_grad()
        schedulerVar.step(step)

        psf_temp = torch.abs(param_img[0]) / torch.sum(torch.abs(param_img[0]))
        img_deconv = wienerF_otf(y, psf_temp, device)


        if (step+1) % opt.save_frequency == 0:
            if opt.channels == 3:
                save_path = os.path.join(path_save_f, '%s_x_'%imgname + str(step) + '.png')
                out_x_np = torch_to_np(out_x)
                out_x_np = out_x_np.squeeze()
                cropw, croph = padw, padh
                out_x_np = out_x_np[cropw//2:cropw//2+img_size[1], croph//2:croph//2+img_size[2]]
                out_x_np = np.uint8(255 * out_x_np)
                out_x_np = cv2.merge([out_x_np, cr, cb])
                out_x_np = cv2.cvtColor(out_x_np, cv2.COLOR_YCrCb2BGR)
                cv2.imwrite(save_path, out_x_np)

            save_path = os.path.join(path_save_f, '%s_k'%imgname + '.png')
            out_k_np = torch_to_np(out_k_m)
            out_k_np = out_k_np.squeeze()
            out_k_np /= np.max(out_k_np)
            imsave(save_path, out_k_np)

            save_path = os.path.join(path_save_f, '%s_x'%imgname + '.png')
            out_x_np = torch_to_np(out_x)
            out_x_np = out_x_np.squeeze()
            out_x_np = out_x_np[padh//2:padh//2+img_size[1], padw//2:padw//2+img_size[2]]
            imsave(save_path, out_x_np)

            # torch.save(net, os.path.join(path_save_f, "%s_xnet.pth" % imgname))
            # torch.save(net_kernel, os.path.join(path_save_f, "%s_knet.pth" % imgname))

    del out_x
    del out_y
    del out_k_m
    del out_k
    del y
    del psf_temp
    del net_input
    del net_input_kernel
    del net
    del net_kernel
    del param_img
    torch.cuda.empty_cache()
