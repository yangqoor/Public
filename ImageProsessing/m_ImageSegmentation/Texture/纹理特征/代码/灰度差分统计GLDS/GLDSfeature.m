function [ feature ] = GLDSfeature()
%�ҶȲ��ͳ��

IMG=imread('E:\MATLAB\contest\bow11\images\training\tea\tea001.bmp');%��ȡͼ��
A=double(IMG);               %ת����double����
[m,n]=size(A);             %�õ�ͼ��ĸ߶ȺͿ��
B=A;
C=zeros(m,n);
for i=1:m-1
    for j=1:n-1
        B(i,j)=A(i+1,j+1);
        C(i,j)=abs(round(A(i,j)-B(i,j)));    %����ҶȲ��ͼ��
    end
end
h=imhist(mat2gray(C))/(m*n);    %����ҶȲ��ͼ��ֱ��ͼ
MEAN=0;    %���ñ�����ֵ
CON=0;    %���ñ�����ֵ
ASM=0;    %���ñ�����ֵ
ENT=0;    %���ñ�����ֵ
for i=1:256
    MEAN=MEAN+(i*h(i))/256;    %����ƽ��ֵ
    CON=CON+i*i*h(i);          %����Աȶ�
    ASM=ASM+h(i)*h(i);         %����Ƕȷ�����׾�
    if(h(i)>0)
    ENT=ENT-h(i)*log2(h(i));    %������
    end
end
   feature=[MEAN,CON,ASM,ENT];
end

