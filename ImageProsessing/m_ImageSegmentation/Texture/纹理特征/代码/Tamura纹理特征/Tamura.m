clc;
clear
image=rgb2gray(imread('E:\MATLAB\Airbus6.jpg'));
Fcrs=coarseness(image,5);%����ֲڶ�
Fcon=contrast(image);  %����Աȶ�
[Fdir,sita]=directionality(image);%���㷽���
Flin=linelikeness(image,sita,4);%�������Զ�
Freg=regularity(image,64);%��������
Frgh=Fcrs+Fcon;%����ֲڶ�
