clear all;
clc;

im = imread('concordaerial.png');
im = imresize(im,1/2,'bilinear');

R = im(:,:,1);
G = im(:,:,2);
B = im(:,:,3);
imshow(im)

Rfft = fftshift((fft2(R)));
Gfft = fftshift((fft2(G)));
Bfft = fftshift((fft2(B)));

hR = fspecial('gaussian', size(R), 2);
hRf = fftshift((fft2(hR)));
gR = imfilter(R, hR);
gG = imfilter(G, hR);
gB = imfilter(B, hR);

% b = lowpass(im,30,2);
% wbR = Rfft.*b;
% wbG = Gfft.*b;
% wbB = Bfft.*b;
out = (cat(3,gR,gG,gB));
figure, imshow(out)

% hR = fspecial('average', size(im,1));
% hRf = (fft2(hR));
% out = imfilter(im, hR);
% figure, imshow(out)

imfR = fftshift((fft2(im(:,:,1))));
imfG = fftshift((fft2(im(:,:,2))));
imfB = fftshift((fft2(im(:,:,3))));

outf = fftshift((fft2(out)));

% z = zeros(size(im,1),size(im,2));
% w0 = imnoise(z,'gaussian',4);

w0 = normrnd(0,30,[size(im,1) size(im,2)]);
nf = fftshift((fft2(w0)));
figure, imshow(w0)

gRfft = fftshift((fft2(out(:,:,1))));
gGfft = fftshift((fft2(out(:,:,2))));
gBfft = fftshift((fft2(out(:,:,3))));

% gRnfft = gRfft + nf;
% gGnfft = gGfft + nf;
% gBnfft = gBfft + nf;
% 
% gRn1 = mat2gray(abs(ifft2(gRnfft)));
% gGn1 = mat2gray(abs(ifft2(gGnfft)));
% gBn1 = mat2gray(abs(ifft2(gBnfft)));

gRn1 = gR + (uint8(w0));
gGn1 = gG + (uint8(w0));
gBn1 = gB + (uint8(w0));

figure
imshow(uint8(cat(3,gRn1,gGn1,gBn1)));

%gRn1 = imnoise(out,'gaussian',0.01);
%figure
%imshow(gRn1)
nfR = fftshift((fft2(gRn1)));
nfG = fftshift((fft2(gGn1)));
nfB = fftshift((fft2(gBn1)));
%l = abs(nf.^2)-abs(outf.^2);

snrR = mean2(abs((imfR.^2)./(nf.^2)));
snrG = mean2(abs((imfG.^2)./(nf.^2)));
snrB = mean2(abs((imfB.^2)./(nf.^2)));
snr = (snrR + snrG + snrB)/3;

%snr = abs((imf).^2 / (nf).^2)

% [x, y] = size(snr);
% for i=1:x
%     for j = 1:y
%         if snr(i,j) == 0
%             snr(i,j) = 0.0001;
%         end
%     end
% end

k = (1/snr) * 10
%w1=nf.*((abs(hRf).^2)./(abs(hRf).^2+k)./hRf); % This is the equation
w1R=nfR.*((conj(hRf))./((abs(hRf).^2)+k)); 
w1G=nfG.*((conj(hRf))./((abs(hRf).^2)+k));
w1B=nfB.*((conj(hRf))./((abs(hRf).^2)+k));
%w1=nf.*((abs(hRf).^2)./(abs(hRf).^2+k)./hRf);
wR=abs(ifftshift(ifft2(w1R)));
wG=abs(ifftshift(ifft2(w1G)));
wB=abs(ifftshift(ifft2(w1B)));

x = mat2gray(cat(3,wR,wG,wB));
figure
imshow(x)

% h1R = round(size(wR,1)/2);
% h2R = round(size(wR,2)/2);
% finalR = zeros(size(wR,1),size(wR,2));
% for i=1:h1R
%     for j=1:h2R
%         finalR(h1R+i,h2R+j) = wR(i,j);
%     end
% end
% for i=h1R+1:size(wR,1)
%     for j=1:h2R+1
%         finalR(i-h1R,j+h2R) = wR(i,j);
%     end
% end
% for j=h2R+1:size(wR,2)
%     for i=1:h1R+1
%         finalR(i+h1R,j-h2R) = wR(i,j);
%     end
% end
% for i=h1R+1:size(wR,1)
%     for j=h2R+1:size(wR,2)
%         finalR(i-h1R,j-h2R) = wR(i,j);
%     end
% end
% 
% h1G = round(size(wG,1)/2);
% h2G = round(size(wG,2)/2);
% finalG = zeros(size(wG,1),size(wG,2));
% for i=1:h1G
%     for j=1:h2G
%         finalG(h1G+i,h2G+j) = wG(i,j);
%     end
% end
% for i=h1G+1:size(wG,1)
%     for j=1:h2G+1
%         finalG(i-h1G,j+h2G) = wG(i,j);
%     end
% end
% for j=h2G+1:size(wG,2)
%     for i=1:h1G+1
%         finalG(i+h1G,j-h2G) = wG(i,j);
%     end
% end
% for i=h1G+1:size(wG,1)
%     for j=h2G+1:size(wG,2)
%         finalG(i-h1G,j-h2G) = wG(i,j);
%     end
% end
% 
% h1B = round(size(wB,1)/2);
% h2B = round(size(wB,2)/2);
% finalB = zeros(size(wB,1),size(wB,2));
% for i=1:h1B
%     for j=1:h2B
%         finalB(h1B+i,h2B+j) = wB(i,j);
%     end
% end
% for i=h1B+1:size(wB,1)
%     for j=1:h2B+1
%         finalB(i-h1B,j+h2B) = wB(i,j);
%     end
% end
% for j=h2B+1:size(wB,2)
%     for i=1:h1B+1
%         finalB(i+h1B,j-h2B) = wB(i,j);
%     end
% end
% for i=h1B+1:size(wB,1)
%     for j=h2B+1:size(wB,2)
%         finalB(i-h1B,j-h2B) = wB(i,j);
%     end
% end
% 
% x = mat2gray(cat(3,finalR,finalG,finalB));
% figure
% imshow(x)
