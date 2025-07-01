import torch
import torch.nn as nn
from .common import *
from .normalizer import Mysoftmax, myExp, Mysigmoid, Mydropout, ScaleLayer
import torch.nn.functional as F


class DCGAN(nn.Module):
    def __init__(self, nz, ngf=64, output_size=(256,256), nc=3, num_measurements=1000):
        super(DCGAN, self).__init__()
        self.nc = nc
        self.output_size = output_size

        self.conv1 = nn.ConvTranspose2d(nz, 8*ngf, kernel_size= 4, stride= 1, padding= 0, bias=False) #kernel_size=4, stride=1, padding=0
        self.bn1 = nn.BatchNorm2d(8*ngf)
        self.conv2 = nn.ConvTranspose2d(8*ngf, 4*ngf, 6, 2, 2, bias=False)
        self.bn2 = nn.BatchNorm2d(4*ngf)
        self.conv3 = nn.ConvTranspose2d(4*ngf, 4*ngf, 6, 2, 2, bias=False)
        self.bn3 = nn.BatchNorm2d(4*ngf)
        self.conv4 = nn.ConvTranspose2d(4*ngf, 4*ngf, 6, 2, 2, bias=False)
        self.bn4 = nn.BatchNorm2d(4*ngf)
        self.conv5 = nn.ConvTranspose2d(4*ngf, 4*ngf, 6, 2, 2, bias=False)
        self.bn5 = nn.BatchNorm2d(4*ngf)
        self.conv6 = nn.ConvTranspose2d(4*ngf, 4*ngf, 6, 2, 2, bias=False)
        self.bn6 = nn.BatchNorm2d(4*ngf)
        self.conv7 = nn.ConvTranspose2d(4*ngf, 4*ngf, 4, 2, 1, bias=False)  # output is image
        self.bn7 = nn.BatchNorm2d(4*ngf)
        self.conv8 = nn.ConvTranspose2d(4*ngf, nc, 4, 2, 1, bias=False)  # output is image

    def forward(self, z):
        input_size = z.size()
        x = F.relu(self.bn1(self.conv1(z)))
        x = F.relu(self.bn2(self.conv2(x)))
        x = F.relu(self.bn3(self.conv3(x)))
        x = F.relu(self.bn4(self.conv4(x)))
        x = F.relu(self.bn5(self.conv5(x)))
        x = F.relu(self.bn6(self.conv6(x)))
        x = F.relu(self.bn7(self.conv7(x)))
        x = self.conv8(x)
        # print(x.shape)
        x = torch.nn.functional.sigmoid(x[:,:,0:self.output_size[0],0:self.output_size[1]])

        return x


