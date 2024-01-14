function imOut = imDnSample2(im, lev)
% Downsamples an image by a factor of 2 "lev" times
% Implemented in a recursive manner
% June 16 2009 Taeg Sang Cho

if lev == 0
    % no downsampling
    imOut = im;
    return;
elseif lev > 1
    % more than one level downsampling
    im = imDnSample2(im, lev-1);
end

%prefilter
sigma = 0.7;
kernel = exp(-([1:5]' - 3).^2/(2*sigma^2));
filt = kernel*kernel';
filt = filt/sum(filt(:));

padSize = 5;

filtFFT = fftshift(filterFFT(filt, size(im, 2) + 2*padSize, size(im, 1)+ 2*padSize));
imOutT = zeros(size(im));

for j = 1:size(im, 3);
    imPad = padarray(im(:, :, j), [padSize, padSize],'replicate','both');
    imOutFFT = fftshift(fft2(ifftshift(imPad))).*filtFFT;
    imOutTT = fftshift(ifft2(ifftshift(imOutFFT)));
    imOutT(:, :, j) = imOutTT(padSize+1:end-padSize, padSize+1:end-padSize);
end
imOut = imOutT(1:2:end, 1:2:end, :);
