clc;
clear;
close all;
addpath(genpath('image'));
addpath(genpath('whyte_code'));
addpath(genpath('cho_code'));
opts.prescale = 1; % %downsampling
opts.xk_iter = 5; % % the iterations
opts.gamma_correct = 1.0;
opts.k_thresh = 20;
opts.theta = 1;
%% Note:
%% lambda_tv, lambda_l0, weight_ring are non-necessary, they are not used in kernel estimation.
%%
filename = './image/real_blur_img3.png'; opts.kernel_size = 35; saturation = 1;
lambda_data = 4e-3; lambda_grad = 4e-3; opts.gamma_correct = 1;
lambda_tv = 0.002; lambda_l0 = 2e-4;
%%
y = imread(filename);

if size(y, 3) == 3
    yg = im2double(rgb2gray(y));
else
    yg = im2double(y);
end

tic;
[kernel, interim_latent] = blind_deconv(yg, lambda_data, lambda_grad, opts);
toc
%% Algorithm is done!
%% ============Non-blind deconvolution ((Just use text deblurring methods))====================%%
y = im2double(y);
%% Final Deblur:
if ~saturation
    %% 1. TV-L2 denoising method
    Latent = deconv_outlier(y, kernel, 5/255, 0.003);
    %     Latent = deconv_RL_sat(y,kernel);
else
    %% 2. Whyte's deconvolution method (For saturated images)
    Latent = ringing_artifacts_removal(y, kernel, lambda_tv, lambda_l0, 1);
    %     Latent = whyte_deconv(y, kernel);
end

figure; imshow(Latent);
%%
k = kernel - min(kernel(:));
k = k ./ max(k(:));
imwrite(Latent, 'enhance.png');
imwrite(k, 'enhance_kernel.png');
