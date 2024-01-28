clc;
clear all;
close all;
addpath(genpath('image'));
addpath(genpath('whyte_code'));
addpath(genpath('cho_code'));
opts.prescale = 1; %%downsampling
opts.xk_iter = 5; %% the iterations
opts.gamma_correct = 1.0;
opts.k_thresh = 20;
%% Test on 2013-08-17
% filename = 'image\test3_blur_55.png'; opts.kernel_size = 85;  saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 4e-3;%opts.gamma_correct = 2.2;
% lambda_tv = 0.001; lambda_l0 = 5e-4; weight_ring = 1;
% %% 
% filename = 'image\0015_blur65.png'; opts.kernel_size =67;  saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 4e-3;opts.gamma_correct = 2.2;
% lambda_tv = 0.001; lambda_l0 = 2e-4; weight_ring = 1;
%
%
filename = 'image\1_pattt_use.png'; opts.kernel_size = 55;   saturation = 0;
lambda_pixel = 4e-3; lambda_grad = 4e-3; opts.gamma_correct = 2.2;
lambda_tv = 0.008; lambda_l0 = 2e-3; weight_ring = 1;
%
%
% filename = 'image\dragon_patch_use.png'; opts.kernel_size = 45;  saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 4e-3;opts.gamma_correct = 2.2;
% lambda_tv = 0.003; lambda_l0 = 2e-3; weight_ring = 1;
%
% filename = 'image\new_test_img_blur.png'; opts.kernel_size = 55;  saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 4e-3;opts.gamma_correct = 2.2;
% lambda_tv = 0.001; lambda_l0 = 1e-4; weight_ring = 1;
% %%
% filename = 'image\2013622235456945_blur_79.png'; opts.kernel_size = 85;  saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 4e-3;opts.gamma_correct = 2.2;
% lambda_tv = 0.0001; lambda_l0 = 1e-4; weight_ring = 1;
%%
% filename = 'image\my_shufa_image_blur_121.png'; opts.kernel_size = 121;  saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 4e-3;opts.gamma_correct = 2.2;
% lambda_tv = 0.0002; lambda_l0 = 1e-4; weight_ring = 1;
%
% filename = 'image\new_test_img10_blur.png'; opts.kernel_size = 85; saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 4e-3;opts.gamma_correct = 2.2;
% lambda_tv = 0.0002; lambda_l0 = 1e-4;
%
%%
% filename = 'image\color_patch_blur_99.png'; opts.kernel_size = 99;  saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 4e-3;%opts.gamma_correct = 2.2;
% lambda_tv = 0.002; lambda_l0 = 2e-4; weight_ring = 1;
% %%
% filename = 'image\blurred_cho.png'; opts.kernel_size = 23;  saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 4e-3;%opts.gamma_correct = 2.2;
% lambda_tv = 0.0002; lambda_l0 = 2e-4; weight_ring = 1;

