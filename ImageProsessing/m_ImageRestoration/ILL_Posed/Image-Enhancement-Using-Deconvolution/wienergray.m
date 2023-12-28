clear all;
close all;
clc;

% im = imread('../top.jpg');
% im = rgb2gray(im);
im = imread('cameraman.tif');
imshow(im)

hR = fspecial('gaussian', size(im), 1);
hRf = (fft2(hR));
out = imfilter(im, hR);

imf = (fft2(im));
outf = (fft2(out));

z = zeros(size(im,1),size(im,2));
w0 = imnoise(z,'gaussian',0.1);
figure, imshow(w0)
nf = fftshift(fft2(w0));
gRfft = fftshift(fft2(out));
gRnfft = gRfft + nf;
gRn = mat2gray(abs(ifft2(gRnfft)));
figure
imshow(uint8(255*gRn));


gRn1 = imnoise(out,'gaussian',0.01);
figure
imshow(gRn1);
nf = (fft2(gRn1));
l = abs(nf.^2)-abs(outf.^2);

snr = mean2(abs((imf.^2)./l));
%snr = abs((imf).^2 / (nf).^2)

[x, y] = size(snr);
for i=1:x
    for j = 1:y
        if snr(i,j) == 0
            snr(i,j) = 0.0001;
        end
    end
end

k = (1/snr)*10
%w1=nf.*((abs(hRf).^2)./(abs(hRf).^2+k)./hRf); % This is the equation
w1=nf.*((conj(hRf))./((abs(hRf).^2)+k)); % This is thw1=wbf.*((conj(b))./(abs(b).^2+k)./b); % This is the equatione equation
%w1=nf.*((abs(hRf).^2)./(abs(hRf).^2+k)./hRf);
w1a=abs(ifftshift(ifft2(w1)));
x = mat2gray(w1a);
% figure
%imshow(x)

% h1 = size(x,1)/2;
% h2 = size(x,2)/2;
% final = zeros(size(x,1),size(x,2));
% 
% for i=1:h1
%     for j=1:h2
%         final(h1+i,h2+j) = x(i,j);
%     end
% end
% 
% for i=h1+1:size(x,1)
%     for j=1:h2+1
%         final(i-128,j+128) = x(i,j);
%     end
% end
% 
% for j=h1+1:size(x,1)
%     for i=1:h2+1
%         final(i+128,j-128) = x(i,j);
%     end
% end
% 
% for i=h1+1:size(x,1)
%     for j=h2+1:size(x,2)
%         final(i-h1,j-h2) = x(i,j);
%     end
% end

figure
imshow(x,[])