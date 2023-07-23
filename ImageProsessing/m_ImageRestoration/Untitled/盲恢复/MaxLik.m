function [im_deblur,estnorm1,estnorm2,estnorm3,likeli] = MaxLik(im, OTF, iterations,im_ideal)
%可以计算最大似然关系
% function im_deblur = MaxLik(im, OTF, iterations)
% function im_deblur = MaxLik(im, PSF, iterations)
% SuperResolution Restores Image Using Maximum Liklihood Method
%
% 
% Inputs: im, OTF, iterations
% Returns: im_deblur
%
% im:    Input Image
% OTF: Blur OTF 
% iterations: Number of Iterations Through Maximum Liklihood Algorithm
%
% im_deblur: SuperResolution Restored Image

% Create psf of Blur
% psf = fspecial('motion',len,angle);

% Performing Median Filtering 
% im = medfilt2(abs(im));

% Convert psf to OTF of Desired Size
% OTF is Optical Transfer Function
% OTF = psf2otf(PSF,size(im));

% Initialize Estimate to Recorded Image
est = im;

i = 1;
while i<=iterations
    
    % Convert Estimate to Frequency Domain
    fest = fft2(est);
    
    % Multiply OTF with Estimate in Frequency Domain
    fblest = OTF.*fest;
    
    % Convert Blurred Image Estimate to Spatial Domain
    imest = ifft2(fblest);
    
    % Ratio of Blurred Image and Estimate of Deblurred Image
    iratio = im./imest;
    
    % Convert Ratio to Frequency Domain
    firatio = fft2(iratio);
    
    % Create Correction Vector
    corrvec = OTF .* firatio;
    
    % Convert Correction Vector to Spatial Domain
    icorrvec = ifft2(corrvec);
    
    % Multiply Correction Vector & Estimate of Deblurred Image, Create Next Estimate
    aftercorr = icorrvec.*est;
    est = aftercorr;
    est=IMRA(est);
    estnorm1(i)=norm2(im_ideal,est);
    ESTF=fft2(est);
    ESTG=ESTF.*OTF;
    estg=ifft2(ESTG);
    estg=IMRA(estg);
     estnorm2(i)=corr2(im_ideal,est);
    estnorm3(i)=norm2(im,estg);
    likeli(i)=Likelihood(im,estg,'ML');
    
    i = i+1;
end

% Restored Image
im_deblur = est;