function [zscore_data]=waveletfeature(I,n)

%  n=2; 
%  I = imread('E:\MATLAB\contest\bow11\images\training\tea\tea001.bmp');
 I=rgb2gray(I); %��ͼ��ת��Ϊ�Ҷ�

%  NBColor=128;
%  I=wcodemat(I,NBColor);

  nb=size(I,1);
%  figure
%  imshow(I,[])
%colormap(pink(nb));edec2

[c,s]=wavedec2(I,n,'haar');%��ָ��С������I��n���άС���ֽ�,�����C��ʾ�ֽ�õ��ĵ�Ƶ�źţ�S���ʾ��Ƶ���֡�
%LL1=appcoef2(c,s,'db1',1);%��ȡ��ά��ɢС�����Ʒ�������
LH1=detcoef2('h',c,s,1);%��ȡ��ά��ɢС��ˮƽϸ�ڷ�������
LV1=detcoef2('v',c,s,1);
LD1=detcoef2('d',c,s,1);

LL2=appcoef2(c,s,'db1',2);%��ȡ��ά��ɢС�����Ʒ�������
LH2=detcoef2('h',c,s,2);%��ȡ��ά��ɢС��ˮƽϸ�ڷ�������
LV2=detcoef2('v',c,s,2);
LD2=detcoef2('d',c,s,2);

cod_LH1=wcodemat(LH1,nb); %ˮƽϸ�ڷ���
cod_LV1=wcodemat(LV1,nb); %��ֱϸ�ڷ���
cod_LD1=wcodemat(LD1,nb); %�Խ�ϸ�ڷ���

cod_LL2=wcodemat(LL2,nb); %���Ʒ���    ��������LL1��ֵ��ΧΪ1~nb
cod_LH2=wcodemat(LH2,nb); %ˮƽϸ�ڷ���
cod_LV2=wcodemat(LV2,nb); %��ֱϸ�ڷ���
cod_LD2=wcodemat(LD2,nb); %�Խ�ϸ�ڷ���


lh1=uint8(cod_LH1);
lv1=uint8(cod_LV1);
ld1=uint8(cod_LD1);
ll2=uint8(cod_LL2);
lh2=uint8(cod_LH2);
lv2=uint8(cod_LV2);
ld2=uint8(cod_LD2);

% subplot(3,2,1);imshow(I,[]);title('ԭͼ');
% subplot(3,2,2);imshow(ld2);title('���Ʒ���');
% subplot(3,2,3);imshow(cod_LH1,[]);title('ˮƽ����');
% subplot(3,2,4);imshow(cod_LV1,[]);title('��ֱ����');
% subplot(3,2,5);imshow(cod_LD1,[]);title('�Խ��߷���');
%% ��GLCM����
%  T1=glcmfeature1(I);
%  T2=glcmfeature1(lh1);
%  T3=glcmfeature1(lv1);
%  T4=glcmfeature1(ld1);
% t=[T1,T2,T3,T4];
%%  LH1
s1 = 0;%ͳ����ͼ�������ֵ��
[heigh1,width1] = size(cod_LH1);
for i = 1:heigh1 %�� 
   for j = 1:width1 %��
       s1=s1+abs(cod_LH1(i,j));
   end
end
mLH1=(1/(heigh1*width1))*s1;
 st1=0;
 for i = 1:heigh1 %�� 
   for j = 1:width1 %��
       st1=st1+(abs(cod_LH1(i,j)-mLH1))*(abs(cod_LH1(i,j)-mLH1));
   end
 end
sLH1=sqrt((1/((heigh1*width1)-1))*st1);
%% LV1
s2 = 0;%ͳ����ͼ�������ֵ��
[heigh2,width2] = size(cod_LV1);
for i = 1:heigh2 %�� 
   for j = 1:width2 %��
       s2=s2+abs(cod_LV1(i,j));
   end
end
mLV1=(1/(heigh2*width2))*s2;
 st2=0;
 for i = 1:heigh2 %�� 
   for j = 1:width2 %��
       st2=st2+(abs(cod_LV1(i,j)-mLV1))*(abs(cod_LV1(i,j)-mLV1));
   end
 end
sLV1=sqrt((1/((heigh2*width2)-1))*st2);
%% LD1
s3=0;
[heigh3,width3] = size(cod_LD1);
for i = 1:heigh3 %�� 
   for j = 1:width3 %��
       s3=s3+abs(cod_LD1(i,j));
   end
end
mLD1=(1/(heigh3*width3))*s3;
 st3=0;
 for i = 1:heigh2 %�� 
   for j = 1:width2 %��
       st3=st3+(abs(cod_LD1(i,j)-mLD1))*(abs(cod_LD1(i,j)-mLD1));
   end
 end
