from collections import namedtuple
import numpy as np
import torch
import torch.nn as nn
import torchvision.models as models
from utils.util import change_conv_weights, change_res_weights, scale
    
class Meta(nn.Module):
    def __init__(self):
        super().__init__()
        
        combDensed = namedtuple('combDensed', ['dense_{}'.format(i) for i in range(0, 14)])
        a = [nn.Linear(1920, 128) for i in range(14)]
        mini_densed = combDensed(*a)
        
        self.conv2_w = nn.Sequential(mini_densed.dense_0,
                      nn.Linear(128, 3 * 3 * 32 * 64) )
        self.conv2_b = nn.Sequential(mini_densed.dense_0,
                              nn.Linear(128, 64) )
        self.conv3_w = nn.Sequential(mini_densed.dense_1,
                              nn.Linear(128, 3 * 3 * 64 * 128) )
        self.conv3_b = nn.Sequential(mini_densed.dense_1,
                              nn.Linear(128, 128) )

        self.res1_1_w = nn.Sequential(mini_densed.dense_2,
                              nn.Linear(128, 3*3*128*128) )
        self.res1_1_b = nn.Sequential(mini_densed.dense_2,
                              nn.Linear(128, 128) )
        self.res1_2_w = nn.Sequential(mini_densed.dense_3,
                              nn.Linear(128, 3*3*128*128) )
        self.res1_2_b = nn.Sequential(mini_densed.dense_3,
                              nn.Linear(128, 128) )

        self.res2_1_w = nn.Sequential(mini_densed.dense_4,
                              nn.Linear(128, 3*3*128*128) )
        self.res2_1_b = nn.Sequential(mini_densed.dense_4,
                              nn.Linear(128, 128) )
        self.res2_2_w = nn.Sequential(mini_densed.dense_5,
                              nn.Linear(128, 3*3*128*128) )
        self.res2_2_b = nn.Sequential(mini_densed.dense_5,
                              nn.Linear(128, 128) )

        self.res3_1_w = nn.Sequential(mini_densed.dense_6,
                              nn.Linear(128, 3*3*128*128) )
        self.res3_1_b = nn.Sequential(mini_densed.dense_6,
                              nn.Linear(128, 128) )
        self.res3_2_w = nn.Sequential(mini_densed.dense_7,
                              nn.Linear(128, 3*3*128*128) )
        self.res3_2_b = nn.Sequential(mini_densed.dense_7,
                              nn.Linear(128, 128) )

        self.res4_1_w = nn.Sequential(mini_densed.dense_8,
                              nn.Linear(128, 3*3*128*128) )
        self.res4_1_b = nn.Sequential(mini_densed.dense_8,
                              nn.Linear(128, 128) )
        self.res4_2_w = nn.Sequential(mini_densed.dense_9,
                              nn.Linear(128, 3*3*128*128) )
        self.res4_2_b = nn.Sequential(mini_densed.dense_9,
                              nn.Linear(128, 128) )

        self.res5_1_w = nn.Sequential(mini_densed.dense_10,
                              nn.Linear(128, 3*3*128*128) )
        self.res5_1_b = nn.Sequential(mini_densed.dense_10,
                              nn.Linear(128, 128) )
        self.res5_2_w = nn.Sequential(mini_densed.dense_11,
                              nn.Linear(128, 3*3*128*128) )
        self.res5_2_b = nn.Sequential(mini_densed.dense_11,
                              nn.Linear(128, 128) )

        self.convup_1_w = nn.Sequential(mini_densed.dense_12,
                                  nn.Linear(128, 3*3*128*64) )
        self.convup_1_b = nn.Sequential(mini_densed.dense_12,
                                  nn.Linear(128, 64) )
        self.convup_2_w = nn.Sequential(mini_densed.dense_13,
                                  nn.Linear(128, 3*3*64*32) )
        self.convup_2_b = nn.Sequential(mini_densed.dense_13,
                                  nn.Linear(128, 32) )
        
        
        
    def forward(self, vgg_out):
        
        relu1_2 = vgg_out.relu1_2 
        relu2_2 = vgg_out.relu2_2
        relu3_3 = vgg_out.relu3_3 
        relu4_3 = vgg_out.relu4_3
        
        relu1_2_mean = torch.mean(relu1_2, dim = (2,3))
        relu1_2_std = torch.std(relu1_2, dim = (2,3))

        relu2_2_mean = torch.mean(relu2_2, dim = (2,3))
        relu2_2_std = torch.std(relu2_2, dim = (2,3))

        relu3_3_mean = torch.mean(relu3_3, dim = (2,3))
        relu3_3_std = torch.std(relu3_3, dim = (2,3))

        relu4_3_mean = torch.mean(relu4_3, dim = (2,3))
        relu4_3_std = torch.std(relu4_3, dim = (2,3))
        
        concat = torch.cat([relu1_2_mean, relu1_2_std, relu2_2_mean,
           relu2_2_std, relu3_3_mean, relu3_3_std, relu4_3_mean,
                            relu4_3_std], axis = 1)
        
        conv2_w = self.conv2_w(concat).reshape(1, 64, 32, 3, 3).squeeze(0)
        conv2_b = self.conv2_b(concat).reshape(1, 64).squeeze(0)
        conv3_w = self.conv3_w(concat).reshape(1, 128, 64, 3, 3).squeeze(0)
        conv3_b = self.conv3_b(concat).reshape(1, 128).squeeze(0)
        
        res1_1_w = self.res1_1_w(concat).reshape(1, 128, 128, 3, 3).squeeze(0)
        res1_1_b = self.res1_1_b(concat).reshape(1, 128).squeeze(0)
        res1_2_w = self.res1_2_w(concat).reshape(1, 128, 128, 3, 3).squeeze(0)
        res1_2_b = self.res1_2_b(concat).reshape(1, 128).squeeze(0)
        
        res2_1_w = self.res2_1_w(concat).reshape(1, 128, 128, 3, 3).squeeze(0)
        res2_1_b = self.res2_1_b(concat).reshape(1, 128).squeeze(0)
        res2_2_w = self.res2_2_w(concat).reshape(1, 128, 128, 3, 3).squeeze(0)
        res2_2_b = self.res2_2_b(concat).reshape(1, 128).squeeze(0)
        
        res3_1_w = self.res3_1_w(concat).reshape(1, 128, 128, 3, 3).squeeze(0)
        res3_1_b = self.res3_1_b(concat).reshape(1, 128).squeeze(0)
        res3_2_w = self.res3_2_w(concat).reshape(1, 128, 128, 3, 3).squeeze(0)
        res3_2_b = self.res3_2_b(concat).reshape(1, 128).squeeze(0)
        
        res4_1_w = self.res4_1_w(concat).reshape(1, 128, 128, 3, 3).squeeze(0)
        res4_1_b = self.res4_1_b(concat).reshape(1, 128).squeeze(0)
        res4_2_w = self.res4_2_w(concat).reshape(1, 128, 128, 3, 3).squeeze(0)
        res4_2_b = self.res4_2_b(concat).reshape(1, 128).squeeze(0)
        
        res5_1_w = self.res5_1_w(concat).reshape(1, 128, 128, 3, 3).squeeze(0)
        res5_1_b = self.res5_1_b(concat).reshape(1, 128).squeeze(0)
        res5_2_w = self.res5_2_w(concat).reshape(1, 128, 128, 3, 3).squeeze(0)
        res5_2_b = self.res5_2_b(concat).reshape(1, 128).squeeze(0)
        
        
        convup_1_w = self.convup_1_w(concat).reshape(1, 64, 128, 3, 3).squeeze(0)
        convup_1_b = self.convup_1_b(concat).reshape(1, 64).squeeze(0)
        convup_2_w = self.convup_2_w(concat).reshape(1, 32 ,64, 3, 3).squeeze(0)
        convup_2_b = self.convup_2_b(concat).reshape(1, 32).squeeze(0)
        
        weight_names = namedtuple('weights', ['conv2_w', 'conv2_b', 'conv3_w', 'conv3_b',
                                        'res1_1_w', 'res1_1_b', 'res1_2_w', 'res1_2_b',
                                        'res2_1_w', 'res2_1_b', 'res2_2_w', 'res2_2_b',
                                        'res3_1_w', 'res3_1_b', 'res3_2_w', 'res3_2_b',
                                        'res4_1_w', 'res4_1_b', 'res4_2_w', 'res4_2_b',
                                        'res5_1_w', 'res5_1_b', 'res5_2_w', 'res5_2_b',
                                        'convup_1_w', 'convup_1_b',
                                        'convup_2_w', 'convup_2_b'])
        
        weights = weight_names(conv2_w, conv2_b, conv3_w, conv3_b,
                                res1_1_w, res1_1_b,res1_2_w, res1_2_b,
                                res2_1_w, res2_1_b,res2_2_w, res2_2_b,
                                res3_1_w, res3_1_b,res3_2_w, res3_2_b,
                                res4_1_w, res4_1_b,res4_2_w, res4_2_b,
                                res5_1_w, res5_1_b,res5_2_w, res5_2_b,
                                convup_1_w, convup_1_b,
                                convup_2_w, convup_2_b)
        return weights

