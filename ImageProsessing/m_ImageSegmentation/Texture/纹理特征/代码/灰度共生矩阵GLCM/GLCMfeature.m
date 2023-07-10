function [ T ] = GLCMfeature( IMG )
%灰度共生矩阵

  IMG = imread('E:\MATLAB\contest\bow11\images\training\tea\tea001.bmp');
  IMG=rgb2gray(IMG);
  
  
  w=5;%窗口大小
% IMG=wextend('2D','zpd',IMG,(w-1)/2); %延拓图像矩阵，2D：二维图像，sym:对称充填，（w-1）/2延拓长度
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
%灰度共生矩阵和4个特征
 l=0;
  for i=(w+1)/2:m-(w+1)/2+1
     for j=(w+1)/2:n-(w+1)/2+1
        l=l+1;
        p=IMG(i-(w-1)/2:i+(w-1)/2,j-(w-1)/2:j+(w-1)/2);
        [glcms,SI]=graycomatrix(p,'NumLevels',16,'G',[],'offset',[0,1;-1,1;-1,0;-1,-1]);
        %计算灰度共生矩阵四个方向四个特征值
        stats = graycoprops(glcms,'all');
        Con=[stats.Contrast];%对比度
        H=[stats.Homogeneity];%同质性
        Cor=[stats.Correlation];%相关性
        En=[stats.Energy];%能量
        I1(i,j)=mean(Con);%均值
        I2(i,j)=mean(H);
        I3(i,j)=mean(Cor);
        I4(i,j)=mean(En);
        b1(i,j)=sqrt(cov(Con));%标准差
        b2(i,j)=sqrt(cov(H));
        b3(i,j)=sqrt(cov(Cor));
        b4(i,j)=sqrt(cov(En));
        T=[I1,I2,I3,I4,b1,b2,b3,b4];
     end
  end
end

