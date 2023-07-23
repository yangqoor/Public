close all;clc;clear;
%-----------------------------------------------------------------------
%f=imread('circles.tif');    %读图象
%f=imresize(f,0.5);
f=imread('circles128.tif');
%f=imread('tank4.tiff');
%f=imresize(f,0.5);
% f=imread('pmmw_winuse12.tif');    %读图象
% f=imresize(f,4);
f=im2double(f);%转换成双精度
% imshow(f,'InitialMagnification','fit');title('初始图像');%显示最初的图像
% imshow(log(1+(abs(imresize(f,8)))));title('初始图像');
imshow(f);title('初始图像');%显示最初的图像
F=fft2(f);  %显示
figure,imshow(log(1+fftshift(abs(F))),[]);title('初始频谱');
%---------------------------------------------------------------------
% OTF=im2double(imread('otf16.tif'));   %读取OTF
% PSF=im2double(imread('psf16.tif'));   %读取PSF
% CirAper=ElipsoidalAperture(512,512,16,16);%产生截止频率为16像素的512x512的孔径；
CirAper=ElipsoidalAperture(size(f,2),size(f,1),16,16);%产生截止频率为16像素的512x512的孔径；
[OTF,PSF]=Aperture2OTF(CirAper);
%--------------------------------------------------------------------

%---------------------------------------------------------------------
% 使用MATLAB自己带的低通滤波器 使用fspecial函数
% 产生一个高斯低通降晰过程
% PSF = fspecial('gaussian',13,11);
% OTF=psf2otf(PSF,size(f));
%-----------------------------------------------------
% 自己设计的低通滤波器
% sigma=40;
% OTF=lpfilter('ideal',size(f,1),size(f,2),sigma);
% figure,imshow(log(1+fftshift(abs(OTF))),[]);title('low pass fft');
%-----------------------------------------------------------------------

%-----------------------------------------------------------------
% G=F.*fftshift(OTF);
% G=F.*OTF; %注意前面所产生的OTF的形状，
% figure,imshow(log(1+fftshift(abs(G))),[]);title('after low pass fft');
% g=ifft2(G);
% g=IMRA(g); %取实部，限制为正值
% % figure,imshow(log(1+abs(imresize(g,8))),[]);title('after low pass');
% figure,imshow(g,[]);title('after low pass');
% PSF=fftshift(ifft2(OTF));
%---------------------------------------------------------------
[g,z]=blur_noise(f,PSF,30);
figure,imshow(g,[]);title('after blure low pass noise');
G=(fft2(g));
figure,imshow(log(1+fftshift(abs(G))),[]);title('after noise low pass fft');
%--------------------------------------------------
% 使用自己编程的最似然算法
% figure,mesh(fftshift(Hp));
% PSF=fft2(OTF);
 [g1,norm11,norm22,norm33,likeli]=MaxLik(g,OTF,50,f);
ff1=fft2(g1);
figure,imshow(log(1+(abs(g1))),[]);title('after ml');
% % figure,imshow(log(1+(abs(imresize(g1,8)))));title('after ml');
% figure,imshow(imresize(g1,8));title('after ml');
figure,imshow(log(1+fftshift(abs(ff1))),[]);title('after ml fft');
%-------------------------------------------------------------------------
[f1,fs1]=SimMap(F,G,3,4);
[f2,fs2]=SimMap(F,ff1,3,4);
n=1:256;
figure,imshow(log(1+(abs(f1))),[])
figure,imshow(log(1+(abs(f2))),[])
figure,plot(n,fs1,n,fs2);
axis([1,256,0,1]), xlabel('频率'),ylabel('相似度')
%---------------------------------------------
% 使用自己编程的最似然算法
% im_w1=wiener_filt(g,PSF,0.0001);
init=0.0001*ones(size(g));
% init=g;
[g1,estnorm11]=MaxLikeli(g,OTF,g,1000,f);
ff1=fft2(g1);
figure,imshow((abs(g1)),[]);title('after ml');
% % figure,imshow(log(1+(abs(imresize(g1,8)))));title('after ml');
% figure,imshow(imresize(g1,8));title('after ml');
% figure,imshow(log(1+fftshift(abs(ff1))));title('after ml fft');
figure,imshow(log(1+fftshift(abs(ff1))),[]),title('after ml fft');
figure,plot(estnorm11);
xlabel('迭代次数');ylabel('MSE');
%-------------------------------------------------------------------------
% CirAper=ElipsoidalAperture(size(f,2),size(f,1),12,12);%产生截止频率为16像素的512x512的孔径；
% [OTF1,PSF1]=Aperture2OTF(CirAper);