def skip_ren(
        num_input_channels=2, num_output_channels=3,
        num_channels_down=[16, 32, 64, 128, 128], num_channels_up=[16, 32, 64, 128, 128],
        num_channels_skip=[4, 4, 4, 4, 4],
        filter_size_down=3, filter_size_up=3, filter_skip_size=1,
        need_sigmoid=True, need_bias=True,
        pad='zero', upsample_mode='nearest', downsample_mode='stride', act_fun='LeakyReLU',
        need1x1_up=True):
    """Assembles encoder-decoder with skip connections.
    Arguments:
        act_fun: Either string 'LeakyReLU|Swish|ELU|none' or module (e.g. nn.ReLU)
        pad (string): zero|reflection (default: 'zero')
        upsample_mode (string): 'nearest|bilinear' (default: 'nearest')
        downsample_mode (string): 'stride|avg|max|lanczos2' (default: 'stride')
    """
    assert len(num_channels_down) == len(num_channels_up) == len(num_channels_skip)

    n_scales = len(num_channels_down)

    if not (isinstance(upsample_mode, list) or isinstance(upsample_mode, tuple)):
        upsample_mode = [upsample_mode] * n_scales

    if not (isinstance(downsample_mode, list) or isinstance(downsample_mode, tuple)):
        downsample_mode = [downsample_mode] * n_scales

    if not (isinstance(filter_size_down, list) or isinstance(filter_size_down, tuple)):
        filter_size_down = [filter_size_down] * n_scales

    if not (isinstance(filter_size_up, list) or isinstance(filter_size_up, tuple)):
        filter_size_up = [filter_size_up] * n_scales

    last_scale = n_scales - 1

    cur_depth = None

    model = nn.Sequential()
    model_tmp = model

    input_depth = num_input_channels
    for i in range(len(num_channels_down)):

        deeper = nn.Sequential()
        skip = nn.Sequential()

        if num_channels_skip[i] != 0:
            model_tmp.add(Concat(1, skip, deeper))
        else:
            model_tmp.add(deeper)

        model_tmp.add(bn(num_channels_skip[i] + (num_channels_up[i + 1] if i < last_scale else num_channels_down[i])))

        if num_channels_skip[i] != 0:
            skip.add(conv(input_depth, num_channels_skip[i], filter_skip_size, bias=need_bias, pad=pad))
            skip.add(bn(num_channels_skip[i]))
            skip.add(act(act_fun))

        # skip.add(Concat(2, GenNoise(nums_noise[i]), skip_part))

        deeper.add(conv(input_depth, num_channels_down[i], filter_size_down[i], 2, bias=need_bias, pad=pad,
                        downsample_mode=downsample_mode[i]))
        deeper.add(bn(num_channels_down[i]))
        deeper.add(act(act_fun))
        # if i > 1:
        #     deeper.add(NONLocalBlock2D(in_channels=num_channels_down[i]))
        deeper.add(conv(num_channels_down[i], num_channels_down[i], filter_size_down[i], bias=need_bias, pad=pad))
        deeper.add(bn(num_channels_down[i]))
        deeper.add(act(act_fun))

        deeper_main = nn.Sequential()

        if i == len(num_channels_down) - 1:
            # The deepest
            k = num_channels_down[i]
        else:
            deeper.add(deeper_main)
            k = num_channels_up[i + 1]

        deeper.add(nn.Upsample(scale_factor=2, mode=upsample_mode[i]))

        model_tmp.add(conv(num_channels_skip[i] + k, num_channels_up[i], filter_size_up[i], 1, bias=need_bias, pad=pad))
        model_tmp.add(bn(num_channels_up[i]))
        model_tmp.add(act(act_fun))

        if need1x1_up:
            model_tmp.add(conv(num_channels_up[i], num_channels_up[i], 1, bias=need_bias, pad=pad))
            model_tmp.add(bn(num_channels_up[i]))
            model_tmp.add(act(act_fun))

        input_depth = num_channels_down[i]
        model_tmp = deeper_main

    model.add(conv(num_channels_up[0], num_output_channels, 1, bias=need_bias, pad=pad))
    if need_sigmoid:
        model.add(nn.Sigmoid())

    return model
