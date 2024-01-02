#5#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import tensorflow as tf
import numpy as np
import tensorflow.keras.backend as K


def get_mse(gt_label, dl_op):
    sub_diff = dl_op - gt_label
    mse_square = tf.square(sub_diff)
    mse = tf.reduce_mean(mse_square) + 0.0001
    return mse


def get_mae(gt_label,dl_op):
    sub_diff =tf.abs(dl_op-gt_label)
    mae=tf.reduce_mean(sub_diff)
    return mae


def get_SSIM(gt_label, dl_op,max_val=1):
    mean_prediction =tf.reduce_mean(dl_op)
    mean_gt =tf.reduce_mean(gt_label)
    sigma_prediction=tf.reduce_mean(tf.square(tf.subtract(dl_op,mean_prediction)))
    sigma_gt=tf.reduce_mean(tf.square(tf.subtract(gt_label,mean_gt)))
    sigma_cross=tf.reduce_mean(tf.multiply(tf.subtract(dl_op,mean_prediction),
                                                    tf.subtract(gt_label,mean_gt)))
    ssim_1=2*tf.multiply(mean_prediction,mean_gt)+1e-4*max_val*max_val
    ssim_2=2*sigma_cross+9e-4**max_val*max_val
    ssim_3=tf.square(mean_prediction)+tf.square(mean_gt)+1e-4**max_val*max_val
    ssim_4=sigma_prediction+sigma_gt+9e-4**max_val*max_val
    ssim=tf.div(tf.multiply(ssim_1,ssim_2),tf.multiply(ssim_3,ssim_4))
    return ssim


def total_loss(x1,y1,x2,y2):
    loss1=get_mse(x1, y1)
    loss2=get_mse(x2, y2)+1.0*(1-get_SSIM(x2,y2))
    loss=0.2*loss1+loss2
    return loss1,loss2,loss

