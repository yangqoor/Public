clear;
%15          16       17      18        19         20          21     
%0.0011     0.0009   0.0007   0.00056   0.000447   0.000359   0.00028
%22
%0.00022
sigma=0.000225 ;  %��������
%% �˹�ͼ�� Landweber�㷨ʵ�������ͼ��
%�˹�ԭʼͼ��
image1;
im2=im1;
%imshow(im2);  

%�˹�ͼ���Ƶ��
%draw_spectrum(im2);

%�˹�����ͼ��
psf=fspecial('gaussian',[15,15],4.6);
bim=imfilter(im2,psf, 'replicate');

bim2=imnoise(bim,'gaussian',0,sigma);
%figure;imshow(bim2,[]);
dd=snr(im2,sigma);
%�˹�����ͼ���Ƶ��
%draw_spectrum(bim2);

%�˹�ͼ��Landweber�㷨�ָ�ͼ��
[im_deblur,MSE,stop_time,performance]=landweber13(bim2,psf,1000,0,im2);
%[im_deblur,MSE,stop_time,performance]=landweber13(bim2,psf,1000,[0,1]);
%figure;imshow(im_deblur,[]);
%figure;plot(MSE);
%�˹�ͼ��Landweber�㷨�ָ�ͼ���Ƶ��
%�˹�ͼ���Ƶ��
%draw_spectrum(im_deblur);
%% �˹�ͼ�� ͶӰNL�㷨ʵ�������ͼ��



%gamma=0.001;
[im_deblur,MSE1,stop_time1,performance]=landweber14(bim2,psf,30,0,im2);
%figure;imshow(im_deblur);

%figure;plot(MSE1(1:20));
%draw_spectrum(im_deblur);
%Newton���ָ���ͼ��
%imshow(im_deblur,[]);  
%Pocs-NL�ָ���ͼ��

im_deblur(im_deblur<0.05)=0;
 im_deblur(im_deblur>0.9)=1;
[im_deblur,MSE2,stop_time2,performance]=landweber13(im_deblur,psf,50,0,im2);
%figure;plot(MSE2(1:20));
%figure;imshow(im_deblur,[]);  

%draw_spectrum(im_deblur);
