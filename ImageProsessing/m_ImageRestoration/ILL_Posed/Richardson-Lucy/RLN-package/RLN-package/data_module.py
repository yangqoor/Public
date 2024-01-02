#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import tensorflow as tf
import numpy as np
#import matplotlib.pyplot as plt
import random
import tifffile as tiff

FLAGS = tf.app.flags.FLAGS
batch_index = 0
indexi=0
filenames = []
input_folder='input'
ground_truth_folder='ground_truth'


def get_filenames(data_dir,data_set): #获取文件名称
    global filenames
    filetype='.tif'
    for root, dirs, files in os.walk(os.path.join(data_dir,data_set,input_folder)):
        for file in files:
            if file.endswith(filetype):
                filenames.append(file)
    random.shuffle(filenames)


def normalize_mi_ma(s,mi,ma,eps=1e-20,dtype=np.float32):
    x=(s-mi)/(ma-mi+eps)
    return x


def normalize(x,pmin=0.0,pmax=99.6,axis=None,eps=1e-20,dtype=np.float32):
    mi=np.percentile(x,pmin,axis=axis,keepdims=True)
    ma=np.percentile(x,pmax,axis=axis,keepdims=True)
    mean_v=x.mean()
    while(pmin> 0.0 and ma-mi<0.05*mean_v):
        mi=np.percentile(x,0.05,axis=axis,keepdims=True)
    return mi,ma,normalize_mi_ma(x,mi,ma,eps=eps,dtype=dtype)