%% Natual images deblurring examples
% filename = 'image\postcard.png'; opts.kernel_size = 75;  saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 2e-3;opts.gamma_correct = 1.0;
% lambda_tv = 0.0005; lambda_l0 = 2e-3; weight_ring = 0;
% filename = 'image\boat_input.png'; opts.kernel_size = 25;  saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 4e-3;opts.gamma_correct = 1.0;
% lambda_tv = 0.001; lambda_l0 = 2e-3; weight_ring = 1;
%%
% filename = 'image\hanzi.jpg'; opts.kernel_size = 33;  saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 4e-3;opts.gamma_correct = 2.2;
% lambda_tv = 0.003; lambda_l0 = 2e-3; weight_ring = 1;
%=================================
% filename = 'image\im06_ker01_blur.png'; opts.kernel_size = 19;  saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 4e-3;%opts.gamma_correct = 2.2;
% lambda_tv = 0.001; lambda_l0 = 2e-3; weight_ring = 0;
% filename = 'image\44_1_blurred.png'; opts.kernel_size = 19;  saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 2e-3;%opts.gamma_correct = 2.2;
% lambda_tv = 0.001; lambda_l0 = 2e-3; weight_ring = 0;
%
% filename = 'image\IMG_4350_small.png'; opts.kernel_size = 55;  saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 2e-3;opts.gamma_correct = 2.2;
% lambda_tv = 0.002; lambda_l0 = 2e-3; weight_ring = 1;
%
% filename = 'image\summerhouse.jpg'; opts.kernel_size = 95;  saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 2e-3;opts.gamma_correct = 2.2;
% lambda_tv = 0.002; lambda_l0 = 2e-3; weight_ring = 0;
%
% filename = 'image\real_blur_img3.png'; opts.kernel_size = 45;  saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 2e-3;opts.gamma_correct = 2.2;
% lambda_tv = 0.002; lambda_l0 = 2e-3; weight_ring = 0;
%
% filename = 'image\real_img2.png'; opts.kernel_size = 25;  saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 2e-3;opts.gamma_correct = 2.2;
% lambda_tv = 0.002; lambda_l0 = 2e-3; weight_ring = 0;
%
% filename = 'image\text_real.bmp'; opts.kernel_size = 55;  saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 2e-3;opts.gamma_correct = 2.2;
% lambda_tv = 0.002; lambda_l0 = 2e-3; weight_ring = 1;
%
% filename = 'image\text10.jpg'; opts.kernel_size = 99;  saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 2e-3;opts.gamma_correct = 2.2;
% lambda_tv = 0.002; lambda_l0 = 2e-3; weight_ring = 1;
%
% filename = 'image\text10_patch.png'; opts.kernel_size = 99;  saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 2e-3;opts.gamma_correct = 2.2;
% lambda_tv = 0.002; lambda_l0 = 2e-3; weight_ring = 1;
% filename = 'image\0015_blur65.png'; opts.kernel_size = 67;  saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 4e-3;opts.gamma_correct = 2.2;
% lambda_tv = 0.002; lambda_l0 = 2e-3; weight_ring = 0;
% filename = 'image\IMG_0747_Gaussion.png'; opts.kernel_size = 75;  saturation = 1;
% lambda_pixel = 4e-3; lambda_grad = 2e-3;%opts.gamma_correct = 2.2;
%%
% filename = 'image\my_test_car6.png'; opts.kernel_size = 115;  saturation = 1;
% lambda_pixel = 4e-3; lambda_grad = 4e-3;opts.gamma_correct = 2.2;
% filename = 'image\8_patch_use.png'; opts.kernel_size = 135;  saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 4e-3; opts.gamma_correct = 2.2;
% lambda_tv = 0.002; lambda_l0 = 2e-4; weight_ring = 1;
% filename = 'image\image_saturation_1.png'; opts.kernel_size = 69;  saturation = 1;
% lambda_pixel = 4e-3; lambda_grad = 4e-3;opts.gamma_correct = 1.0;
% filename = 'image\my_test_car6.png'; opts.kernel_size = 135;  saturation = 1;
% lambda_pixel = 4e-3; lambda_grad = 4e-3;opts.gamma_correct = 2.2;
%%
% filename = 'image\IMG_4561.JPG'; opts.kernel_size = 135;  saturation = 1;
% lambda_pixel = 4e-3; lambda_grad = 4e-3;opts.gamma_correct = 2.2;
% filename = 'image\1_pattt_use.png'; opts.kernel_size = 55;   saturation = 0;
% lambda_pixel = 0; lambda_grad = 4e-3; opts.gamma_correct = 2.2;
% lambda_tv = 0.008; lambda_l0 = 2e-3; weight_ring = 1;
% filename = 'image\my_shufa_image_blur_121.png'; opts.kernel_size = 111;  saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 4e-3;opts.gamma_correct = 2.2;
% lambda_tv = 0.0002; lambda_l0 = 1e-4; weight_ring = 1;
% filename = 'image\cvpr14_text.png'; opts.kernel_size = 65;  saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 4e-3;opts.gamma_correct = 2.2;
% lambda_tv = 2e-3; lambda_l0 = 1e-3; weight_ring = 1;
% filename = 'image\new_test_img_blur.png'; opts.kernel_size = 55;  saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 4e-3;opts.gamma_correct = 2.2;
% lambda_tv = 0.001; lambda_l0 = 1e-4; weight_ring = 1;