class VGG16(nn.Module):
    def __init__(self, requires_grad = False):
        super(VGG16, self).__init__()
        vgg_pretrained_features = models.vgg16(pretrained=True).features
        self.slice1 = nn.Sequential()
        self.slice2 = nn.Sequential()
        self.slice3 = nn.Sequential()
        self.slice4 = nn.Sequential()
        
        for x in range(4):
            self.slice1.add_module(str(x), vgg_pretrained_features[x])
        for x in range(4, 9):
            self.slice2.add_module(str(x), vgg_pretrained_features[x])
        for x in range(9, 16):
            self.slice3.add_module(str(x), vgg_pretrained_features[x])
        for x in range(16, 23):
            self.slice4.add_module(str(x), vgg_pretrained_features[x])
            
        if not requires_grad:
            for param in self.parameters():
                param.requires_grad = False
    
    def forward(self, x):
        h = self.slice1(x)
        h_relu1_2 = h
        h = self.slice2(h)
        h_relu2_2 = h
        h = self.slice3(h)
        h_relu3_3 = h
        h = self.slice4(h)
        h_relu4_3 = h
        vgg_outputs = namedtuple("VggOutputs", ['relu1_2', 'relu2_2', 'relu3_3', 'relu4_3'])
        out = vgg_outputs(h_relu1_2, h_relu2_2, h_relu3_3, h_relu4_3)
        return out

