#5#!/usr/bin/env python3
# -*- coding: utf-8 -*-


import tensorflow as tf
import numpy as np
import tensorflow.keras.backend as K
from tensorflow.keras.layers import Lambda
from internals import init_w, gaussian_ker, fft3d, ifft3d


@tf.custom_gradient
def tensor_div(a,x1):
    m=tf.div_no_nan(a, x1+0.0001)

    def grad(dy):
        return dy,-tf.square(m)*dy
    return m, grad


@tf.custom_gradient
def tensor_mul(a,x):
    m=tf.multiply(a, x)

    def grad(dy):
        return dy,dy*(a)
    return m, grad


def chan_ave(x):
    xo=tf.reduce_mean(x,axis=-1,keep_dims=True)
    return xo

def _name(s):
    return s

def activationF(x, name='leaky_relu'):
    return tf.nn.softplus(x)


def batch_norm(x):
    return tf.contrib.layers.layer_norm(x)


def avg_pool(x):
    output=tf.nn.avg_pool3d(x,[1,2,2,2,1],strides=[1,2,2,2,1],padding='VALID',data_format='NDHWC')
    return output


def FP_add_part(x,y):
    bs, _, _, _, ch = x.get_shape().as_list()
    y=activationF(tf.tile(input=y,multiples=[1,1,1,1,ch]))
    output=x+y
    return output


def FP_H1(x,ch):
    with tf.name_scope('FP_H1'):
        inputs=avg_pool(x)
        kernel1=gaussian_ker(shape=[3,3,3,1,ch], name='e_1')
        kernel2=gaussian_ker(shape=[3,3,3,ch,ch], name='e_2')
        kernel3=gaussian_ker(shape=[3,3,3,2*ch,ch], name='e_3')

        layer=tf.nn.conv3d(input=inputs, filter=kernel1,strides=[1, 1, 1, 1, 1], padding='SAME', name='conv_1')
        layer=batch_norm(layer)
        layer=activationF(layer)

        temp1=layer

        layer=tf.nn.conv3d(input=layer, filter=kernel2,strides=[1, 1, 1, 1, 1], padding='SAME', name='conv_2')
        layer=batch_norm(layer)
        layer=activationF(layer)

        layer=tf.concat([layer,temp1],-1)

        layer=tf.nn.conv3d(input=layer, filter=kernel3,strides=[1, 1, 1, 1, 1], padding='SAME', name='conv_2')
        layer=batch_norm(layer)
        layer=activationF(layer)

        layer=FP_add_part(layer,inputs)

        return layer


def DV_H1(x,y):
    with tf.name_scope('BP_H1'):
        devidend=avg_pool(x)
        devisor=chan_ave(y)
        output=tensor_div(devidend, devisor)
        output=batch_norm(output)
        return output


