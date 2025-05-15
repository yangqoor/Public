import caffe
import sys, os
import numpy as np
import scipy.io
from PIL import Image
from sklearn.preprocessing import LabelEncoder
import timeit

model = 'model/fcn_blur2mflow.caffemodel'
img_mean = (111.64, 113.53, 93.96)
net = caffe.Net('model/fcn_blur2mflow.prototxt', model, caffe.TEST)

le_u = LabelEncoder()
le_v = LabelEncoder()
le_u.classes_ = np.loadtxt('model/labels_u.txt')
le_v.classes_ = np.loadtxt('model/labels_v.txt')

# load image, switch to BGR, subtract mean, and make dims C x H x W for Caffe
im = Image.open(sys.argv[1])
in_ = np.array(im, dtype=np.float32)
in_ = in_[:,:,::-1]
in_ -= img_mean
in_ = in_.transpose((2,0,1))

# shape for input (data blob is N x C x H x W), set data
net.blobs['data'].reshape(1, *in_.shape)
net.blobs['data'].data[...] = in_
# run net and take argmax for prediction
net.forward()
mf1 = net.blobs['score1'].data[0].argmax(0)
mf2 = net.blobs['score2'].data[0].argmax(0)

mf1 = le_u.inverse_transform(mf1.flatten()).reshape(mf1.shape)
mf2 = le_v.inverse_transform(mf2.flatten()).reshape(mf2.shape)

mfmap = np.stack((mf1, mf2)).transpose((1, 2, 0))


scipy.io.savemat(sys.argv[2], {'mfmap': mfmap})
