load artimage;
im1=artimage;
noise_density=0.001;
im1=im1/max2(im1);
% figure;imshow(im1,[]);
% draw_spectrum(im1,0);
% Ä£ºýÍ¼Ïñ
psf=fspecial('gaussian',[15,15],4.6);

bim=imfilter(im1,psf);
bim=imnoise(bim,'gaussian',0,noise_density);

Fbim=fft2(bim);
Fbim=Fbim-mean(Fbim(:));
spec1=xcorr2(Fbim,conj(Fbim));

spec1=abs(spec1);
spec1=spec1/max2(spec1);

imshow(spec1);

