clc;
clear all;
close all
x=[0 1 1 0];  % x1x2x3x4
y=[0 0 1 1];  % y1y2y3y4   %�����ĸ��� [0 0] [1 0] [1 1] [0 1]
H_F=fill(x,y,[0 0.1 0.2 0.6]);  %�����ĸ����Cֵ

row_cmap = 100;  %����ɫͼ���������
color_map_=zeros(row_cmap,3);  %����ɫͼ����
color_r = 0:1/(row_cmap-1):1; 
color_g = 0:1/(row_cmap-1):1;
color_b = 0:1/(row_cmap-1):1;
color_map_(:,1) = color_r; 
% color_map1(:,2) = color_g;
color_map_(:,3) = color_b;
colormap(color_map_);
colorbar;

%��������ɫ��[0 0 0] �仯��[1 1 0]
%����row_cmap��ֵ����仯��100����ɿ�����ɫ�Ľ��䣬������Ծ�ͱ仯��