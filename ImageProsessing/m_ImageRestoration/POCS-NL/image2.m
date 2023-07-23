%% draw concentric circles
clear;
im=zeros(256,256);

%draw the center point
radius=2;
im1=draw_circle(im,radius);

%draw the first inner circle
radius=25;
im1=draw_circle(im1,radius);

%draw the 2nd circle
radius=48;
im1=draw_circle(im1,radius);

%draw the 3rd inner circle
radius=60;
im1=draw_circle(im1,radius);

%draw the first 4th circle
radius=110;
im1=draw_circle(im1,radius);

%draw the first 5th circle
radius=128;
im1=draw_circle(im1,radius);

im1=double(im1); 
subplot(321);imshow(im1);

%% blur and desample;
% set psf
psf=fspecial('gaussian',[25,25],5);

%blur
bim=imfilter(im1,psf);
bim=bim/max(bim(:));
bim=imnoise(bim,'gaussian',0.01);
subplot(322);imshow(bim,[]);

% desample
bim2=bim(1:4:end,1:4:end);
subplot(323);imshow(bim2,[]);

%upsample
%实践说明，频率插值效果并不好，图像在45度方向上出现大幅度模糊
%bim3=interp_fre2(bim2,4);    %use frequence interpolation
%subplot(224);imshow(bim3,[]);

%use 'cubic'
bim3=interp2(bim2,2,'cubic');
bim3(bim3<0)=0;
subplot(324);imshow(bim3,[]);

%计算MSE，保存在Mse中
Mse=zeros(1,100);
rim=bim;
N=30;   %iteration time
for iter=1:N;
    rim=deconvlucy(rim,psf,1);
    rim_k=deconvlucy(bim,psf,5);

    Mse(iter)=mse1(im1,rim);
end
 subplot(325);imshow(rim/max2(rim),[]);
 figure;plot(Mse);

rim2=deconvlucy(bim,psf,N);
figure;imshow(rim2/max2(rim2),[]);

% rf=ML(bim,psf,20);
% imshow(rf/max2(rf));









