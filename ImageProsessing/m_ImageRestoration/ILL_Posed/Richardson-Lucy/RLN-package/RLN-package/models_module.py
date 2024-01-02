#5#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import faulthandler
faulthandler.enable()
import time
import os
os.environ['TF_CPP_MIN_LOG_LEVEL']='2'
import tensorflow as tf
import numpy as np
import tifffile as tiff
import tensorflow.keras.backend as K
from tensorflow.keras.layers import Lambda
from tensorflow.python.ops import gen_image_ops
import argparse
#import tflearn
import data_module as inputf
import random
import math
from scipy.ndimage import zoom
from scipy.ndimage import rotate
from scipy.ndimage import gaussian_filter1d
from blocks import setup_RLN
from loss import total_loss
import itertools
import tqdm



def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('--mode',  type=str, default='TS',  help="set the mode")
    parser.add_argument('--batchsizes',  type=int, default=1,  help="set the batchsize number")
    parser.add_argument('--gpu_id', type=str, default='0',   help="id(s) for CUDA_VISIBLE_DEVICES")
    parser.add_argument('--gpu_memory_limit', type=float, default=0.4, help="limit GPU memory to this fraction (0...1)")
    parser.add_argument('--train_iter', type=int, default=10000, help="set the training iteration number")
    parser.add_argument('--crop_size', type=int, default=300, help="set the large data crop size")
    parser.add_argument('--data_gen', type=bool, default=False, help="crop the train data or not")

    parser.add_argument('--main_dir', type=str, default=None, help="path to folder with input images")
    parser.add_argument('--normal_pmin', type=float, default=0.2, help="'pmin' for PercentileNormalizer")
    parser.add_argument('--normal_pmax', type=float, default=99.8, help="'pmax' for PercentileNormalizer")

    return parser, parser.parse_args()


class RLNet:
    def __init__(self):
        self.input_image = {}
        self.ground_truth = {}
        self.shape = {}
        self.cast_image = None
        self.cast_ground_truth = None
        self.cast_ground_truth1 = None
        self.loss= None
        self.prediction1, self.prediction2,self.prediction3= [None] * 3
        self.sub_diff,self.mse_square,self.mse=[None] * 3
        self.learning_rate=[None]
        self.global_step=[None]
        self.train_step = [None]
        self.loss1,self.loss2,self.loss = [None] * 3

    def set_up_rlnet(self, batch_size,fp_ch=4,bp_ch=8,merge_ch=8):
        with tf.name_scope('input'):
            output_data_channel=1
            self.shape=tf.placeholder(dtype=tf.int32)
            self.input_image = tf.placeholder(dtype=tf.float32)
            self.ground_truth = tf.placeholder(dtype=tf.float32)
            self.cast_image = tf.reshape(
                tensor=self.input_image,
                shape=[batch_size, self.shape[0], self.shape[1], self.shape[2], 1]
            )

            self.cast_ground_truth = tf.reshape(
                    tensor=self.ground_truth,
                    shape=[batch_size, self.shape[0],self.shape[1],self.shape[2],output_data_channel]
                    )

            self.cast_ground_truth1 = self.cast_ground_truth * 0.8 + 0.2 * self.cast_image

            inputs=self.cast_image

            self.prediction1, self.prediction2,self.prediction3=setup_RLN(inputs,fp_ch,bp_ch,merge_ch,batch_size,self.shape)

            self.loss1,self.loss2,self.loss=total_loss(self.cast_ground_truth1,self.prediction1,self.cast_ground_truth,self.prediction3)

            with tf.name_scope('step'):
                self.global_step = tf.Variable(0, trainable=False)
                self.learning_rate = tf.train.exponential_decay(0.025, self.global_step, 200, 0.95, staircase=False)
            with tf.control_dependencies(tf.get_collection(tf.GraphKeys.UPDATE_OPS)):
                self.train_step = tf.train.AdamOptimizer(learning_rate=self.learning_rate).minimize(self.loss,global_step=self.global_step)


    def train(self,batch_size,train_iter,train_path,normal_pmin,normal_pmax):
        if "/" in train_path:
            train_path = os.sep.join(train_path.split("/"))

        if "//" in train_path:
            train_path = os.sep.join(train_path.split("//"))

        inputf.indexi = 0
        inputf.filenames=[]
        input_path = os.path.join(train_path, 'train','input')
        inputf.filenames=os.listdir(input_path)
        inputf.filenames.sort()
        epoch = len(inputf.filenames)*10

        train_dir=os.path.join(train_path,'train','model')
        if not os.path.exists(train_dir):
            os.makedirs(train_dir)

        train_out=os.path.join(train_path,'train','output')
        if not os.path.exists(train_out):
            os.makedirs(train_out)

        checkpoint_path=os.path.join(train_dir,'model.ckpt')
        all_parameters_saver = tf.train.Saver() #save
        with tf.Session(config=config) as sess:
            sess.run(tf.global_variables_initializer())
            sess.run(tf.local_variables_initializer())
            sum_los = 0.0
            dtime=0.0
            time_start=time.time()
            for k in range(train_iter):
                t1=time.time()
                train_images,train_GT,label2out,shape=inputf.get_data_train(train_path,'train',batch_size,normal_pmin,normal_pmax)
                t2=time.time()
                dtime=dtime+t2-t1
                loss1,loss2,loss,trainer= sess.run([self.loss1,self.loss2,self.loss,self.train_step],feed_dict={self.shape:shape,self.input_image:train_images, self.ground_truth: train_GT})
