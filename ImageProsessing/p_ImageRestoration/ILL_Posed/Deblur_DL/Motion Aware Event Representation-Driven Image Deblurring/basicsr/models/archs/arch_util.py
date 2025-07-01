import math
import torch
from torch import nn as nn
from torch.nn import functional as F
from torch.nn import init as init
from torch.nn.modules.batchnorm import _BatchNorm
import sys

from basicsr.utils import get_root_logger

from einops import rearrange
import numbers
from timm.models.layers import DropPath, trunc_normal_, to_2tuple

@torch.no_grad()
def default_init_weights(module_list, scale=1, bias_fill=0, **kwargs):
    """Initialize network weights.

    Args:
        module_list (list[nn.Module] | nn.Module): Modules to be initialized.
        scale (float): Scale initialized weights, especially for residual
            blocks. Default: 1.
        bias_fill (float): The value to fill bias. Default: 0
        kwargs (dict): Other arguments for initialization function.
    """
    if not isinstance(module_list, list):
        module_list = [module_list]
    for module in module_list:
        for m in module.modules():
            if isinstance(m, nn.Conv2d):
                init.kaiming_normal_(m.weight, **kwargs)
                m.weight.data *= scale
                if m.bias is not None:
                    m.bias.data.fill_(bias_fill)
            elif isinstance(m, nn.Linear):
                init.kaiming_normal_(m.weight, **kwargs)
                m.weight.data *= scale
                if m.bias is not None:
                    m.bias.data.fill_(bias_fill)
            elif isinstance(m, _BatchNorm):
                init.constant_(m.weight, 1)
                if m.bias is not None:
                    m.bias.data.fill_(bias_fill)


def make_layer(basic_block, num_basic_block, **kwarg):
    """Make layers by stacking the same blocks.

    Args:
        basic_block (nn.module): nn.module class for basic block.
        num_basic_block (int): number of blocks.

    Returns:
        nn.Sequential: Stacked blocks in nn.Sequential.
    """
    layers = []
    for _ in range(num_basic_block):
        layers.append(basic_block(**kwarg))
    return nn.Sequential(*layers)


class ResidualBlockNoBN(nn.Module):
    """Residual block without BN.

    It has a style of:
        ---Conv-ReLU-Conv-+-
         |________________|

    Args:
        num_feat (int): Channel number of intermediate features.
            Default: 64.
        res_scale (float): Residual scale. Default: 1.
        pytorch_init (bool): If set to True, use pytorch default init,
            otherwise, use default_init_weights. Default: False.
    """

    def __init__(self, num_feat=64, res_scale=1, pytorch_init=False):
        super(ResidualBlockNoBN, self).__init__()
        self.res_scale = res_scale
        self.conv1 = nn.Conv2d(num_feat, num_feat, 3, 1, 1, bias=True)
        self.conv2 = nn.Conv2d(num_feat, num_feat, 3, 1, 1, bias=True)
        self.relu = nn.ReLU(inplace=True)

        if not pytorch_init:
            default_init_weights([self.conv1, self.conv2], 0.1)

    def forward(self, x):
        identity = x
        out = self.conv2(self.relu(self.conv1(x)))
        return identity + out * self.res_scale


class Upsample(nn.Sequential):
    """Upsample module.

    Args:
        scale (int): Scale factor. Supported scales: 2^n and 3.
        num_feat (int): Channel number of intermediate features.
    """

    def __init__(self, scale, num_feat):
        m = []
        if (scale & (scale - 1)) == 0:  # scale = 2^n
            for _ in range(int(math.log(scale, 2))):
                m.append(nn.Conv2d(num_feat, 4 * num_feat, 3, 1, 1))
                m.append(nn.PixelShuffle(2))
        elif scale == 3:
            m.append(nn.Conv2d(num_feat, 9 * num_feat, 3, 1, 1))
            m.append(nn.PixelShuffle(3))
        else:
            raise ValueError(f'scale {scale} is not supported. '
                             'Supported scales: 2^n and 3.')
        super(Upsample, self).__init__(*m)


def flow_warp(x,
              flow,
              interp_mode='bilinear',
              padding_mode='zeros',
              align_corners=True):
    """Warp an image or feature map with optical flow.

    Args:
        x (Tensor): Tensor with size (n, c, h, w).
        flow (Tensor): Tensor with size (n, h, w, 2), normal value.
        interp_mode (str): 'nearest' or 'bilinear'. Default: 'bilinear'.
        padding_mode (str): 'zeros' or 'border' or 'reflection'.
            Default: 'zeros'.
        align_corners (bool): Before pytorch 1.3, the default value is
            align_corners=True. After pytorch 1.3, the default value is
            align_corners=False. Here, we use the True as default.

    Returns:
        Tensor: Warped image or feature map.
    """
    assert x.size()[-2:] == flow.size()[1:3]
    _, _, h, w = x.size()
    # create mesh grid
    grid_y, grid_x = torch.meshgrid(
        torch.arange(0, h).type_as(x),
        torch.arange(0, w).type_as(x))
    grid = torch.stack((grid_x, grid_y), 2).float()  # W(x), H(y), 2
    grid.requires_grad = False

    vgrid = grid + flow
    # scale grid to [-1,1]
    vgrid_x = 2.0 * vgrid[:, :, :, 0] / max(w - 1, 1) - 1.0
    vgrid_y = 2.0 * vgrid[:, :, :, 1] / max(h - 1, 1) - 1.0
    vgrid_scaled = torch.stack((vgrid_x, vgrid_y), dim=3)
    output = F.grid_sample(
        x,
        vgrid_scaled,
        mode=interp_mode,
        padding_mode=padding_mode,
        align_corners=align_corners)

    # TODO, what if align_corners=False
    return output


