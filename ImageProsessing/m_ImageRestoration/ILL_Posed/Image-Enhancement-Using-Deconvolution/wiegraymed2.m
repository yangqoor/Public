clear all;
close all;
clc;

im = imread('images/pet1.png');
imf = fftshift(fft2(im));
figure, imshow(im);

cr = wait(imrect)
%figure; 
%imshow(im(cr(2):cr(2)+h(4),h(1):h(1)+h(3),:));
imc = im(cr(2):cr(2)+cr(4),cr(1):cr(1)+cr(3),:);
figure, imshow(imc);

%im = imread('cameraman.tif');
% %im = rgb2gray(im);
% figure, imshow(im)
% 
% imf = fftshift(fft2(im));
% %b = lowpass(im,30,2);
b = zeros(size(im));
h = size(im,1);
wid = size(im,2);
% %b(h/2,((wid/2)-4):((wid/2)+4)) = 1/9; % horizontal
b(((h/2)-2):((h/2)+2),((wid/2)-5):((wid/2)+5)) = 1/16; % h
% b(((h/2)-12):((h/2)+12),((wid/2)-12):((wid/2)+12)) = 1/50; % h
c = b;
figure, imshow(c);
% % b = fftshift(fft2(b));
% % wb = imf.*b;
% % out = abs(ifftshift(ifft2(wb)));
out = imfilter(im,b);
b = fftshift(fft2(b));
out = uint8(255*mat2gray(out));
%figure
%imshow(out)
wnf = fftshift(fft2(out));

%w0 = normrnd(0,30,[size(im,1) size(im,2)]);
%nf = fftshift(fft2(w0));
 
% wn = out + (uint8(w0));
% figure, imshow(wn);
% wnf = fftshift(fft2(wn));

% tmp = ones(size(im)); %+ 255;
% temp = imnoise(tmp,'speckle',0.001);

% nf = fftshift(fft2(imc));
nf = fftshift(fft2(imc)) ;

snr = mean2(abs(imf.^2))./(mean2(abs(nf.^2)))
snr(snr<0) = 0;

k = (1./snr) * 10
w1 = imf.*((conj(b))./((abs(b).^2)+k));
w1a=abs(ifftshift(ifft2(w1)));
x = mat2gray(w1a);
figure
imshow(x,[])
figure, imshow(imadjust(x));
