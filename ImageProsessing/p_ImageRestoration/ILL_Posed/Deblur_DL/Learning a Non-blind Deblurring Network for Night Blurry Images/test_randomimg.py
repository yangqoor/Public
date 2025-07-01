import os
import numpy as np
import cv2
import torch
import data.util as util
from models import architecture as arch_deblur, lambda_net as arch_lambda

def load_kernel(kername):
    ker = cv2.imread(kername, cv2.IMREAD_UNCHANGED) * 1.0 / 255
    if len(ker.shape) > 2:
        ker = util.rgb2gray(ker)
    h, w = ker.shape
    if h != w:
        res = (abs(h - w)) // 2
        if h > w:
            ker = ker[res:-res, :]
        else:
            ker = ker[:, res:-res]
    ker = ker / ker.sum()
    kerT = np.rot90(ker, 2)
    kernel = np.expand_dims(ker, axis=2)
    kernelT = np.expand_dims(kerT, axis=2)
    kernel = torch.from_numpy(np.ascontiguousarray(np.transpose(kernel, (2, 0, 1)))).float().unsqueeze(0).to(device)
    kernelT = torch.from_numpy(np.ascontiguousarray(np.transpose(kernelT, (2, 0, 1)))).float().unsqueeze(0).to(device)
    return kernel, kernelT

def load_img(imgname):
    img = cv2.imread(imgname, cv2.IMREAD_UNCHANGED) * 1.0 / 255
    if len(img.shape) == 2:
        # img = util.rgb2gray(img)
        img = np.expand_dims(img, axis=2)
    if img.shape[2] == 3:
        img = img[:, :, [2, 1, 0]]
    img = torch.from_numpy(np.ascontiguousarray(np.transpose(img, (2, 0, 1)))).float().unsqueeze(0).to(device)
    return img

# options
os.environ['CUDA_VISIBLE_DEVICES'] = '0'
lambda_path = './pretrained_models/final_lambda.pth'
model_path = './pretrained_models/final_G.pth'
device = torch.device('cpu')

model = arch_deblur.deblur()
model.load_state_dict(torch.load(model_path), strict=True)
lambda_net = arch_lambda.lnet()
lambda_net.load_state_dict(torch.load(lambda_path), strict=True)

model.eval()
lambda_net.eval()
model = model.to(device)
lambda_net = lambda_net.to(device)
print('Testing Deblur ...')

##########################
kername = './kernel.png'
imgname = './blur.png'
kernel, kernelT = load_kernel(kername)
img = load_img(imgname)
#############################

prev_state = torch.from_numpy(np.zeros((img.shape[0], 32, 128, 128))).float().to(device)
padding= True
if padding:
    k_size = kernel.shape[2]
    padding_size = int((k_size / 2) * 1.5)
    img = torch.nn.functional.pad(img, [padding_size, padding_size, padding_size, padding_size], mode='replicate')

channel = img.shape[1]
output = np.zeros([img.shape[2],img.shape[3], img.shape[1]])
for c in range(channel):
    imgc = img[:,c].unsqueeze(1)
    rec_img = imgc
    for i in range(0, 4):
        with torch.no_grad():
            p, obs = lambda_net(rec_img, prev_state)
            x = model(rec_img, imgc, kernel, kernelT, p, i)
            rec_img = x
            prev_state = obs
    output[:,:,c] = util.tensor2img(x)

output = output[50:-50, 50:-50]
if channel == 3: util.save_img(output[:,:,[2,1,0]], './results.png')
else: util.save_img(output, './results.png')


print('test finished.....')
