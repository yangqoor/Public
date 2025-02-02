from collections import namedtuple
import numpy as np
import torch
import torch.nn as nn
from PIL import Image

def change_conv_weights(conv_layer, weight, bias):
    conv_layer.conv2d.weight = torch.nn.Parameter(weight, requires_grad= False)
    conv_layer.conv2d.bias = torch.nn.Parameter(bias, requires_grad= False)
    return conv_layer

def change_res_weights(res_block, weights, biases):
    res_block.conv1.conv2d.weight = torch.nn.Parameter(weights[0], requires_grad= False)
    res_block.conv1.conv2d.bias = torch.nn.Parameter(biases[0], requires_grad= False)
    res_block.conv2.conv2d.weight = torch.nn.Parameter(weights[1], requires_grad= False)
    res_block.conv2.conv2d.bias = torch.nn.Parameter(biases[1], requires_grad= False)
    return res_block

def tv_loss(img, tv_weight):

    w_variance = torch.sum(torch.pow(img[:,:,:,:-1] - img[:,:,:,1:], 2))
    h_variance = torch.sum(torch.pow(img[:,:,:-1,:] - img[:,:,1:,:], 2))
    loss = tv_weight * (h_variance + w_variance)
    return loss

def load_image(filename, size=None):
    img = Image.open(filename)
    if size is not None:
        img = img.resize((size, size), Image.ANTIALIAS)
    return img

def save_image(filename, data):
    img = data.clone().clamp(0, 255).numpy()
    img = img.transpose(1, 2, 0).astype("uint8")
    img = Image.fromarray(img)
    img.save(filename)

def normalize_batch(batch):
    mean = batch.new_tensor([0.485, 0.456, 0.406]).view(-1, 1, 1)
    std = batch.new_tensor([0.229, 0.224, 0.225]).view(-1, 1, 1)
    batch = batch.div_(255.0)
    return (batch - mean)/std

def scale(img):
    img = img.squeeze(0)
    for i in range(img.shape[0]):
        img[i] = ((img[i] - torch.min(img[i], 0)[0]) / (torch.max(img[i], 0)[0] - torch.min(img[i], 0)[0]) * 255)
    return img

