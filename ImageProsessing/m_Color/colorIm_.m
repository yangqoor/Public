%�Ҷ�ͼ���ɫͼ(��ʱ����)

clc,clear all
figure
subplot(2,2,1)
imshow('gray_face.jpg');
subplot(2,2,2)
imshow('F:\\520.jpg');
% ���Ⱥ������Ҷ�ͼ����չ����ͨ��������ͨ������Ȼ������ͼ��תΪyCbCr�ռ䡣
%���ͨ��һ������ѭ�������������ɽ��ͼ��
colorIm = gray2rgb('gray_face.jpg','F:\\520.jpg');
subplot(2,2,3.5)
imshow(colorIm)