def resize_flow(flow,
                size_type,
                sizes,
                interp_mode='bilinear',
                align_corners=False):
    """Resize a flow according to ratio or shape.

    Args:
        flow (Tensor): Precomputed flow. shape [N, 2, H, W].
        size_type (str): 'ratio' or 'shape'.
        sizes (list[int | float]): the ratio for resizing or the final output
            shape.
            1) The order of ratio should be [ratio_h, ratio_w]. For
            downsampling, the ratio should be smaller than 1.0 (i.e., ratio
            < 1.0). For upsampling, the ratio should be larger than 1.0 (i.e.,
            ratio > 1.0).
            2) The order of output_size should be [out_h, out_w].
        interp_mode (str): The mode of interpolation for resizing.
            Default: 'bilinear'.
        align_corners (bool): Whether align corners. Default: False.

    Returns:
        Tensor: Resized flow.
    """
    _, _, flow_h, flow_w = flow.size()
    if size_type == 'ratio':
        output_h, output_w = int(flow_h * sizes[0]), int(flow_w * sizes[1])
    elif size_type == 'shape':
        output_h, output_w = sizes[0], sizes[1]
    else:
        raise ValueError(
            f'Size type should be ratio or shape, but got type {size_type}.')

    input_flow = flow.clone()
    ratio_h = output_h / flow_h
    ratio_w = output_w / flow_w
    input_flow[:, 0, :, :] *= ratio_w
    input_flow[:, 1, :, :] *= ratio_h
    resized_flow = F.interpolate(
        input=input_flow,
        size=(output_h, output_w),
        mode=interp_mode,
        align_corners=align_corners)
    return resized_flow


# TODO: may write a cpp file
def pixel_unshuffle(x, scale):
    """ Pixel unshuffle.

    Args:
        x (Tensor): Input feature with shape (b, c, hh, hw).
        scale (int): Downsample ratio.

    Returns:
        Tensor: the pixel unshuffled feature.
    """
    b, c, hh, hw = x.size()
    out_channel = c * (scale**2)
    assert hh % scale == 0 and hw % scale == 0
    h = hh // scale
    w = hw // scale
    x_view = x.view(b, c, h, scale, w, scale)
    return x_view.permute(0, 1, 3, 5, 2, 4).reshape(b, out_channel, h, w)

##########################################################################
## Layer Norm

def to_3d(x):
    return rearrange(x, 'b c h w -> b (h w) c')

def to_4d(x,h,w):
    return rearrange(x, 'b (h w) c -> b c h w',h=h,w=w)

class BiasFree_LayerNorm(nn.Module):
    def __init__(self, normalized_shape):
        super(BiasFree_LayerNorm, self).__init__()
        if isinstance(normalized_shape, numbers.Integral):
            normalized_shape = (normalized_shape,)
        normalized_shape = torch.Size(normalized_shape)

        assert len(normalized_shape) == 1

        self.weight = nn.Parameter(torch.ones(normalized_shape))
        self.normalized_shape = normalized_shape

    def forward(self, x):
        sigma = x.var(-1, keepdim=True, unbiased=False)
        return x / torch.sqrt(sigma+1e-5) * self.weight

class WithBias_LayerNorm(nn.Module):
    def __init__(self, normalized_shape):
        super(WithBias_LayerNorm, self).__init__()
        if isinstance(normalized_shape, numbers.Integral):
            normalized_shape = (normalized_shape,)
        normalized_shape = torch.Size(normalized_shape)

        assert len(normalized_shape) == 1

        self.weight = nn.Parameter(torch.ones(normalized_shape))
        self.bias = nn.Parameter(torch.zeros(normalized_shape))
        self.normalized_shape = normalized_shape

    def forward(self, x):
        mu = x.mean(-1, keepdim=True)
        sigma = x.var(-1, keepdim=True, unbiased=False)
        return (x - mu) / torch.sqrt(sigma+1e-5) * self.weight + self.bias


class LayerNorm(nn.Module):
    def __init__(self, dim, LayerNorm_type):
        super(LayerNorm, self).__init__()
        if LayerNorm_type =='BiasFree':
            self.body = BiasFree_LayerNorm(dim)
        else:
            self.body = WithBias_LayerNorm(dim)

    def forward(self, x):
        h, w = x.shape[-2:]
        return to_4d(self.body(to_3d(x)), h, w)


