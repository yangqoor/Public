clear all;
clc;

w = imread('cameraman.tif');
% w = rgb2gray(w);
% w = imresize(w,1/5,'bilinear');
figure, imshow(w)

%wb = fftshift(fftn(w));
wf = fftshift(fft2(w));
%b = lowpass(w,50,2);

b = zeros(size(w));
h = size(w,1);
wid = size(w,2);
b(((h/2)-4):((h/2)+4),wid/2) = 1/9; % vertical
%b(h/2,((wid/2)-4):((wid/2)+4)) = 1/9;
c = b;
b = fftshift(fft2(b));
wb = wf.*b;
wba = abs(ifftshift(ifft2(wb)));
wba = uint8(255*mat2gray(wba));
figure, imshow(wba)

% w0 = imnoise(wba,'poisson'); %recorded image
%w0 = imnoise(wba,'gaussian',0,0.001);
% w0b = fftshift(fft2(w0));
% figure, imshow(w0) 
% w0bf = ifft2(w0b);

%Initial Estimate
%u = medfilt2(w0);
%u = imfilter(w0,c);
%figure, imshow(u);
u = wba;
z = u;

%noise = poissrnd(2,[size(u,1) size(u,2)]);
psf = c;
otf = psf2otf(psf);

tic;
while 1
    ufft = fftshift(fft2(u));
    temp1 = imfilter(u,psf);
    temp2 = wba ./ temp1 ;
    temp3 = imfilter(temp2,psf);
    
    %Updation
    unew = u .* uint8(temp3);
  
    imshow(unew);
    
    %Removing Negative Numbers
    unew(unew <0)  = 0;
    
    %Threshold
    diff = abs(sum((abs(unew(:)))) - sum(abs(double(u(:)))))./(sum(abs(double(u(:))))+eps) ;
    sum(diff)
    if sum(diff) < 0.0000001
        break
    else
        u = unew;
    end
    imshow(u);
    waitforbuttonpress;
end
toc
figure, imshow(u);