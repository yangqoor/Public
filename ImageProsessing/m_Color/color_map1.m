clc;
clear all;
close all
x=[0 1 1 0];  % x1x2x3x4
y=[0 0 1 1];  % y1y2y3y4   %定义四个点 [0 0] [1 0] [1 1] [0 1]
H_F=fill(x,y,[0 0.1 0.2 0.6]);  %定义四个点的C值

row_cmap = 100;  %定义色图矩阵的行数
color_map_=zeros(row_cmap,3);  %定义色图矩阵
color_r = 0:1/(row_cmap-1):1; 
color_g = 0:1/(row_cmap-1):1;
color_b = 0:1/(row_cmap-1):1;
color_map_(:,1) = color_r; 
% color_map1(:,2) = color_g;
color_map_(:,3) = color_b;
colormap(color_map_);
colorbar;

%本例中颜色从[0 0 0] 变化到[1 1 0]
%增加row_cmap的值，如变化到100，则可看到颜色的渐变，而非跳跃型变化。