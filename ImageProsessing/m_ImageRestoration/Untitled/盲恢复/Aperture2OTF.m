function [OTF,PSF] = Aperture2OTF(im)
%-----------------------------------
% 从孔径函数转换为OTF
% clc;clear;close all;
% f=imread('aperture512_16.tif');
im=im2double(im);  %转换成双精度型
%-------------------------------------
% %因为OTF是孔径函数的归一化自相关函数，而自相关函数与功率谱互为FT变换
% ff=fft2(im);   
% ff=abs(ff).^2;         %求功率谱
% %计算OTF
% fff=fft2(ff);         %求反FT变换
% 
% ff_max=max(fff(:));    %归一化处理
% OTF=fff/ff_max;
% %   计算PSF
% PSF=ifft2(OTF);
% PSF=IMRA(PSF);
%因为OTF是孔径函数的归一化自相关函数，而自相关函数与功率谱互为FT变换
ff=fft2(im);   
ff=abs(ff).^2;         %求功率谱
fff=ifft2(ff);         %求反FT变换
fff=IMRA(fff);
ff_max=max(fff(:));    %归一化处理
OTF=fff/ff_max;
PSF=ifft2(OTF);
PSF=IMRA(PSF);
%---------------------------------------------------
%T2=abs(fftshift(OTF));
%figure,imshow(log(1+T2),[]);
%figure,mesh(T2(1:5:end,1:5:end));title('OTF立体视图');
%figure,plot(T2((floor(size(OTF,1)/2)+1),:));title('过OTF中心的截面视图');
%---------------------------------------------------