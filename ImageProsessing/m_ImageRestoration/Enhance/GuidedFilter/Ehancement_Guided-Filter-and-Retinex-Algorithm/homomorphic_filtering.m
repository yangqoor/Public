function [imghm] = homomorphic_filtering(img)


% Homomorphic filtering -----------------
% convert img to floating-point type
img = im2double(img);
% convert the image to log domain
img = log(1+img);

% DFT  wraparound error solve.
M = 2*size(img,1)+1;
N = 2*size(img,2)+1;
std = 10; % setting a standard deviation for Gaussian to filter out low frequency band 

% the high pass filter
[X,Y] = meshgrid(1:N,1:M);
centerX = ceil(N/2);    
centerY = ceil(M/2);    
gaussianNumerator = (X - centerX).^2 + (Y - centerY).^2;
H = exp(-gaussianNumerator./(2*std.^2)); 
H = 1 - H;  
H = fftshift(H); % rearranging the filter in uncentered format

% high pass filter the log transformed img in the frequency domain
imgf = fft2(img,M,N); 
imgout = real(ifft2(H.*imgf)); 
imgout = imgout(1:size(img,1),1:size(img,2)); 

imghm = exp(imgout) - 1; % apply exponential to invert log transform to get the Homomorphic Img


end

