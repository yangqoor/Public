clc;
clear all;
img = imread('微信图片_20191227124400.jpg'); % 读取图像
figure;
imshow(img);
title('原始图像');
img_gray = rgb2gray(img); % 转换成灰度图
figure;
imshow(img_gray);
title('灰度图像');
[m,n] = size(img_gray); % 得到图像的大小
new_img_gray = img_gray; % 新建一个一样大的图像 
pxValue = 0; % roberts计算所得到的像素值 
% 对边界象素操作 
threshold_value=30;     
    for i=1:m-1        
        for j=1:n-1          
            pxValue = abs(img_gray(i,j)-img_gray(i+1,j+1))+...  
                abs(img_gray(i+1,j)-img_gray(i,j+1));      
            if(pxValue > threshold_value)      
                new_img_gray(i,j) = 0;          
            else
                new_img_gray(i,j) =255;      
            end
        end
    end
    figure;
    imshow(new_img_gray);  
    title('roberts边缘检测图像');