class Mutual_Attention(nn.Module):
    def __init__(self, dim, num_heads, bias):
        super(Mutual_Attention, self).__init__()
        self.num_heads = num_heads
        self.temperature = nn.Parameter(torch.ones(num_heads, 1, 1))

        self.q = nn.Conv2d(dim, dim, kernel_size=1, bias=bias)
        self.k = nn.Conv2d(dim, dim, kernel_size=1, bias=bias)
        self.v = nn.Conv2d(dim, dim, kernel_size=1, bias=bias)

        self.project_out = nn.Conv2d(dim, dim, kernel_size=1, bias=bias)
        

    def forward(self, x, y):

        assert x.shape == y.shape, 'The shape of feature maps from image and event branch are not equal!'

        b,c,h,w = x.shape

        q = self.q(x) # image
        k = self.k(y) # event
        v = self.v(y) # event
        
        q = rearrange(q, 'b (head c) h w -> b head c (h w)', head=self.num_heads)
        k = rearrange(k, 'b (head c) h w -> b head c (h w)', head=self.num_heads)
        v = rearrange(v, 'b (head c) h w -> b head c (h w)', head=self.num_heads)

        q = torch.nn.functional.normalize(q, dim=-1)
        k = torch.nn.functional.normalize(k, dim=-1)

        attn = (q @ k.transpose(-2, -1)) * self.temperature
        attn = attn.softmax(dim=-1)
        out = (attn @ v)
        out = rearrange(out, 'b head c (h w) -> b (head c) h w', head=self.num_heads, h=h, w=w)
        out = self.project_out(out)
        return out
    
class Mutual_AttentionwithPrompt(nn.Module):
    def __init__(self, dim, num_heads, bias):
        super(Mutual_AttentionwithPrompt, self).__init__()
        self.num_heads = num_heads
        self.temperature = nn.Parameter(torch.ones(num_heads, 1, 1))
        self.highdim = 256

        self.q = nn.Conv2d(dim, self.highdim, kernel_size=4, stride=4, bias=bias)
        self.k = nn.Conv2d(dim, self.highdim, kernel_size=4, stride=4, bias=bias)
        self.v = nn.Conv2d(dim, self.highdim, kernel_size=4, stride=4, bias=bias)

        self.prompt = nn.Parameter(torch.randn(1, self.num_heads, 20, int(self.highdim/self.num_heads)))

        # self.project_out = nn.Conv2d(dim, dim, kernel_size=1, bias=bias)
        self.project = nn.PixelShuffle(4)
        self.project_out = nn.Conv2d(16, dim, kernel_size=1, bias=bias)
        

    def forward(self, x, y):

        assert x.shape == y.shape, 'The shape of feature maps from image and event branch are not equal!'

        # b,c,h,w = x.shape
        # prompt = self.prompt.repeat(b,1,1,1)

        q = self.q(x) # image
        k = self.k(y) # event
        v = self.v(y) # event

        b,c,h,w = q.shape
        prompt = self.prompt.repeat(b,1,1,1)
        
        q = rearrange(q, 'b (head c) h w -> b head (h w) c', head=self.num_heads)
        k = rearrange(k, 'b (head c) h w -> b head (h w) c', head=self.num_heads)
        v = rearrange(v, 'b (head c) h w -> b head (h w) c', head=self.num_heads)
        
        q = torch.nn.functional.normalize(q, dim=-2)
        k = torch.nn.functional.normalize(k, dim=-2)
        # q = torch.cat([q,prompt],dim=-1) # b head hw c
        k = torch.cat([k,prompt],dim=-2) # b head hw+L c
        v = torch.cat([v,prompt],dim=-2) # b head hw+L c

        attn = (q @ k.transpose(-2, -1)) * self.temperature # b head hw hw+L
        attn = attn.softmax(dim=-1)
        out = (attn @ v) # b head hw c
        out = rearrange(out, 'b head (h w) c -> b (head c) h w', head=self.num_heads, h=h, w=w)
        out = self.project(out) # b 256 h/8 w/8 -> b 4 h w
        out = self.project_out(out) # b c h w

        return out
    
class Mutual_AttentionwithPromptv2(nn.Module):#改大卷积核size
    def __init__(self, dim, num_heads, bias, prom):
        super(Mutual_AttentionwithPrompt, self).__init__()
        self.num_heads = num_heads
        self.temperature = nn.Parameter(torch.ones(num_heads, 1, 1))

        self.q = nn.Conv2d(dim, dim, kernel_size=1, bias=bias)
        self.k = nn.Conv2d(dim, dim, kernel_size=1, bias=bias)
        self.v = nn.Conv2d(dim, dim, kernel_size=1, bias=bias)

        self.prompt = prom

        self.project_out = nn.Conv2d(dim, dim, kernel_size=1, bias=bias)
        

    def forward(self, x, y):

        assert x.shape == y.shape, 'The shape of feature maps from image and event branch are not equal!'

        b,c,h,w = x.shape
        prompt = self.prompt.repeat(b,1,1,h*w)

        q = self.q(x) # image
        k = self.k(y) # event
        v = self.v(y) # event
        
        q = rearrange(q, 'b (head c) h w -> b head c (h w)', head=self.num_heads)
        k = rearrange(k, 'b (head c) h w -> b head c (h w)', head=self.num_heads)
        v = rearrange(v, 'b (head c) h w -> b head c (h w)', head=self.num_heads)
        
        q = torch.nn.functional.normalize(q, dim=-1)
        k = torch.nn.functional.normalize(k, dim=-1)
        k = torch.cat([k,prompt],dim=2)
        v = torch.cat([v,prompt],dim=2)

        attn = (q @ k.transpose(-2, -1)) * self.temperature
        attn = attn.softmax(dim=-1)
        out = (attn @ v)
        out = rearrange(out, 'b head c (h w) -> b (head c) h w', head=self.num_heads, h=h, w=w)
        out = self.project_out(out)
        return out
    
