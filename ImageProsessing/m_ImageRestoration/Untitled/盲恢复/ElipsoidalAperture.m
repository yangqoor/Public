function [f] = ElipsoidalAperture(M,N,axisx,axisy)
%其实就是产生一个圆孔径函数
%ElipsoidalAperture 产生一个椭圆孔径图像
% M为图像垂直像素数，N为图像水平像素数
% axisx为椭圆水平轴像素数，axisy为椭圆垂像素数
% 可以有两种方式产生，一种是用FOR语句，一种是用MESHGRID向量化产生
% 如果开始不分配内存，FOR语句要比MESHGRD用时多的多，
% 但是如果开始分配内存，FOR语句和MESHGRID差不多，略微少些。
% close all;clc;clear;
%----------------------------------
% 初始值
% M=512;
% N=512;
% axisx=80;
% axisy=32;
%---------------------------------
f=zeros(M,N);
% 增强判断是否超过了一半像素(可用可不用）
% if(axisx>=M/2)
%     axisx=M/2;
% end
% if(axisy>=N/2)
%     axisy=N/2;
% end
%-----------------------------------
halfrow=ceil(M/2); % 确定创建图像的X轴中心点
halfcol=ceil(N/2); % 确定创建图像的Y轴中心点
% halfrow=M/2;
% halfcol=N/2;
%-------------------------------------------------------------------------
% 用FOR语句产生的椭圆
% tic;
% for i=1:1:N
%     for j=1:1:M
%         flxcen=i-halfcol;
%         flycen=j-halfrow;
%         flradius=(flxcen*flxcen)/(axisy*axisy)+(flycen*flycen)/(axisx*axisx);
%         if flradius<1
%             f(i,j)=1;
%         else
%             f(i,j)=0;
%         end
%     end
% end
% y=toc;
%-----------------------------------------------------------------------
% 用矩阵方法产生的快速椭圆方法
% f=fftshift(lpfilter('ideal',63,63,32));
% tic;
[U,V]=meshgrid(1:M,1:N);%产生一网格坐标便于矩阵运算
U=U-halfrow;            %确定图像中每个像素的X轴相对位置
V=V-halfcol;            %确定图像中每个像素的Y轴相对位置
D=U.^2/axisx.^2+V.^2/axisy.^2;%确定图像中每个像素的相对半径
f=D<1;
f=im2double(f);
% x=toc;    
%------------------------------------------------------------------------
% y=x-y;
% imshow(ff);
%figure,imshow(f);
%figure,mesh(f(1:5:end,1:5:end));