def skip(
        num_input_channels=2, num_output_channels=3,
        num_channels_down=[16, 32, 64, 128, 128], num_channels_up=[16, 32, 64, 128, 128], num_channels_skip=[4, 4, 4, 4, 4],
        filter_size_down=3, filter_size_up=3, filter_skip_size=1,
        need_sigmoid=True, need_bias=True,
        pad='zero', upsample_mode='nearest', downsample_mode='stride', act_fun='LeakyReLU',
        need1x1_up=True):
    """Assembles encoder-decoder with skip connections.

    Arguments:
        act_fun: Either string 'LeakyReLU|Swish|ELU|none' or module (e.g. nn.ReLU)
        pad (string): zero|reflection (default: 'zero')
        upsample_mode (string): 'nearest|bilinear' (default: 'nearest')
        downsample_mode (string): 'stride|avg|max|lanczos2' (default: 'stride')

    """
    assert len(num_channels_down) == len(num_channels_up) == len(num_channels_skip)

    n_scales = len(num_channels_down)

    if not (isinstance(upsample_mode, list) or isinstance(upsample_mode, tuple)):
        upsample_mode   = [upsample_mode]*n_scales

    if not (isinstance(downsample_mode, list) or isinstance(downsample_mode, tuple)):
        downsample_mode   = [downsample_mode]*n_scales

    if not (isinstance(filter_size_down, list) or isinstance(filter_size_down, tuple)):
        filter_size_down   = [filter_size_down]*n_scales

    if not (isinstance(filter_size_up, list) or isinstance(filter_size_up, tuple)):
        filter_size_up   = [filter_size_up]*n_scales

    last_scale = n_scales - 1

    cur_depth = None

    model = nn.Sequential()
    model_tmp = model

    input_depth = num_input_channels
    for i in range(len(num_channels_down)):

        deeper = nn.Sequential()
        skip = nn.Sequential()

        if num_channels_skip[i] != 0:
            model_tmp.add(Concat(1, skip, deeper))
        else:
            model_tmp.add(deeper)

        # model_tmp.add(bn(num_channels_skip[i] + (num_channels_up[i + 1] if i < last_scale else num_channels_down[i])))
        # model_tmp.add(nn.Dropout(p=0.3))
        # model_tmp.add(Mydropout())
        # if i == 0:
        #     model_tmp.add(Mydropout())
        # else:
        #     model_tmp.add(bn(num_channels_skip[i] + num_channels_up[i]))
        # if i == 0:
        #     model_tmp.add(bn(num_channels_skip[i] + num_channels_up[i+1]))
        # else:
        #     model_tmp.add(bn(num_channels_skip[i] + (num_channels_up[i + 1] if i < last_scale else num_channels_down[i])))

        if i !=0:
            model_tmp.add(nn.Dropout(p=0.3))

        # if i == 0:
        # # if i in range(3):
        #     model_tmp.add(bn(num_channels_skip[i] + num_channels_up[i+1]))
        # else:
        #     model_tmp.add(Mydropout())

        if num_channels_skip[i] != 0:
            skip.add(conv(input_depth, num_channels_skip[i], filter_skip_size, bias=need_bias, pad=pad))
            skip.add(bn(num_channels_skip[i]))
            # skip.add(Mydropout())
            skip.add(act(act_fun))

        # skip.add(Concat(2, GenNoise(nums_noise[i]), skip_part))

        deeper.add(conv(input_depth, num_channels_down[i], filter_size_down[i], 2, bias=need_bias, pad=pad, downsample_mode=downsample_mode[i]))
        deeper.add(bn(num_channels_down[i]))
        # deeper.add(Mydropout())
        deeper.add(act(act_fun))
        # if i>1:
        #     deeper.add(NONLocalBlock2D(in_channels=num_channels_down[i]))
        deeper.add(conv(num_channels_down[i], num_channels_down[i], filter_size_down[i], bias=need_bias, pad=pad))
        deeper.add(bn(num_channels_down[i]))
        # deeper.add(Mydropout())
        deeper.add(act(act_fun))

        deeper_main = nn.Sequential()

        if i == len(num_channels_down) - 1:
            # The deepest
            k = num_channels_down[i]
        else:
            deeper.add(deeper_main)
            k = num_channels_up[i + 1]

        deeper.add(nn.Upsample(scale_factor=2, mode=upsample_mode[i]))

        model_tmp.add(conv(num_channels_skip[i] + k, num_channels_up[i], filter_size_up[i], 1, bias=need_bias, pad=pad))
        model_tmp.add(bn(num_channels_up[i]))
        # model_tmp.add(Mydropout())
        model_tmp.add(act(act_fun))
        # model_tmp.add(Mydropout())


        if need1x1_up:
            model_tmp.add(conv(num_channels_up[i], num_channels_up[i], 1, bias=need_bias, pad=pad))
            model_tmp.add(bn(num_channels_up[i]))
            # model_tmp.add(Mydropout())
            model_tmp.add(act(act_fun))
            # model_tmp.add(Mydropout())

        input_depth = num_channels_down[i]
        model_tmp = deeper_main

    model.add(conv(num_channels_up[0], num_output_channels, 1, bias=need_bias, pad=pad))

    # model.add(conv(num_channels_up[0], 64, 1, bias=need_bias, pad=pad))
    # model.add(act(act_fun))
    # model.add(conv(64, num_output_channels, 1, bias=need_bias, pad=pad))
    if need_sigmoid:
        # model.add(nn.Sigmoid()) #nn.Sigmoid() Mysigmoid()
        # model.add(bn(1))
        model.add(nn.Sigmoid())  # nn.Sigmoid() Mysigmoid() nn.Sigmoid()
        # model.add(nn.Softplus())
        # model.add(ScaleLayer(value=2))
    # else:
    #     # model.add(nn.ReLU())
    #     model.add(bn(1))
    return model

