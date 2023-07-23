clear;

%% load

im1=double(imread('image2.jpg'));
im1=im1/max2(im1);

bim=interp2(im1,3,'cubic'); 
psf=fspecial('gaussian',[15,15],3.7);
figure;imshow(bim,[]);
%%  use my min2newton function
gamma=0.001;
[im_deblur,MSE,stop_time,performance]=min2newton2(bim,psf,gamma);
 imshow(im_deblur,[]);
%% use newton functin
% [im_deblur,MSE,stop_time,performance]=landweber13(bim,psf,500,0,im1)
%  imshow(im_deblur,[]);
%  draw_spectrum(im_deblur);

%%  加入增量运算，进一步提高质量
gamma=0.001;MSE_min_first=100000;MSE_min_next=10000;

[im_deblur,MSE,stop_time,performance]=min2newton2(bim,psf,gamma);
 MSE=MSE/prod(size(bim));
gamma=0.001;

for k=1:9
    [im_deblur,MSE,stop_time]=min2newton_increment2(bim,im_deblur,psf,gamma);
end
im2=im_deblur;
%im2(im2<0.48)=0;
figure;imshow(im2,[]);  

% %%  use my min2newton +  landweber
%  gamma=0.001;
%  [im_deblur,MSE,stop_time,performance]=min2newton(bim,psf,im1,gamma);
%   imshow(im_deblur,[]);
%   
%   incr_x=im1-im_deblur; incr_y=bim-imfilter(im_deblur,psf);iter=100;th=0;
%  [im_delta,MSE,stop_time,performance]=landweber13(incr_y,psf,iter,th,incr_x)
% 
%  im_deblur=im_deblur+im_delta;
%  im_deblur(im_deblur<0)=0;
%  im_deblur(im_deblur>1)=1;
%  figure;imshow(im_deblur,[]);
%  
%   [im_delta,MSE,stop_time,performance]=landweber13(bim,psf,1000,th,im1);
%   figure;imshow(im_delta);
%%
% rim=deconvwnr(bim,psf,noise_density*15);
% rim=real(rim);
% rim(rim<0)=0;
% rim(rim>1)=1;

% figure;
% imshow(rim,[]);
















