from scipy import signal
import numpy as np
import math
import torch
import torch.nn.functional as F

dtype = torch.cuda.FloatTensor
from skimage.io import imread


def img_to_torch(fname):
    img_np = imread(fname)
    if img_np.ndim == 3:
        img_np = img_np.transpose(2, 0, 1)
    else:
        img_np = img_np[None, ...]
    img_np = img_np.astype(np.float32) / 225.
    return torch.from_numpy(img_np[None, ...])


def pil_to_np(img_PIL):
    '''Converts image in PIL format to np.array.

    From W x H x C [0...255] to C x W x H [0..1]
    '''
    #    ar = np.array(img_PIL)

    if len(ar.shape) == 3:
        ar = ar.transpose(2, 0, 1)
    else:
        ar = ar[None, ...]

    return ar.astype(np.float32) / 255.


def torch_to_img(img_np):
    '''Converts image in np.array format to PIL image.

    From C x W x H [0..1] to  W x H x C [0...255]
    '''
    img_np = img_np.numpy()[0]
    ar = np.clip(img_np * 255, 0, 255).astype(np.uint8)

    if img_np.shape[0] == 1:
        ar = ar[0]
    else:
        ar = ar.transpose(1, 2, 0)

    return ar


def np_to_torch(img_np):
    '''Converts image in numpy.array to torch.Tensor.

    From C x W x H [0..1] to  C x W x H [0..1]
    '''
    return torch.from_numpy(img_np)[None, :]


def nextpow2(number):
    return math.ceil(math.log(number, 2))


def padimg(img, padsize, mode='pad'):
    """
    pad the imag with required size

    """
    assert len(padsize) == 4, "four size need to pad"
    t_pad, b_pad, l_pad, r_pad = tuple(padsize)
    if mode == 'pad':
        if img.ndim == 4 and img.shape[1] == 3:
            img_padded = torch.stack([F.pad(img[:, 0, ...], (l_pad, r_pad, t_pad, b_pad), 'constant'),
                                      F.pad(img[:, 1, ...], (l_pad, r_pad, t_pad, b_pad), 'constant'),
                                      F.pad(img[:, 2, ...], (l_pad, r_pad, t_pad, b_pad), 'constant')], axis=1)
        else:
            img_padded = F.pad(img, (l_pad, r_pad, t_pad, b_pad), 'constant')
    else:
        img_padded = img[..., t_pad:-1 - b_pad + 1, l_pad:-1 - r_pad + 1]
    return img_padded