def random_crop(x,y,b_d=64,b_h=64,b_w=64):
    w=max(0,(x.shape[0]-b_d)//16)
    h=max(0,(x.shape[1]-b_h)//16)
    d=max(0,(x.shape[2]-b_w)//16)
    x1=random.randint(0,max(0,w-1))*16
    y1=random.randint(0,max(0,h-1))*16
    z1=random.randint(0,max(0,d-1))*16
    x2=x1+b_d #新的结尾坐标
    y2=y1+b_h
    z2=z1+b_w
    if x2>x.shape[0]:
        x1=0
        x2=x.shape[0]-1
    if y2>x.shape[1]:
        y1=0
        y2=x.shape[1]-1
    if z2>x.shape[2]:
        z1=0
        z2=x.shape[2]-1
    r_x=x[x1:x2,y1:y2,z1:z2]
    r_y=y[x1:x2,y1:y2,z1:z2]
    return r_x,r_y


def data_aug_online(x,y,b_d=64,b_h=64,b_w=64):
    mean_whole=y.mean()
    x1,y1=random_crop(x,y,b_d,b_h,b_w)
    while (y1.mean()<mean_whole*0.8):
        x1,y1=random_crop(x,y,b_d,b_h,b_w)
    return x1,y1


def data_gen(b_d,b_h,b_w,crop_time,path_in,path_out):
    if "/" in path_in:
        path_in=os.sep.join(path_in.split("/"))

    if "//" in path_in:
        path_in=os.sep.join(path_in.split("//"))

    if "/" in path_out:
        path_out=os.sep.join(path_out.split("/"))

    if "//" in path_out:
        path_out=os.sep.join(path_out.split("//"))

    path_in1=os.path.join(path_in,'input')
    path_in2 = os.path.join(path_in, 'ground_truth')

    path_out1=os.path.join(path_out,'input')
    path_out2 = os.path.join(path_out, 'ground_truth')

    if not os.path.exists(path_out1):
        os.makedirs(path_out1)

    if not os.path.exists(path_out2):
        os.makedirs(path_out2)

    datanames = os.listdir(path_in1)

    for i in datanames:
        filename_main=i
        input_path=path_in1+filename_main
        decon_path = path_in2+ filename_main

        low_tif = tiff.imread(input_path)
        decon_tif=tiff.imread(decon_path)

        for j in range(crop_time):
            low_tiff_c,decon_tif_c=data_aug_online(low_tif,decon_tif,b_d,b_h,b_w)

            low_out = path_input_out + i[0:-4]+'-'+str(j)+'.tif'
            decon_out=path_decon_out+i[0:-4]+'-'+str(j)+'.tif'
            tiff.imsave(low_out,low_tiff_c)
            tiff.imsave(decon_out,decon_tif_c)


def get_data_train(data_dir, data_set, batch_size, pmin, pmax):
    global batch_index, filenames, maxl, indexi

    if len(filenames) == 0: get_filenames(data_dir, data_set)  # 读取数据列表
    maxl = len(filenames)  # 得到file长度

    begin = 0  # 判断每一个batch的范围
    end = batch_size

    x_data = np.array([], np.float32)
    y_data = np.array([], np.float32)  # zero-filled list for 'one hot encoding'
    label_out = []

    a = random.randint(0, 1)

    if "/" in data_dir:
        data_dir=os.sep.join(data_dir.split("/"))

    if "//" in data_dir:
        data_dir=os.sep.join(data_dir.split("//"))

    Input_Path =os.path.join(data_dir,data_set,input_folder,filenames[indexi])
    GroundTruth_Path =os.path.join(data_dir,data_set,ground_truth_folder,filenames[indexi])
    label_out.append(filenames[indexi])

    input_tif1 = tiff.imread(Input_Path)  # 利用tifffile读取tiff文件，[depth,height,width],所以需要考虑是不是需要调整一下顺序
    input_GT1 = tiff.imread(GroundTruth_Path)

    for j in range(begin, end):
        input_tif, input_GT = data_aug_online(input_tif1, input_GT1)

        _,_,normal_input_tif = normalize(input_tif, pmin, pmax)  # last100
        _,_,normal_gt_tif=normalize(input_GT, 0.0, 99.9)
        normal_gt_tif = np.maximum(0, normal_gt_tif)  # ER 1.0,99.5
        [d, h, w] = normal_input_tif.shape
        x_data = np.append(x_data, normal_input_tif)  # 将输入保存到数组中
        y_data = np.append(y_data, normal_gt_tif)  # 将真值保存在数组中

    if indexi + 1 >= maxl:
        indexi = 0
    else:
        indexi = indexi + 1  # update index for the next batch
    x_data_ = x_data.reshape(batch_size, -1)
    y_data_ = y_data.reshape(batch_size, -1)

    return x_data_, y_data_, label_out, [d, h, w]  # 返回数组中的值


def get_data_valid(data_dir, data_set, batch_size, pmin, pmax):
    global batch_index, filenames, maxl, indexi

    if len(filenames) == 0: get_filenames(data_dir, data_set)  # 读取数据列表
    maxl = len(filenames)  # 得到file长度

    begin = 0  # 判断每一个batch的范围
    end = batch_size

    x_data = np.array([], np.float32)
    y_data = np.array([], np.float32)  # zero-filled list for 'one hot encoding'
    label_out = []

    a = random.randint(0, 1)

    if "/" in data_dir:
        data_dir=os.sep.join(data_dir.split("/"))

    if "//" in data_dir:
        data_dir=os.sep.join(data_dir.split("//"))

    Input_Path =os.path.join(data_dir,data_set,input_folder,filenames[indexi])
    GroundTruth_Path =os.path.join(data_dir,data_set,ground_truth_folder,filenames[indexi])
    label_out.append(filenames[indexi])

    input_tif1 = tiff.imread(Input_Path)  # 利用tifffile读取tiff文件，[depth,height,width],所以需要考虑是不是需要调整一下顺序
    input_GT1 = tiff.imread(GroundTruth_Path)

    for j in range(begin, end):
        input_tif, input_GT = input_tif1, input_GT1

        _,_,normal_input_tif = normalize(input_tif, pmin, pmax)  # last100
        _,_,normal_gt_tif=normalize(input_GT, 0.03, 99.7)
        normal_gt_tif = np.maximum(0, normal_gt_tif)  # ER 1.0,99.5
        [d, h, w] = normal_input_tif.shape
        x_data = np.append(x_data, normal_input_tif)  # 将输入保存到数组中
        y_data = np.append(y_data, normal_gt_tif)  # 将真值保存在数组中

    if indexi + 1 >= maxl:
        indexi = 0
    else:
        indexi = indexi + 1  # update index for the next batch
    x_data_ = x_data.reshape(batch_size, -1)
    y_data_ = y_data.reshape(batch_size, -1)

    return x_data_, y_data_, label_out, [d, h, w]  # 返回数组中的值


def get_data_test(data_dir, data_set, batch_size, pmin, pmax):
    global batch_index, filenames

    if len(filenames) == 0: get_filenames(data_dir, data_set)  # 读取数据列表
    max = len(filenames)  # 得到file长度

    begin = batch_index  # 判断每一个batch的范围
    end = batch_index + batch_size

    x_data = np.array([], np.float32)
    label_out = []

    if "/" in data_dir:
        data_dir=os.sep.join(data_dir.split("/"))

    if "//" in data_dir:
        data_dir=os.sep.join(data_dir.split("//"))

    for i in range(begin, end):
        Input_Path = os.path.join(data_dir,data_set,input_folder,filenames[indexi])
        label_out.append(filenames[i])

        input_tif = tiff.imread(Input_Path)  # 利用tifffile读取tiff文件，[depth,height,width],所以需要考虑是不是需要调整一下顺序

        _,max_v, normal_input_tif = normalize(input_tif, pmin, pmax)  # (input_tif-inmin)/(inmax-inmin)
        [d, h, w] = normal_input_tif.shape  # last 100,933

        x_data = np.append(x_data, normal_input_tif)  # 将输入保存到数组中

    if end >= max:
        end = max
        batch_index = 0
    else:
        batch_index += batch_size  # update index for the next batch
    x_data_ = x_data.reshape(batch_size, -1)

    return np.squeeze(max_v), x_data_, label_out, [d, h, w]  # 返回数组中的值
