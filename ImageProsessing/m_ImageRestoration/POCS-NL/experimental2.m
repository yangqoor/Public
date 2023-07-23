clear;
%15          16       17      18        19         20          21     
%0.0011     0.0009   0.0007   0.00056   0.000447   0.000359   0.00028
%22
%0.00022
sigma=0.000225 ;  %噪声方差
%% 人工图像 Landweber算法实验产生的图像
%人工原始图像
image1;
im2=im1;
%imshow(im2);  

%人工图像的频谱
%draw_spectrum(im2);

%人工降晰图像
psf=fspecial('gaussian',[15,15],4.6);
bim=imfilter(im2,psf, 'replicate');

bim2=imnoise(bim,'gaussian',0,sigma);
%figure;imshow(bim2,[]);
dd=snr(im2,sigma);
%人工降晰图像的频谱
%draw_spectrum(bim2);

%人工图像Landweber算法恢复图像
[im_deblur,MSE,stop_time,performance]=landweber13(bim2,psf,1000,0,im2);
%[im_deblur,MSE,stop_time,performance]=landweber13(bim2,psf,1000,[0,1]);
%figure;imshow(im_deblur,[]);
%figure;plot(MSE);
%人工图像Landweber算法恢复图像的频谱
%人工图像的频谱
%draw_spectrum(im_deblur);
%% 人工图像 投影NL算法实验产生的图像



%gamma=0.001;
[im_deblur,MSE1,stop_time1,performance]=landweber14(bim2,psf,30,0,im2);
%figure;imshow(im_deblur);

%figure;plot(MSE1(1:20));
%draw_spectrum(im_deblur);
%Newton法恢复的图像
%imshow(im_deblur,[]);  
%Pocs-NL恢复的图像

im_deblur(im_deblur<0.05)=0;
 im_deblur(im_deblur>0.9)=1;
[im_deblur,MSE2,stop_time2,performance]=landweber13(im_deblur,psf,50,0,im2);
%figure;plot(MSE2(1:20));
%figure;imshow(im_deblur,[]);  

%draw_spectrum(im_deblur);
