clc;
clear;
close all;
addpath(genpath('cho_final_deconv'));
addpath(genpath('hu_final_deconv'));
addpath(genpath('whyte_final_deconv'));

addpath(genpath('images'));
addpath(genpath('utils'));

%% ==Required input parameters for each example== %%
% maximum number of I/k alternations at each level (4 by defalut); 
opts.Ik_iter = 4;
% display the intermdiate results at each iteration (1/0)
opts.display = 1;

%% revised
dirname = 'images/results/';

filename = 'my_test_car6.png';
opts.kernel_size = 85;
opts.lambda_grad = 0.008; 
opts.k_reg_wt = 0.1;
opts.gamma_correct = 1.0;
opts.sigma = 5/255;

% filename = 'IMG_16082016_085203.png';
% opts.kernel_size = 45;
% opts.lambda_grad = 0.008;% 
% opts.k_reg_wt = 0.1;
% opts.gamma_correct = 1.0;%
% opts.sigma = 5/255;

% filename = '1102019.png';
% opts.kernel_size = 39;
% opts.lambda_grad = 0.008;% 
% opts.k_reg_wt = 0.1;
% opts.gamma_correct = 1.0;% or 2.2;
% opts.sigma = 5/255;

yg = imread(filename);
yg = im2double(yg);
y = yg;

[kernel, latent,weight_k,weight_x] = blind_deconv_main_ours(y, opts);
latent_outname = [dirname filename(1:end-4) '_interim.png'];

% cho_final_deconv: handling outliers
sigma = 5/255;%
reg_str = 0.003;%
Latent = deconv_outlier(y, kernel, sigma, reg_str);
img_outname=[dirname filename(1:end-4) '_deblur_cho.png'];

% hu_final_deconv: 
Latent1 = deconv_RL_sat(y,kernel,0.01);
img_outname1=[dirname filename(1:end-4) '_deblur_hu.png'];

% whyte_final_deconv
Latent2 = whyte_deconv(y, kernel);
img_outname2=[dirname filename(1:end-4) '_deblur_whyte.png'];

ker_outname=[dirname filename(1:end-4) '_kernel_ours.png'];
k = kernel - min(kernel(:));
k = k./max(k(:));
imwrite(k,ker_outname)
imwrite(latent,latent_outname)
imwrite(Latent,img_outname)
imwrite(Latent1,img_outname1)
imwrite(Latent2,img_outname2)



