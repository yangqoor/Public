%灰度图变彩色图(耗时长！)

clc,clear all
figure
subplot(2,2,1)
imshow('gray_face.jpg');
subplot(2,2,2)
imshow('F:\\520.jpg');
% 首先函数将灰度图像扩展到三通道（复制通道），然后将两张图像转为yCbCr空间。
%最后，通过一个二重循环来逐像素生成结果图。
colorIm = gray2rgb('gray_face.jpg','F:\\520.jpg');
subplot(2,2,3.5)
imshow(colorIm)
