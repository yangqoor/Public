function ifbl = degrade(im, LEN, THETA, noisetype, M, V)
%Converting the image to grayshade by eliminating hue and saturation
if size(im, 3) == 3,
    im = rgb2gray(im);
end

%Converting to double
imd = im2double(im);

%Converting the image to frequency domain
imf = fft2(imd);

%Create PSF of degradation
PSF = fspecial('motion',LEN,THETA);

%Convert psf to otf of desired size
%OTF is Optical Transfer Function
%fbl is blurred image in frequency domain
OTF = psf2otf(PSF,size(im));

%Blurring the image
fbl = OTF.*imf;

%Converting back to spatial domain
ifbl = abs(ifft2(fbl));

%Checking if the image is in the range 0 to 1
for i = 1:size(ifbl, 1)
    for j = 1:size(ifbl, 2)
        if ifbl(i, j) >= 1
            ifbl(i, j) = 0.999999;
        end
        if ifbl(i, j) <= 0
            ifbl(i, j) = 0.000001;
        end
    end
end        

%Adding noise
if nargin>3
    if nargin==4      %using default values
        ifbl = imnoise(ifbl, noisetype);
    elseif nargin==5  %specifying additional parameters explicitly
        ifbl = imnoise(ifbl, noisetype, M);
    elseif nargin==6  %specifying additional parameters explicitly
        ifbl = imnoise(ifbl, noisetype, M, V);
    end
end