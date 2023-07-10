%调用举例：  
%image=rgb2gray(imread('example.jpg'));  
%[Fdir,sita]=directionality(image)  
  
%sita为各像素点的角度矩阵，在线性度中会用到，所以这里作为结果返回  
function [Fdir,sita]=directionality(graypic)  
[h, w]=size(graypic);  
%两个方向的卷积矩阵  
GradientH=[-1 0 1;-1 0 1;-1 0 1];  
GradientV=[ 1 1 1;0 0 0;-1 -1 -1];  
%卷积，取有效结果矩阵  
MHconv=conv2(graypic,GradientH);  
MH=MHconv(3:h,3:w);  
MVconv=conv2(graypic,GradientV);  
MV=MVconv(3:h,3:w);  
%向量模  
MG=(abs(MH)+abs(MV))./2;  
%有效矩阵大小  
validH=h-2;  
validW=w-2;  
%各像素点的方向  
for i=1:validH  
    for j=1:validW  
        sita(i,j)=atan(MV(i,j)/MH(i,j))+(pi/2);  
    end  
end  
n=16;  
t=12;  
Nsita=zeros(1,n);  
%构造方向的统计直方图  
for i=1:validH  
    for j=1:validW  
        for k=1:n  
            if sita(i,j)>=(2*(k-1)*pi/2/n) && sita(i,j)<((2*(k-1)+1)*pi/2/n) && MG(i,j)>=t  
                Nsita(k)=Nsita(k)+1;  
            end  
        end  
    end  
end  
for k=1:n  
    HD(k)=Nsita(k)/sum(Nsita(:));  
end  
%假设每幅图片只有一个方向峰值，为计算方便简化了原著  
[~,FIp]=max(HD);  
Fdir=0;  
for k=1:n  
    Fdir=Fdir+(k-FIp)^2*HD(k);%公式与原著有改动  
end  
end  