%--------------------------------------------
%--------------------------------------------------
% % 使用自己编程的盲最似然算法
% % figure,mesh(fftshift(Hp));
% % PSF=fft2(OTF);
%  [g1,est_OTF]=BlindMaxLik(g,OTF1,50);
% ff1=fft2(g1);
% figure,imshow(log(1+(abs(g1))),[]);title('after blind ml');
% figure,imshow(log(1+fftshift(abs(ff1))),[]);title('after blind ml fft');
% % figure,imshow(log(1+fftshift(abs(est_OTF))),[]);title('after ml OTF');
%--------------------------------------------------------------------------
% %使用自己编程的最大后验算法
% [g1]=MaxMap(f,OTF,50);
% ff1=fft2(g1);
% figure,imshow(log(1+(abs(imresize(g1,8)))),[]);title('after map');
% % figure,imshow(imresize(g1,8));title('after map');
% figure,imshow(log(1+fftshift(abs(ff1))));title('after map fft');
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%使用自己编程的最大熵算法
% [g1]=mem1(g,OTF,50);
% ff1=fft2(g1);
% figure,imshow(log(1+(abs(g1))),[]);title('after map');
% % figure,imshow(imresize(g1,8));title('after map');
% figure,imshow(log(1+fftshift(abs(ff1))));title('after map fft');
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%-
% %使用LUCY-RICHARSON
% % 注意输入到Lucy_Richardson的PSF的函数是中心对称的。
% gg2=deconvlucy(g,PSF,50);  % 注意输入到Lucy_Richardson的PSF的函数是中心对称的。
% ff2=fft2(gg2);
% % fff2=real(fft(gg2));
% figure,imshow(log(1+(abs(gg2))),[]);title('after rl');
% figure,imshow(log(1+fftshift(abs(ff2))),[]);title('after rl fft');
% % % figure,imshow(abs(fftshift(gg2)),[]);title('after rl');
% % figure,imshow(log(1+abs(fftshift(ff2))),[]);title('after rl fft');
% % figure,imshow(log(1+abs(fff2)),[]);title('after rl fft2');
% % figure,plot(norm3);title('error figure');
% %-----------------------------------------------------
% %盲图像恢复
% gg2=deconvblind(g,fftshift(real(PSF1)),150);  % 注意输入到Lucy_Richardson的PSF的函数是中心对称的。
% ff2=fft2(gg2);
% figure,imshow(log(1+(abs(gg2))),[]);title('after rl');
% figure,imshow(log(1+fftshift(abs(ff2))),[]);title('after rl fft');
% %--------------------------------------------------------------------------
% % Landweber 算法
% lf=landweber2(g,OTF,1.2,0,100);
% ff2=fft2(lf);
% % fff2=real(fft(gg2));
% figure,imshow(abs(lf),[]);title('after landweber');
% % figure,imshow(imresize(lf,8));title('after landweber');
% figure,imshow(log(1+fftshift(abs(ff2))),[]);title('after landweber fft');
% % %--------------------------------------------------------------------------
% % % Adaptive Landweber 算法
% [alf,r]=AdaptiveLandweber1(g,OTF,1,0,100);
% ff2=fft2(alf);
% % fff2=real(fft(gg2));
% figure,imshow(log(1+(abs(alf))),[]);title('after adaptive landweber');
% figure,imshow(log(1+fftshift(abs(ff2))),[]);title('after adaptive landweber fft');
