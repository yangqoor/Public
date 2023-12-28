clear all;
clc;

% A = imread('roll.png');
% h = fspecial('gaussian', size(A), 3);
% g = imfilter(A, h);
% imshow(A)
% figure
% imshow(g)

im = imread('yellowlily.jpg');
R = im(:,:,1);
G = im(:,:,2);
B = im(:,:,3);
imshow(im)

hR = fspecial('gaussian', size(R), 3);
gR = imfilter(R, hR);
hG = fspecial('gaussian', size(G), 3);
gG = imfilter(G, hG);
hB = fspecial('gaussian', size(B), 3);
gB = imfilter(B, hB);
out = uint8(cat(3,gR,gG,gB));
figure, imshow(out)

imf = fftshift(fft2(im));
outf = fftshift(fft2(out));

z = zeros(size(im,2),size(im,1));
w0 = imnoise(z,'gaussian',0.01);
figure, imshow(w0)
nf = fftshift(fft2(w0));

gRfft = fftshift(fft2(gR));
gGfft = fftshift(fft2(gG));
gBfft = fftshift(fft2(gB));

gRnfft = gRfft + nf;
gGnfft = gGfft + nf;
gBnfft = gBfft + nf;

gRn = mat2gray(abs(ifft2(gRnfft)));
gGn = mat2gray(abs(ifft2(gGnfft)));
gBn = mat2gray(abs(ifft2(gBnfft)));

nim = uint8(cat(3,gRn,gGn,gBn));
figure
imshow(nim);
