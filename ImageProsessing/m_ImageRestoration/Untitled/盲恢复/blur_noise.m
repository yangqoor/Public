function [z,y]= blur_noise(x,psf,SNR)
%----------------------------------
%降晰增加噪声
%psf为点扩展函数,SNR为要加的信号比,一般加的高斯零均值的噪声.
[M,N]=size(x);
% y=filter2(f,x);
% y=fftshift(y);
X=fft2(x);
OTF=fft2(psf);
% G=F.*fftshift(OTF);
G=X.*OTF; %注意前面所产生的OTF的形状，
% figure,imshow(log(1+fftshift(abs(G))),[]);title('after low pass fft');
y=ifft2(G);
% y=real(y);
y=IMRA(y); %取实部，限制为正值
%----------------------------------------
% S_y=var2(y);
%----------------------------
%可以用这个计算方差
S_y = (std2(y))^2;
%
%-----------------------------------------------
a=sqrt(S_y/(10^(SNR/10)));
z=y+randn(M,N)*a+0;
%------------------------------------------------
%另外一种方式
% z=imnoise(y,'gaussian',0,a^2);

%---------------------------------------
z=abs(z);