#mse,ssim,lo,mse2,trainer
                sum_los += loss
                if k % 101 == 0:
                    time_end=time.time()
                    used_time=time_end-time_start
                    print('num %d, loss1: %.6f, loss2: %.6f, loss: %.6f, runtime:%.6f ' % (k, loss1, loss2, loss,used_time))
                if (k+1)%epoch==0:#13
                    print('sum_lo: %.6f' %(sum_los))
                    sum_los = 0.0
                if (k+1)%10000==0:
                    image= sess.run([self.prediction3],
                                  feed_dict={self.shape:shape,self.input_image:train_images, self.ground_truth: train_GT})
                    image1=np.array(image)
                    image1=image1.astype(np.float16)
                    print(label2out)
                    reshape_image=np.squeeze(image1)
                    if batch_size == 1:
                        single=reshape_image
                        filenames_out=os.path.join(val_out,'rl_'+label2out[0])
                        tiff.imsave(filenames_out,single)
                    else:    
                        for v in range(batch_size):
                            single=reshape_image[v]
                            filenames_out=os.path.join(val_out,'rl_'+label2out[v])
                            tiff.imsave(filenames_out,single)
                if (k+1)%epoch == 0:
                    all_parameters_saver.save(sess=sess, save_path=checkpoint_path)
            print("Done training")
        sess.close()

    def valid(self,val_path,normal_pmin=0.05,normal_pmax=99.5,batch_size=1):
        if "/" in val_path:
            val_path = os.sep.join(val_path.split("/"))

        if "//" in val_path:
            val_path = os.sep.join(val_path.split("//"))

        inputf.filenames=[]
        inputf.indexi=0
        input_path = os.path.join(val_path, 'test','input')
        inputf.filenames=os.listdir(input_path)
        inputf.filenames.sort()
        val_iter = len(inputf.filenames)

        model_dir=os.path.join(val_path,'train','model')
        checkpoint_path=os.path.join(model_dir,'model.ckpt')

        val_out=os.path.join(val_path,'test','output')
        if not os.path.exists(val_out):
            os.makedirs(val_out)

        all_parameters_saver = tf.train.Saver()
        with tf.Session() as sess:  # 开始一个会话
            sess.run(tf.global_variables_initializer())
            sess.run(tf.local_variables_initializer())
            all_parameters_saver.restore(sess=sess, save_path=checkpoint_path)
            sum_los = 0.0
            for m in range(val_iter):
                time_start=time.time()
                test_images,test_GT,label2out,shape=inputf.get_data_valid(val_path,'test',batch_size,normal_pmin,normal_pmax)
                image, los = sess.run([self.prediction3, self.loss],feed_dict={self.shape:shape,self.input_image:test_images, self.ground_truth: test_GT})
                sum_los += los
                image1=np.array(image)
                image1=image1.astype(np.float16)
                print(image1.shape)
                reshape_image=np.squeeze(image1)
                if batch_size == 1:
                    single=reshape_image
                    filenames_out=os.path.join(val_out,'rl_'+label2out[0])
                    tiff.imsave(filenames_out,single)
                else:    
                    for v in range(batch_size):
                        single=reshape_image[v]
                        filenames_out=os.path.join(val_out,'rl_'+label2out[v])
                        tiff.imsave(filenames_out,single)
                if m % 1 == 0:
                    time_end=time.time()
                    print('num %d, loss: %.6f, runtime:%.6f ' % (m, los,time_end-time_start))
        print('Done validating')


    def test(self,test_path,normal_pmin=0.05,normal_pmax=99.5,batch_size=1):
        if "/" in test_path:
            test_path = os.sep.join(test_path.split("/"))

        if "//" in test_path:
            test_path = os.sep.join(test_path.split("//"))

        inputf.indexi = 0
        inputf.filenames=[]
        input_path = os.path.join(test_path, 'test','input')
        inputf.filenames=os.listdir(input_path)
        inputf.filenames.sort()
        test_iter = len(inputf.filenames)

        model_dir=os.path.join(test_path,'train','model')
        checkpoint_path=os.path.join(model_dir,'model.ckpt')

        test_out=os.path.join(test_path,'test','output')
        if not os.path.exists(test_out):
            os.makedirs(test_out)

        all_parameters_saver = tf.train.Saver()
        with tf.Session() as sess:  # 开始一个会话
            sess.run(tf.global_variables_initializer())
            sess.run(tf.local_variables_initializer())
            all_parameters_saver.restore(sess=sess, save_path=checkpoint_path)
            for m in range(test_iter):
                time_start=time.time()
                max_v,test_images,label2out,shape=inputf.get_data_test(test_path,'test',batch_size,normal_pmin,normal_pmax)
                image = sess.run([self.prediction3],feed_dict={self.shape:shape,self.input_image:test_images})
                image1=np.array(image)
                image1=image1.astype(np.float16)
                print(image1.shape)
                reshape_image=np.squeeze(image1)
                if batch_size == 1:
                    single=reshape_image
                    filenames_out=os.path.join(test_out,'rl_'+label2out[0])
                    tiff.imsave(filenames_out,single)
                else:    
                    for v in range(batch_size):
                        single=reshape_image[v]
                        filenames_out=os.path.join(test_out,'rl_'+label2out[v])
                        tiff.imsave(filenames_out,single)
                if m % 1 == 0:
                    time_end=time.time()
                    print('num %d, runtime:%.6f ' % (m, time_end-time_start))
        print('Done testing')


    def test_large(self,test_path,normal_pmin=0.05,normal_pmax=99.5,crop_data_size=300,batch_size=1):
        image_dim = 3
        num_output_channels=1

        inputf.indexi = 0
        inputf.filenames=[]
        input_path = os.path.join(test_path, 'test','input')
        inputf.filenames=os.listdir(input_path)
        inputf.filenames.sort()
        test_iter = len(inputf.filenames)
        model_dir = os.path.join(test_path, 'train', 'model')
        checkpoint_path = os.path.join(model_dir, 'model.ckpt')

        test_out = os.path.join(test_path, 'test', 'output')
        if not os.path.exists(test_out):
            os.makedirs(test_out)

        variables=tf.contrib.framework.get_variables_to_restore()
        variables_to_restore1=[v for v in variables if (v.name.split('/')[0]!='step')]
        all_parameters_saver = tf.train.Saver(variables_to_restore1)
        with tf.Session() as sess:  # 开始一个会话
            time_start_init = time.time()
            sess.run(tf.global_variables_initializer())
            sess.run(tf.local_variables_initializer())
            all_parameters_saver.restore(sess=sess, save_path=checkpoint_path)
            time_read_all = 0
            time_crop_all = 0
            time_process_all = 0
            time_save_all = 0

            for nn in range(0, test_iter):
                time_start = time.time()
                input_file = os.path.join(input_path,inputf.filenames[nn])
                print(input_file)
                label_out = inputf.filenames[nn]

                time_read_s = time.time()
                input_tif = tiff.imread(input_file)  # the input large data_size
                time_read_e = time.time()
                time_read_all = time_read_all + time_read_e - time_read_s

                output_image_shape = input_tif.shape
                input_image_shape = input_tif.shape

                time_crop_s = time.time()
                if input_image_shape[0] < 40:
                    d = 0
                else:
                    d = 10
                overlap_shape = (d, 24, 24)
                if input_image_shape[1] % 2 != 0:
                    overlap_shape = (d, 23, 24)
                if input_image_shape[2] % 2 != 0:
                    overlap_shape = (d, 32, 24)
                # set the cropped size
                crop_d = min(output_image_shape[0], 2000)
                crop_w = min(math.floor(math.sqrt(crop_data_size / 4 * 1024 * 1024 / crop_d)), 1998)
                crop_h = min(math.floor(math.sqrt(crop_data_size / 4 * 1024 * 1024 / crop_d)), 1998)
                if crop_w % 2 != 0:
                    different = 2 - crop_w % 2
                    crop_w = crop_w - different
                if crop_h % 2 != 0:
                    different = 2 - crop_h % 2
                    crop_h = crop_h - different
                model_input_image_shape = (crop_d, crop_h, crop_w)
                print(model_input_image_shape)
                step_shape = tuple(m - o for m, o in zip(model_input_image_shape, overlap_shape))

                block_weight = np.ones(
                    [m - 2 * o for m, o
                     in zip(model_input_image_shape, overlap_shape)], dtype=np.float32)
                block_weight = np.pad(
                    block_weight,
                    [(o + 1, o + 1) for o in overlap_shape],
                    'linear_ramp')[(slice(1, -1),) * image_dim]


                applied = np.zeros(
                    (*output_image_shape, num_output_channels), dtype=np.float32)
                sum_weight = np.zeros(output_image_shape, dtype=np.float32)
                num_steps = tuple(
                    i // s + (((i // s) * s + o) < i)
                    for i, s, o in zip(input_image_shape, step_shape, overlap_shape))

                blocks = list(itertools.product(
                    *[np.arange(n) * s for n, s in zip(num_steps, step_shape)]))

                print(blocks)

                time_crop_e = time.time()
                time_crop_all = time_crop_all + time_crop_e - time_crop_s

                time_process_s = time.time()

                for chunk_index in tqdm.trange(
                        0, len(blocks),batch_size, disable=False,
                        dynamic_ncols=True, ascii=tqdm.utils.IS_WIN):
                    rois = []
                    maxv = []
                    minv = []
                    for batch_index, tl in enumerate(blocks[chunk_index:chunk_index + batch_size]):
                        # tl 左上角坐标， br 右下角坐标
                        br = [min(t + m, i) for t, m, i in zip(tl, model_input_image_shape, input_image_shape)]
                        # r1是用于预测的图像区域
                        r1, r2 = zip(*[(slice(s, e), slice(0, e - s)) for s, e in zip(tl, br)])
                        # print(r2)

                        m = input_tif[r1]
                        block_weight1 = block_weight
                        # print(m.shape)
                        if model_input_image_shape != m.shape:
                            # reshape the weight block
                            block_weight1 = block_weight[:m.shape[0], :m.shape[1], :m.shape[2]]

                            # expand the data
                            # pad_width = [(0, b - s) for b, s
                            #             in zip(model_input_image_shape, m.shape)]
                            # print(pad_width)
                            # m = np.pad(m, pad_width, 'reflect')

                        shape_in = m.shape
                        # print(shape_in)
                        min_v, max_v, normal_input_tif = inputf.normalize(m, normal_pmin, normal_pmax)
                        batch = normal_input_tif
                        rois.append((r1, r2))
                        maxv.append(max_v)
                        minv.append(min_v)

                    # time_start = time.time()
                    image = sess.run(self.prediction3,
                                     feed_dict={self.shape: shape_in, self.input_image: batch})
                    #                    if maxv[0]>2*minv[0]:
                    #                        image = image*maxv[0]-minv[0]
                    #                    else:
                    image = image * maxv[0]
                    # image[image<0]=0
                    # print('num %d, runtime:%.6f ' % (nn,time_end-time_start))
                    for batch_index in range(len(rois)):
                        for channel in range(num_output_channels):
                            image[batch_index, ..., channel] *= block_weight1

                        r1, r2 = [roi for roi in rois[batch_index]]
                        # print(applied[r1].shape,image[batch_index][r2].shape)

                        applied[r1] += image[batch_index][r2]
                        sum_weight[r1] += block_weight[r2]

                time_process_e = time.time()
                time_process_all = time_process_all + time_process_e - time_process_s
                time_save_s = time.time()
                for channel in range(num_output_channels):
                    applied[..., channel] /= sum_weight

                if applied.shape[-1] == 1:
                    applied = applied[..., 0]

                image1 = np.array(applied)
                image1 = np.squeeze(image1)
                single = image1.astype(np.float16)
                print(single.shape)
                filenames_out =os.path.join(test_out , 'RLN_' + label_out)
                tiff.imsave(filenames_out, single)
                time_save_e = time.time()
                time_save_all = time_save_all + time_save_e - time_save_s
                time_end = time.time()
                print('num %d, runtime_all:%.6f ' % (nn, time_end - time_start))
            print('total_time: %.6f' % (time.time() - time_start_init))
            print('time_read_all: %.6f,time_crop_all: %.6f,time_process_all: %.6f,time_save_all: %.6f' % (
            time_read_all, time_crop_all, time_process_all, time_save_all))
        print('Done testing')


