clear all;
close all;
clc;

im = imread('../flower.jpg');
im = rgb2gray(im);
figure, imshow(im)

imf = fftshift(fft2(im));
%b = lowpass(im,30,2);
b = zeros(size(im));
h = size(im,1);
wid = size(im,2);
%b(h/2,((wid/2)-4):((wid/2)+4)) = 1/9; % horizontal
% b((round(h/2)-8):(round(h/2)+8),(round(wid/2)-3):(round(wid/2)+3)) = 1/24; % vertical
b((round(h/2)-8):(round(h/2)+8),round(wid/2)) = 1/24; % vertical
c=b;
b = imrotate(b,45,'crop');
% b(h/2,wid/2) = 1; % vertical
figure, imshow(b);

% b = fftshift(fft2(b));
% wb = imf.*b;
% out = abs(ifftshift(ifft2(wb)));
out = imfilter(im,b);
b = fftshift(fft2(b));
out = uint8(255*mat2gray(out));
figure
imshow(out)
outf = fftshift(fft2(out));

%w0 = normrnd(0,30,[size(im,1) size(im,2)]);
w0 = normrnd(0,30,[size(im)]);
nf = fftshift(fft2(w0));

wn = out + (uint8(w0));
figure, imshow(wn);
wnf = fftshift(fft2(wn));

% im = imread('images/oct_1.png');
% imf = fftshift(fft2(im));

snr = mean2(abs((imf.^2)./(nf.^2)))
%snr(snr<0) = 0;

k = (1./snr) * 10
w1 = wnf.*((conj(b))./((abs(b).^2)+k));
w1a=abs(ifftshift(ifft2(w1)));
x = mat2gray(w1a);
figure
imshow(x)
