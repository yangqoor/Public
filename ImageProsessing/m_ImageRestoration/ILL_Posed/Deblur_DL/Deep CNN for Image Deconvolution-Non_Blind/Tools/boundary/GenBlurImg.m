function [FBImg, FImg, UBImg] = GenBlurImg(img,PSF,noisestr)
    % input image should be of the type double 
    % PSF should be positive and summed to 1 

    if nargin < 3
        noisestr = 0;
    end    
    
    [kerH, kerW] = size(PSF);
    blurimg = zeros(size(img,1),size(img,2),size(img,3));
    for ch = 1:size(img,3)
        % blur degragation
        blurimg(:,:,ch) = conv2(img(:,:,ch),PSF,'same');
    end
    % quantization
    UBImg = uint8(blurimg*255);    
    % noise degration
    if noisestr > 0 
        UBImg = imnoise(UBImg,'gaussian',0,noisestr);
        noisebimg = im2double(UBImg);
    else
        noisebimg = im2double(UBImg);
    end    
    FImg = img(1+kerH:end-kerH,1+kerW:end-kerW,:);
    FBImg = noisebimg(1+kerH:end-kerH,1+kerW:end-kerW,:);
    
    UBImg = UBImg(1+kerH:end-kerH,1+kerW:end-kerW,:);