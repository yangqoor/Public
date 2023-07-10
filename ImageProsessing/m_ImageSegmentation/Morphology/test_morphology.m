% 形态学梯度检测二值图像的边缘
clc; close all; clear
I = imread('wrod213.bmp');
figure
imshow(I);
I = ~I;                  % 腐蚀运算对灰度值为1的进行
figure, imshow(I);
SE = strel('square', 3); % 定义3×3腐蚀结构元素
J = imerode(~I, SE);
% figure, imshow(J);
BW = (~I) - J;           % 检测边缘
figure, imshow(BW);
