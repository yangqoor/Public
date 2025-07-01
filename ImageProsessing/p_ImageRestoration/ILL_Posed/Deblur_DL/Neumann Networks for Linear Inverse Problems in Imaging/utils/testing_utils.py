from PIL import Image
import torch
import matplotlib.pyplot as plt
import numpy as np
import imageio

def save_tensor_as_color_img(img_tensor, filename):
    np_array = img_tensor.cpu().detach().numpy()
    imageio.save(filename, np_array)

def save_batch_as_color_imgs(tensor_batch, batch_size, ii, folder_name, names):
    # img_array = (np.transpose(tensor_batch.cpu().detach().numpy(),(0,2,3,1)) + 1.0) *  127.5
    img_array = (np.clip(np.transpose(tensor_batch.cpu().detach().numpy(),(0,2,3,1)),-1,1) + 1.0) *  127.5
    # img_array = tensor_batch.cpu().detach().numpy()
    # print(np.max(img_array[:]))
    # print(np.min(img_array[:]))

    img_array = img_array.astype(np.uint8)
    for kk in range(batch_size):
        img_number = batch_size*ii + kk
        filename = folder_name + str(img_number) + "_" + str(names[kk]) + ".png"
        # print(np.shape(img_array))
        # print(filename)
        imageio.imwrite(filename, img_array[kk,...])

def save_mri_as_imgs(tensor_batch, batch_size, ii, folder_name, names):
    # img_array = (np.transpose(tensor_batch.cpu().detach().numpy(),(0,2,3,1)) + 1.0) *  127.5
    img_array = tensor_batch.cpu().detach().numpy()

    for kk in range(batch_size):
        img_number = batch_size*ii + kk
        filename = folder_name + str(img_number) + "_" + str(names[kk]) + ".png"
        plt.imshow(np.sqrt(img_array[kk,0,:,:]**2 + img_array[kk,1,:,:]**2))
        plt.gray()
        plt.xticks([])
        plt.yticks([])
        plt.savefig(filename, bbox_inches='tight')