class ConvLayer(nn.Module):
    def __init__(self, in_channels, out_channels, kernel_size, stride):
        super(ConvLayer, self).__init__()
        reflection_padding = kernel_size//2
        self.reflection_pad = nn.ReflectionPad2d(reflection_padding)
        self.conv2d = nn.Conv2d(in_channels, out_channels, kernel_size, stride)
    
    def forward(self, x):
        out = self.reflection_pad(x)
        out = self.conv2d(out)
        return out

class ResidualBlock(nn.Module):
    def __init__(self, channels):
        super(ResidualBlock, self).__init__()
        
        self.conv1 = ConvLayer(channels, channels, kernel_size = 3, stride = 1)
        self.in1= nn.InstanceNorm2d(channels, affine= True)
        self.conv2 = ConvLayer(channels, channels, kernel_size= 3, stride = 1)
        self.in2 = nn.InstanceNorm2d(channels, affine = True)
        self.relu = nn.ReLU()
    

    def forward(self, x):
        residual = x
        out = self.relu(self.in1(self.conv1(x)))
        out = self.in2(self.conv2(out))
        out = out + residual
        return out

class UpsampleConvLayer(nn.Module):
    def __init__(self, in_channels, out_channels, kernel_size, stride, upsample=None):
        super(UpsampleConvLayer, self).__init__()
        self.upsample = upsample
        reflection_padding = kernel_size//2
        self.reflection_pad = nn.ReflectionPad2d(reflection_padding)
        self.conv2d = nn.Conv2d(in_channels, out_channels, kernel_size, stride)
    
    def forward(self, x):
        x_in = x
        if self.upsample:
            x_in = nn.functional.interpolate(x_in, mode = 'nearest', scale_factor = self.upsample)
        
        out = self.reflection_pad(x_in)
        out = self.conv2d(out)
        return out