sLD1=sqrt((1/((heigh3*width3)-1))*st3);
%% LL2
s4=0;
[heigh4,width4] = size(cod_LL2);
for i = 1:heigh4 %�� 
   for j = 1:width4 %��
       s4=s4+abs(cod_LL2(i,j));
   end
end
mLL2=(1/(heigh4*width4))*s4;
 st4=0;
 for i = 1:heigh4 %�� 
   for j = 1:width4 %��
       st4=st4+(abs(cod_LL2(i,j)-mLL2))*(abs(cod_LL2(i,j)-mLL2));
   end
 end
sLL2=sqrt((1/((heigh4*width4)-1))*st4);
%% LH2
s5=0;
[heigh5,width5] = size(cod_LH2);
for i = 1:heigh5 %�� 
   for j = 1:width5 %��
       s5=s5+abs(cod_LH2(i,j));
   end
end
mLH2=(1/(heigh5*width5))*s5;
 st5=0;
 for i = 1:heigh5 %�� 
   for j = 1:width5 %��
       st5=st5+(abs(cod_LH2(i,j)-mLH2))*(abs(cod_LH2(i,j)-mLH2));
   end
 end
sLH2=sqrt((1/((heigh5*width5)-1))*st5);
%% LV2
s6=0;
[heigh6,width6] = size(cod_LV2);
for i = 1:heigh6 %�� 
   for j = 1:width6 %��
       s6=s6+abs(cod_LV2(i,j));
   end
end
mLV2=(1/(heigh6*width6))*s6;
 st6=0;
 for i = 1:heigh6 %�� 
   for j = 1:width6 %��
       st6=st6+(abs(cod_LV2(i,j)-mLV2))*(abs(cod_LV2(i,j)-mLV2));
   end
 end
sLV2=sqrt((1/((heigh6*width6)-1))*st6);
%% LD2
s7=0;
[heigh7,width7] = size(cod_LD2);
for i = 1:heigh7 %�� 
   for j = 1:width7 %��
       s7=s7+abs(cod_LD2(i,j));
   end
end
mLD2=(1/(heigh7*width7))*s7;
 st7=0;
 for i = 1:heigh7 %�� 
   for j = 1:width7 %��
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

%% �������� �Ը�����ϵ�3����Ƶ��ͼ�ֱ����ÿ�����ص�����
% h = ones(11,11);%���ڴ�СΪ11*11��ֻ��Ϊ����
% energy_LH1 = imfilter(cod_LH1,h,'replicate');%��ֵ�˲������ͼ��ı߽�ͨ��������߽��ֵ����չ
% energy_LV1 = imfilter(cod_LV1,h,'replicate');%imfilter������������������άͼ������˲�
% energy_LD1 = imfilter(cod_LD1,h,'replicate');
% %figure;
% subplot(2,2,1);imshow(energy_LH1,[]);title('ˮƽ����');
% subplot(2,2,2);imshow(energy_LV1,[]);title('��ֱ����');
% subplot(2,2,3);imshow(energy_LD1,[]);title('�Խ��߷���');
% %% �������ͼ���ء�Ϊʲô������ÿ�����ض���������������ÿ����ͼֻ��һ����������
% [heigh,width] = size(cod_LH1);
% 
% %��1����Ƶ��ͼ����
% sumSquare = 0;%ͳ����ͼ�������ֵ��
% for i = 1:heigh %�� 
%    for j = 1:width %��
%    sumSquare = sumSquare + cod_LH1(i,j);
%    end
% end
% 
% for i = 1:heigh %��
%    for j = 1:width %��
%    temp(i,j) = cod_LH1(i,j)^2/sumSquare;
%    end
% end
% entropy_LH1 = entropy(temp)
% 
% %��2����Ƶ��ͼ����
% sumSquare = 0;%ͳ����ͼ�������ֵƽ����
% for i = 1:heigh %�� 
% for j = 1:width %��
% sumSquare = sumSquare + cod_LV1(i,j);
% end
% end
% 
% for i = 1:heigh %��
% for j = 1:width %��
% temp(i,j) = cod_LV1(i,j)^2/sumSquare;
% end
% end
% entropy_LV1 = entropy(temp)
% 
% %��3����Ƶ��ͼ����
% sumSquare = 0;%ͳ����ͼ�������ֵƽ����
% for i = 1:heigh %�� 
% for j = 1:width %��
% sumSquare = sumSquare + cod_LD1(i,j);
% end
% end
% 
% for i = 1:heigh %��
% for j = 1:width %��
% temp(i,j) = cod_LD1(i,j)^2/sumSquare;
% end
% end
% entropy_LD1 = entropy(temp)
end
