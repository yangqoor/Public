%ʹ������㷨���ԶԽ��и��ַ�������
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
% % % % % % % % % %%ģ�� �������
 CirAper=ElipsoidalAperture(a,b,16,16);%����ֱ��Ϊ16���ص�256x256�Ŀ׾���%�����Fѡ��Բ�׾��뾶Ϊ6
 [OTF,PSF]=Aperture2OTF(CirAper);%��������������ɵ�׶�ε�ͨ�˲���,��ֹƵ��32����
% % % % % % % % % % load('OTF.mat');
F=fft2(g);
G=F.*OTF; 
g1=ifft2(G);
g1=IMRA(g1); %ȡʵ��������Ϊ��ֵ
g1=add_noise(g1,30);
g1=(g1-min(g1(:)))./(max(g1(:))-min(g1(:)));
% %------------------------------------
  figure,imshow(g1,[]);title('blured and noised image');
 FF=fft2(g1);figure;imshow(log(1+fftshift(abs(FF))),[]);
% %--------------------------------------------------------------------------
% %�Ƿ��������
% noise=1;%======================��˹��������
% if noise==0 
%    g=g1;
%    G=G1;
% else
%    %and gaussian noise
%    %g=imnoise(g1,'gaussian',0,(2/255)^2);
%    snr=15;%=====================�������������Ĵ�С���������Ϊ��׼
%    S_g=var(g1(:));
%    a=sqrt(S_g/(10^(snr/10)));
%    g=IMRA(g1+randn(M,N)*a);
%    G=fft2(g);

%    figure,imshow(log(1+fftshift(abs(G))),[]);title('blured and noised frequency');
%    %win0=double(abs(OTF)<=1e-10);%�ҳ�OTF��ȫΪ���
%    %win1=1-win0;%�ҳ�OTF�в�Ϊ��ĵ�
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
        %Richardson-Lucy �㷨�ǻ��ڲ��ɷֲ�ģ�͵�һ��ML�㷨
        iterations=100;
        [res_image_RL,mse_RL]=RL(g,g1,OTF,iterations,0,0);%һ�㲻ͶӰ
        res_fre_RL=fft2(res_image_RL);
