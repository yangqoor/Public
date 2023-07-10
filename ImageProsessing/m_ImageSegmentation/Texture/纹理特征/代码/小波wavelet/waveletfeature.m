function [zscore_data]=waveletfeature(I,n)

%  n=2; 
%  I = imread('E:\MATLAB\contest\bow11\images\training\tea\tea001.bmp');
 I=rgb2gray(I); %将图像转换为灰度

%  NBColor=128;
%  I=wcodemat(I,NBColor);

  nb=size(I,1);
%  figure
%  imshow(I,[])
%colormap(pink(nb));edec2

[c,s]=wavedec2(I,n,'haar');%用指定小波计算I的n层二维小波分解,结果中C表示分解得到的低频信号，S则表示高频部分。
%LL1=appcoef2(c,s,'db1',1);%提取二维离散小波近似分量函数
LH1=detcoef2('h',c,s,1);%提取二维离散小波水平细节分量函数
LV1=detcoef2('v',c,s,1);
LD1=detcoef2('d',c,s,1);

LL2=appcoef2(c,s,'db1',2);%提取二维离散小波近似分量函数
LH2=detcoef2('h',c,s,2);%提取二维离散小波水平细节分量函数
LV2=detcoef2('v',c,s,2);
LD2=detcoef2('d',c,s,2);

cod_LH1=wcodemat(LH1,nb); %水平细节分量
cod_LV1=wcodemat(LV1,nb); %垂直细节分量
cod_LD1=wcodemat(LD1,nb); %对角细节分量

cod_LL2=wcodemat(LL2,nb); %近似分量    调整输入LL1的值范围为1~nb
cod_LH2=wcodemat(LH2,nb); %水平细节分量
cod_LV2=wcodemat(LV2,nb); %垂直细节分量
cod_LD2=wcodemat(LD2,nb); %对角细节分量


lh1=uint8(cod_LH1);
lv1=uint8(cod_LV1);
ld1=uint8(cod_LD1);
ll2=uint8(cod_LL2);
lh2=uint8(cod_LH2);
lv2=uint8(cod_LV2);
ld2=uint8(cod_LD2);

% subplot(3,2,1);imshow(I,[]);title('原图');
% subplot(3,2,2);imshow(ld2);title('近似分量');
% subplot(3,2,3);imshow(cod_LH1,[]);title('水平方向');
% subplot(3,2,4);imshow(cod_LV1,[]);title('垂直方向');
% subplot(3,2,5);imshow(cod_LD1,[]);title('对角线方向');
%% 求GLCM特征
%  T1=glcmfeature1(I);
%  T2=glcmfeature1(lh1);
%  T3=glcmfeature1(lv1);
%  T4=glcmfeature1(ld1);
% t=[T1,T2,T3,T4];
%%  LH1
s1 = 0;%统计子图像的像素值和
[heigh1,width1] = size(cod_LH1);
for i = 1:heigh1 %行 
   for j = 1:width1 %列
       s1=s1+abs(cod_LH1(i,j));
   end
end
mLH1=(1/(heigh1*width1))*s1;
 st1=0;
 for i = 1:heigh1 %行 
   for j = 1:width1 %列
       st1=st1+(abs(cod_LH1(i,j)-mLH1))*(abs(cod_LH1(i,j)-mLH1));
   end
 end
sLH1=sqrt((1/((heigh1*width1)-1))*st1);
%% LV1
s2 = 0;%统计子图像的像素值和
[heigh2,width2] = size(cod_LV1);
for i = 1:heigh2 %行 
   for j = 1:width2 %列
       s2=s2+abs(cod_LV1(i,j));
   end
end
mLV1=(1/(heigh2*width2))*s2;
 st2=0;
 for i = 1:heigh2 %行 
   for j = 1:width2 %列
       st2=st2+(abs(cod_LV1(i,j)-mLV1))*(abs(cod_LV1(i,j)-mLV1));
   end
 end
sLV1=sqrt((1/((heigh2*width2)-1))*st2);
%% LD1
s3=0;
[heigh3,width3] = size(cod_LD1);
for i = 1:heigh3 %行 
   for j = 1:width3 %列
       s3=s3+abs(cod_LD1(i,j));
   end
end
mLD1=(1/(heigh3*width3))*s3;
 st3=0;
 for i = 1:heigh2 %行 
   for j = 1:width2 %列
       st3=st3+(abs(cod_LD1(i,j)-mLD1))*(abs(cod_LD1(i,j)-mLD1));
   end
 end
sLD1=sqrt((1/((heigh3*width3)-1))*st3);
%% LL2
s4=0;
[heigh4,width4] = size(cod_LL2);
for i = 1:heigh4 %行 
   for j = 1:width4 %列
       s4=s4+abs(cod_LL2(i,j));
   end
