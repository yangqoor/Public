I = checkerboard(8);%原图像
noise = 0.1*randn(size(I));%噪声
PSF = fspecial('motion',21,11);%运动模糊的滤波器
Blurred = imfilter(I,PSF,'circular');%产生运动模糊的图像
BlurredNoisy = im2uint8(Blurred + noise);%运动模糊的图像加上噪声
NSR = sum(noise(:).^2)/sum(I(:).^2);%噪声信号功率比
NP = abs(fftn(noise)).^2; 
NPOW = sum(NP(:))/prod(size(noise));%噪声功率谱
NCORR = fftshift(real(ifftn(NP))); %噪声自相关函数
IP = abs(fftn(I)).^2;%
IPOW = sum(IP(:))/prod(size(I));%原图像功率谱
ICORR = fftshift(real(ifftn(IP)));%原图像相关函数
ICORR1 = ICORR(:,ceil(size(I,1)/2));
NSR = NPOW/IPOW;%噪声信号功率比
J1=deconvwnr(BlurredNoisy,PSF);%依次改变各个参数进行维纳滤波
J2=deconvwnr(BlurredNoisy,PSF,NSR);
J3=deconvwnr(BlurredNoisy,PSF,NCORR,ICORR);
J4=deconvwnr(BlurredNoisy,PSF,NPOW,ICORR1);
figure,%显示原图像，退化的图像和维纳滤波后的图像
subplot(321), imshow(I); title('original image');
subplot(322); imshow(BlurredNoisy,[]); 
title('A = Blurred and Noisy');
subplot(323), imshow(J1,[]); title('deconvwnr(BlurredNoisy,PSF)');
subplot(324);imshow(J2,[]); title('deconvwnr(A,PSF,NSR)');
subplot(325);imshow(J3,[]); title('deconvwnr(A,PSF,NCORR,ICORR)');
subplot(326);imshow(J4,[]); title('deconvwnr(A,PSF,NPOW,ICORR_1_D)');
