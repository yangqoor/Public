% Example 1 of using stacked auto-encoders
clear all ; clc
load mnist_uint8
train_x = double(train_x)/255;
test_x = double(test_x)/255;
train_y = double(train_y);
test_y = double(test_y);

% setting options for MNIST dataset
opts.epsilon_w = 0.1;
opts.epsilon_vb = 0.1;
opts.epsilon_vc = 0.1;
opts.momentum = 0.5;
opts.weightcost = 0.0002;
opts.numepochs = 10;
opts.sizes = [1000 500 250 30];
opts.batch_size = 100;

% creating the stacked auto-encoder
st = stacked_autoencoder(train_x,opts,false);

% test the samples 
[test_x_out,a_test_out,err_sum] = sae_test(st,test_x,opts,false);