end
mLL2=(1/(heigh4*width4))*s4;
 st4=0;
 for i = 1:heigh4 %行 
   for j = 1:width4 %列
       st4=st4+(abs(cod_LL2(i,j)-mLL2))*(abs(cod_LL2(i,j)-mLL2));
   end
 end
sLL2=sqrt((1/((heigh4*width4)-1))*st4);
%% LH2
s5=0;
[heigh5,width5] = size(cod_LH2);
for i = 1:heigh5 %行 
   for j = 1:width5 %列
       s5=s5+abs(cod_LH2(i,j));
   end
end
mLH2=(1/(heigh5*width5))*s5;
 st5=0;
 for i = 1:heigh5 %行 
   for j = 1:width5 %列
       st5=st5+(abs(cod_LH2(i,j)-mLH2))*(abs(cod_LH2(i,j)-mLH2));
   end
 end
sLH2=sqrt((1/((heigh5*width5)-1))*st5);
%% LV2
s6=0;
[heigh6,width6] = size(cod_LV2);
for i = 1:heigh6 %行 
   for j = 1:width6 %列
       s6=s6+abs(cod_LV2(i,j));
   end
end
mLV2=(1/(heigh6*width6))*s6;
 st6=0;
 for i = 1:heigh6 %行 
   for j = 1:width6 %列
       st6=st6+(abs(cod_LV2(i,j)-mLV2))*(abs(cod_LV2(i,j)-mLV2));
   end
 end
sLV2=sqrt((1/((heigh6*width6)-1))*st6);
%% LD2
s7=0;
[heigh7,width7] = size(cod_LD2);
for i = 1:heigh7 %行 
   for j = 1:width7 %列
       s7=s7+abs(cod_LD2(i,j));
   end
end
mLD2=(1/(heigh7*width7))*s7;
 st7=0;
 for i = 1:heigh7 %行 
   for j = 1:width7 %列
       st7=st7+(abs(cod_LD2(i,j)-mLD2))*(abs(cod_LD2(i,j)-mLD2));
   end
 end
sLD2=sqrt((1/((heigh7*width7)-1))*st7);
%% 
feature=[sLH1,mLH1,sLV1,mLV1,sLD1,mLD1,sLL2,mLL2,sLH2,mLH2,mLV2,sLV2,mLD2,sLD2];
m=size(feature,2);
zscore_data=zeros(1,m);
for n=1:m
    zscore_data(1,n)=(feature(1,n)-mean(feature))/std(feature);
end

%% 能量计算 对各层次上的3个高频子图分别计算每个象素的能量
% h = ones(11,11);%窗口大小为11*11，只能为奇数
% energy_LH1 = imfilter(cod_LH1,h,'replicate');%均值滤波，输出图像的边界通过复制外边界的值来扩展
% energy_LV1 = imfilter(cod_LV1,h,'replicate');%imfilter：对任意类型数组或多维图像进行滤波
% energy_LD1 = imfilter(cod_LD1,h,'replicate');
% %figure;
% subplot(2,2,1);imshow(energy_LH1,[]);title('水平方向');
% subplot(2,2,2);imshow(energy_LV1,[]);title('垂直方向');
% subplot(2,2,3);imshow(energy_LD1,[]);title('对角线方向');
% %% 计算各子图的熵。为什么能量是每个像素都有能量，而熵是每个子图只有一个？？？？
% [heigh,width] = size(cod_LH1);
% 
% %第1个高频子图的熵
% sumSquare = 0;%统计子图像的像素值和
% for i = 1:heigh %行 
%    for j = 1:width %列
%    sumSquare = sumSquare + cod_LH1(i,j);
%    end
% end
% 
% for i = 1:heigh %行
%    for j = 1:width %列
%    temp(i,j) = cod_LH1(i,j)^2/sumSquare;
%    end
% end
% entropy_LH1 = entropy(temp)
% 
% %第2个高频子图的熵
% sumSquare = 0;%统计子图像的像素值平方和
% for i = 1:heigh %行 
% for j = 1:width %列
% sumSquare = sumSquare + cod_LV1(i,j);
% end
% end
% 
% for i = 1:heigh %行
% for j = 1:width %列
% temp(i,j) = cod_LV1(i,j)^2/sumSquare;
% end
% end
% entropy_LV1 = entropy(temp)
% 
% %第3个高频子图的熵
% sumSquare = 0;%统计子图像的像素值平方和
% for i = 1:heigh %行 
% for j = 1:width %列
% sumSquare = sumSquare + cod_LD1(i,j);
% end
% end
% 
% for i = 1:heigh %行
% for j = 1:width %列
% temp(i,j) = cod_LD1(i,j)^2/sumSquare;
% end
% end
% entropy_LD1 = entropy(temp)
end
