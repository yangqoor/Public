%使用这个算法可以对进行各种方法仿真
%This script is to compare all kinds of super-resolution algorithm
%tests of all kinds of super-resolution algorithms

close all;clear;clc;
% % % % [g,m]=imread('E:\a\libb_multi_for.jpg');
% % % % g=rgb2gray(g);
% % % % g=im2double(g);
I=imread('block.png');
I=rgb2gray(I);
I=im2double(I);
I=(I-min(I(:)))./(max(I(:))-min(I(:)));

g=I;
 
 [a,b]=size(I);
% g=im2double(imread('E:/a/libb.jpg'));
figure;imshow(g,[]);
% % % F1=fft2(g1);figure;imshow(log(1+fftshift(abs(F1))),[]);
% % % % % % % % % %%模糊 添加噪声
 CirAper=ElipsoidalAperture(a,b,16,16);%产生直径为16像素的256x256的孔径；%如果是F选择圆孔径半径为6
 [OTF,PSF]=Aperture2OTF(CirAper);%由于衍射受限造成的锥形低通滤波器,截止频率32像素
% % % % % % % % % % load('OTF.mat');
F=fft2(g);
G=F.*OTF; 
g1=ifft2(G);
g1=IMRA(g1); %取实部，限制为正值
g1=add_noise(g1,30);
g1=(g1-min(g1(:)))./(max(g1(:))-min(g1(:)));
% %------------------------------------
  figure,imshow(g1,[]);title('blured and noised image');
 FF=fft2(g1);figure;imshow(log(1+fftshift(abs(FF))),[]);
% %--------------------------------------------------------------------------
% %是否加入噪声
% noise=1;%======================高斯噪声开关
% if noise==0 
%    g=g1;
%    G=G1;
% else
%    %and gaussian noise
%    %g=imnoise(g1,'gaussian',0,(2/255)^2);
%    snr=15;%=====================调整输入噪声的大小，以信噪比为标准
%    S_g=var(g1(:));
%    a=sqrt(S_g/(10^(snr/10)));
%    g=IMRA(g1+randn(M,N)*a);
%    G=fft2(g);

%    figure,imshow(log(1+fftshift(abs(G))),[]);title('blured and noised frequency');
%    %win0=double(abs(OTF)<=1e-10);%找出OTF中全为零的
%    %win1=1-win0;%找出OTF中不为零的点
%    %G=G.*win1;
%    %g=IMRA(ifft2(G));
% end
% error_orig=fre_error(F,G);

%==========================================================================
% All kinds of super-resolution algorithm
% plese choose super-resolution algorithm such as 
%'RL','poisson_MAP','ISAR','Landweber'
%choose='RL';
choose='wave_map';
switch choose
    case 'RL'
        %Richardson-Lucy 算法是基于泊松分布模型的一种ML算法
        iterations=100;
        [res_image_RL,mse_RL]=RL(g,g1,OTF,iterations,0,0);%一般不投影
        res_fre_RL=fft2(res_image_RL);
%        error=fre_error(F,res_fre_RL);
        
        figure,imshow(res_image_RL,[]);
        title('restored image based on RL algorithm');
        figure,imshow(log(1+fftshift(abs(res_fre_RL))),[]);
        title('restored frequency based on RL algorithm');
        t=0:iterations;
        figure,plot(t,mse_RL,'k');
        xlabel('iterations'); ylabel('MSE');legend('RL算法MSE变化曲线');
        PSNR_RL=10*log10(max_o^2./mse_RL);
        figure,plot(PSNR_RL,'k');axis([0,iterations,15.5,18.6]);
        xlabel('iterations'); ylabel('PSNR/dB');legend('RL算法PSNR变化曲线','Location','NorthWest');
        
     case 'RL2'
        %这是一种加速的RL算法，通过指数变换并引入松弛参数来加速RL算法
        %Richardson-Lucy 算法是基于泊松分布模型的一种ML算法（exp型）
        iterations=100;
        [res_image_RL2,mse_RL2]=RL2(f,g,OTF,iterations,1.9,1,0);%一般不投影
        res_fre_RL2=fft2(res_image_RL2);
        error=fre_error(F,res_fre_RL2);
        
        figure,imshow(res_image_RL2,[]);
        title('restored image based on RL2 algorithm');
        figure,imshow(log(1+fftshift(abs(res_fre_RL2))),[]);
        title('restored frequency based on RL2 algorithm');
        t=0:iterations;
        figure,plot(t,mse_RL2,'k');
        xlabel('iterations'); ylabel('MSE');title('RL2算法MSE变化曲线');
        
    case 'poisson_MAP'
        %泊松最大后验概率算法是基于泊松分布模型的一种MAP算法
        iterations=100;
        [res_image_MAP,mse_MAP]=poisson_MAP(g,g1,OTF,iterations,1,0,0);
        res_fre_MAP=fft2(res_image_MAP);