% filename = 'image\cvpr14_text2.png'; opts.kernel_size = 65;  saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 4e-3;opts.gamma_correct = 2.2;
% lambda_tv = 2e-3; lambda_l0 = 1e-3; weight_ring = 1;
% filename = 'image\new_test_img_blur.png'; opts.kernel_size = 55;  saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 4e-3;opts.gamma_correct = 2.2;
% lambda_tv = 0.001; lambda_l0 = 1e-4; weight_ring = 1;
% filename = 'image\im07_ker08_blur.png'; opts.kernel_size = 35;  saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 4e-3;opts.gamma_correct = 1.0;
% lambda_tv = 2e-3; lambda_l0 = 1e-4; weight_ring = 0;
% filename = 'image\cvpr14_text5.png'; opts.kernel_size = 35;  saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 4e-3;opts.gamma_correct = 2.2;
% lambda_tv = 2e-3; lambda_l0 = 1e-3; weight_ring = 1;
%
% filename = 'image\IMG_4548_small.png'; opts.kernel_size = 35;  saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 4e-3;opts.gamma_correct = 2.2;
% lambda_tv = 2e-3; lambda_l0 = 1e-3; weight_ring = 1;
% filename = 'image\IMG_4548_small.png'; opts.kernel_size = 35;  saturation = 1;
% lambda_pixel = 4e-3; lambda_grad = 4e-3;opts.gamma_correct = 1.0;
% lambda_tv = 0.001; lambda_l0 = 5e-4; weight_ring = 1; % Gaussian filters
%y = imfilter(y,fspecial('gaussian',5,1),'same','replicate'); 
%%
% filename = 'image\las_vegas_saturated.png'; opts.kernel_size = 99;  saturation = 0;
% lambda_pixel = 4e-3; lambda_grad = 4e-3;opts.gamma_correct = 1.0;
% lambda_tv = 0.001; lambda_l0 = 5e-4; weight_ring = 1;
%===================================
y = imread(filename);
% y = imnoise(y,'salt & pepper', 0.01);
% y = y(3:end-2,3:end-2,:);
%y = imfilter(y,fspecial('gaussian',5,1),'same','replicate'); 

%% filters
filters{1} = [1, -1];
filters{2} = [1; -1];
filters{3} = [-1; 2; -1];
filters{4} = [-1, 2, -1];
filters{5} = [-1 1;1 -1];

%load weights_filters_7_4_learning_rate_0.01.mat
%load weight_filters_linux_2e_3.mat
load weight_filters_linux_4e_3_ker_0_1.mat
parameter_p = 2;

isselect = 0; %false or true
if isselect ==1
    figure, imshow(y);
    %tips = msgbox('Please choose the area for deblurring:');
    fprintf('Please choose the area for deblurring:\n');
    h = imrect;
    position = wait(h);
    close;
    B_patch = imcrop(y,position);
    y = (B_patch);
else
    y = y;
end
%eval(sprintf('load ./test_data/im%02d_ker%02d',1,4))
if size(y,3)==3
    yg = im2double(rgb2gray(y));
else
    yg = im2double(y);
end
tic;
[kernel, interim_latent] = blind_deconv(yg, lambda_grad, weights_filters, parameter_p, filters, opts);
toc
y = im2double(y);
%% Final Deblur: 
if ~saturation
    %% 1. TV-L2 denoising method
    Latent = ringing_artifacts_removal(y, kernel, lambda_tv, lambda_l0, weight_ring);
else
    %% 2. Whyte's deconvolution method (For saturated images)
    Latent = whyte_deconv(y, kernel);
end
figure; imshow(Latent)
%%
k = kernel - min(kernel(:));
k = k./max(k(:));
imwrite(k,['results\' filename(7:end-4) '_kernel.png']);
imwrite(Latent,['results\' filename(7:end-4) '_result.png']);
imwrite(interim_latent,['results\' filename(7:end-4) '_interim_result.png']);
%%

