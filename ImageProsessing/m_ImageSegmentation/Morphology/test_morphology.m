% ��̬ѧ�ݶȼ���ֵͼ��ı�Ե
clc; close all; clear
I = imread('wrod213.bmp');
figure
imshow(I);
I = ~I;                  % ��ʴ����ԻҶ�ֵΪ1�Ľ���
figure, imshow(I);
SE = strel('square', 3); % ����3��3��ʴ�ṹԪ��
J = imerode(~I, SE);
% figure, imshow(J);
BW = (~I) - J;           % ����Ե
figure, imshow(BW);
