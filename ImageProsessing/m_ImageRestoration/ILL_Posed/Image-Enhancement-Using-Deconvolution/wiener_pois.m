clear all;
close all;
clc;

w = imread('cameraman.tif');
%figure
%imshow(w)
%wb = fftshift(fftn(w));
wf = fftshift(fftn(w));
b = lbutter(w,50,2);
wb = wf.*b;
wba = abs(ifftn(wb));
wba = uint8(255*mat2gray(wba));
figure
imshow(wba)

w0 = imnoise(wba,'gaussian',0.01);
w0b = fftshift(fftn(w0));
figure
imshow(w0)

%k = mean(abs((wf.^2)./(w0b.^2)));
k = mean2(abs((wf.^2)./(w0b.^2)))*0.01
wbf=fftshift(fftn(wba));
w1=wbf.*((conj(b))./(abs(b).^2+k)./b); % This is the equation
w1a=abs(ifftn(w1));
x = mat2gray(w1a);
figure
imshow(x)