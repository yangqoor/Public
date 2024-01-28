% % install and compile MatConvNet (needed once)
% untar('http://www.vlfeat.org/matconvnet/download/matconvnet-1.0-beta18.tar.gz') ;
% cd matconvnet-1.0-beta18
% run matlab/vl_compilenn

% % download a pre-trained CNN from the web (needed once)
% urlwrite(...
%   'http://www.vlfeat.org/matconvnet/models/imagenet-vgg-f.mat', ...
%   'imagenet-vgg-f.mat') ;
% 
% % setup MatConvNet
% run  matlab/vl_setupnn

% load the pre-trained CNN
net = load('imagenet-vgg-f.mat') ;

% load and preprocess an image
im = imread('peppers.png') ;
im_ = single(im) ; % note: 0-255 range
im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
im_ = im_ - net.meta.normalization.averageImage ;

% run the CNN
res = vl_simplenn(net, im_) ;

% show the classification result
scores = squeeze(gather(res(end).x)) ;
[bestScore, best] = max(scores) ;
figure(1) ; clf ; imagesc(im) ;
title(sprintf('%s (%d), score %.3f',...
net.meta.classes.description{best}, best, bestScore)) ;