class TransformerNet(nn.Module):
    def __init__(self):
        super(TransformerNet, self).__init__()
        
        #Initial Conv layers
        self.conv1 = ConvLayer(3, 32, kernel_size = 9, stride = 1)
        self.conv2 = ConvLayer(32, 64, kernel_size = 3, stride = 2)
        self.conv2 = self.conv2.requires_grad_(False) 
        self.in1 = nn.InstanceNorm2d(64, affine = True)
        self.conv3 = ConvLayer(64, 128, kernel_size=3, stride=2)
        self.conv3 = self.conv3.requires_grad_(False)
        self.in2 = nn.InstanceNorm2d(128, affine=True)
        
        #Residual Layers
        self.res1 = ResidualBlock(128)
        self.res2 = ResidualBlock(128)
        self.res3 = ResidualBlock(128)
        self.res4 = ResidualBlock(128)
        self.res5 = ResidualBlock(128)
        self.res1 = self.res1.requires_grad_(False)
        self.res2 = self.res2.requires_grad_(False)
        self.res3 = self.res3.requires_grad_(False)
        self.res4 = self.res4.requires_grad_(False)
        self.res5 = self.res5.requires_grad_(False)
        
        #Upsampling layers
        self.deconv1 = UpsampleConvLayer(128, 64, kernel_size = 3, stride= 1, upsample= 2)
        self.deconv1 = self.deconv1.requires_grad_(False)
        self.in4 = nn.InstanceNorm2d(64, affine = True)
        self.deconv2 = UpsampleConvLayer(64, 32, kernel_size = 3, stride= 1, upsample= 2)
        self.deconv2 = self.deconv2.requires_grad_(False)
        self.in5 = nn.InstanceNorm2d(32, affine = True)
        self.deconv3 = ConvLayer(32, 3, kernel_size = 9, stride = 1)
        
        # Non-linearities
        self.relu = nn.ReLU()
        
    def forward(self, X, weights = None):
        if type(weights) != type(None):
            self.conv2 = change_conv_weights(self.conv2, weights.conv2_w, weights.conv2_b)
            self.conv3 = change_conv_weights(self.conv3, weights.conv3_w, weights.conv3_b)
            self.res1 = change_res_weights(self.res1, [weights.res1_1_w, weights.res1_2_w],
                                                [weights.res1_1_b, weights.res1_2_b])
            self.res2 = change_res_weights(self.res2, [weights.res2_1_w, weights.res2_2_w],
                                                [weights.res2_1_b, weights.res2_2_b])
            self.res3 = change_res_weights(self.res3, [weights.res3_1_w, weights.res3_2_w],
                                                [weights.res3_1_b, weights.res3_2_b])
            self.res4 = change_res_weights(self.res4, [weights.res4_1_w, weights.res4_2_w],
                                                [weights.res4_1_b, weights.res4_2_b])
            self.res5 = change_res_weights(self.res5, [weights.res5_1_w, weights.res5_2_w],
                                                [weights.res5_1_b, weights.res5_2_b])
            self.deconv1 = change_conv_weights(self.deconv1, weights.convup_1_w, weights.convup_1_b)
            self.deconv2 = change_conv_weights(self.deconv2, weights.convup_2_w, weights.convup_2_b)

        y = self.relu(self.conv1(X))
        y = self.relu(self.in1(self.conv2(y)))
        y = self.relu(self.in2(self.conv3(y)))
        y = self.res1(y)
        y = self.res2(y)
        y = self.res3(y)
        y = self.res4(y)
        y = self.res5(y)
        y = self.relu(self.in4(self.deconv1(y)))
        y = self.relu(self.in5(self.deconv2(y)))
        y = self.deconv3(y)
        return torch.stack([scale(i) for i in y])