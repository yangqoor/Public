close all
clear
clc

%% 参数设置
% 迭代次数
IterMax = 15;
% 松弛因子 必须大于0(拉格朗日乘数)
lambda = 0.03;  
imageName = 'lena_gray_512.tif';

%% 读图
srcImage = imread(imageName);
srcImage = im2double(srcImage);

%% 添加高斯噪声
image_noise = imnoise(srcImage, 'gaussian', 0, 0.01);

%% TV算法
dstImage = total_variation(image_noise,IterMax,lambda);

%% 图像显示
figure;
subplot(1,2,1);imagesc(image_noise);axis image; axis off; colormap(gray);title('噪声图像');   
subplot(1,2,2);imagesc(dstImage);axis image; axis off; colormap(gray);title('全变差去噪图像'); 

%% 图像评价指标
PSNR = psnr(srcImage,dstImage)
SSIM = ssim(srcImage,dstImage)
