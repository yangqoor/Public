import numpy as np
import imageio
from scipy import interpolate
import torch
import sys
sys.path.append('../')
from utils.SSIM import SSIM
from utils.common_utils import readimg
from skimage import filters


def calculate_psnr(img1, img2, max_value):
    """"Calculating peak signal-to-noise ratio (PSNR) between two images."""
    mse = np.mean((np.array(img1, dtype=np.float32) - np.array(img2, dtype=np.float32)) ** 2)
    if mse == 0:
        return 100
    #return 20 * np.log10(max_value / (np.sqrt(mse)))
    return 20 * np.log10(max_value / (np.sqrt(mse)))


def custom_otsu_seg(img, excl=40):
    if torch.is_tensor(img):
        img = img.detach().cpu().numpy()
    img_temp = img.copy().flatten()
    thr = np.percentile(img_temp, excl)

    ind = np.argwhere(img_temp < thr)
    img_temp_new = np.delete(img_temp, ind)

    val = filters.threshold_otsu(img_temp_new)
    binary = img > val

    return binary


def shifter_bi_seg(I1, I2, maxshift=10, limit=25, dice=False):
    shifts = np.arange(-maxshift, maxshift+0.25, 0.25)

    I2 = I2[limit:I2.shape[0] - limit, limit:I2.shape[1] - limit]
    I1 = I1[limit - maxshift:I1.shape[0]-limit +maxshift, limit - maxshift:I1.shape[1]-limit + maxshift]
    I2_x, I2_y = I2.shape

    gx, gy = np.arange(-maxshift, I2_x + maxshift, 1), np.arange(-maxshift, I2_y + maxshift, 1)
    gx0, gy0 = np.arange(0, I2_x, 1), np.arange(0, I2_y, 1)

    f = interpolate.RectBivariateSpline(gx, gy, I1)
    mse_ar = np.zeros((len(shifts), len(shifts)))

    for i in range(0, len(shifts)):
        for j in range(0, len(shifts)):
            gxn = gx0 + shifts[i]
            gyn = gy0 + shifts[j]

            Inew = f(gxn, gyn)
            mse_ar[i, j] = np.mean(np.sqrt((Inew - I2)**2))

    mse_min = np.min(mse_ar)
    index = np.where(mse_ar == mse_min)

    I1_shift = f(gx0 + shifts[index[0]], gy0 + shifts[index[1]])
    psnrs = calculate_psnr(I1_shift, I2, 1.0)

    #Convert to torch
    I1_shift_th = torch.from_numpy(I1_shift)[None, None, :]
    I2_th = torch.from_numpy(I2)[None, None, :]
    ssim = SSIM()
    ssims = ssim(I1_shift_th, I2_th)

    if dice == True:
        I1_shift_seg = custom_otsu_seg(I1_shift)
        I2_seg = custom_otsu_seg(I2)
        dice = np.sum(I1_shift_seg[I2_seg==1])*2.0 / (np.sum(I1_shift_seg) + np.sum(I2_seg))
        return psnrs, ssims.numpy(), dice, I1_shift_seg, I2_seg
    else:
        return psnrs, ssims.numpy(), I1_shift, I2


def eval_func_seg(path_img, path_gt, window=10):
    img = imageio.imread(path_img)
    gt = imageio.imread(path_gt)

    if len(gt.shape) == 3:
        img_ychcr_gt, gt, cb_gt, cr_gt = readimg(path_gt)

    if len(img.shape) == 3:
        img_ychcr_img, img, cb_img, cr_img = readimg(path_img)

    #img_db = (cropper(img, kernel_size)/ 255.).astype(np.double)
    img_db = (img/255.).astype(np.double)
    gt_db = (gt / 255.).astype(np.double)

    psnr, ssim, dice, pred_seg, gt_seg = shifter_bi_seg(img_db, gt_db, window, dice=True)

    return psnr, ssim, dice, pred_seg, gt_seg


def comp_upto_shift(I1, I2, maxshift=10, limit=15):
    shifts = np.arange(-maxshift, maxshift+0.25, 0.25)
    #print("These are the shifts: ", shifts)

    I2 = I2[limit:I2.shape[0] - limit, limit:I2.shape[1] - limit]
    I1 = I1[limit - maxshift:I1.shape[0]-limit +maxshift, limit - maxshift:I1.shape[1]-limit + maxshift]
    I2_x, I2_y = I2.shape

    gx, gy = np.arange(-maxshift, I2_x + maxshift, 1), np.arange(-maxshift, I2_y + maxshift, 1)
    gx0, gy0 = np.arange(0, I2_x, 1), np.arange(0, I2_y, 1)

    f = interpolate.RectBivariateSpline(gx, gy, I1)
    mse_ar = np.zeros((len(shifts), len(shifts)))

    for i in range(0, len(shifts)):
        for j in range(0, len(shifts)):
            gxn = gx0 + shifts[i]
            gyn = gy0 + shifts[j]

            Inew = f(gxn, gyn)
            mse_ar[i, j] = np.mean(np.sqrt((Inew - I2)**2))

    mse_min = np.min(mse_ar)
    index = np.where(mse_ar == mse_min)

    I1_shift = f(gx0 + shifts[index[0]], gy0 + shifts[index[1]])

    return I1_shift, I2


def eval_func_err(path_img, path_gt, path_deblur, window=10):
    img = imageio.imread(path_img)
    gt = imageio.imread(path_gt)
    gt_deblur = imageio.imread(path_deblur)

    img_db = (img / 255.).astype(np.double)
    gt_db = (gt / 255.).astype(np.double)
    gt_deblur_db = (gt_deblur / 255.).astype(np.double)

    psnr, ssim, I_shift, I_gt = shifter_bi_seg(img_db, gt_db, window)
    I_gt_shift, I_gt2 = comp_upto_shift(gt_deblur_db, gt_db, window)

    err = np.linalg.norm((I_shift - I_gt), 2) / np.linalg.norm((I_gt_shift - I_gt2), 2)

    return psnr, ssim, err


def eval_func(path_img, path_gt, window=10):
    img = imageio.imread(path_img)
    gt = imageio.imread(path_gt)

    img_db = (img / 255.).astype(np.double)
    gt_db = (gt / 255.).astype(np.double)

    psnr, ssim, I_shift, I_gt = shifter_bi_seg(img_db, gt_db, window)

    return psnr, ssim


def eval_func_sun(path_img, path_gt, window=10):
    img = imageio.imread(path_img)
    gt = imageio.imread(path_gt)

    if len(gt.shape) == 3:
        img_ychcr_gt, gt, cb_gt, cr_gt = readimg(path_gt)

    if len(img.shape) == 3:
        img_ychcr_img, img, cb_img, cr_img = readimg(path_img)

    if gt.shape != img.shape:
        crop_x = int((gt.shape[0] - img.shape[0])/2)
        crop_y = int((gt.shape[1] - img.shape[1])/2)
        gt = gt[crop_x:(img.shape[0] + crop_x), crop_y:(img.shape[1] + crop_y)]

    #img_db = (cropper(img, kernel_size)/ 255.).astype(np.double)
    img_db = (img/255.).astype(np.double)
    gt_db = (gt / 255.).astype(np.double)

    psnr, ssim, I_shift, I_gt = shifter_bi_seg(img_db, gt_db, window)

    return psnr, ssim