%        error=fre_error(F,res_fre_MAP);
        
        figure,imshow(res_image_MAP,[]);
        title('restored image based on poisson-MAP algorithm');
% % % %         figure,imshow(log(1+fftshift(abs(res_fre_MAP))),[]);
% % % %         title('restored frequency based on poisson-MAP algorithm');
% % % %         t=0:iterations;
% % % %         figure,plot(t,mse_MAP);
% % % %         xlabel('iterations'); ylabel('MSE');title('poisson-MAP算法MSE变化曲线');
        
         case 'wave_map'
        %ISAR算法是基于高斯分布模型的一种乘性迭代算法
        iterations=100;
        [res_image_wmap,mse_wmap]=wavelet_map(g,g1,OTF);
        res_fre_wmap=fft2(res_image_wmap);
        figure,imshow(res_image_wmap,[]);
  %      error=fre_error(F,res_fre_ISRA);
        
        title('restored image based on wmap algorithm');
        figure,imshow(log(1+fftshift(abs(res_fre_wmap))),[]);
        title('restored frequency based on wmap algorithm');
        t=0:iterations;
        figure,plot(t,mse_wmap,'k');
        xlabel('iterations'); ylabel('MSE');title('wmap算法MSE变化曲线');
        
        
        case 'wave_map1'
        %ISAR算法是基于高斯分布模型的一种乘性迭代算法
 
        [res_image_wmap,mse_wmap]=wavelet_map1(g,g1,OTF);
        res_fre_wmap=fft2(res_image_wmap);
        figure,imshow(res_image_wmap,[]);

        
        title('restored image based on wmap algorithm');
        figure,imshow(log(1+fftshift(abs(res_fre_wmap))),[]);
        title('restored frequency based on wmap algorithm');
        t=0:iterations;
        figure,plot(t,mse_wmap,'k');
        xlabel('iterations'); ylabel('MSE');title('wmap算法MSE变化曲线');
        
        
        
        
        
        
        
        
        
        
    case 'ISRA'
        %ISAR算法是基于高斯分布模型的一种乘性迭代算法
        iterations=100;
        [res_image_ISRA,mse_ISRA]=isra(g,g1,OTF,iterations,0,0);
        res_fre_ISRA=fft2(res_image_ISRA);
        figure,imshow(res_image_ISRA,[]);
  %      error=fre_error(F,res_fre_ISRA);
        
        title('restored image based on ISRA algorithm');
        figure,imshow(log(1+fftshift(abs(res_fre_ISRA))),[]);
        title('restored frequency based on ISRA algorithm');
        t=0:iterations;
        figure,plot(t,mse_ISRA,'k');
        xlabel('iterations'); ylabel('MSE');title('ISRA算法MSE变化曲线');
        
    case 'ISRA2'
        %ISAR算法是基于高斯分布模型的一种乘性迭代算法
        iterations=100;
        [res_image_ISRA2,mse_ISRA2]=isra2(f,g,OTF,iterations,1.9,1,0);
        res_fre_ISRA2=fft2(res_image_ISRA2);
        error=fre_error(F,res_fre_ISRA2);
        
        figure,imshow(res_image_ISRA2,[]);
        title('restored image based on ISRA2 algorithm');
        figure,imshow(log(1+fftshift(abs(res_fre_ISRA2))),[]);
        title('restored frequency based on ISRA2 algorithm');
        t=0:iterations;
        figure,plot(t,mse_ISRA2,'k');
        xlabel('iterations'); ylabel('MSE');title('ISRA2算法MSE变化曲线');
        
    case 'Landweber'
        %Landweber算法是基于高斯分布模型的一种加性迭代算法
        iterations=100;
        [res_image_landweber,mse_landweber]=land_weber(g,g1,OTF,iterations,1,0,0);
        %上面的是和下面在频域迭代的时候有细微差别
        %[res_image_landweber,mse_landweber]=land_weber2(f,g,OTF,iterations,0.8,0,1);
   res_fre_landweber=fft2(res_image_landweber);
  %      error=fre_error(F,res_fre_landweber);
        
        figure,imshow(res_image_landweber,[]);
        title('restored image based on landweber algorithm');
        figure,imshow(log(1+fftshift(abs(res_fre_landweber))),[]);
        title('restored frequency based on landweber algorithm');
        t=0:iterations;
        figure,plot(t,mse_landweber,'k');
        xlabel('iterations'); ylabel('MSE');title('landweber算法MSE变化曲线');
    case 'my_ml'
        %这是一种对基于泊松假设下的ML算法的欧拉方程采用的最陡上升算法
        iterations=100;
        [res_image_myml,mse_myml]=my_ml(f,g,OTF,iterations,0.08,1,0);
        res_fre_myml=fft2(res_image_myml);
        figure,imshow(res_image_myml,[]);
        title('restored image based on myml algorithm');
        figure,imshow(log(1+fftshift(abs(res_fre_myml))),[]);
        title('restored frequency based on myml algorithm');
        t=0:iterations;
        figure,plot(t,mse_myml);
        xlabel('iterations'); ylabel('MSE');title('myml算法MSE变化曲线');
    case 'TV'
        %------------------------------------------------------------------
        %Time:2009.12.27  21:43  进行TV算法超分辨实验
        %TV算法实验失败，有待检查原因.......................
        %------------------------------------------------------------------
        iterations=100;
        [res_image_tv,mse_tv]=tv_image_restoration(f,g,1,OTF,iterations,0.2,0.01);
        res_fre_tv=fft2(res_image_tv);
        figure,imshow(res_image_tv,[]);
        title('restored image based on tv algorithm');
        figure,imshow(log(1+fftshift(abs(res_fre_tv))),[]);
        title('restored frequency based on tv algorithm');
        t=0:iterations;
        figure,plot(t,mse_tv);
        xlabel('iterations'); ylabel('MSE');title('tv算法MSE变化曲线');  
    case 'compare_mse'
        %比较加速前后RL算法的收敛速度
        iterations=100;
        [res_image_RL,mse_RL]=RL(f,g,OTF,iterations,1,0);%一般不投影
        [res_image_RL2,mse_RL2]=RL2(f,g,OTF,iterations,1.9,1,0);%一般不投影
         t=0:iterations;
        figure,plot(t,mse_RL,'-k',t,mse_RL2,':k');
        xlabel('iterations'); ylabel('MSE');
        legend('RL','A-RL');
    case 'ABSD'
        %Bidirectional shock-Diffusion 偏微分方程中的双向冲击扩散
        iterations=100;
        g_lp=gauss(g,5,1);
        figure,imshow(g,[]),title('预滤波以后的图像');
        [res_image_absd,mse_absd]=absd(f,g_lp,0.005,-0.2,iterations,0.05);
        %[res_image_absd,mse_absd]=absd(f,g,0.005,-0.2,iterations,0.05);
        figure,imshow(res_image_absd,[]);
        title('restored image based on absd algorithm');
        figure,imshow(log(1+abs(fftshift(fft2(res_image_absd)))),[]);
        title('restored frequency based on absde algorithm');
        t=0:iterations;
        figure,plot(t,mse_absd);
        xlabel('iterations'); ylabel('MSE');title('absd算法MSE变化曲线'); 
        figure,subplot(4,1,1),plot(f(128,:));title('图像处理前后第128行的灰度变换情况');
        subplot(4,1,2),plot(g1(128,:));
        subplot(4,1,3),plot(g(128,:));
        subplot(4,1,4),plot(res_image_absd(128,:));    
        
end