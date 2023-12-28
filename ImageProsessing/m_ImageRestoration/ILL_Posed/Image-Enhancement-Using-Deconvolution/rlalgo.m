clear all;
clc;

w = imread('top.jpg');
w = rgb2gray(w);
w = imresize(w,1/5,'bilinear');
figure, imshow(w)
%figure
%imshofn.tiw(w)
%wb = fftshift(fftn(w));
wf = fftshift(fft2(w));
b = lowpass(w,30,2);
wb = wf.*b;
wba = abs(ifft2(wb));
wba = uint8(255*mat2gray(wba));
figure
imshow(wba)

%w0 = imnoise(wba,'poisson'); %recorded image
w0 = imnoise(wba,'salt & pepper',0.03);
%w0 = imnoise(wba,'speckle',0.1);
w0b = fftshift(fft2(w0));
figure
imshow(w0) 
w0bf = ifft2(w0b);

%Initial Estimate
u = medfilt2(w0);
figure
imshow(u);
i = size(u,1);
j = size(u,2);

%noise = poissrnd(2,[size(u,1) size(u,2)]);
psf = b;

% size(u)
% size(psf)
otf = psf2otf(psf);

tic;
for i=1:1000
    %display('a')
    ufft = fftshift(fft2(u));
    %psffft = fftshift(fft2(psf));
    temp1 = ufft .* otf;
    temp1 = ifft2(temp1);
    %u = reshape(u,1,((size(u,1)) * (size(u,2))));
    %psf = reshape(psf,1,((size(psf,1)) * (size(psf,2))));
    %temp1 = conv2(u,psf);
    %temp1 = reshape(temp1,size(u,1),size(u,2));
    %temp2 = w0./temp1;
    tmp = conj(temp1) ./ ((real(temp1)).^2 + (imag(temp1)).^2) ; 
    temp2 = w0bf .* tmp ;
    temp3 = (fftshift(fft2(temp2))) .* (conj(otf));
    temp4 = ifft2(temp3);
    
    %Updation
    unew = (ifft2(ufft)) .* temp4;
  
    %Removing Negative Numbers
    unew(unew <0)  = 0;
    
    %Threshold
    diff = sum((abs(unew(:)))) - sum(abs(double(u(:))))./sum(abs(double(u(:))))+eps ;
    sum(diff)
    if sum(diff) < 0.0001
        break
    else
        u = unew;
    end
    imshow(u);
    waitforbuttonpress;
end
toc

figure 
imshow(u);
    
