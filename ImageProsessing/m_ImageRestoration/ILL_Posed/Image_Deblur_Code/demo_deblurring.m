close all;
clear all;
clc;

addpath(genpath('image'));
addpath(genpath('images'));
addpath(genpath('whyte_code'));
addpath(genpath('cho_code'));

opts.prescale = 1;%downsampling
opts.xk_iter = 40;%the maximum number of iterations
opts.k_thresh = 20;
opts.iter_lambda = 8e-3;%the parameter of the iteration of latent image estimation
opts.ks = 0.20;%the parameter of kernel selection

lambda_tv = 0.001; 
lambda_l0 = 5e-4; 
weight_ring = 1;

% filename = 'image\real_blur_img3.png';
% filename = 'image\toy.png';
% filename = 'image\wall.png';
% filename = 'image\las_vegas_saturated.png';
% filename = 'image\image_saturation_1.png';
% filename = 'image\postcard.png';
% filename = 'image\7_patch_use.png';
% filename = 'image\8_patch_use.png';
filename = 'image\IMG_0664_small_patch.png';
% filename = 'image\IMG_0650_small_patch.png';
% filename = 'image\blurry_7.png';
% filename = 'image\my_test_car6.png';
% filename = 'image\Blurry1_10.png';
% filename = 'image\Blurry2_8.png';
%filename = 'image\Blurry3_7.png';
% filename = 'image\Blurry4_2.png';

y = imread(filename);
yd = im2double(y);
yg = im2double(rgb2gray(y)); 

[Kernel opts] = estimate_Kernel(yg,opts);
[kurt opts.lambda_grad_min opts.saturation] = para(yg);%kurtosis of image, minimum image gradient, flag of saturation

tic;
[kernel, interim_latent] = deblurring_main(yg, opts,Kernel,kurt);%estimation the blur kernel and latent image
toc;
figure(1); imshow(kernel,[]);
figure('NumberTitle', 'off', 'Name', 'Latent image'); imshow(interim_latent,[]); %wang

if(opts.saturation == 0)
    if( kurt >= 4 )
        lambda_tv = 0.02; 
        lambda_l0 = 2e-3; 
    end
    Latent = ringing_artifacts_removal(yd, kernel, lambda_tv, lambda_l0, weight_ring);%deconvolution
else
    Latent = whyte_deconv(yd, kernel);
end
figure('NumberTitle', 'off', 'Name', 'Deblur result'); imshow(Latent);%wang
figure('NumberTitle', 'off', 'Name', 'Blurred image'); imshow(y);%wang
k = kernel - min(kernel(:));
k = k./max(k(:));
% kernelf=rot90(kernel,2);
% y_color = double(y)/255;
% deblur = [];
% for cc = 1:size(y_color,3)
%     deblur(:,:,cc)=deconvSps(y_color(:,:,cc),kernelf,0.0068,100);
% end
imwrite(k,['results\' filename(7:end-4) '_kernel.png']);
imwrite(Latent,['results\' filename(7:end-4) '_result.png']);
% imwrite(deblur,['results\' filename(7:end-4) '_result68.png']);
imwrite(interim_latent,['results\' filename(7:end-4) '_interim_result.png']);