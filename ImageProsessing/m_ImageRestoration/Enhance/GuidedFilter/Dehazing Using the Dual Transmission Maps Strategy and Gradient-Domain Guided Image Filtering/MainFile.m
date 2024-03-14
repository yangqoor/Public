clear; close all; clc

% Reading the image
[file,absPath]=uigetfile('*.tif;*.bmp;*.png;*.jpeg;*.jpg;*.gif','File Image');
image_path = [absPath, file];
img = imread(image_path);

figure;
imshow(img,[]);
title('Original Image');

%Peforming Normalization
[img_gray, img_color] = Normalization(img);

% Dark Channel Computation
w1 = 15;
img_dark = dark_channel_computation(img_color, w1);

% Atmospheric Light Estimation
Atmospheric_light = atmospheric_light_estimation(img_color, img_dark);

omega = 0.95;
w_small = 3;
w_large = 15;
% Dual Transmission Map Estimation
[t1, t2] = dual_transmission_map_estimation(img_color, Atmospheric_light,...
    w_small, w_large, omega);

% Fusing both transmission map
alpha=0.85;
transmission_map = transmission_map_fusion(t1, t2, alpha);

% Applying Gradient Domain Guided Image Filtering on the transmission map
% to further refine it.

% Gridient Doman Guided Filter
r=3;
refined_trans_map = gdgif(img_gray,transmission_map , r, 0.1);

% Restoring the haze-free image
restored_img = Recover_Image(img_color,refined_trans_map,Atmospheric_light);
figure; imshow(restored_img); title('Recovered Haze Free Image')
