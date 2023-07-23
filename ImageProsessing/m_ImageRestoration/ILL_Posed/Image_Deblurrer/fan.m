clear all; close all;clc;
%% ����ϲ�ͼ��
f_color=imread('mowagner.jpg');  %����һ������ϲ�ͼ��
f=rgb2gray(f_color);    %ת�ɻҶ�ͼ
figure(3); imshow(f); xlabel('ԭʼͼ��');
[hang,lie]=size(f);
%% ����չ����PSF
PSF=fspecial('gaussian',7,10);   %����һ��Ԥ�ȶ���Ķ�ά������psf
%Blurred=imfilter(I,PSF,'symmetric','conv');  %��ͼ��I���и�˹�˲�������ʱ�ÿ��ٸ���Ҷ������д�����imfilter����  
h=PSF;
%h=[4.05 4.57 6.73 10.01;5.26 3.91 4.59 6.87;8.05 5.29 3.82 4.68;11.13 8.08 5.06 3.67 ];%hΪ����չ����

%a=255*ones(4,4);

%�������
F=fft2(f);
H_180=fft2(rot90(h, 2), hang, lie);  %�������.�ɸ���Ҷ�����ʽg=f*h����G=F��H���ø���Ҷ���پ������fft����ʵ��
g_complex=ifft2(F.*H_180);
g_d=real(g_complex);
g=mat2gray(g_d);   %��ͨ��ͼ��g_d����ת���ɱ�׼�ĻҶ�ͼ��
%���ͼ��
  figure(1);
  subplot(121);
  imshow(f);
  xlabel('�ϲ�ԭʼ�Ҷȷֲ�');
  figure(1);
  subplot(122);
  imshow(g);
  xlabel('��������ͼ��');
%  figure(2);
%  imshow(h);
%  xlabel('����չ����');
%�������������
g_reverse=g;  %�����ĵ�������Ǿ����ĻҶȷֲ�ͼ
G_reverse=fft2(g_reverse);
h_inv=inv(h);
H_180_inv=fft2(rot90(h, 2), hang,lie);
F_reverse=G_reverse.*H_180_inv;
f_reverse=real(ifft(F_reverse));    %����������Լ�Ϲ��ģ���������̷������㣬���ֲ��У�MATLAB���Դ��ķ��������û������ͼ�񷴾����
%���ͼ��
  figure(2);
  subplot(121);
  imshow(g_reverse);
  xlabel('�����Ҷȷֲ�ͼ');
  figure(2);
  subplot(122);
  imshow(f_reverse);
  xlabel('�������ϲ�ͼ��');
  


