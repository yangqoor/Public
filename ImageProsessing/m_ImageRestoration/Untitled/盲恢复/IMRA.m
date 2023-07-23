function f=IMRA(im)
% IMRA实现去除虚部，使用实部为正的操作
% im为输入图像
% f为输出图像
f=real(im);  %取实部
I=find(f<0); %查找小于零的坐标位置
f(I)=0;      %小于零的坐标位置置零