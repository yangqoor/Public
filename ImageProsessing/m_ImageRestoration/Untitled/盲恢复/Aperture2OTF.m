function [OTF,PSF] = Aperture2OTF(im)
%-----------------------------------
% �ӿ׾�����ת��ΪOTF
% clc;clear;close all;
% f=imread('aperture512_16.tif');
im=im2double(im);  %ת����˫������
%-------------------------------------
% %��ΪOTF�ǿ׾������Ĺ�һ������غ�����������غ����빦���׻�ΪFT�任
% ff=fft2(im);   
% ff=abs(ff).^2;         %������
% %����OTF
% fff=fft2(ff);         %��FT�任
% 
% ff_max=max(fff(:));    %��һ������
% OTF=fff/ff_max;
% %   ����PSF
% PSF=ifft2(OTF);
% PSF=IMRA(PSF);
%��ΪOTF�ǿ׾������Ĺ�һ������غ�����������غ����빦���׻�ΪFT�任
ff=fft2(im);   
ff=abs(ff).^2;         %������
fff=ifft2(ff);         %��FT�任
fff=IMRA(fff);
ff_max=max(fff(:));    %��һ������
OTF=fff/ff_max;
PSF=ifft2(OTF);
PSF=IMRA(PSF);
%---------------------------------------------------
%T2=abs(fftshift(OTF));
%figure,imshow(log(1+T2),[]);
%figure,mesh(T2(1:5:end,1:5:end));title('OTF������ͼ');
%figure,plot(T2((floor(size(OTF,1)/2)+1),:));title('��OTF���ĵĽ�����ͼ');
%---------------------------------------------------