def skipkernel(
        num_input_channels=2, num_output_channels=3,
        num_channels_down=[16, 32, 64, 128, 128], num_channels_up=[16, 32, 64, 128, 128],
        num_channels_skip=[4, 4, 4, 4, 4],
        filter_size_down=3, filter_size_up=3, filter_skip_size=1,
        need_sigmoid=True, need_bias=True,
        pad='zero', upsample_mode='nearest', downsample_mode='stride', act_fun='LeakyReLU',
        need1x1_up=True):
    """Assembles encoder-decoder with skip connections.

    Arguments:
        act_fun: Either string 'LeakyReLU|Swish|ELU|none' or module (e.g. nn.ReLU)
        pad (string): zero|reflection (default: 'zero')
        upsample_mode (string): 'nearest|bilinear' (default: 'nearest')
        downsample_mode (string): 'stride|avg|max|lanczos2' (default: 'stride')

    """
    assert len(num_channels_down) == len(num_channels_up) == len(num_channels_skip)

    n_scales = len(num_channels_down)

    if not (isinstance(upsample_mode, list) or isinstance(upsample_mode, tuple)):
        upsample_mode = [upsample_mode] * n_scales

    if not (isinstance(downsample_mode, list) or isinstance(downsample_mode, tuple)):
        downsample_mode = [downsample_mode] * n_scales

    if not (isinstance(filter_size_down, list) or isinstance(filter_size_down, tuple)):
        filter_size_down = [filter_size_down] * n_scales

    if not (isinstance(filter_size_up, list) or isinstance(filter_size_up, tuple)):
        filter_size_up = [filter_size_up] * n_scales

    last_scale = n_scales - 1

    cur_depth = None

    model = nn.Sequential()
    model_tmp = model

    input_depth = num_input_channels
    for i in range(len(num_channels_down)):

        deeper = nn.Sequential()
        skip = nn.Sequential()

        if num_channels_skip[i] != 0:
            model_tmp.add(Concat(1, skip, deeper))
        else:
            model_tmp.add(deeper)

        model_tmp.add(bn(num_channels_skip[i] + (num_channels_up[i + 1] if i < last_scale else num_channels_down[i])))
        # if i == 0:
        #     model_tmp.add(bn(num_channels_skip[i] + num_channels_up[i+1]))
        # else:
        #     model_tmp.add(Mydropout())
        # model_tmp.add(Mydropout())
        if num_channels_skip[i] != 0:
            skip.add(conv(input_depth, num_channels_skip[i], filter_skip_size, bias=need_bias, pad=pad))
            skip.add(bn(num_channels_skip[i]))
            skip.add(act(act_fun))

        # skip.add(Concat(2, GenNoise(nums_noise[i]), skip_part))

        deeper.add(conv(input_depth, num_channels_down[i], filter_size_down[i], 2, bias=need_bias, pad=pad,
                        downsample_mode=downsample_mode[i]))
        deeper.add(bn(num_channels_down[i]))
        deeper.add(act(act_fun))
        # if i > 1:
        #     deeper.add(NONLocalBlock2D(in_channels=num_channels_down[i]))
        deeper.add(conv(num_channels_down[i], num_channels_down[i], filter_size_down[i], bias=need_bias, pad=pad))
        deeper.add(bn(num_channels_down[i]))
        deeper.add(act(act_fun))

        deeper_main = nn.Sequential()

        if i == len(num_channels_down) - 1:
            # The deepest
            k = num_channels_down[i]
        else:
            deeper.add(deeper_main)
            k = num_channels_up[i + 1]

        deeper.add(nn.Upsample(scale_factor=2, mode=upsample_mode[i]))

        model_tmp.add(conv(num_channels_skip[i] + k, num_channels_up[i], filter_size_up[i], 1, bias=need_bias, pad=pad))
        model_tmp.add(bn(num_channels_up[i]))
        model_tmp.add(act(act_fun))

        if need1x1_up:
            model_tmp.add(conv(num_channels_up[i], num_channels_up[i], 1, bias=need_bias, pad=pad))
            model_tmp.add(bn(num_channels_up[i]))
            model_tmp.add(act(act_fun))

        input_depth = num_channels_down[i]
        model_tmp = deeper_main



    model.add(conv(num_channels_up[0], num_output_channels,5, bias=need_bias, pad=pad)) # kernel size
    # model.add(conv(1, opt.grid_size[0]*opt.grid_size[1], 1, bias=need_bias, pad=pad)) model.add(Mysoftmax())
    # model.add(bn(4))
    # model.add(act(act_fun)) opt.grid_size[0]*opt.grid_size[1]
    # model.add(conv(4, 4, 1, bias=need_bias, pad=pad))
    # model.add(bn(4))
    # model.add(act(act_fun))
    # model.add(conv(1, num_output_channels, 1, bias=need_bias, pad=pad))
    if need_sigmoid:
        # model.add(bn(1))
        model.add(Mysoftmax())

    return model