class Mutual_AttentionwithNF(nn.Module):
    def __init__(self, dim, num_heads, bias):
        super(Mutual_AttentionwithNF, self).__init__()
        self.num_heads = num_heads
        self.temperature = nn.Parameter(torch.ones(num_heads, 1, 1))

        self.q = nn.Conv2d(dim, dim, kernel_size=1, bias=bias)
        self.k = nn.Conv2d(dim, dim, kernel_size=1, bias=bias)
        self.v = nn.Conv2d(dim, dim, kernel_size=1, bias=bias)

        self.project_out = nn.Conv2d(dim, dim, kernel_size=1, bias=bias)

        self.gated_feature_composer = torch.nn.Sequential(
        torch.nn.Linear(2 * dim, dim // 2),
        torch.nn.LayerNorm(dim // 2),
        torch.nn.ReLU(),
        torch.nn.Linear(dim // 2, dim),
        )
        self.chan_attn = torch.nn.AdaptiveAvgPool2d(1)

    def forward(self, x, y):

        assert x.shape == y.shape, 'The shape of feature maps from image and event branch are not equal!'

        b,c,h,w = x.shape

        x_ = rearrange(x, 'b c h w -> b (h w) c')
        y_ = rearrange(y, 'b c h w -> b (h w) c')

        y_weight = self.gated_feature_composer(torch.cat([x_,y_],dim = -1))

        # y_ = rearrange(y_weight, 'b (h w) c -> b c h w', h=h, w=w)
        # y_ = self.chan_attn(y_)
        # y_ = y_.squeeze()
        # import pdb;pdb.set_trace()
        # max_value,_ = torch.max(y_,dim=-1)
        # min_value,_ = torch.min(y_,dim=-1)
        # max_value = max_value.unsqueeze(-1)
        # min_value = min_value.unsqueeze(-1)
        # y_ = (y_-min_value)/(max_value-min_value)
        # y_ = y_.unsqueeze(dim=-1).unsqueeze(dim=-1)
        # y_ = y * y_
        y_weight = F.sigmoid(y_weight)
        y_filter = y_weight * y_

        y_ = rearrange(y_filter, 'b (h w) c -> b c h w', h=h, w=w)


        q = self.q(x) # image
        k = self.k(y_) # event
        v = self.v(y_) # event
        
        q = rearrange(q, 'b (head c) h w -> b head c (h w)', head=self.num_heads)
        k = rearrange(k, 'b (head c) h w -> b head c (h w)', head=self.num_heads)
        v = rearrange(v, 'b (head c) h w -> b head c (h w)', head=self.num_heads)

        q = torch.nn.functional.normalize(q, dim=-1)
        k = torch.nn.functional.normalize(k, dim=-1)

        attn = (q @ k.transpose(-2, -1)) * self.temperature
        attn = attn.softmax(dim=-1)
        out = (attn @ v)
        out = rearrange(out, 'b head c (h w) -> b (head c) h w', head=self.num_heads, h=h, w=w)
        out = self.project_out(out)

        return out,y_
    
class Mutual_AttentionwithFC(nn.Module):
    def __init__(self, dim, num_heads, bias):
        super(Mutual_AttentionwithFC, self).__init__()
        self.num_heads = num_heads
        self.temperature = nn.Parameter(torch.ones(num_heads, 1, 1))

        self.q = nn.Conv2d(dim, dim, kernel_size=1, bias=bias)
        self.k = nn.Conv2d(dim, dim, kernel_size=1, bias=bias)
        self.v = nn.Conv2d(dim, dim, kernel_size=1, bias=bias)

        self.project_out = nn.Conv2d(dim, dim, kernel_size=1, bias=bias)

        self.scale = nn.Conv2d(dim,dim,kernel_size=1,bias=bias)
        self.shift = nn.Conv2d(dim,dim,kernel_size=1,bias=bias)


    def forward(self, x, y):

        assert x.shape == y.shape, 'The shape of feature maps from image and event branch are not equal!'

        b,c,h,w = x.shape

        scale = F.leaky_relu(self.scale(x))
        shift = F.leaky_relu(self.shift(x))
        y_ = y * (scale + 1) + shift

        q = self.q(x) # image
        k = self.k(y_) # event
        v = self.v(y_) # event
        
        q = rearrange(q, 'b (head c) h w -> b head c (h w)', head=self.num_heads)
        k = rearrange(k, 'b (head c) h w -> b head c (h w)', head=self.num_heads)
        v = rearrange(v, 'b (head c) h w -> b head c (h w)', head=self.num_heads)

        q = torch.nn.functional.normalize(q, dim=-1)
        k = torch.nn.functional.normalize(k, dim=-1)

        attn = (q @ k.transpose(-2, -1)) * self.temperature
        attn = attn.softmax(dim=-1)
        out = (attn @ v)
        out = rearrange(out, 'b head c (h w) -> b (head c) h w', head=self.num_heads, h=h, w=w)
        out = self.project_out(out)

        return out


##########################################################################
## Event-Image Channel Attention (EICA)
class EventImage_ChannelAttentionTransformerBlock(nn.Module):
    def __init__(self, dim, num_heads, ffn_expansion_factor=2, bias=False, LayerNorm_type='WithBias'):
        super(EventImage_ChannelAttentionTransformerBlock, self).__init__()

        self.norm1_image = LayerNorm(dim, LayerNorm_type)
        self.norm1_event = LayerNorm(dim, LayerNorm_type)
        self.attn = Mutual_Attention(dim, num_heads, bias)
        # mlp
        self.norm2 = nn.LayerNorm(dim)
        mlp_hidden_dim = int(dim * ffn_expansion_factor)
        self.ffn = Mlp(in_features=dim, hidden_features=mlp_hidden_dim, act_layer=nn.GELU, drop=0.)

    def forward(self, image, event):
        # image: b, c, h, w
        # event: b, c, h, w
        # return: b, c, h, w
        assert image.shape == event.shape, 'the shape of image doesnt equal to event'
        b, c , h, w = image.shape
        fused = image + self.attn(self.norm1_image(image), self.norm1_event(event)) # b, c, h, w

        # mlp
        fused = to_3d(fused) # b, h*w, c
        fused = fused + self.ffn(self.norm2(fused))
        fused = to_4d(fused, h, w)

        return fused



class Mlp(nn.Module):
    def __init__(self, in_features, hidden_features=None, out_features=None, act_layer=nn.GELU, drop=0.):
        super().__init__()
        out_features = out_features or in_features
        hidden_features = hidden_features or in_features
        self.fc1 = nn.Linear(in_features, hidden_features)
        self.act = act_layer()
        self.fc2 = nn.Linear(hidden_features, out_features)
        self.drop = nn.Dropout(drop)

    def forward(self, x):
        x = self.fc1(x)
        x = self.act(x)
        x = self.drop(x)
        x = self.fc2(x)
        x = self.drop(x)
        return x


class Attention(nn.Module):
    def __init__(self, dim, num_heads=8, qkv_bias=False, qk_scale=None, attn_drop=0., proj_drop=0., sr_ratio=1):
        super().__init__()
        assert dim % num_heads == 0, f"dim {dim} should be divided by num_heads {num_heads}."

        self.dim = dim
        self.num_heads = num_heads
        head_dim = dim // num_heads
        self.scale = qk_scale or head_dim ** -0.5

        self.q = nn.Linear(dim, dim, bias=qkv_bias)
        self.kv = nn.Linear(dim, dim * 2, bias=qkv_bias)
        self.attn_drop = nn.Dropout(attn_drop)
        self.proj = nn.Linear(dim, dim)
        self.proj_drop = nn.Dropout(proj_drop)

        self.sr_ratio = sr_ratio
        if sr_ratio > 1:
            self.sr = nn.Conv2d(dim, dim, kernel_size=sr_ratio, stride=sr_ratio)
            self.norm = nn.LayerNorm(dim)

    def forward(self, x, y, H=None, W=None):
        # x: image
        # y: event
        assert x.dim()==3, x.shape
        assert x.shape == y.shape
        B, N, C = x.shape
        q = self.q(x).reshape(B, N, self.num_heads, C // self.num_heads).permute(0, 2, 1, 3)

        if self.sr_ratio > 1:
            y_ = y.permute(0, 2, 1).reshape(B, C, H, W)
            y_ = self.sr(y_).reshape(B, C, -1).permute(0, 2, 1)
            y_ = self.norm(y_)
            kv = self.kv(y_).reshape(B, -1, 2, self.num_heads, C // self.num_heads).permute(2, 0, 3, 1, 4)
        else:
            kv = self.kv(y).reshape(B, -1, 2, self.num_heads, C // self.num_heads).permute(2, 0, 3, 1, 4)
        k, v = kv[0], kv[1]

        attn = (q @ k.transpose(-2, -1)) * self.scale
        attn = attn.softmax(dim=-1)
        attn = self.attn_drop(attn)

        x = (attn @ v).transpose(1, 2).reshape(B, N, C)
        x = self.proj(x)
        x = self.proj_drop(x)

        return x

class LayerNormFunction(torch.autograd.Function):

    @staticmethod
    def forward(ctx, x, weight, bias, eps):
        ctx.eps = eps
        N, C, H, W = x.size()
        mu = x.mean(1, keepdim=True)
        var = (x - mu).pow(2).mean(1, keepdim=True)
        y = (x - mu) / (var + eps).sqrt()
        ctx.save_for_backward(y, var, weight)
        y = weight.view(1, C, 1, 1) * y + bias.view(1, C, 1, 1)
        return y

    @staticmethod
    def backward(ctx, grad_output):
        eps = ctx.eps

        N, C, H, W = grad_output.size()
        y, var, weight = ctx.saved_variables
        g = grad_output * weight.view(1, C, 1, 1)
        mean_g = g.mean(dim=1, keepdim=True)

        mean_gy = (g * y).mean(dim=1, keepdim=True)
        gx = 1. / torch.sqrt(var + eps) * (g - y * mean_gy - mean_g)
        return gx, (grad_output * y).sum(dim=3).sum(dim=2).sum(dim=0), grad_output.sum(dim=3).sum(dim=2).sum(
            dim=0), None

class LayerNorm2d(nn.Module):

    def __init__(self, channels, eps=1e-6):
        super(LayerNorm2d, self).__init__()
        self.register_parameter('weight', nn.Parameter(torch.ones(channels)))
        self.register_parameter('bias', nn.Parameter(torch.zeros(channels)))
        self.eps = eps

    def forward(self, x):
        return LayerNormFunction.apply(x, self.weight, self.bias, self.eps)

class Sparsemask(nn.Module):
    def __init__(self, k=20.0):
        super(Sparsemask, self).__init__()
        self.k_tensor = nn.Parameter(torch.tensor(k))

    def forward(self, x):
        topk_values, topk_indices = torch.topk(x, k=int(self.k_tensor), dim=-1)
        bottomk_values, bottomk_indices = torch.topk(x, k=int(self.k_tensor), dim=-1, largest=False)

        mask = torch.ones_like(x)
        mask.scatter_(-1, topk_indices, 0)
        mask.scatter_(-1, bottomk_indices, 0)
        x = x.masked_fill(mask == 1,0)
        return x

class EventImage_BiAttentionTransformerBlock(nn.Module):
    def __init__(self, dim, num_heads, ffn_expansion_factor=2, bias=False, LayerNorm_type='WithBias'):
        super(EventImage_BiAttentionTransformerBlock, self).__init__()

        self.norm1_image = LayerNorm(dim, LayerNorm_type)
        self.norm1_event = LayerNorm(dim, LayerNorm_type)
        self.attn = Mutual_Attention(dim, num_heads, bias)
        # mlp
        self.norm2 = nn.LayerNorm(dim*2)
        mlp_hidden_dim = int(dim * ffn_expansion_factor)
        self.ffn = Mlp(in_features=dim*2, hidden_features=mlp_hidden_dim, act_layer=nn.GELU, drop=0.)
        self.conv = nn.Conv2d(in_channels=2*dim,out_channels=dim,kernel_size=1,stride=1)

    def forward(self, image, event):
        # image: b, c, h, w
        # event: b, c, h, w
        # return: b, 2c, h, w
        assert image.shape == event.shape, 'the shape of image doesnt equal to event'
        b, c, h, w = image.shape
        fused_image = image + self.attn(self.norm1_image(image), self.norm1_event(event)) # b, c, h, w
        fused_event = event + self.attn(self.norm1_image(event), self.norm1_event(image))
        # mlp
        fused = torch.cat([fused_image,fused_event],dim=1)
        fused = to_3d(fused) # b, h*w, 2c
        fused = fused + self.ffn(self.norm2(fused))
        fused = to_4d(fused, h, w) # b,2c,h,w
        fused = self.conv(fused)


        return fused
    

class EventImage_BiAttentionTransformerBlockPrompt(nn.Module):
    def __init__(self, dim, num_heads, ffn_expansion_factor=2, bias=False, LayerNorm_type='WithBias'):
        super(EventImage_BiAttentionTransformerBlockPrompt, self).__init__()

        self.norm1_image = LayerNorm(dim, LayerNorm_type)
        self.norm1_event = LayerNorm(dim, LayerNorm_type)
        self.attn = Mutual_AttentionwithPrompt(dim, num_heads, bias)
        # mlp
        self.norm2 = nn.LayerNorm(dim*2)
        mlp_hidden_dim = int(dim * ffn_expansion_factor)
        self.ffn = Mlp(in_features=dim*2, hidden_features=mlp_hidden_dim, act_layer=nn.GELU, drop=0.)
        self.conv = nn.Conv2d(in_channels=2*dim,out_channels=dim,kernel_size=1,stride=1)

    def forward(self, image, event):
        # image: b, c, h, w
        # event: b, c, h, w
        # return: b, 2c, h, w
        assert image.shape == event.shape, 'the shape of image doesnt equal to event'
        b, c, h, w = image.shape
        fused_image = image + self.attn(self.norm1_image(image), self.norm1_event(event)) # b, c, h, w b 768 h/16 w/16
        fused_event = event + self.attn(self.norm1_image(event), self.norm1_event(image))
        # mlp
        fused = torch.cat([fused_image,fused_event],dim=1)
        fused = to_3d(fused) # b, h*w, 2c
        fused = fused + self.ffn(self.norm2(fused))
        fused = to_4d(fused, h, w) # b,2c,h,w
        fused = self.conv(fused)


        return fused
    
class EventImage_BiAttentionTransformerBlockwithNFtri(nn.Module):
    def __init__(self, dim, num_heads, ffn_expansion_factor=2, bias=False, LayerNorm_type='WithBias'):
        super(EventImage_BiAttentionTransformerBlockwithNF, self).__init__()

        self.norm1_image = LayerNorm(dim, LayerNorm_type)
        self.norm1_event = LayerNorm(dim, LayerNorm_type)
        self.attn = Mutual_AttentionwithNF(dim, num_heads, bias)
        # mlp
        self.norm2 = nn.LayerNorm(dim*2)
        mlp_hidden_dim = int(dim * ffn_expansion_factor)
        self.ffn = Mlp(in_features=dim*2, hidden_features=mlp_hidden_dim, act_layer=nn.GELU, drop=0.)
        self.conv = nn.Conv2d(in_channels=2*dim,out_channels=dim,kernel_size=1,stride=1)

    def forward(self, image, event):
        # image: b, c, h, w
        # event: b, c, h, w
        # return: b, 2c, h, w
        assert image.shape == event.shape, 'the shape of image doesnt equal to event'
        b, c, h, w = image.shape
        fu_img, tr_event = self.attn(self.norm1_image(image), self.norm1_event(event))
        fused_image = image + fu_img # b, c, h, w b 768 h/16 w/16
        fu_event, tr_img = self.attn(self.norm1_image(event), self.norm1_event(image))
        fused_event = event + fu_event
        # mlp
        fused = torch.cat([fused_image,fused_event],dim=1)
        fused = to_3d(fused) # b, h*w, 2c
        fused = fused + self.ffn(self.norm2(fused))
        fused = to_4d(fused, h, w) # b,2c,h,w
        fused = self.conv(fused)

        return fused, tr_event, tr_img
    
class EventImage_BiAttentionTransformerBlockwithNF(nn.Module):
    def __init__(self, dim, num_heads, ffn_expansion_factor=2, bias=False, LayerNorm_type='WithBias'):
        super(EventImage_BiAttentionTransformerBlockwithNF, self).__init__()

        self.norm1_image = LayerNorm(dim, LayerNorm_type)
        self.norm1_event = LayerNorm(dim, LayerNorm_type)
        self.attn = Mutual_AttentionwithNF(dim, num_heads, bias)
        # mlp
        self.norm2 = nn.LayerNorm(dim*2)
        mlp_hidden_dim = int(dim * ffn_expansion_factor)
        self.ffn = Mlp(in_features=dim*2, hidden_features=mlp_hidden_dim, act_layer=nn.GELU, drop=0.)
        self.conv = nn.Conv2d(in_channels=2*dim,out_channels=dim,kernel_size=1,stride=1)

    def forward(self, image, event):
        # image: b, c, h, w
        # event: b, c, h, w
        # return: b, 2c, h, w
        assert image.shape == event.shape, 'the shape of image doesnt equal to event'
        b, c, h, w = image.shape
        fu_img, tr_event = self.attn(self.norm1_image(image), self.norm1_event(event))
        fused_image = image + fu_img # b, c, h, w b 768 h/16 w/16
        fu_event, tr_img = self.attn(self.norm1_image(event), self.norm1_event(image))
        fused_event = event + fu_event
        # mlp
        fused = torch.cat([fused_image,fused_event],dim=1)
        fused = to_3d(fused) # b, h*w, 2c
        fused = fused + self.ffn(self.norm2(fused))
        fused = to_4d(fused, h, w) # b,2c,h,w
        fused = self.conv(fused)

        return fused
    
class EventImage_BiAttentionTransformerBlockwithFC(nn.Module):
    def __init__(self, dim, num_heads, ffn_expansion_factor=2, bias=False, LayerNorm_type='WithBias'):
        super(EventImage_BiAttentionTransformerBlockwithFC, self).__init__()

        self.norm1_image = LayerNorm(dim, LayerNorm_type)
        self.norm1_event = LayerNorm(dim, LayerNorm_type)
        self.attn = Mutual_AttentionwithFC(dim, num_heads, bias)
        # mlp
        self.norm2 = nn.LayerNorm(dim*2)
        mlp_hidden_dim = int(dim * ffn_expansion_factor)
        self.ffn = Mlp(in_features=dim*2, hidden_features=mlp_hidden_dim, act_layer=nn.GELU, drop=0.)
        self.conv = nn.Conv2d(in_channels=2*dim,out_channels=dim,kernel_size=1,stride=1)

    def forward(self, image, event):
        # image: b, c, h, w
        # event: b, c, h, w
        # return: b, 2c, h, w
        assert image.shape == event.shape, 'the shape of image doesnt equal to event'
        b, c, h, w = image.shape

        # out_i,im_ = self.attn(self.norm1_image(image), self.norm1_event(event))
        # fused_image = image + out_i
        # out_e,e_ = self.attn(self.norm1_image(event), self.norm1_event(image))
        # fused_event = event + out_e
        fused_image = image + self.attn(self.norm1_image(image), self.norm1_event(event)) # b, c, h, w b 768 h/16 w/16
        fused_event = event + self.attn(self.norm1_image(event), self.norm1_event(image))
        # mlp
        fused = torch.cat([fused_image,fused_event],dim=1)
        fused = to_3d(fused) # b, h*w, 2c
        fused = fused + self.ffn(self.norm2(fused))
        fused = to_4d(fused, h, w) # b,2c,h,w
        fused = self.conv(fused)

        return fused
    
class EventImage_BiAttentionTransformerBlockwithFC_I2E(nn.Module):
    def __init__(self, dim, num_heads, ffn_expansion_factor=2, bias=False, LayerNorm_type='WithBias'):
        super(EventImage_BiAttentionTransformerBlockwithFC_I2E, self).__init__()

        self.norm1_image = LayerNorm(dim, LayerNorm_type)
        self.norm1_event = LayerNorm(dim, LayerNorm_type)
        self.attn = Mutual_AttentionwithFC(dim, num_heads, bias)
        # mlp
        self.norm2 = nn.LayerNorm(dim)
        mlp_hidden_dim = int(dim * ffn_expansion_factor)
        self.ffn = Mlp(in_features=dim, hidden_features=mlp_hidden_dim, act_layer=nn.GELU, drop=0.)
        self.conv = nn.Conv2d(in_channels=dim,out_channels=dim,kernel_size=1,stride=1)

    def forward(self, image, event):
        # image: b, c, h, w
        # event: b, c, h, w
        # return: b, 2c, h, w
        assert image.shape == event.shape, 'the shape of image doesnt equal to event'
        b, c, h, w = image.shape

        fused_image = image + self.attn(self.norm1_image(image), self.norm1_event(event)) # b, c, h, w b 768 h/16 w/16
        # fused_event = event + self.attn(self.norm1_image(event), self.norm1_event(image))
        # mlp
        # fused = torch.cat([fused_image,fused_event],dim=1)
        fused = to_3d(fused_image) # b, h*w, 2c
        fused = fused + self.ffn(self.norm2(fused))
        fused = to_4d(fused, h, w) # b,2c,h,w
        fused = self.conv(fused)

        return fused
    
class EventImage_BiAttentionTransformerBlockwithFC_E2I(nn.Module):
    def __init__(self, dim, num_heads, ffn_expansion_factor=2, bias=False, LayerNorm_type='WithBias'):
        super(EventImage_BiAttentionTransformerBlockwithFC_E2I, self).__init__()

        self.norm1_image = LayerNorm(dim, LayerNorm_type)
        self.norm1_event = LayerNorm(dim, LayerNorm_type)
        self.attn = Mutual_AttentionwithFC(dim, num_heads, bias)
        # mlp
        self.norm2 = nn.LayerNorm(dim)
        mlp_hidden_dim = int(dim * ffn_expansion_factor)
        self.ffn = Mlp(in_features=dim, hidden_features=mlp_hidden_dim, act_layer=nn.GELU, drop=0.)
        self.conv = nn.Conv2d(in_channels=dim,out_channels=dim,kernel_size=1,stride=1)

    def forward(self, image, event):
        # image: b, c, h, w
        # event: b, c, h, w
        # return: b, 2c, h, w
        assert image.shape == event.shape, 'the shape of image doesnt equal to event'
        b, c, h, w = image.shape

        # fused_image = image + self.attn(self.norm1_image(image), self.norm1_event(event)) # b, c, h, w b 768 h/16 w/16
        fused_event = event + self.attn(self.norm1_image(event), self.norm1_event(image))
        # mlp
        # fused = torch.cat([fused_image,fused_event],dim=1)
        fused = to_3d(fused_event) # b, h*w, 2c
        fused = fused + self.ffn(self.norm2(fused))
        fused = to_4d(fused, h, w) # b,2c,h,w
        fused = self.conv(fused)

        return fused


class EventImage_BiAttentionTransformerBlock2c(nn.Module):
    def __init__(self, dim, num_heads, ffn_expansion_factor=2, bias=False, LayerNorm_type='WithBias'):
        super(EventImage_BiAttentionTransformerBlock2c, self).__init__()

        self.norm1_image = LayerNorm(dim, LayerNorm_type)
        self.norm1_event = LayerNorm(dim, LayerNorm_type)
        self.attn = Mutual_Attention(dim, num_heads, bias)
        # mlp
        self.norm2 = nn.LayerNorm(dim*2)
        mlp_hidden_dim = int(dim * ffn_expansion_factor)
        self.ffn = Mlp(in_features=dim*2, hidden_features=mlp_hidden_dim, act_layer=nn.GELU, drop=0.)
        # self.conv = nn.Conv2d(in_channels=2*dim,out_channels=dim,kernel_size=1,stride=1)

    def forward(self, image, event):
        # image: b, c, h, w
        # event: b, c, h, w
        # return: b, 2c, h, w
        assert image.shape == event.shape, 'the shape of image doesnt equal to event'
        b, c, h, w = image.shape
        fused_image = image + self.attn(self.norm1_image(image), self.norm1_event(event)) # b, c, h, w
        fused_event = event + self.attn(self.norm1_image(event), self.norm1_event(image))
        # mlp
        fused = torch.cat([fused_image,fused_event],dim=1)
        fused = to_3d(fused) # b, h*w, 2c
        fused = fused + self.ffn(self.norm2(fused))
        fused = to_4d(fused, h, w) # b,2c,h,w


        return fused
    
if __name__ == "__main__":
    attn = Mutual_AttentionwithPrompt(4,2,True)
    x = torch.rand((3, 4, 256, 256))
    event = torch.randn((3,4,256,256))
    res = attn(x,event)