%        error=fre_error(F,res_fre_RL);
        
        figure,imshow(res_image_RL,[]);
        title('restored image based on RL algorithm');
        figure,imshow(log(1+fftshift(abs(res_fre_RL))),[]);
        title('restored frequency based on RL algorithm');
        t=0:iterations;
        figure,plot(t,mse_RL,'k');
        xlabel('iterations'); ylabel('MSE');legend('RL�㷨MSE�仯����');
        PSNR_RL=10*log10(max_o^2./mse_RL);
        figure,plot(PSNR_RL,'k');axis([0,iterations,15.5,18.6]);
        xlabel('iterations'); ylabel('PSNR/dB');legend('RL�㷨PSNR�仯����','Location','NorthWest');
        
     case 'RL2'
        %����һ�ּ��ٵ�RL�㷨��ͨ��ָ���任�������ɳڲ���������RL�㷨
        %Richardson-Lucy �㷨�ǻ��ڲ��ɷֲ�ģ�͵�һ��ML�㷨��exp�ͣ�
        iterations=100;
        [res_image_RL2,mse_RL2]=RL2(f,g,OTF,iterations,1.9,1,0);%һ�㲻ͶӰ
        res_fre_RL2=fft2(res_image_RL2);
        error=fre_error(F,res_fre_RL2);
        
        figure,imshow(res_image_RL2,[]);
        title('restored image based on RL2 algorithm');
        figure,imshow(log(1+fftshift(abs(res_fre_RL2))),[]);
        title('restored frequency based on RL2 algorithm');
        t=0:iterations;
        figure,plot(t,mse_RL2,'k');
        xlabel('iterations'); ylabel('MSE');title('RL2�㷨MSE�仯����');
        
    case 'poisson_MAP'
        %��������������㷨�ǻ��ڲ��ɷֲ�ģ�͵�һ��MAP�㷨
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
% % % %         xlabel('iterations'); ylabel('MSE');title('poisson-MAP�㷨MSE�仯����');
        
         case 'wave_map'
        %ISAR�㷨�ǻ��ڸ�˹�ֲ�ģ�͵�һ�ֳ��Ե����㷨
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
        xlabel('iterations'); ylabel('MSE');title('wmap�㷨MSE�仯����');
        
        
        case 'wave_map1'
        %ISAR�㷨�ǻ��ڸ�˹�ֲ�ģ�͵�һ�ֳ��Ե����㷨
 
        [res_image_wmap,mse_wmap]=wavelet_map1(g,g1,OTF);
        res_fre_wmap=fft2(res_image_wmap);
        figure,imshow(res_image_wmap,[]);

        
        title('restored image based on wmap algorithm');
        figure,imshow(log(1+fftshift(abs(res_fre_wmap))),[]);
        title('restored frequency based on wmap algorithm');
        t=0:iterations;
        figure,plot(t,mse_wmap,'k');
        xlabel('iterations'); ylabel('MSE');title('wmap�㷨MSE�仯����');
        
        
        
        
        
        
        
        
        
        
    case 'ISRA'
        %ISAR�㷨�ǻ��ڸ�˹�ֲ�ģ�͵�һ�ֳ��Ե����㷨
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
        xlabel('iterations'); ylabel('MSE');title('ISRA�㷨MSE�仯����');
        
    case 'ISRA2'
        %ISAR�㷨�ǻ��ڸ�˹�ֲ�ģ�͵�һ�ֳ��Ե����㷨
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
        xlabel('iterations'); ylabel('MSE');title('ISRA2�㷨MSE�仯����');
        
    case 'Landweber'
        %Landweber�㷨�ǻ��ڸ�˹�ֲ�ģ�͵�һ�ּ��Ե����㷨
        iterations=100;
        [res_image_landweber,mse_landweber]=land_weber(g,g1,OTF,iterations,1,0,0);
        %������Ǻ�������Ƶ�������ʱ����ϸ΢���
        %[res_image_landweber,mse_landweber]=land_weber2(f,g,OTF,iterations,0.8,0,1);
   res_fre_landweber=fft2(res_image_landweber);
  %      error=fre_error(F,res_fre_landweber);
        
        figure,imshow(res_image_landweber,[]);
        title('restored image based on landweber algorithm');
        figure,imshow(log(1+fftshift(abs(res_fre_landweber))),[]);
        title('restored frequency based on landweber algorithm');
        t=0:iterations;
        figure,plot(t,mse_landweber,'k');
        xlabel('iterations'); ylabel('MSE');title('landweber�㷨MSE�仯����');
    case 'my_ml'
        %����һ�ֶԻ��ڲ��ɼ����µ�ML�㷨��ŷ�����̲��õ�������㷨
        iterations=100;
        [res_image_myml,mse_myml]=my_ml(f,g,OTF,iterations,0.08,1,0);
        res_fre_myml=fft2(res_image_myml);
        figure,imshow(res_image_myml,[]);
        title('restored image based on myml algorithm');
        figure,imshow(log(1+fftshift(abs(res_fre_myml))),[]);
        title('restored frequency based on myml algorithm');
        t=0:iterations;
        figure,plot(t,mse_myml);
        xlabel('iterations'); ylabel('MSE');title('myml�㷨MSE�仯����');
    case 'TV'
        %------------------------------------------------------------------
        %Time:2009.12.27  21:43  ����TV�㷨���ֱ�ʵ��
        %TV�㷨ʵ��ʧ�ܣ��д����ԭ��.......................
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
        xlabel('iterations'); ylabel('MSE');title('tv�㷨MSE�仯����');  
    case 'compare_mse'
        %�Ƚϼ���ǰ��RL�㷨�������ٶ�
        iterations=100;
        [res_image_RL,mse_RL]=RL(f,g,OTF,iterations,1,0);%һ�㲻ͶӰ
        [res_image_RL2,mse_RL2]=RL2(f,g,OTF,iterations,1.9,1,0);%һ�㲻ͶӰ
         t=0:iterations;
        figure,plot(t,mse_RL,'-k',t,mse_RL2,':k');
        xlabel('iterations'); ylabel('MSE');
        legend('RL','A-RL');
    case 'ABSD'
        %Bidirectional shock-Diffusion ƫ΢�ַ����е�˫������ɢ
        iterations=100;
        g_lp=gauss(g,5,1);
        figure,imshow(g,[]),title('Ԥ�˲��Ժ��ͼ��');
        [res_image_absd,mse_absd]=absd(f,g_lp,0.005,-0.2,iterations,0.05);
        %[res_image_absd,mse_absd]=absd(f,g,0.005,-0.2,iterations,0.05);
        figure,imshow(res_image_absd,[]);
        title('restored image based on absd algorithm');
        figure,imshow(log(1+abs(fftshift(fft2(res_image_absd)))),[]);
        title('restored frequency based on absde algorithm');
        t=0:iterations;
        figure,plot(t,mse_absd);
        xlabel('iterations'); ylabel('MSE');title('absd�㷨MSE�仯����'); 
        figure,subplot(4,1,1),plot(f(128,:));title('ͼ����ǰ���128�еĻҶȱ任���');
        subplot(4,1,2),plot(g1(128,:));
        subplot(4,1,3),plot(g(128,:));
        subplot(4,1,4),plot(res_image_absd(128,:));    
        
end