def concatenation(input1, input2):
    inputs_shapes2 = [input1.shape[2], input2.shape[2]]
    inputs_shapes3 = [input1.shape[3], input2.shape[3]]

    if np.all(np.array(inputs_shapes2) == min(inputs_shapes2)) and np.all(np.array(inputs_shapes3) == min(inputs_shapes3)):
        inputs_ = [input1, input2]
    else:
        target_shape2 = min(inputs_shapes2)
        target_shape3 = min(inputs_shapes3) # Get the minimal size of the input.

        inputs_ = []
        for inp in [input1, input2]:
            diff2 = (inp.size(2) - target_shape2) // 2
            diff3 = (inp.size(3) - target_shape3) // 2
            inputs_.append(inp[:, :, diff2: diff2 + target_shape2, diff3:diff3 + target_shape3]) # Cut the redundant dimensions

    return torch.cat(inputs_, dim=1)

class unet_skip(nn.Module):
    def __init__(self, num_input_channels=2, num_output_channels=3, norm_layer=nn.BatchNorm2d,
        num_channels_down=[128, 128, 128, 128, 128], num_channels_up=[128, 128, 128, 128, 128], num_channels_skip=[4, 4, 4, 4, 4],
        filter_size_down=3, filter_size_up=3, filter_skip_size=1,
        need_sigmoid=True, need_bias=True,
        pad='reflection', upsample_mode='bilinear', downsample_mode='stride', act_fun='LeakyReLU',
        need1x1_up=True, drop_prob = 0.3, morph=True, debug = False): #'nearest' zero zero reflection
        super(unet_skip, self).__init__()
        self.INF = torch.finfo(torch.float32).max
        self._strel_dim = (5, 5)
        self._origin = (self._strel_dim[0] // 2, self._strel_dim[1] // 2)

        self._strel_data_0 = torch.rand(self._strel_dim, dtype=torch.float32).cuda()
        self._strel_tensor_gpu = torch.nn.Parameter(self._strel_data_0, requires_grad=True)
        self._strel_data_1 = torch.ones(self._strel_dim, dtype=torch.float32).cuda()
        self._strel_tensor_1_gpu = torch.nn.Parameter(self._strel_data_1, requires_grad=True)
        # self._strel_tensor_1_gpu = self._strel_data_1.detach()
        assert len(num_channels_down) == len(num_channels_up) == len(num_channels_skip)
        self.debug = debug
        n_scales = len(num_channels_down)

        if not (isinstance(upsample_mode, list) or isinstance(upsample_mode, tuple)):
            upsample_mode = [upsample_mode] * n_scales

        if not (isinstance(downsample_mode, list) or isinstance(downsample_mode, tuple)):
            downsample_mode = [downsample_mode] * n_scales

        if not (isinstance(filter_size_down, list) or isinstance(filter_size_down, tuple)):
            filter_size_down = [filter_size_down] * n_scales

        if not (isinstance(filter_size_up, list) or isinstance(filter_size_up, tuple)):
            filter_size_up = [filter_size_up] * n_scales

        self.level = len(num_channels_down)
        self.encoder_list = nn.ModuleList()
        self.decoder_list = nn.ModuleList()
        self.skip_list    = nn.ModuleList()
        self.up_list      = nn.ModuleList()

        self.output_module = nn.ModuleList()

        input_depth = num_input_channels # Size 1
        for i in range(self.level):
            encoder = nn.Sequential()
            decoder = nn.Sequential()
            skip    = nn.Sequential()

            ##### Encoder at Level i
            encoder.add(conv(input_depth, num_channels_down[i], filter_size_down[i], 2, bias=need_bias, pad=pad,
                            downsample_mode=downsample_mode[i])) ## 1 -> 1/2
            encoder.add(bn(num_channels_down[i]))
            encoder.add(act(act_fun))
            encoder.add(conv(num_channels_down[i], num_channels_down[i], filter_size_down[i], bias=need_bias, pad=pad))
            encoder.add(bn(num_channels_down[i]))
            encoder.add(act(act_fun))
            self.encoder_list.append(encoder)

            ##### Skip at Level i
            if num_channels_skip[i] != 0: ## 1
                skip.add(conv(input_depth, num_channels_skip[i], filter_skip_size, bias=need_bias, pad=pad))
                skip.add(bn(num_channels_skip[i]))
                skip.add(act(act_fun))
            else:
                skip.add(None)

            ##### Decoder at Level i
            self.up_list.append(nn.Upsample(scale_factor=2, mode=upsample_mode[i])) ## 1/2 -> 1
            self.skip_list.append(skip) ## Concate upsampled 1 and skipped 1
            if i == self.level - 1:
                k = num_channels_down[i]
            else:
                k = num_channels_up[i + 1]
            if i < n_scales - 1:
                decoder.add(bn(num_channels_skip[i] + num_channels_up[i + 1]))
            # else:
            #     decoder.add(nn.Dropout(p=drop_prob))
            # model_tmp.add(
            #     bn(num_channels_skip[i] + (num_channels_up[i + 1] if i < last_scale else num_channels_down[i])))
            # if i == 0:
            #     decoder.add(bn(num_channels_skip[i] + num_channels_up[i + 1],norm_layer))
            # else:
            #     decoder.add(nn.Dropout(p=drop_prob))

            decoder.add(conv(num_channels_skip[i] + k, num_channels_up[i], filter_size_up[i], 1, bias=need_bias, pad=pad))
            decoder.add(bn(num_channels_up[i]))
            decoder.add(act(act_fun))

            if need1x1_up:
                decoder.add(conv(num_channels_up[i], num_channels_up[i], 1, bias=need_bias, pad=pad))
                decoder.add(bn(num_channels_up[i]))
                decoder.add(act(act_fun))

            input_depth = num_channels_down[i]
            self.decoder_list.append(decoder)

        ##### Output Module
        self.output_module = nn.Sequential()
        self.output_module.add(conv(num_channels_up[0], num_output_channels, 1, bias=need_bias, pad=pad))
        # if need_sigmoid:
        #     self.output_module.add(Mysoftmax()) #nn.Sigmoid()) #nn.Tanh()) #Sigmoid())
        self.norm = Mysoftmax()

        self.morph = morph
        self.drop = nn.Dropout(p=0.3)

    def forward(self, input, debug = None, drop=None):
        encoder_output = [None] * self.level
        decoder_output = [None] * self.level
        skip_output    = [None] * self.level

        ### Encoder and Skip Part
        for i in range(self.level):
            if i == 0:
                encoder_output[i] = self.encoder_list[i](input) # 1 -> 1/2
            else:
                encoder_output[i] = self.encoder_list[i](encoder_output[i-1])

            if self.skip_list[i][0] is not None:
                if i == 0:
                    skip_output[i] = self.skip_list[i](input) # 1 -> 1
                else:
                    skip_output[i] = self.skip_list[i](encoder_output[i-1])

        ### Decoder Part
        for i in reversed(range(self.level)):
            if i == self.level - 1:
                upsampled = self.up_list[i](encoder_output[i])
                concated = concatenation(skip_output[i], upsampled)
                decoder_output[i] = self.decoder_list[i](concated) # No upsample here
            else:
                upsampled = self.up_list[i](decoder_output[i+1])
                concated = concatenation(skip_output[i], upsampled)
                decoder_output[i] = self.decoder_list[i](concated)

        ### Output module
        # _image_eroded_gpu = ErosionFunction.apply(decoder_output[0], self._strel_tensor_gpu, self._origin, self.INF)
        # _image_eroded_gpu = DilationFunction.apply(_image_eroded_gpu, self._strel_tensor_1_gpu, self._origin,-self.INF)
        # net_output = self.output_module(_image_eroded_gpu)

        if self.morph:
            if drop:
                decoder_output[0] = self.drop(decoder_output[0])
            _image_eroded_gpu = DilationFunction.apply(decoder_output[0], torch.nn.functional.softmax(self._strel_tensor_1_gpu), self._origin,-self.INF)
            net_output = self.output_module(_image_eroded_gpu)
        else:
            net_output = self.output_module(decoder_output[0])

        # # net_output = self.output_module(decoder_output[0])

        # net_output = self.output_module(decoder_output[0])
        # net_output = DilationFunction.apply(net_output, self._strel_tensor_1_gpu, self._origin,-self.INF)

        # net_output = self.output_module(decoder_output[0])
        if debug:
            if self.morph:
                return self.norm(net_output), net_output, decoder_output[0], _image_eroded_gpu
            else:
                return self.norm(net_output), net_output, decoder_output[0]
        else:
            return self.norm(net_output)

class Mynet(nn.Module):
    def __init__(self,opt=None,num_input_channels=2, num_output_channels=3,
        num_channels_down=[16, 32, 64, 128, 128], num_channels_up=[16, 32, 64, 128, 128],
        num_channels_skip=[4, 4, 4, 4, 4],
        filter_size_down=3, filter_size_up=3, filter_skip_size=1,
        need_sigmoid=True, need_bias=True,
        pad='zero', upsample_mode='nearest', downsample_mode='stride', act_fun='LeakyReLU',
        need1x1_up=True):
        super(Mynet,self).__init__()
        self.prenet = skip(num_input_channels=num_input_channels, num_output_channels=num_output_channels,
        num_channels_down=num_channels_down, num_channels_up=num_channels_up,
        num_channels_skip=num_channels_skip,
        filter_size_down=filter_size_down, filter_size_up=filter_size_up, filter_skip_size=filter_skip_size,
        need_sigmoid=need_sigmoid, need_bias=need_bias,
        pad=pad, upsample_mode=upsample_mode, downsample_mode=downsample_mode, act_fun=act_fun,
        need1x1_up=need1x1_up)
        # self.net_input = net_input_saved
        self.conv = nn.Conv2d(1,1,kernel_size=1,stride=1)
        self.opt = opt

    def forward(self,x):
        x = self.prenet(x)
        # below is the extended network
        x1 = nn.functional.upsample(x,size=(self.opt.img_size[0],self.opt.img_size[1]),mode='bilinear') #scale_factor=2.0
        x2 = self.conv(x1)
        x = x1 + x2
        x = nn.functional.sigmoid(x)
        return x

class Mynetk(nn.Module):
    def __init__(self,opt=None,num_input_channels=2, num_output_channels=3,
        num_channels_down=[16, 32, 64, 128, 128], num_channels_up=[16, 32, 64, 128, 128],
        num_channels_skip=[4, 4, 4, 4, 4],
        filter_size_down=3, filter_size_up=3, filter_skip_size=1,
        need_sigmoid=True, need_bias=True,
        pad='zero', upsample_mode='nearest', downsample_mode='stride', act_fun='LeakyReLU',
        need1x1_up=True):
        super(Mynetk,self).__init__()
        self.prenet = skipkernel(num_input_channels=num_input_channels, num_output_channels=num_output_channels,
        num_channels_down=num_channels_down, num_channels_up=num_channels_up,
        num_channels_skip=num_channels_skip,
        filter_size_down=filter_size_down, filter_size_up=filter_size_up, filter_skip_size=filter_skip_size,
        need_sigmoid=need_sigmoid, need_bias=need_bias,
        pad=pad, upsample_mode=upsample_mode, downsample_mode=downsample_mode, act_fun=act_fun,
        need1x1_up=need1x1_up)
        # self.net_input = net_input_saved
        self.conv = nn.Conv2d(1,1,kernel_size=1,stride=1)
        self.opt = opt

    def forward(self,x):
        x = self.prenet(x)
        # below is the extended network
        x1 = nn.functional.upsample(x,size=(self.opt.kernel_size[0],self.opt.kernel_size[1]),mode='bilinear') #scale_factor=2.0
        x2 = self.conv(x1)
        x = x1 + x2
        x = x.view(1,1,1,-1)
        x = torch.squeeze(x)
        output = nn.functional.softmax(x,dim=0)
        output = output.view(-1,1,self.opt.kernel_size[0],self.opt.kernel_size[1])
        # x = nn.functional.sigmoid(x)
        return output