addpath(genpath('/home/jian/DownloadCodes/matconvnet-1.0-beta16/'));

% set the image to be deblurred
%impath = ['/home/jian/Projects/BlurMotionEsti_NN/Examples/nudge3.png'];
impath = ['./Examples/ex_labeExt_img.png'];
im = imread(impath);
%im = imresize(im, 0.5);

%load ../blurryExamples/video.mat
%im = mov(10).cdata;
%im = imresize(im, 0.6);

figure,imshow(uint8(im))

% load kernel parameters
load('kernels.mat');
num_blurs = length(kernels);

% set parameters
params.alpha = 1/2;
params.mu = 0;
params.maxIter_out = 1;
params.maxIter_in = 5;
params.useGPU = 1;

% call the main function for deblur
nTopNN = 20;
load('net-epoch-600.mat');
net.layers{end}.type = 'softmax' ;

if params.useGPU 
    net = vl_simplenn_move(net, 'gpu') ;
end
[mlhmag, mlhori, res] = Deblur_CNN_motion(im, net, kernels, kernel_labels, nTopNN, params);

% visualize the results