def BP_H1(x,ch,shapes):
    with tf.name_scope('BP_H1'):
        kernel1=init_w(shape=[3,3,3,1,ch], name='e_1')
        kernel2=init_w(shape=[3,3,3,ch,ch], name='e_2')
        kernel3=init_w(shape=[3,3,3,2*ch,ch], name='e_2')
        up_kernel1 = init_w(shape=[2, 2, 2, ch//2, ch], name='up_1')
        up_kernel2 = init_w(shape=[3, 3, 3, ch //2, ch//2], name='up_2')

        layer=tf.nn.conv3d(input=x, filter=kernel1,strides=[1, 1, 1, 1, 1], padding='SAME', name='conv_1')
        layer=batch_norm(layer)
        layer=activationF(layer)

        temp1=layer

        layer=tf.nn.conv3d(input=layer, filter=kernel2,strides=[1, 1, 1, 1, 1], padding='SAME', name='conv_2')
        layer=batch_norm(layer)
        layer=activationF(layer)

        layer=tf.concat([layer,temp1],-1)

        layer=tf.nn.conv3d(input=layer, filter=kernel3,strides=[1, 1, 1, 1, 1], padding='SAME', name='conv_3')
        layer=batch_norm(layer)
        layer=activationF(layer)

        layer=tf.nn.conv3d_transpose(value=layer, filter=up_kernel1,output_shape=shapes,strides=[1, 2, 2, 2, 1], padding='VALID', name='up_1')
        layer=batch_norm(layer)
        layer=activationF(layer)

        layer=tf.nn.conv3d(input=layer, filter=up_kernel2,strides=[1, 1, 1, 1, 1], padding='SAME', name='up_2')
        layer=batch_norm(layer)
        layer=activationF(layer)

        output=chan_ave(layer)

        return output


def update_H1(x,y):
    with tf.name_scope('update_H1'):
        output=tf.multiply(x,y)
        return output


def FP_H2(x,ch):
    with tf.name_scope('FP_H2'):
        kernel1=gaussian_ker(shape=[3,3,3,1,ch], name='e_1')
        kernel2=gaussian_ker(shape=[3,3,3,ch,ch], name='e_2')

        inputs=x
        layer=tf.nn.conv3d(input=inputs, filter=kernel1,strides=[1, 1, 1, 1, 1], padding='SAME', name='conv_1')
        layer=batch_norm(layer)
        layer=activationF(layer)

        layer=tf.nn.conv3d(input=layer, filter=kernel2,strides=[1, 1, 1, 1, 1], padding='SAME', name='conv_2')
        layer=batch_norm(layer)
        layer=activationF(layer)

        layer=FP_add_part(layer,inputs)

        return layer


def DV_H2(x,y):
    with tf.name_scope('BP_H2'):
        devidend=x
        devisor=chan_ave(y)
        output=tensor_div(devidend, devisor)
        output=batch_norm(output)
        return output


def BP_H2(x,ch):
    with tf.name_scope('BP_H2'):
        kernel1=init_w(shape=[3,3,3,1,ch], name='e_1')
        kernel2=init_w(shape=[3,3,3,ch,ch], name='e_2')

        layer=tf.nn.conv3d(input=x, filter=kernel1,strides=[1, 1, 1, 1, 1], padding='SAME', name='conv_1')
        layer=batch_norm(layer)
        layer=activationF(layer)

        layer=tf.nn.conv3d(input=layer, filter=kernel2,strides=[1, 1, 1, 1, 1], padding='SAME', name='conv_2')
        layer=batch_norm(layer)
        layer=activationF(layer)
        layer=layer+tf.ones_like(layer)

        output=chan_ave(layer)

        return output


def update_H2(x,y):
    with tf.name_scope('update_H2'):
        x=batch_norm(x)
        x=activationF(x)
        layer=tf.multiply(x,y)
        layer=batch_norm(layer)
        output=activationF(layer)
        return output


def merge_H3(e1,e2,ch):
    with tf.name_scope('BP_H2'):
        e1=batch_norm(e1)
        e1=activationF(e1)

        kernel1=init_w(shape=[3,3,3,1,ch], name='e_1')
        kernel2=init_w(shape=[3,3,3,ch+2,ch], name='e_2')
        kernel3=init_w(shape=[3,3,3,2*ch,ch], name='e_3')

        layer=tf.nn.conv3d(input=e2, filter=kernel1,strides=[1, 1, 1, 1, 1], padding='SAME', name='conv_1')
        layer=batch_norm(layer)
        layer=activationF(layer)
        temp1=layer

        layer=tf.concat([layer,e1,e2],-1)

        layer=tf.nn.conv3d(input=layer, filter=kernel2,strides=[1, 1, 1, 1, 1], padding='SAME', name='conv_2')
        layer=batch_norm(layer)
        layer=activationF(layer)

        layer=tf.concat([layer,temp1],-1)

        layer=tf.nn.conv3d(input=layer, filter=kernel3,strides=[1, 1, 1, 1, 1], padding='SAME', name='conv_3')
        layer=batch_norm(layer)
        layer=activationF(layer)

        output=chan_ave(layer)

        return output


def global_avg_pool(x):
    b,_,_,_,c=x.shape
    return tf.reshape(tf.reduce_mean(x,axis=[1,2,3]),(b,1,c))


def mul_attention1(inputs,index,inner_units_ratio=0.5): #channel_attention
    with tf.variable_scope("CAB%s"%(index)):
        inputs_shape = map(lambda x: x.value, inputs.shape)
        b,d,h,w,c=inputs_shape
        GAP=global_avg_pool(inputs)
        fc_1=tf.layers.dense(inputs=GAP,units=c*inner_units_ratio,name="fc_1",activation=None)
        fc_1=tf.nn.relu(fc_1)
        fc_2=tf.layers.dense(inputs=fc_1,units=c,name="fc_2",activation=None)
        fc_2=tf.nn.sigmoid(fc_2)
        channel_attention=tf.reshape(fc_2, shape=[b,1, 1, 1,c])
        out1= tf.multiply(inputs, channel_attention)
        return out1


def mul_attention_FCA(inputs, index, inner_units_ratio=8.0):
    with tf.variable_scope("CAB%s" % (index)):
        b, _, _, _, c = inputs.get_shape().as_list()
        d = tf.shape(inputs)[1]
        h = tf.shape(inputs)[2]
        w = tf.shape(inputs)[3]
        absfft1 = Lambda(fft3d, arguments={'gamma': 1.0})(inputs)

        mean_map = tf.reduce_mean(absfft1, axis=-1, keep_dims=True)
        max_map = tf.reduce_max(absfft1, axis=-1, keep_dims=True)
        merge_map = tf.concat([mean_map, max_map], -1)
        kernels1 = init_w(shape=[3, 3, 3, 2, 2], name=_name("inside_kernel1%s" % (index)))
        kernels2 = init_w(shape=[3, 3, 3, 2, 2], name=_name("inside_kernel2%s" % (index)))
        kernels3 = init_w(shape=[3, 3, 3, 2, 2], name=_name("inside_kernel3%s" % (index)))
        kernels4 = init_w(shape=[3, 3, 3, 6, c], name=_name("inside_kernel4%s" % (index)))
        inside_conv1 = tf.nn.conv3d(
            input=merge_map, filter=kernels1,
            strides=[1, 1, 1, 1, 1], padding='SAME', name=_name("conv_1%s" % (index)))
        inside_conv2 = tf.nn.conv3d(
            input=inside_conv1, filter=kernels2,
            strides=[1, 1, 1, 1, 1], padding='SAME', name=_name("conv_2%s" % (index)))
        inside_conv3 = tf.nn.conv3d(
            input=inside_conv2, filter=kernels3,
            strides=[1, 1, 1, 1, 1], padding='SAME', name=_name("conv_3%s" % (index)))
        merge_map_all = tf.concat([inside_conv1, inside_conv2, inside_conv3], -1)
        inside_conv = tf.nn.conv3d(
            input=merge_map_all, filter=kernels4,
            strides=[1, 1, 1, 1, 1], padding='SAME', name=_name("conv_%s" % (index)))
        inside_ac = tf.nn.sigmoid(batch_norm(x=inside_conv))  # tf.nn.sigmoid(inside_conv)
        out1 = tf.multiply(absfft1, inside_ac)

        out2 = Lambda(ifft3d, arguments={'gamma': 1.0})(out1)
        out2 = out2 / (tf.reduce_max(out2) + 0.001)

        out3 = mul_attention1(out2, index, 2)
        inputs = mul_attention1(inputs, index + 10, 2)
        out4 = tf.concat([inputs, out3], -1)
        kernels5 = init_w(shape=[3, 3, 3, 2 * c, c], name=_name("inside_kernel5%s" % (index)))
        output = tf.nn.conv3d(
            input=out4, filter=kernels5,
            strides=[1, 1, 1, 1, 1], padding='SAME', name=_name("conv_1%s" % (index)))
        output = activationF(batch_norm(x=output))

        return output


def setup_RLN(x,fp_ch,bp_ch,merge_ch,batchsizes,input_shape):
    inputs=x
    shapes = [batchsizes, input_shape[0], input_shape[1], input_shape[2], bp_ch//2]
    fp1=FP_H1(inputs,fp_ch)
    dv1=DV_H1(inputs, fp1)
    bp1=BP_H1(dv1, bp_ch, shapes)
    update1=update_H1(inputs,bp1)

    fp2 = FP_H2(inputs, fp_ch)
    dv2 = DV_H2(inputs, fp2)
    bp2 = BP_H2(dv2, bp_ch,)
    update2 = update_H2(update1, bp2)

    mergeh3=merge_H3(update1,update2,merge_ch)

    return update1, update2, mergeh3
