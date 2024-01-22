%% If any of these codes are helpful, please cite the paper
% @inproceedings{chen2020oid,
%   author    = {Liang Chen and Faming Fang and Jiawei Zhang and Jun Liu and Guixu Zhang},
%   title     = {{OID:} Outlier Identifying and Discarding in Blind Image Deblurring},
%   booktitle = {{ECCV} 2020},
%   year      = {2020}
% }

clc;
clear;
close all;
addpath(genpath('image'));
addpath(genpath('main_code'));
opts.prescale = 0; %%downsampling
opts.xk_iter = 4; %% the iterations
opts.last_iter = 4; %% larger if image is very noisy
opts.k_thresh = 20;

opts.isnoisy = 1; %% filter the input for coarser scales before deblurring 0 or 1
opts.kernel_size = 27;  %% kernel size
opts.predeblur = 'L0';  %% deblurring method for coarser scales; Lp or L0
filename = './example.png'; 
lambda_grad = 4e-3; %% range(1e-3 - 2e-2)
opts.gamma_correct = 1.0; %% range (1.0-2.2)

y = imread(filename);
if size(y,3)==3
    yg = im2double(rgb2gray(y));
else
    yg = im2double(y);
end
tic;
[kernel, interim_latent] = blind_deconv(yg, lambda_grad, opts);
toc
%% Algorithm is done!
y = im2double(y);
Latent = image_estimate(y, kernel, 0.003,0);
figure; imshow(Latent)
%%
k = kernel - min(kernel(:));
k = k./max(k(:));
imwrite(k,'./kernel.png');
imwrite(Latent,'./result.png');