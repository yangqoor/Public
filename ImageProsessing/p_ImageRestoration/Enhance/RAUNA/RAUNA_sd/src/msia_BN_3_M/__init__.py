import torch
import torch.nn as nn
import torch.nn.functional as F

def illu_attention_3_M(input_feature, input_i):
  channels = input_i.shape[1]
  con1 = nn.Conv2d(in_channels=channels,out_channels=channels,
                   kernel_size=3, stride=1, padding=1, bias=False,padding_mode='reflect').cuda()
  concat = con1(input_i)
  assert concat.shape[1] == input_i.shape[1]
  concat = nn.Sigmoid()(concat)

  return input_feature * concat

def pool_upsamping_3_M(input_feature, level):
    channels = input_feature.shape[1]
    if level == 1:
        conv1 = nn.Sequential(
            nn.Conv2d(in_channels=channels, out_channels=channels, kernel_size=3, padding=1,padding_mode='reflect'),
            nn.BatchNorm2d(channels),
            nn.ReLU(),
        ).cuda()
        conv_up = conv1(input_feature)
    elif level==2:
        conv2 = nn.Sequential(
            nn.MaxPool2d(kernel_size=2, stride=2, padding=0),
            nn.Conv2d(in_channels=channels, out_channels=channels, kernel_size=3,
                      stride=1, padding=1, padding_mode='reflect'),
            nn.ReLU(),
            nn.ConvTranspose2d(in_channels=channels,out_channels=channels,kernel_size=2,
                               stride=2, padding=0),
        ).cuda()
        conv_up = conv2(input_feature)
    elif level ==4:
        conv4 = nn.Sequential(
            nn.MaxPool2d(kernel_size=4, stride=4, padding=0),
            nn.Conv2d(in_channels=channels, out_channels=channels, kernel_size=1, stride=1, padding=0,padding_mode='reflect'),
            nn.ReLU(),
            nn.ConvTranspose2d(in_channels=channels,out_channels=channels,kernel_size=2,stride=2),
            nn.ConvTranspose2d(in_channels=channels, out_channels=channels, kernel_size=2, stride=2),
        ).cuda()
        conv_up = conv4(input_feature)

    return conv_up


def Multi_Scale_Module_3_M(input_feature):
    channels = input_feature.shape[1]
    Scale_1 = pool_upsamping_3_M(input_feature, 1)
    Scale_2 = pool_upsamping_3_M(input_feature, 2)
    Scale_4 = pool_upsamping_3_M(input_feature, 4)
    res = torch.cat([input_feature, Scale_1, Scale_2, Scale_4], dim=1)
    conv = nn.Conv2d(in_channels=channels*4, out_channels=channels, kernel_size=1, stride=1,padding_mode='reflect').cuda()
    multi_scale_feature = conv(res)
    return multi_scale_feature

def msia_3_M(input_feature, input_i):
    spatial_attention_feature = illu_attention_3_M(input_feature, input_i)
    msia_feature = Multi_Scale_Module_3_M(spatial_attention_feature)
    return msia_feature




