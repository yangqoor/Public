% The code in this package implements the class-specific image deblurring 
% method as described in the following papers:
% 
% S. Anwar, C. P. Huynh and F. Porikli 
% "Image Deblurring with a Class-Specific Prior,"
% IEEE Transactions on Pattern Analysis and Machine Intelligence (TPAMI), 2018. 
% 
% and  
% 
% S. Anwar, C. P. Huynh and F. Porikli 
% "Class-specific image deblurring,"
% IEEE International Conference on Computer Vision(ICCV), 2015. 
% 
% Please cite the papers if you are using this code in your research.
% Contact:       
% Saeed Anwar <saeed.anwar@anu.edu.au> or 
% the email provided on my website at https://saeed-anwar.github.io/.
clear;
close all

%%
addpath(genpath('MainDeblurCode'));
% Includes functions like snr, ssim, nonblind code etc.
addpath(genpath('Utils'));
addpath(genpath('filters'));
addpath(genpath('butterworth'));
addpath(genpath('l1_ls_matlab'));

% Blur kernels from Levin etal 2017 in the filters directory
load('LevinKernels.mat');

%%
opts.isolatedPixel=1; % To remove single pixels in kernl: 1->Remove isolated Pixel, otherwise 0
opts.synth = 1;
opts.pruneNoise=1; % To remove noise less then certain level: 1-> Remove , 0-> no pruning

opts.gammaCorrection=1.0;
opts.thickness = 2; % controls the thickness of the kernel, normally is in between 0.005 and 2

opts.maxIter=20; % increasing the number will make algorithm slower.
opts.filters_path='filters\Bpfilters_70filters.mat'; % more filters means slower the algorihtm

opts.savepath = 'Results_single\';
%%
if ~exist(opts.savepath,'dir')
    mkdir(opts.savepath);
end

path = 'datasets\Test\'; % path to test images
test_im='human_2.png';
Dir = dir([path test_im]);

opts.path_train = 'datasets\Train\'; % Path to train images.
opts.ext_train  = '*.pnm';
%% Read image and blur it.

fprintf('Deblurring Started\n');
im =imread([path test_im]);
opts.name = test_im(1:end-4);
if opts.synth == 1
    PSF=kernel(1).ker; % blurring with the first levin kernel
    opts.kSizeMax=size(PSF,1);    % Kernel size
    opts.kSizeMaxCentre = floor(opts.kSizeMax/2);   
    imOriginal= imfilter(im,PSF,'circular','conv');
else
    opts.kSizeMax=25;    % It has to be adjusted in case of real images.
    opts.kSizeMaxCentre = floor(opts.kSizeMax/2);  
    imOriginal = im;
end
imOriginal=im2double(imOriginal);
imOriginal=imOriginal.^opts.gammaCorrection;

%% % RGB to GrayScale
if size(imOriginal,3)==3
    imBlurred = rgb2gray(imOriginal);
else
    imBlurred = imOriginal;
end

%% This is used to create scales of the kernel
opts=ComputeScales(opts);

%% estimating the kernel
ker=deConvMain(imBlurred, opts);

%% Non-blind deconvolution
DeIm = NonBlindDeblurring(imOriginal, rot90(ker,2));

%% Save results.
if opts.synth==1   
    PSNR_im = 10*log10(1/mean((DeIm(:)-im2double(im(:))).^2));
    PSNR_ker = 10*log10(1/mean((ker(:)-PSF(:)).^2));
    
    fprintf('Image PSNR: %.2f and Kernel PSNR: %.2f\n',PSNR_im, PSNR_ker);
    save(fullfile(opts.savepath, 'PSNR_im.mat'), 'PSNR_im');
    save(fullfile(opts.savepath, 'PSNR_ker.mat'),'PSNR_ker');  
end

imwrite(DeIm, fullfile(opts.savepath, [ '\deblur_' test_im(1:end-4) '.png']));
kw=ker-min(ker(:));
kw=kw./max(kw(:));
imwrite(kw,fullfile(opts.savepath, ['\Ker_' test_im(1:end-4) '.png']));