if __name__=="__main__":
    parser, args = parse_args()

    os.environ["CUDA_DEVICE_ORDER"] = "PCI_BUS_ID"
    os.environ["CUDA_VISIBLE_DEVICES"] = args.gpu_id

    config = tf.ConfigProto()
    config.gpu_options.per_process_gpu_memory_fraction = args.gpu_memory_limit

    path_main=args.main_dir
    if args.data_gen:
        path_in=os.path.join(args.main_dir, 'train')
        path_out=os.path.join(args.main_dir, 'train1')
        inputf.data_gen(64, 64, 64, 10, path_in, path_out)
        os.rename(path_in,os.path.join(args.main_dir, 'train_old'))
        os.rename(path_out,os.path.join(args.main_dir, 'train'))

    mode=args.mode
    net = RLNet()
    if mode == 'TR':
        net.set_up_rlnet(args.batchsizes)
        net.train(args.batchsizes,args.train_iter,args.main_dir,args.normal_pmin,args.normal_pmax)
    if mode == 'VL':
        net.set_up_rlnet(args.batchsizes)
        net.valid(args.main_dir,args.normal_pmin,args.normal_pmax)
    if mode == 'TS':
        net.set_up_rlnet(args.batchsizes)
        net.test(args.main_dir,args.normal_pmin,args.normal_pmax)
    if mode == 'TSS':
        net.set_up_rlnet(args.batchsizes)
        net.test_large(args.main_dir,args.normal_pmin,args.normal_pmax,args.crop_size)





