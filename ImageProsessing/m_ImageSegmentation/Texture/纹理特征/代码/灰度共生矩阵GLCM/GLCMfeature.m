function [ T ] = GLCMfeature( IMG )
%�Ҷȹ�������

  IMG = imread('E:\MATLAB\contest\bow11\images\training\tea\tea001.bmp');
  IMG=rgb2gray(IMG);
  
  
  w=5;%���ڴ�С
% IMG=wextend('2D','zpd',IMG,(w-1)/2); %����ͼ�����2D����άͼ��sym:�ԳƳ����w-1��/2���س���
 [m,n]=size(Img);
 I1=zeros(m,n);
 I2=zeros(m,n);
 I3=zeros(m,n);
 I4=zeros(m,n);
 b1=zeros(m,n);
 b2=zeros(m,n);
 b3=zeros(m,n);
 b4=zeros(m,n);
 T=zeros(400,4);
%�Ҷȹ��������4������
 l=0;
  for i=(w+1)/2:m-(w+1)/2+1
     for j=(w+1)/2:n-(w+1)/2+1
        l=l+1;
        p=IMG(i-(w-1)/2:i+(w-1)/2,j-(w-1)/2:j+(w-1)/2);
        [glcms,SI]=graycomatrix(p,'NumLevels',16,'G',[],'offset',[0,1;-1,1;-1,0;-1,-1]);
        %����Ҷȹ��������ĸ������ĸ�����ֵ
        stats = graycoprops(glcms,'all');
        Con=[stats.Contrast];%�Աȶ�
        H=[stats.Homogeneity];%ͬ����
        Cor=[stats.Correlation];%�����
        En=[stats.Energy];%����
        I1(i,j)=mean(Con);%��ֵ
        I2(i,j)=mean(H);
        I3(i,j)=mean(Cor);
        I4(i,j)=mean(En);
        b1(i,j)=sqrt(cov(Con));%��׼��
        b2(i,j)=sqrt(cov(H));
        b3(i,j)=sqrt(cov(Cor));
        b4(i,j)=sqrt(cov(En));
        T=[I1,I2,I3,I4,b1,b2,b3,b4];
     end
  end
end

