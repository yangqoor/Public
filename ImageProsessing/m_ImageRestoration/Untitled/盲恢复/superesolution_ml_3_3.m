close all;clc;clear;
%-----------------------------------------------------------------------
%f=imread('circles.tif');    %��ͼ��
%f=imresize(f,0.5);
f=imread('circles128.tif');
%f=imread('tank4.tiff');
%f=imresize(f,0.5);
% f=imread('pmmw_winuse12.tif');    %��ͼ��
% f=imresize(f,4);
f=im2double(f);%ת����˫����
% imshow(f,'InitialMagnification','fit');title('��ʼͼ��');%��ʾ�����ͼ��
% imshow(log(1+(abs(imresize(f,8)))));title('��ʼͼ��');
imshow(f);title('��ʼͼ��');%��ʾ�����ͼ��
F=fft2(f);  %��ʾ
figure,imshow(log(1+fftshift(abs(F))),[]);title('��ʼƵ��');
%---------------------------------------------------------------------
% OTF=im2double(imread('otf16.tif'));   %��ȡOTF
% PSF=im2double(imread('psf16.tif'));   %��ȡPSF
% CirAper=ElipsoidalAperture(512,512,16,16);%������ֹƵ��Ϊ16���ص�512x512�Ŀ׾���
CirAper=ElipsoidalAperture(size(f,2),size(f,1),16,16);%������ֹƵ��Ϊ16���ص�512x512�Ŀ׾���
[OTF,PSF]=Aperture2OTF(CirAper);
%--------------------------------------------------------------------

%---------------------------------------------------------------------
% ʹ��MATLAB�Լ����ĵ�ͨ�˲��� ʹ��fspecial����
% ����һ����˹��ͨ��������
% PSF = fspecial('gaussian',13,11);
% OTF=psf2otf(PSF,size(f));
%-----------------------------------------------------
% �Լ���Ƶĵ�ͨ�˲���
% sigma=40;
% OTF=lpfilter('ideal',size(f,1),size(f,2),sigma);
% figure,imshow(log(1+fftshift(abs(OTF))),[]);title('low pass fft');
%-----------------------------------------------------------------------

%-----------------------------------------------------------------
% G=F.*fftshift(OTF);
% G=F.*OTF; %ע��ǰ����������OTF����״��
% figure,imshow(log(1+fftshift(abs(G))),[]);title('after low pass fft');
% g=ifft2(G);
% g=IMRA(g); %ȡʵ��������Ϊ��ֵ
% % figure,imshow(log(1+abs(imresize(g,8))),[]);title('after low pass');
% figure,imshow(g,[]);title('after low pass');
% PSF=fftshift(ifft2(OTF));
%---------------------------------------------------------------
[g,z]=blur_noise(f,PSF,30);
figure,imshow(g,[]);title('after blure low pass noise');
G=(fft2(g));
figure,imshow(log(1+fftshift(abs(G))),[]);title('after noise low pass fft');
%--------------------------------------------------
% ʹ���Լ���̵�����Ȼ�㷨
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
axis([1,256,0,1]), xlabel('Ƶ��'),ylabel('���ƶ�')
%---------------------------------------------
% ʹ���Լ���̵�����Ȼ�㷨
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
xlabel('��������');ylabel('MSE');
%-------------------------------------------------------------------------
% CirAper=ElipsoidalAperture(size(f,2),size(f,1),12,12);%������ֹƵ��Ϊ16���ص�512x512�Ŀ׾���
% [OTF1,PSF1]=Aperture2OTF(CirAper);

%--------------------------------------------
%--------------------------------------------------
% % ʹ���Լ���̵�ä����Ȼ�㷨
% % figure,mesh(fftshift(Hp));
% % PSF=fft2(OTF);
%  [g1,est_OTF]=BlindMaxLik(g,OTF1,50);
% ff1=fft2(g1);
% figure,imshow(log(1+(abs(g1))),[]);title('after blind ml');
% figure,imshow(log(1+fftshift(abs(ff1))),[]);title('after blind ml fft');
% % figure,imshow(log(1+fftshift(abs(est_OTF))),[]);title('after ml OTF');
%--------------------------------------------------------------------------
% %ʹ���Լ���̵��������㷨
% [g1]=MaxMap(f,OTF,50);
% ff1=fft2(g1);
% figure,imshow(log(1+(abs(imresize(g1,8)))),[]);title('after map');
% % figure,imshow(imresize(g1,8));title('after map');
% figure,imshow(log(1+fftshift(abs(ff1))));title('after map fft');
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%ʹ���Լ���̵�������㷨
% [g1]=mem1(g,OTF,50);
% ff1=fft2(g1);
% figure,imshow(log(1+(abs(g1))),[]);title('after map');
% % figure,imshow(imresize(g1,8));title('after map');
% figure,imshow(log(1+fftshift(abs(ff1))));title('after map fft');
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%-
% %ʹ��LUCY-RICHARSON
% % ע�����뵽Lucy_Richardson��PSF�ĺ��������ĶԳƵġ�
% gg2=deconvlucy(g,PSF,50);  % ע�����뵽Lucy_Richardson��PSF�ĺ��������ĶԳƵġ�
% ff2=fft2(gg2);
% % fff2=real(fft(gg2));
% figure,imshow(log(1+(abs(gg2))),[]);title('after rl');
% figure,imshow(log(1+fftshift(abs(ff2))),[]);title('after rl fft');
% % % figure,imshow(abs(fftshift(gg2)),[]);title('after rl');
% % figure,imshow(log(1+abs(fftshift(ff2))),[]);title('after rl fft');
% % figure,imshow(log(1+abs(fff2)),[]);title('after rl fft2');
% % figure,plot(norm3);title('error figure');
% %-----------------------------------------------------
% %äͼ��ָ�
% gg2=deconvblind(g,fftshift(real(PSF1)),150);  % ע�����뵽Lucy_Richardson��PSF�ĺ��������ĶԳƵġ�
% ff2=fft2(gg2);
% figure,imshow(log(1+(abs(gg2))),[]);title('after rl');
% figure,imshow(log(1+fftshift(abs(ff2))),[]);title('after rl fft');
% %--------------------------------------------------------------------------
% % Landweber �㷨
% lf=landweber2(g,OTF,1.2,0,100);
% ff2=fft2(lf);
% % fff2=real(fft(gg2));
% figure,imshow(abs(lf),[]);title('after landweber');
% % figure,imshow(imresize(lf,8));title('after landweber');
% figure,imshow(log(1+fftshift(abs(ff2))),[]);title('after landweber fft');
% % %--------------------------------------------------------------------------
% % % Adaptive Landweber �㷨
% [alf,r]=AdaptiveLandweber1(g,OTF,1,0,100);
% ff2=fft2(alf);
% % fff2=real(fft(gg2));
% figure,imshow(log(1+(abs(alf))),[]);title('after adaptive landweber');
% figure,imshow(log(1+fftshift(abs(ff2))),[]);title('after adaptive landweber fft');