def conv2d_same_padding(input, weight, bias=None, stride=[1, 1], padding=1, dilation=[1, 1], groups=1):
    # 函数中padding参数可以无视，实际实现的是padding=same的效果
    input_rows = input.shape[2]
    filter_rows = weight.shape[2]
    input_cols = input.shape[3]
    filter_cols = weight.shape[3]
    effective_filter_size_rows = (filter_rows - 1) * dilation[0] + 1
    out_rows = (input_rows + stride[0] - 1) // stride[0]
    out_cols = (input_cols + stride[1] - 1) // stride[1]
    padding_rows = max(0, (out_rows - 1) * stride[0] +
                       (filter_rows - 1) * dilation[0] + 1 - input_rows)
    rows_odd = (padding_rows % 2 != 0)
    padding_cols = max(0, (out_cols - 1) * stride[1] +
                       (filter_cols - 1) * dilation[1] + 1 - input_cols)
    cols_odd = (padding_cols % 2 != 0)

    if rows_odd or cols_odd:
        input = F.pad(input, [0, int(cols_odd), 0, int(rows_odd)])

    return F.conv2d(input, weight, bias, stride,
                    padding=(padding_rows // 2, padding_cols // 2),
                    dilation=dilation, groups=groups)


def ind2sub(array_shape, ind):
    #    ind[ind < 0] = -1
    #    ind[ind >= array_shape[0]*array_shape[1]] = -1
    rows = (int(ind) // array_shape[1])
    cols = ind % array_shape[1]
    return (rows, cols)


# class EFF():
#     """
#     EFF Class implements the Efficient Filter Flow approximation for non-uniform blurring
#     The main idea is to devide the image by overlapping patches
#     """
#
#     def __init__(self, img_size, blur_size=[31, 31], grid_size=[6, 8]):
#         self.img_size = img_size
#         self.blur_size = blur_size
#         self.grid_size = grid_size
#         self.patch_size = None
#         self.patch_inner_size = None
#         self.padded_size = None
#         self.W = None
#         self.Wsum = None
#         self.pad = None  # note that the top, bottom, left and right/ left,right,top,bottom
#         self.t_patch = None
#         self.b_patch = None
#         self.l_patch = None
#         self.r_patch = None
#         self.x_patch_centers = None
#         self.y_patch_centers = None
#
#     def makeEFF(self):
#         """
#         Do the forward computation of the related quality
#
#         """
#         h_psf = 1 + self.blur_size[0]
#         w_psf = 1 + self.blur_size[1]
#
#         h_sharp = self.img_size[0]
#         w_sharp = self.img_size[1]
#
#         # set up grid of patches
#         if (h_sharp - w_sharp) * (self.grid_size[0] - self.grid_size[1]) < 0:
#             self.grid_size = self.grid_size[::-1]
#
#         h_grid = self.grid_size[0]
#         w_grid = self.grid_size[1]
#
#         if h_grid > 1:
#             h_patch_inner = math.ceil(h_sharp / (h_grid - 1))
#             # make it even
#             # h_patch_inner = int(h_patch_inner - math.remainder(h_patch_inner,2))
#             h_patch_inner = int(h_patch_inner - int(h_patch_inner) % 2)
#         else:
#             h_patch_inner = h_sharp
#
#         if w_grid > 1:
#             w_patch_inner = math.ceil(w_sharp / (w_grid - 1))
#             # make it even
#             # w_patch_inner = int(w_patch_inner - math.remainder(w_patch_inner,2))
#             w_patch_inner = int(w_patch_inner - int(w_patch_inner) % 2)
#         else:
#             w_patch_inner = w_sharp
#
#         self.patch_inner_size = [h_patch_inner, w_patch_inner]
#
#         # next we do the sufficent zero-padding of the image
#         pow_h_patch = nextpow2(h_patch_inner + h_psf)
#         pow_w_patch = nextpow2(w_patch_inner + w_psf)
#
#         w_patch = 2 ** pow_w_patch
#         h_patch = 2 ** pow_h_patch
#
#         self.patch_size = [h_patch, w_patch]
#
#         # find pixels at the center of each patches
#         y_patch_centers = np.arange(h_grid) * h_patch_inner + h_patch
#         x_patch_centers = np.arange(w_grid) * w_patch_inner + w_patch
#
#         self.y_patch_centers = y_patch_centers
#         self.x_patch_centers = x_patch_centers
#
#         # determine the padded size
#         h_padded = y_patch_centers[-1] + h_patch
#         w_padded = x_patch_centers[-1] + w_patch
#
#         self.padded_size = [h_padded, w_padded]
#
#         pad_zero_t = int(math.floor((h_padded - h_sharp) / 2))
#         pad_zero_b = int(math.ceil((h_padded - h_sharp) / 2))
#         pad_zero_l = int(math.floor((w_padded - w_sharp) / 2))
#         pad_zero_r = int(math.ceil((w_padded - w_sharp) / 2))
#
#         self.pad = [pad_zero_t, pad_zero_b, pad_zero_l, pad_zero_r]
#
#         # compute the mask begin and end point indices
#         l_patch = []
#         r_patch = []
#         t_patch = []
#         b_patch = []
#         for gx in range(w_grid):
#             l_patch.append(x_patch_centers[gx] - w_patch)
#             r_patch.append(x_patch_centers[gx] + w_patch)
#         for gy in range(h_grid):
#             t_patch.append(y_patch_centers[gy] - h_patch)
#             b_patch.append(y_patch_centers[gy] + h_patch)
#
#         self.l_patch = l_patch
#         self.r_patch = r_patch
#         self.t_patch = t_patch
#         self.b_patch = b_patch
#
#         # compute the windowing function
#         b_r = signal.barthann(2 * h_patch_inner + 1)
#         b_r.shape = (-1, 1)
#         b_c = signal.barthann(2 * w_patch_inner + 1)
#         b_c.shape = (-1, 1)
#         b_c = b_c.transpose()
#         W = b_r * b_c
#         W = W[:-1, :-1]
#         W = torch.from_numpy(W)
#         W = padimg(W,
#                    [h_patch - h_patch_inner, h_patch - h_patch_inner, w_patch - w_patch_inner, w_patch - w_patch_inner])
#
#         # compute the sum of the window function
#         Wsum = torch.zeros((h_padded, w_padded))
#
#         for gx in range(w_grid):
#             for gy in range(h_grid):
#                 # print((gy,gx))
#                 # print(Wsum[t_patch[gy]:b_patch[gy],l_patch[gx]:r_patch[gx]].shape)
#                 Wsum[t_patch[gy]:b_patch[gy], l_patch[gx]:r_patch[gx]] = Wsum[t_patch[gy]:b_patch[gy],
#                                                                          l_patch[gx]:r_patch[gx]] + W
#
#         self.W = W[None, None, ...]
#         self.Wsum = Wsum[None, None, ...]
#
#     def extractImageStack(self, img, img_stack, which_patch, mode='sharp'):
#         """
#         extract the padded img with the patch index
#         """
#         assert img.shape[2:] == tuple(self.padded_size), "the size does not match"
#         t_patch = self.t_patch
#         b_patch = self.b_patch
#         l_patch = self.l_patch
#         r_patch = self.r_patch
#         h_patch = self.patch_size[0]
#         w_patch = self.patch_size[1]
#
#         try:
#             n_grid = len(which_patch)
#         except:
#             n_grid = 1
#             which_patch = [which_patch]
#         assert np.max(np.array(which_patch)) < self.grid_size[0] * self.grid_size[1], "out of the number of patches"
#         channels = img.shape[1]  # if img.ndim == 4 else 1
#
#         weights = self.W  # np.squeeze(np.ones((2*h_patch,2*w_patch,channels))) #self.W
#         #        if channels > 1:
#         #            weights = weights.repeat(-1,)
#
#         if channels > 1:
#             weights = weights.repeat(1, channels, 1, 1)
#         for i in range(n_grid):
#             gy, gx = ind2sub(self.grid_size, which_patch[i])
#             img_stack_s = img[..., t_patch[gy]:b_patch[gy], l_patch[gx]:r_patch[gx]]
#             if mode != 'blurry':
#                 img_stack[i, ...] = (img_stack_s * weights)[0, ...]
#             else:
#                 img_stack[i, ...] = img_stack_s[0, ...]
#         # return img_stack
#
#     def combineStackImage(self, img, img_stack, which_patch):
#         """
#         Combine the Stack Imgae
#         """
#         assert img.shape[2:] == tuple(self.padded_size), "the size does not match"
#         assert img_stack.shape[2:] == tuple([2 * x for x in self.patch_size]), "the size does not match"
#
#         #        assert which_patch < self.grid_size[0]*self.grid_size[1], "out of the number of patches"
#         t_patch = self.t_patch
#         b_patch = self.b_patch
#         l_patch = self.l_patch
#         r_patch = self.r_patch
#         try:
#             n_grid = len(which_patch)
#         except:
#             n_grid = 1
#             which_patch = [which_patch]
#         assert np.max(np.array(which_patch)) < self.grid_size[0] * self.grid_size[1], "out of the number of patches"
#         assert img_stack.shape[0] == len(which_patch), "the length is not matched"
#         for i in range(n_grid):
#             gy, gx = ind2sub(self.grid_size, which_patch[i])
#             img[0, :, t_patch[gy]:b_patch[gy], l_patch[gx]:r_patch[gx]] = img[0, :, t_patch[gy]:b_patch[gy],
#                                                                           l_patch[gx]:r_patch[gx]] + img_stack[i, ...]
#
#     def cuda(self):
#         self.W = self.W.cuda().type(dtype)
#         self.Wsum = self.Wsum.cuda().type(dtype)
#
#     def cpu(self):
#         self.W = self.W.cpu()
#         self.Wsum = self.Wsum.cpu()
class EFF():
    """
    EFF Class implements the Efficient Filter Flow approximation for non-uniform blurring
    The main idea is to devide the image by overlapping patches
    """

    def __init__(self, img_size, blur_size=[31, 31], grid_size=[6, 8]):
        self.img_size = img_size
        self.blur_size = blur_size
        self.grid_size = grid_size
        self.patch_size = None
        self.patch_inner_size = None
        self.padded_size = None
        self.W = None
        self.Wsum = None
        self.pad = None  # note that the top, bottom, left and right/ left,right,top,bottom
        self.t_patch = None
        self.b_patch = None
        self.l_patch = None
        self.r_patch = None
        self.x_patch_centers = None
        self.y_patch_centers = None

    def makeEFF(self):
        """
        Do the forward computation of the related quality

        """
        h_psf = self.blur_size[0] #0 #int((self.blur_size[0] - 1) / 2.) #0 #self.blur_size[0] #int((self.blur_size[0] - 1) / 2.)
        w_psf = self.blur_size[1] #0 #int((self.blur_size[1] - 1) / 2.) #0 #self.blur_size[1] #int((self.blur_size[1] - 1) / 2.)

        # h_psf = int((self.blur_size[0] - 1))
        # w_psf = int((self.blur_size[1] - 1))

        h_sharp = self.img_size[0]
        w_sharp = self.img_size[1]

        # set up grid of patches
        if (h_sharp - w_sharp) * (self.grid_size[0] - self.grid_size[1]) < 0:
            self.grid_size = self.grid_size[::-1]

        h_grid = self.grid_size[0]
        w_grid = self.grid_size[1]

        if h_grid > 1:
            h_patch_inner = math.ceil(h_sharp / (h_grid-1))
            # make it even
            # h_patch_inner = int(h_patch_inner - math.remainder(h_patch_inner,2))
            h_patch_inner = int(h_patch_inner - int(h_patch_inner) % 2)
        else:
            h_patch_inner = h_sharp

        if w_grid > 1:
            w_patch_inner = math.ceil(w_sharp / (w_grid-1))
            # make it even
            # w_patch_inner = int(w_patch_inner - math.remainder(w_patch_inner,2))
            w_patch_inner = int(w_patch_inner - int(w_patch_inner) % 2)
        else:
            w_patch_inner = w_sharp

        self.patch_inner_size = [h_patch_inner, w_patch_inner]

        # next we do the sufficent zero-padding of the image
        #         pow_h_patch = nextpow2(h_patch_inner + h_psf)
        #         pow_w_patch = nextpow2(w_patch_inner + w_psf)

        #         w_patch = 2 ** pow_w_patch
        #         h_patch = 2 ** pow_h_patch

        w_patch = w_patch_inner + w_psf # error
        h_patch = h_patch_inner + h_psf

        self.patch_size = [h_patch, w_patch]

        # h_psf_2 = int((self.blur_size[0] - 1))
        # w_psf_2 = int((self.blur_size[1] - 1))
        # find pixels at the center of each patches
        y_patch_centers = np.arange(h_grid) * h_patch_inner + h_patch
        x_patch_centers = np.arange(w_grid) * w_patch_inner + w_patch

        self.y_patch_centers = y_patch_centers
        self.x_patch_centers = x_patch_centers

        # determine the padded size
        h_padded = y_patch_centers[-1] + h_patch
        w_padded = x_patch_centers[-1] + w_patch

        self.padded_size = [h_padded, w_padded]

        pad_zero_t = int(math.floor((h_padded - h_sharp) / 2))
        pad_zero_b = int(math.ceil((h_padded - h_sharp) / 2))
        pad_zero_l = int(math.floor((w_padded - w_sharp) / 2))
        pad_zero_r = int(math.ceil((w_padded - w_sharp) / 2))

        self.pad = [pad_zero_t, pad_zero_b, pad_zero_l, pad_zero_r]

        # compute the mask begin and end point indices
        l_patch = []
        r_patch = []
        t_patch = []
        b_patch = []
        for gx in range(w_grid):
            l_patch.append(x_patch_centers[gx] - w_patch)
            r_patch.append(x_patch_centers[gx] + w_patch)
        for gy in range(h_grid):
            t_patch.append(y_patch_centers[gy] - h_patch)
            b_patch.append(y_patch_centers[gy] + h_patch)

        self.l_patch = l_patch
        self.r_patch = r_patch
        self.t_patch = t_patch
        self.b_patch = b_patch

        # compute the windowing function
        b_r = signal.barthann(2 * h_patch_inner + 1)
        b_r.shape = (-1, 1)
        b_c = signal.barthann(2 * w_patch_inner + 1)
        b_c.shape = (-1, 1)
        b_c = b_c.transpose()
        W = b_r * b_c
        W = W[:-1, :-1]
        W = torch.from_numpy(W)
        W = padimg(W,
                   [h_patch - h_patch_inner, h_patch - h_patch_inner, w_patch - w_patch_inner,
                    w_patch - w_patch_inner])

        # compute the sum of the window function
        Wsum = torch.zeros((h_padded, w_padded))

        for gx in range(w_grid):
            for gy in range(h_grid):
                # print((gy,gx))
                # print(Wsum[t_patch[gy]:b_patch[gy],l_patch[gx]:r_patch[gx]].shape)
                Wsum[t_patch[gy]:b_patch[gy], l_patch[gx]:r_patch[gx]] = Wsum[t_patch[gy]:b_patch[gy],
                                                                         l_patch[gx]:r_patch[gx]] + W

        self.W = W[None, None, ...]
        self.Wsum = Wsum[None, None, ...]

    def extractImageStack(self, img, img_stack, which_patch, mode='sharp'):
        """
        extract the padded img with the patch index
        """
        assert img.shape[2:] == tuple(self.padded_size), "the size does not match"
        t_patch = self.t_patch
        b_patch = self.b_patch
        l_patch = self.l_patch
        r_patch = self.r_patch
        h_patch = self.patch_size[0]
        w_patch = self.patch_size[1]

        try:
            n_grid = len(which_patch)
        except:
            n_grid = 1
            which_patch = [which_patch]
        assert np.max(np.array(which_patch)) < self.grid_size[0] * self.grid_size[1], "out of the number of patches"
        channels = img.shape[1]  # if img.ndim == 4 else 1

        weights = self.W  # np.squeeze(np.ones((2*h_patch,2*w_patch,channels))) #self.W
        #        if channels > 1:
        #            weights = weights.repeat(-1,)

        if channels > 1:
            weights = weights.repeat(1, channels, 1, 1)
        # for i in range(n_grid):
        #     gy, gx = ind2sub(self.grid_size, which_patch[i])
        #     img_stack_s = img[..., t_patch[gy]:b_patch[gy], l_patch[gx]:r_patch[gx]]
        #     if mode != 'blurry':
        #         img_stack[i, ...] = (img_stack_s * weights)[0, ...]
        #     else:
        #         img_stack[i, ...] = img_stack_s[0, ...]
        # return img_stack
        for i in range(n_grid):
            gy, gx = ind2sub(self.grid_size, which_patch[i])
            img_stack_s = img[..., t_patch[gy]:b_patch[gy], l_patch[gx]:r_patch[gx]]
            if mode != 'blurry':
                img_stack[i, ...] = (img_stack_s * weights)[0, ...]
            else:
                img_stack[i, ...] = img_stack_s[0, ...]

    def combineStackImage(self, img, img_stack, which_patch):
        """
        Combine the Stack Imgae
        """
        assert img.shape[2:] == tuple(self.padded_size), "the size does not match"
        assert img_stack.shape[2:] == tuple([2 * x for x in self.patch_size]), "the size does not match"

        #        assert which_patch < self.grid_size[0]*self.grid_size[1], "out of the number of patches"
        t_patch = self.t_patch
        b_patch = self.b_patch
        l_patch = self.l_patch
        r_patch = self.r_patch
        try:
            n_grid = len(which_patch)
        except:
            n_grid = 1
            which_patch = [which_patch]
        assert np.max(np.array(which_patch)) < self.grid_size[0] * self.grid_size[1], "out of the number of patches"
        assert img_stack.shape[0] == len(which_patch), "the length is not matched"
        for i in range(n_grid):
            gy, gx = ind2sub(self.grid_size, which_patch[i])
            img[0, :, t_patch[gy]:b_patch[gy], l_patch[gx]:r_patch[gx]] = img[0, :, t_patch[gy]:b_patch[gy],
                                                                          l_patch[gx]:r_patch[gx]] + img_stack[
                                                                              i, ...]
        # for i in which_patch:
        #     gy, gx = ind2sub(self.grid_size, which_patch)
        #     img[0, :, t_patch[gy]:b_patch[gy], l_patch[gx]:r_patch[gx]] = img[0, :, t_patch[gy]:b_patch[gy],
        #                                                                   l_patch[gx]:r_patch[gx]] + img_stack[
        #                                                                       i, ...]

    # def extractImageStack(self, img, img_stack, which_patch, mode='sharp'):
    #     """
    #     extract the padded img with the patch index
    #     """
    #     assert img.shape[2:] == tuple(self.padded_size), "the size does not match"
    #     t_patch = self.t_patch
    #     b_patch = self.b_patch
    #     l_patch = self.l_patch
    #     r_patch = self.r_patch
    #     h_patch = self.patch_size[0]
    #     w_patch = self.patch_size[1]
    #
    #     try:
    #         n_grid = len(which_patch)
    #     except:
    #         n_grid = 1
    #         which_patch = [which_patch]
    #     assert np.max(np.array(which_patch)) < self.grid_size[0] * self.grid_size[1], "out of the number of patches"
    #     # channels = img.shape[1]  # if img.ndim == 4 else 1
    #     #
    #     # weights = self.W  # np.squeeze(np.ones((2*h_patch,2*w_patch,channels))) #self.W
    #     # #        if channels > 1:
    #     # #            weights = weights.repeat(-1,)
    #     #
    #     # if channels > 1:
    #     #     weights = weights.repeat(1, channels, 1, 1)
    #
    #     # for i in range(n_grid):
    #     #     gy, gx = ind2sub(self.grid_size, which_patch[i])
    #     #     img_stack_s = img[..., t_patch[gy]:b_patch[gy], l_patch[gx]:r_patch[gx]]
    #     #     if mode != 'blurry':
    #     #         img_stack[i, ...] = (img_stack_s * weights)[0, ...]
    #     #     else:
    #     #         img_stack[i, ...] = img_stack_s[0, ...]
    #     # return img_stack
    #     for i in range(n_grid):
    #         gy, gx = ind2sub(self.grid_size, which_patch[i])
    #         img_stack_s = img[..., t_patch[gy]:b_patch[gy], l_patch[gx]:r_patch[gx]]
    #         if mode != 'blurry':
    #             img_stack[i, ...] = img_stack_s[0, ...]
    #         else:
    #             img_stack[i, ...] = img_stack_s[0, ...]
    #
    # def combineStackImage(self, img, img_stack, which_patch):
    #     """
    #     Combine the Stack Imgae
    #     """
    #     assert img.shape[2:] == tuple(self.padded_size), "the size does not match"
    #     assert img_stack.shape[2:] == tuple([2 * x for x in self.patch_size]), "the size does not match"
    #
    #     #        assert which_patch < self.grid_size[0]*self.grid_size[1], "out of the number of patches"
    #     t_patch = self.t_patch
    #     b_patch = self.b_patch
    #     l_patch = self.l_patch
    #     r_patch = self.r_patch
    #     try:
    #         n_grid = len(which_patch)
    #     except:
    #         n_grid = 1
    #         which_patch = [which_patch]
    #     assert np.max(np.array(which_patch)) < self.grid_size[0] * self.grid_size[1], "out of the number of patches"
    #     assert img_stack.shape[0] == len(which_patch), "the length is not matched"
    #     channels = img.shape[1]  # if img.ndim == 4 else 1
    #
    #     weights = self.W  # np.squeeze(np.ones((2*h_patch,2*w_patch,channels))) #self.W
    #     #        if channels > 1:
    #     #            weights = weights.repeat(-1,)
    #
    #     if channels > 1:
    #         weights = weights.repeat(1, channels, 1, 1)
    #
    #     for i in range(n_grid):
    #         gy, gx = ind2sub(self.grid_size, which_patch[i])
    #         img[0, :, t_patch[gy]:b_patch[gy], l_patch[gx]:r_patch[gx]] = img[0, :, t_patch[gy]:b_patch[gy],
    #                                                                       l_patch[gx]:r_patch[gx]] + img_stack[
    #                                                                           i, ...]* weights[0,...]
    #     # for i in which_patch:
    #     #     gy, gx = ind2sub(self.grid_size, which_patch)
    #     #     img[0, :, t_patch[gy]:b_patch[gy], l_patch[gx]:r_patch[gx]] = img[0, :, t_patch[gy]:b_patch[gy],
    #     #                                                                   l_patch[gx]:r_patch[gx]] + img_stack[
    #     #                                                                       i, ...]

    def cuda(self):
        self.W = self.W.cuda().type(dtype)
        self.Wsum = self.Wsum.cuda().type(dtype)

    def cpu(self):
        self.W = self.W.cpu()
        self.Wsum = self.Wsum.cpu()
    def forward(self,img,kernel):
        n_grid = self.grid_size[0] * self.grid_size[1]
        channels = img.shape[1]  # 3 for color image
        img_stack = torch.zeros((n_grid, channels, 2 * self.patch_size[0], 2 * self.patch_size[1]),device=img.device)
        self.extractImageStack(img, img_stack, range(n_grid), 'sharp')
        # generate a filter
        # h = gaussian_filter((15, 15), 5)
        if kernel.shape[1] == 1:
            kernel = kernel.repeat(1, n_grid, 1, 1)
        kernel_size_x,kernel_size_y = kernel.shape[2],kernel.shape[3]
        start_x = int((kernel_size_x - 1) / 2.)
        start_y = int((kernel_size_y - 1) / 2.)
        s_1, s_2 = img_stack.shape[2:]
        # channels = img_stack.shape[1]
        IMG_S = torch.zeros((1, channels, s_1, s_2),device=img.device).repeat(n_grid, 1, 1, 1)
        # put a placeholder to store the blurry image
        img_placeholder = torch.zeros(img.shape,device=img.device)
        if img_stack.shape[1] == 3:
            for j in range(3):
                for i in range(n_grid):
                    IMG_S[i:i + 1, j:j+1, start_x:- start_x, start_y:- start_y] = \
                        F.conv2d(img_stack[i:i + 1, j:j + 1, ...], kernel[:, i:i + 1, ...], padding=0, bias=None)
        else:
            for i in range(n_grid):
                IMG_S[i:i + 1, :, start_x:- start_x, start_y:- start_y] = F.conv2d(img_stack[i:i + 1, ...], kernel[:, i:i + 1, ...],padding=0, bias=None)

        # for i in range(n_grid):
        #     # if img_stack.shape[1] == 3:
        #     #     IMG_S[i:i + 1, :, start_x:-1 - start_x, start_y:-1 - start_y] = ...
        #     #     torch.cat([F.conv2d(img_stack[i:i + 1, j:j + 1, ...], kernel[:, i:i+1, ...],padding=0, bias=None) for j in range(3)], axis=1)
        #     # else:
        #     #     IMG_S[i:i + 1, :, start_x:-1 - start_x, start_y:-1 - start_y] = F.conv2d(img_stack[i:i + 1, ...],
        #     #                                                                              kernel[:, i:i + 1, ...],
        #     #                                                                              padding=0, bias=None)
        #     if img_stack.shape[1] == 3: # start_x:- start_x - kernel_size[0] % 2
        #         IMG_S[i:i + 1, :, start_x:- start_x, start_y:- start_y] = \
        #             torch.cat([F.conv2d(img_stack[i:i + 1, j:j + 1, ...], kernel[:, i:i + 1, ...], padding=0, bias=None) for j in range(3)], axis=1)
        #     else:
        #         IMG_S[i:i + 1, :, start_x:- start_x, start_y:- start_y] = F.conv2d(img_stack[i:i + 1, ...],
        #                                                                                      kernel[:, i:i + 1, ...],
        #                                                                                      padding=0, bias=None)
        self.combineStackImage(img_placeholder, IMG_S, range(n_grid))
        # plot the figure
        img_blurred = padimg(img_placeholder, self.pad, 'depad')  # depad
        return img_blurred
    def extract_mask(self,img_ori,kernel, which=None):
        assert which < self.grid_size[0] * self.grid_size[1], "The index is out of range"
        n_grid = which
        img_stack = torch.zeros((1, 1, 2 * self.patch_size[0], 2 * self.patch_size[1]),device=img_ori.device)
        # extract the position is hard, here we use the temp mask approach from the img_ori
        temp_img_one = torch.ones_like(img_ori)[:,0:1,...]
        temp_img = padimg(temp_img_one,self.pad)
        self.extractImageStack(temp_img, img_stack, n_grid, 'blurry')

        # generate a filter
        # h = gaussian_filter((15, 15), 5)
        kernel = torch.ones_like(kernel)
        # if kernel.shape[1] == 1:
        #     kernel = kernel.repeat(1, n_grid, 1, 1)
        kernel_size_x,kernel_size_y = kernel.shape[2],kernel.shape[3]
        start_x = int((kernel_size_x - 1) / 2.)
        start_y = int((kernel_size_y - 1) / 2.)
        s_1, s_2 = img_stack.shape[2:]
        # channels = img_stack.shape[1]
        IMG_S = torch.zeros((1, 1, s_1, s_2),device=img_ori.device) #.repeat(1, 1, 1, 1)
        # put a placeholder to store the blurry image
        img_placeholder = torch.zeros(temp_img.shape,device=img_ori.device)
        # if img_stack.shape[1] == 3:
        #     for j in range(3):
        #         for i in range(n_grid):
        #             IMG_S[i:i + 1, j:j+1, start_x:- start_x, start_y:- start_y] = \
        #                 F.conv2d(img_stack[i:i + 1, j:j + 1, ...], kernel[:, i:i + 1, ...], padding=0, bias=None)
        # else:
        # for i in range(n_grid):
        i = 0
        # print(kernel.shape)
        IMG_S[i:i + 1, :, start_x:- start_x, start_y:- start_y] = F.conv2d(img_stack[i:i + 1, ...], kernel[:, i:i + 1, ...],padding=0, bias=None)

        self.combineStackImage(img_placeholder, IMG_S, n_grid)
        # plot the figure
        img_blurred = padimg(img_placeholder, self.pad, 'depad')  # depad
        # extract the index
        idxs = torch.nonzero(img_blurred>=1)
        h_start, w_start = torch.min(idxs,dim=0)[0][2].item(), torch.min(idxs,dim=0)[0][3].item()
        h_end, w_end = torch.max(idxs, dim=0)[0][2].item(), torch.max(idxs, dim=0)[0][3].item()
        return h_start, h_end, w_start, w_end

    def forward_instance(self,img,kernel, which=None):
        assert which < self.grid_size[0] * self.grid_size[1], "The index is out of range"
        try:
            n_grid = len(which)
        except:
            n_grid = 1
            which = [which]
        channels = img.shape[1]  # 3 for color image
        img_stack = torch.zeros((1, channels, 2 * self.patch_size[0], 2 * self.patch_size[1]),device=img.device)
        self.extractImageStack(img, img_stack, which, 'blurry')
        # generate a filter
        # h = gaussian_filter((15, 15), 5)

        # if kernel.shape[1] == 1:
        #     kernel = kernel.repeat(1, n_grid, 1, 1)
        kernel_size_x,kernel_size_y = kernel.shape[2],kernel.shape[3]
        start_x = int((kernel_size_x - 1) / 2.)
        start_y = int((kernel_size_y - 1) / 2.)
        s_1, s_2 = img_stack.shape[2:]
        # channels = img_stack.shape[1]
        IMG_S = torch.zeros((1, channels, s_1, s_2),device=img.device) #.repeat(n_grid, 1, 1, 1)
        # put a placeholder to store the blurry image
        img_placeholder = torch.zeros(img.shape,device=img.device)
        if img_stack.shape[1] == 3:
            for j in range(3):
                for i in range(n_grid):
                    IMG_S[i:i + 1, j:j+1, start_x:- start_x, start_y:- start_y] = \
                        F.conv2d(img_stack[i:i + 1, j:j + 1, ...], kernel[:, i:i + 1, ...], padding=0, bias=None)
        else:
            for i in range(n_grid):
                IMG_S[i:i + 1, :, start_x:- start_x, start_y:- start_y] = F.conv2d(img_stack[i:i + 1, ...], kernel[:, i:i + 1, ...],padding=0, bias=None)

        self.combineStackImage(img_placeholder, IMG_S, which)
        # plot the figure
        img_blurred = padimg(img_placeholder, self.pad, 'depad')  # depad
        return img_blurred

    def extract_mask2(self,img_ori,kernel, which=None):
        # assert which < self.grid_size[0] * self.grid_size[1], "The index is out of range"
        if not isinstance(which,list):
            which = [which]
        n_grid = len(which)
        kernel_size_x, kernel_size_y = kernel.shape[2], kernel.shape[3]
        start_x = int((kernel_size_x - 1) / 2.)
        start_y = int((kernel_size_y - 1) / 2.)
        img_stack = torch.zeros((n_grid,1, 2 * self.patch_size[0], 2 * self.patch_size[1]),device=img_ori.device)
        # extract the position is hard, here we use the temp mask approach from the img_ori
        temp_img_one = torch.ones_like(img_ori)[:,0:1,...]
        temp_img = padimg(temp_img_one,self.pad)
        self.extractImageStack(temp_img, img_stack, which, 'blurry')

        # generate a filter
        # h = gaussian_filter((15, 15), 5)
        kernel = torch.ones_like(kernel)/(kernel_size_x*kernel_size_y)
        # if kernel.shape[1] == 1:
        #     kernel = kernel.repeat(1, n_grid, 1, 1)

        s_1, s_2 = img_stack.shape[2:]
        # channels = img_stack.shape[1]
        index_data = []
        IMG_S = torch.zeros((1, 1, s_1-2*start_x, s_2-2*start_y),device=img_ori.device).repeat(n_grid,1, 1, 1)
        # put a placeholder to store the blurry image

        # img_placeholder = torch.zeros(temp_img.shape,device=img_ori.device)

        # if img_stack.shape[1] == 3:
        #     for j in range(3):
        #         for i in range(n_grid):
        #             IMG_S[i:i + 1, j:j+1, start_x:- start_x, start_y:- start_y] = \
        #                 F.conv2d(img_stack[i:i + 1, j:j + 1, ...], kernel[:, i:i + 1, ...], padding=0, bias=None)
        # else:
        # for i in range(n_grid):
        # print(kernel.shape)
        for j in range(n_grid):
            # i = which[i]
            IMG_S[j:j+1,0:1, ...] = F.conv2d(img_stack[j:j+1,0:1,...], kernel[:, 0:1, ...],padding=0, bias=None)
        # return IMG_S
        # self.combineStackImage(img_placeholder, IMG_S, which)
        # plot the figure
        # img_blurred = padimg(img_placeholder, self.pad, 'depad')  # depad
        # extract the index

        for j in range(n_grid):
            idxs = torch.nonzero(abs(IMG_S[j:j+1,...]-1.0)<=1e-4)
            h_start, w_start = torch.min(idxs,dim=0)[0][2].item(), torch.min(idxs,dim=0)[0][3].item()
            h_end, w_end = torch.max(idxs, dim=0)[0][2].item(), torch.max(idxs, dim=0)[0][3].item()
            index_data.append((h_end-h_start+2,w_end-w_start + 2,h_start, h_end+1,w_start, w_end+1))
        return index_data

    def extractImageStack_y(self, img, kernel_size, which_patch, mode='blurry'):
        """
        extract the padded img with the patch index
        """
        if not isinstance(which_patch,list):
            which_patch = [which_patch]
        n_grid = len(which_patch)
        channels = img.shape[1]  # 3 for color image
        kernel_size_x, kernel_size_y = kernel_size[0], kernel_size[1]
        start_x = int((kernel_size_x - 1) / 2.)
        start_y = int((kernel_size_y - 1) / 2.)

        img_stack = torch.zeros((n_grid, channels, 2 * self.patch_size[0]-2*start_x, 2 * self.patch_size[1]-2*start_y), device=img.device)

        assert img.shape[2:] == tuple(self.padded_size), "the size does not match"
        t_patch = self.t_patch
        b_patch = self.b_patch
        l_patch = self.l_patch
        r_patch = self.r_patch
        h_patch = self.patch_size[0]
        w_patch = self.patch_size[1]

        try:
            n_grid = len(which_patch)
        except:
            n_grid = 1
            which_patch = [which_patch]
        assert np.max(np.array(which_patch)) < self.grid_size[0] * self.grid_size[1], "out of the number of patches"
        channels = img.shape[1]  # if img.ndim == 4 else 1

        weights = self.W  # np.squeeze(np.ones((2*h_patch,2*w_patch,channels))) #self.W
        #        if channels > 1:
        #            weights = weights.repeat(-1,)

        if channels > 1:
            weights = weights.repeat(1, channels, 1, 1)
        # for i in range(n_grid):
        #     gy, gx = ind2sub(self.grid_size, which_patch[i])
        #     img_stack_s = img[..., t_patch[gy]:b_patch[gy], l_patch[gx]:r_patch[gx]]
        #     if mode != 'blurry':
        #         img_stack[i, ...] = (img_stack_s * weights)[0, ...]
        #     else:
        #         img_stack[i, ...] = img_stack_s[0, ...]
        # return img_stack
        for i in range(n_grid):
            gy, gx = ind2sub(self.grid_size, which_patch[i])
            img_stack_s = img[..., t_patch[gy]+start_x:b_patch[gy]-start_x, l_patch[gx]+start_y:r_patch[gx]-start_y]
            if mode != 'blurry':
                img_stack[i, ...] = (img_stack_s * weights)[0, ...]
            else:
                img_stack[i, ...] = img_stack_s[0, ...]
        return img_stack

    def forward_instance2(self,img,kernel, which=None):
        # assert which < self.grid_size[0] * self.grid_size[1], "The index is out of range"
        if not isinstance(which,list):
            which = [which]
        # try:
        #     n_grid = len(which)
        # except:
        #     n_grid = 1
        #     which = [which]
        n_grid = len(which)
        channels = img.shape[1]  # 3 for color image
        kernel_size_x,kernel_size_y = kernel.shape[2],kernel.shape[3]
        start_x = int((kernel_size_x - 1) / 2.)
        start_y = int((kernel_size_y - 1) / 2.)
        img_stack = torch.zeros((n_grid, channels, 2 * self.patch_size[0], 2 * self.patch_size[1]),device=img.device)
        self.extractImageStack(img, img_stack, which, 'blurry')
        # generate a filter
        # h = gaussian_filter((15, 15), 5)

        # if kernel.shape[1] == 1:
        #     kernel = kernel.repeat(1, n_grid, 1, 1)

        s_1, s_2 = img_stack.shape[2:]
        # channels = img_stack.shape[1]
        IMG_S = torch.zeros((1, channels, s_1-2*start_x, s_2-2*start_y),device=img.device).repeat(n_grid, 1, 1, 1)
        # put a placeholder to store the blurry image
        # img_placeholder = torch.zeros(img.shape,device=img.device)
        if img_stack.shape[1] == 3:
            for j in range(3):
                for i in range(n_grid):
                    IMG_S[i:i + 1, j:j+1, ...] = \
                        F.conv2d(img_stack[i:i + 1, j:j + 1, ...], kernel[:, i:i + 1, ...], padding=0, bias=None)
        else:
            for i in range(n_grid):
                IMG_S[i:i + 1, :, ...] = F.conv2d(img_stack[i:i + 1, ...], kernel[:, i:i + 1, ...],padding=0, bias=None)

        # self.combineStackImage(img_placeholder, IMG_S, which)
        # # plot the figure
        # img_blurred = padimg(img_placeholder, self.pad, 'depad')  # depad
        # return img_blurred
        return IMG_S



def gaussian_filter(shape=(5, 5), sigma=10):
    x, y = [edge / 2 for edge in shape]
    grid = np.array(
        [[((i ** 2 + j ** 2) / (2.0 * sigma ** 2)) for i in np.arange(-x, x + 1)] for j in np.arange(-y, y + 1)])
    g_filter = np.exp(-grid) / (2 * np.pi * sigma ** 2)
    g_filter /= np.sum(g_filter)
    g_filter.astype(np.float32)
    return torch.from_numpy(g_filter[None, None, ...]).type(torch.FloatTensor)