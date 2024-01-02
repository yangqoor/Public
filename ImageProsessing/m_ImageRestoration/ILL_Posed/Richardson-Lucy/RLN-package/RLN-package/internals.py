#5#!/usr/bin/env python3
# -*- coding: utf-8 -*-


import tensorflow as tf
import numpy as np
import tensorflow.keras.backend as K


def init_w(shape, name, stddev=1.0):  # 0.5和1都可以
    with tf.name_scope('init_w'):
        w = tf.Variable(initial_value=tf.truncated_normal(shape=shape, mean=0.0, stddev=stddev, dtype=tf.float32),
                        name=name)
        return w


def tf_fspecial_gauss(size, sigma1):
    # define 3D gaussian function block
    x_data, y_data, z_data = np.mgrid[-size[0]//2 + 1:size[0]//2 + 1, -size[1]//2 + 1:size[1]//2 + 1,-size[2]//2 + 1:size[2]//2 + 1]
    x_data = np.expand_dims(x_data, axis=-1)
    x_data = np.expand_dims(x_data, axis=-1)

    y_data = np.expand_dims(y_data, axis=-1)
    y_data = np.expand_dims(y_data, axis=-1)

    z_data = np.expand_dims(z_data, axis=-1)
    z_data = np.expand_dims(z_data, axis=-1)

    x = tf.constant(x_data, dtype=tf.float32)
    y = tf.constant(y_data, dtype=tf.float32)
    z = tf.constant(z_data, dtype=tf.float32)

    g = tf.exp(-((x**2 + y**2+z**2)/(2.0*sigma1**2)))
    g=g/tf.reduce_max(g)
    return g


def gaussian_ker(shape,name,stddev=1):#1
    c=shape[4]
    init=tf_fspecial_gauss(shape,stddev*0.5)
    for i in range(2,c+1):
        kernel=tf_fspecial_gauss(shape,stddev*0.5*i)
        init = tf.concat([init,kernel], -1)
    rad=tf.random_uniform([1,1,1,shape[3],1],minval=0.7,maxval=1,dtype=tf.float32)
    init=tf.tile(init,[1,1,1,shape[3],1])*rad
    w =tf.Variable(initial_value=init, name=name)
    return w


def copy_and_crop_and_merge(result_from_downsampling, result_from_upsampling):
    return tf.concat(values=[result_from_downsampling, result_from_upsampling], axis=-1)


## FFT function
def fft2d(input, gamma=0.1):
    temp = K.permute_dimensions(input, (0, 3, 1, 2))
    fft = tf.signal.fft2d(tf.complex(temp, tf.zeros_like(temp)))
    absfft = tf.pow(tf.abs(fft)+1e-8, gamma)
    output = K.permute_dimensions(absfft, (0, 2, 3, 1))
    return output


def fft3d(input, gamma=0.1):
    input = apodize3d(input, napodize=5)
    temp = K.permute_dimensions(input, (0, 4, 1, 2, 3))
    fft = tf.signal.fft3d(tf.complex(temp, tf.zeros_like(temp)))
    absfft = tf.pow(tf.abs(fft) + 1e-8, gamma)
    output = K.permute_dimensions(absfft, (0, 2, 3, 4, 1))
    return output


def ifft3d(input, gamma=0.1):
    input = apodize3d(input, napodize=5)
    temp = K.permute_dimensions(input, (0, 4, 1, 2, 3))
    fft = tf.signal.ifft3d(tf.complex(temp, tf.zeros_like(temp)))
    absfft = tf.pow(tf.abs(fft) + 1e-8, gamma)
    output = K.permute_dimensions(absfft, (0, 2, 3, 4, 1))
    return output


def fftshift2d(input,size_psc=128):
    h=tf.shape(input)[1]
    w=tf.shape(input)[2]
    fs11 = input[:, -h // 2:h, -w // 2:w, :]
    fs12 = input[:, -h // 2:h, 0:w // 2, :]
    fs21 = input[:, 0:h // 2, -w // 2:w, :]
    fs22 = input[:, 0:h // 2, 0:w // 2, :]
    output = tf.concat([tf.concat([fs11, fs21], axis=1), tf.concat([fs12, fs22], axis=1)], axis=2)
    output = tf.image.resize_images(output, (size_psc, size_psc), 0)
    return output


def fftshift3d(input,size_psc=[64,64,64]):
    bs, _, _, _, ch = input.get_shape().as_list()
    h=tf.shape(input)[1]
    w=tf.shape(input)[2]
    z=tf.shape(input)[3]
    fs111 = input[:, -h // 2:h, -w // 2:w, -z // 2 + 1:z, :]
    fs121 = input[:, -h // 2:h, 0:w // 2, -z // 2 + 1:z, :]
    fs211 = input[:, 0:h // 2, -w // 2:w, -z // 2 + 1:z, :]
    fs221 = input[:, 0:h // 2, 0:w // 2, -z // 2 + 1:z, :]
    fs112 = input[:, -h // 2:h, -w // 2:w, 0:z // 2 + 1, :]
    fs122 = input[:, -h // 2:h, 0:w // 2, 0:z // 2 + 1, :]
    fs212 = input[:, 0:h // 2, -w // 2:w, 0:z // 2 + 1, :]
    fs222 = input[:, 0:h // 2, 0:w // 2, 0:z // 2 + 1, :]
    output1 = tf.concat([tf.concat([fs111, fs211], axis=1), tf.concat([fs121, fs221], axis=1)], axis=2)
    output2 = tf.concat([tf.concat([fs112, fs212], axis=1), tf.concat([fs122, fs222], axis=1)], axis=2)
    output0 = tf.concat([output1, output2], axis=3)
##original 2
    output = []
    output=tf.reshape(output0,[bs,h,w,-1] )#tf.map_fn(lambda x:tf.image.resize_images(x, (size_psc, size_psc),0),elems=output0)
    output=tf.image.resize_images(output, (size_psc[0], size_psc[1]),0)
    output=tf.reshape(output,[bs,size_psc[0],size_psc[1],z,ch] )
    output=tf.reshape(output,[bs*size_psc[0],size_psc[1],z,ch] )
    output=tf.image.resize_images(output, (size_psc[1], size_psc[2]),0)
    output=tf.reshape(output,[bs,size_psc[0],size_psc[1],size_psc[2],ch] )
##original 1
#    for iz in tf.range(0,z1):
#        output.append(tf.image.resize_images(output0[:, :, :, iz, :], (size_psc, size_psc), 0))
#    output = tf.stack(output, axis=0)
    return output


def apodize2d(img, napodize=10):
    bs, ny, nx, ch = img.get_shape().as_list()
    img_apo = img[:, napodize:ny-napodize, :, :]

    imageUp = img[:, 0:napodize, :, :]
    imageDown = img[:, ny-napodize:, :, :]
    diff = (imageDown[:, -1::-1, :, :] - imageUp) / 2
    l = np.arange(napodize)
    fact_raw = 1 - np.sin((l + 0.5) / napodize * np.pi / 2)
    fact = fact_raw[np.newaxis, :, np.newaxis, np.newaxis]
    fact = tf.convert_to_tensor(fact, dtype=tf.float32)
    fact = tf.tile(fact, [tf.shape(img)[0], 1, nx, ch])
    factor = diff * fact
    imageUp = tf.add(imageUp, factor)
    imageDown = tf.subtract(imageDown, factor[:, -1::-1, :, :])
    img_apo = tf.concat([imageUp, img_apo, imageDown], axis=1)

    imageLeft = img_apo[:, :, 0:napodize, :]
    imageRight = img_apo[:, :, nx-napodize:, :]
    img_apo = img_apo[:, :, napodize:nx-napodize, :]
    diff = (imageRight[:, :, -1::-1, :] - imageLeft) / 2
    fact = fact_raw[np.newaxis, np.newaxis, :, np.newaxis]
    fact = tf.convert_to_tensor(fact, dtype=tf.float32)
    fact = tf.tile(fact, [tf.shape(img)[0], ny, 1, ch])
    factor = diff * fact
    imageLeft = tf.add(imageLeft, factor)
    imageRight = tf.subtract(imageRight, factor[:, :, -1::-1, :])
    img_apo = tf.concat([imageLeft, img_apo, imageRight], axis=2)

    return img_apo


def apodize3d(img, napodize=5):
    bs, _, _, _, ch = img.get_shape().as_list()
    ny=tf.shape(img)[1]
    nx=tf.shape(img)[2]
    nz=tf.shape(img)[3]
    img_apo = img[:, napodize:ny-napodize, :, :, :]
    imageUp = img[:, 0:napodize, :, :, :]
    imageDown = img[:, ny-napodize:, :, :, :]
    diff = (imageDown[:, -1::-1, :, :, :] - imageUp) / 2
    l = np.arange(napodize)
    fact_raw = 1 - np.sin((l + 0.5) / napodize * np.pi / 2)
    fact = fact_raw[np.newaxis, :, np.newaxis, np.newaxis, np.newaxis]
    fact = tf.convert_to_tensor(fact, dtype=tf.float32)
    fact = tf.tile(fact, [tf.shape(img)[0], 1, nx, nz, ch])
    factor = diff * fact
    imageUp = tf.add(imageUp, factor)
    imageDown = tf.subtract(imageDown, factor[:, -1::-1, :, :, :])
    img_apo = tf.concat([imageUp, img_apo, imageDown], axis=1)
    imageLeft = img_apo[:, :, 0:napodize, :, :]
    imageRight = img_apo[:, :, nx-napodize:, :, :]
    img_apo = img_apo[:, :, napodize:nx-napodize, :, :]
    diff = (imageRight[:, :, -1::-1, :, :] - imageLeft) / 2
    fact = fact_raw[np.newaxis, np.newaxis, :, np.newaxis, np.newaxis]
    fact = tf.convert_to_tensor(fact, dtype=tf.float32)
    fact = tf.tile(fact, [tf.shape(img)[0], ny, 1, nz, ch])
    factor = diff * fact
    imageLeft = tf.add(imageLeft, factor)
    imageRight = tf.subtract(imageRight, factor[:, :, -1::-1, :, :])
    img_apo = tf.concat([imageLeft, img_apo, imageRight], axis=2)
    return img_apo