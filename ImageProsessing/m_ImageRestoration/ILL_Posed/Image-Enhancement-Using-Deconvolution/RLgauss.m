clear all;
clc;

w = imread('cameraman.tif');
%w = rgb2gray(w);
%w = imresize(w,1/2,'bilinear');
figure, imshow(w)

%wb = fftshift(fftn(w));
wf = fftshift(fft2(w));
%b = lowpass(w,50,2);

b = zeros(size(w));
h = size(w,1);
wid = size(w,2);
b((round(h/2)-4):(round(h/2)+4),round(wid/2)) = 1/9; % vertical
%b(round(h/2),(round(wid/2)-4):(round(wid/2)+4)) = 1/9;
c = b;
b = fftshift(fft2(b));
wb = wf.*b;
wba = abs(ifftshift(ifft2(wb)));
wba = uint8(255*mat2gray(wba));
figure, imshow(wba)

% w0 = imnoise(wba,'poisson'); %recorded image
w0 = imnoise(wba,'gaussian',0,0.002);
%w0 = imnoise(wba,'speckle',0.1);
w0b = fftshift(fft2(w0));
figure, imshow(w0) 
w0bf = ifft2(w0b);

%Initial Estimate
%u = medfilt2(w0);
u = imfilter(w0,c);
figure, imshow(u);
z = u;
i = size(u,1);
j = size(u,2);

%noise = poissrnd(2,[size(u,1) size(u,2)]);
psf = c;
otf = psf2otf(psf);

tic;
%for i=1:1000000
while 1
    ufft = fftshift(fft2(u));
%     temp1 = ufft .* otf;
%     temp1 = ifft2(temp1);
    temp1 = imfilter(u,psf);
    %tmp = conj(temp1) ./ ((real(temp1)).^2 + (imag(temp1)).^2) ; 
%     temp2 = w0 ./temp1 ;
    temp2 = w0 - temp1 ;
    temp3 = imfilter(temp2,psf);
    %temp3 = (fftshift(fft2(temp2))) .* (conj(otf));
    %temp4 = ifft2(temp3);
    
    %Updation
    %unew = (ifft2(ufft)) .* temp4;
    unew = u + uint8(temp3);
%     unewf = fft2(unew) ;
%     unew = ifft2(unewf) ;
  
    %Removing Negative Numbers
    unew(unew <0)  = 0;
    %Threshold
    diff = abs(sum((abs(unew(:)))) - sum(abs(double(u(:)))))./(sum(abs(double(u(:))))+eps) ;
    sum(diff)
    if sum(diff) < 0.00001
        break
    else
        u = unew;
    end
%     imshow(u);
%     waitforbuttonpress;
end
toc
figure, imshow(u);