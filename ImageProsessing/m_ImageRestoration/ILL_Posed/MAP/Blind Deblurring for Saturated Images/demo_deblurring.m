clc;
clear;
close all;
addpath(genpath('main_code'));
opts.display = 1; %%%display intermediate results
%%

% filename = '.\image\k1.png'; opts.kernel_size = 135; 
% lambda_grad = 8e-3; opts.gamma_correct = 1.0; opts.final_grad = 0.01;

% filename = '.\image\dark_water.png'; opts.kernel_size = 25;  
% lambda_grad = 8e-3; opts.gamma_correct = 1.5; opts.final_grad = 0.001;

% filename = '.\image\IMG_0141_small.jpg'; opts.kernel_size = 75;  
% lambda_grad = 8e-3; opts.gamma_correct = 1.0; opts.final_grad = 0.004;

% filename = '.\image\car.png'; opts.kernel_size = 135;  
% lambda_grad = 8e-3; opts.gamma_correct = 2.2; opts.final_grad = 0.001;

% filename = '.\image\3.png'; opts.kernel_size = 65;  
% lambda_grad = 8e-3; opts.gamma_correct = 2.2; opts.final_grad = 0.01;

% filename = '.\image\street.jpg'; opts.kernel_size = 55;  
% lambda_grad = 8e-3; opts.gamma_correct = 2.2; opts.final_grad = 0.003;

% filename = '.\image\car4.jpg'; opts.kernel_size = 135;  
% lambda_grad = 8e-3; opts.gamma_correct = 2.2; opts.final_grad = 0.003;

% filename = '.\image\IMG_0650_small_patch.png'; opts.kernel_size = 95;  
% lambda_grad = 8e-3; opts.gamma_correct = 1.5; opts.final_grad = 0.003;

% filename = '.\image\IMG_0664_small_patch.png'; opts.kernel_size = 95;  
% lambda_grad = 8e-3; opts.gamma_correct = 1.5; opts.final_grad = 0.003;

% filename = '.\image\IMG_0747_patch.png'; opts.kernel_size = 75;  
% lambda_grad = 8e-3; opts.gamma_correct = 2.2; opts.final_grad = 0.003;

% filename = '.\image\IMG_4561.jpg'; opts.kernel_size = 95;  
% lambda_grad = 8e-3; opts.gamma_correct = 1.0; opts.final_grad = 0.003;

filename = '.\image\9.jpg'; opts.kernel_size = 75;  
lambda_grad = 8e-3; opts.gamma_correct = 1.5; opts.final_grad = 0.003;

%%
%===================================
y = imread(filename);
tic;
[Latent, kernel, interim_latent] = blind_deconv(y, lambda_grad, opts);
toc
figure; imshow(Latent)
%% save results
mkdir('./results');
k = kernel - min(kernel(:));
k = k./max(k(:));
imwrite(k,'./results/kernel.png');
imwrite(Latent,'./results/image.png');

