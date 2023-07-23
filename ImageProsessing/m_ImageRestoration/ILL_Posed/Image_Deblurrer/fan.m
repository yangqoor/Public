clear all; close all;clc;
%% 读入断层图像
f_color=imread('mowagner.jpg');  %读入一个火焰断层图像
f=rgb2gray(f_color);    %转成灰度图
figure(3); imshow(f); xlabel('原始图像');
[hang,lie]=size(f);
%% 点扩展函数PSF
PSF=fspecial('gaussian',7,10);   %创建一个预先定义的二维过滤器psf
%Blurred=imfilter(I,PSF,'symmetric','conv');  %对图像I进行高斯滤波处理；此时用快速傅里叶卷积进行处理不用imfilter函数  
h=PSF;
%h=[4.05 4.57 6.73 10.01;5.26 3.91 4.59 6.87;8.05 5.29 3.82 4.68;11.13 8.08 5.06 3.67 ];%h为点扩展函数

%a=255*ones(4,4);

%卷积过程
F=fft2(f);
H_180=fft2(rot90(h, 2), hang, lie);  %卷积过程.由傅里叶卷积公式g=f*h，则G=F。H，用傅里叶快速卷积函数fft（）实现
g_complex=ifft2(F.*H_180);
g_d=real(g_complex);
g=mat2gray(g_d);   %单通道图像g_d将其转化成标准的灰度图。
%输出图像
  figure(1);
  subplot(121);
  imshow(f);
  xlabel('断层原始灰度分布');
  figure(1);
  subplot(122);
  imshow(g);
  xlabel('卷积后叠加图像');
%  figure(2);
%  imshow(h);
%  xlabel('点扩展函数');
%反卷积过程如下
g_reverse=g;  %卷积后的叠加像就是卷积后的灰度分布图
G_reverse=fft2(g_reverse);
h_inv=inv(h);
H_180_inv=fft2(rot90(h, 2), hang,lie);
F_reverse=G_reverse.*H_180_inv;
f_reverse=real(ifft(F_reverse));    %反卷积过程自己瞎编的，将卷积过程反向运算，发现不行，MATLAB中自带的反卷积函数没法进行图像反卷积，
%输出图像
  figure(2);
  subplot(121);
  imshow(g_reverse);
  xlabel('卷积后灰度分布图');
  figure(2);
  subplot(122);
  imshow(f_reverse);
  xlabel('反卷积后断层图像');
  


