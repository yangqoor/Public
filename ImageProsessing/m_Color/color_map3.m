% 函数功能：将灰度图像转化为伪彩色图像
close all;clear;clc;
%先得到要处理的原始灰度图像，将其替换为自己所研究的课题的图片
load('C:\Users\Administrator\Desktop\数据库\乳腺数据\ICYL.mat');
im= ICYL(3,:,:);
im=reshape(im,[1000 600]);
imo=im;
figure
imshow(imo, 'DisplayRange',[]);
title('原始图像')
 
%使用matlab已有的色图图得到伪彩色图像
%参考博文：http://blog.csdn.net/steelbasalt/article/details/49799869
figure
subplot(1,3,1)
imshow(im, 'DisplayRange',[]);
colormap jet 
map=colormap('jet');
colorbar;%显示色度条
 
%以下自定义色度图
% n=size(unique(reshape(im,size(im,1)*size(im,2),size(im,3))),1);%色度级等于灰度级
n=max(im(:));%将色度级定义为最大的灰度值
map1=colormap(jet(n));
res1=grs2rgb(im,map1);
subplot(1,3,2)
imshow(res1, 'DisplayRange',[]);
colorbar
 
map2=colormap(jet(256));
res2=grs2rgb(im,map2);
subplot(1,3,3)
imshow(res2, 'DisplayRange',[]);
colorbar