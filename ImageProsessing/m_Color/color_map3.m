% �������ܣ����Ҷ�ͼ��ת��Ϊα��ɫͼ��
close all;clear;clc;
%�ȵõ�Ҫ�����ԭʼ�Ҷ�ͼ�񣬽����滻Ϊ�Լ����о��Ŀ����ͼƬ
load('C:\Users\Administrator\Desktop\���ݿ�\��������\ICYL.mat');
im= ICYL(3,:,:);
im=reshape(im,[1000 600]);
imo=im;
figure
imshow(imo, 'DisplayRange',[]);
title('ԭʼͼ��')
 
%ʹ��matlab���е�ɫͼͼ�õ�α��ɫͼ��
%�ο����ģ�http://blog.csdn.net/steelbasalt/article/details/49799869
figure
subplot(1,3,1)
imshow(im, 'DisplayRange',[]);
colormap jet 
map=colormap('jet');
colorbar;%��ʾɫ����
 
%�����Զ���ɫ��ͼ
% n=size(unique(reshape(im,size(im,1)*size(im,2),size(im,3))),1);%ɫ�ȼ����ڻҶȼ�
n=max(im(:));%��ɫ�ȼ�����Ϊ���ĻҶ�ֵ
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