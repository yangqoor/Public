clc;
clear
image=rgb2gray(imread('E:\MATLAB\Airbus6.jpg'));
Fcrs=coarseness(image,5);%计算粗糙度
Fcon=contrast(image);  %计算对比度
[Fdir,sita]=directionality(image);%计算方向度
Flin=linelikeness(image,sita,4);%计算线性度
Freg=regularity(image,64);%计算规则度
Frgh=Fcrs+Fcon;%计算粗糙度
