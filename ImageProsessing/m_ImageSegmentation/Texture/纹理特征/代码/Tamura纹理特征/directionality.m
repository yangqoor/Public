%���þ�����  
%image=rgb2gray(imread('example.jpg'));  
%[Fdir,sita]=directionality(image)  
  
%sitaΪ�����ص�ĽǶȾ��������Զ��л��õ�������������Ϊ�������  
function [Fdir,sita]=directionality(graypic)  
[h, w]=size(graypic);  
%��������ľ������  
GradientH=[-1 0 1;-1 0 1;-1 0 1];  
GradientV=[ 1 1 1;0 0 0;-1 -1 -1];  
%�����ȡ��Ч�������  
MHconv=conv2(graypic,GradientH);  
MH=MHconv(3:h,3:w);  
MVconv=conv2(graypic,GradientV);  
MV=MVconv(3:h,3:w);  
%����ģ  
MG=(abs(MH)+abs(MV))./2;  
%��Ч�����С  
validH=h-2;  
validW=w-2;  
%�����ص�ķ���  
for i=1:validH  
    for j=1:validW  
        sita(i,j)=atan(MV(i,j)/MH(i,j))+(pi/2);  
    end  
end  
n=16;  
t=12;  
Nsita=zeros(1,n);  
%���췽���ͳ��ֱ��ͼ  
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
%����ÿ��ͼƬֻ��һ�������ֵ��Ϊ���㷽�����ԭ��  
[~,FIp]=max(HD);  
Fdir=0;  
for k=1:n  
    Fdir=Fdir+(k-FIp)^2*HD(k);%��ʽ��ԭ���иĶ�  
end  
end  
