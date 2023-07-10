%% 
clc;
clear;
close all
%%
% I=imread('D:\My_Study\MATlab\image_processing\Image\paper\503.jpg');
% I=rgb2gray(I);


x=linspace(-2, 2, 25);
y=linspace(-2, 2, 25);
[xx, yy]=meshgrid(x, y);
zz=xx.*exp(-xx.^2 - yy.^2);
h=contour(zz, 12);
clabel(h);
[dx, dy]=gradient(zz,.2,2);
hold on;
quiver(dx, dy);

% [X,Y]=gradient(I);
% hold on;
% quiver(X,Y);
% hold off
% 
% b=gradient(double(I));
% [ax,ay]=gradient(double(I));
% imshow(b);
% hold on;
% quiver(ax,ay);
% hold off