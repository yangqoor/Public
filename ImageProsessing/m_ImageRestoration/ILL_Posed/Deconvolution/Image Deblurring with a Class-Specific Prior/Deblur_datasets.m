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

% Blur kernels from Levin etal 2017
load('LevinKernels.mat');

%%
opts.isolatedPixel=1; % To remove single pixels in kernl: 1->Remove isolated Pixel, otherwise 0
opts.synth = 1;
opts.pruneNoise=1; % To remove noise less then certain level: 1-> Remove , 0-> no pruning

opts.gammaCorrection=1.0;
opts.thickness = 2; % controls the thickness of the kernel, normally is in between 0.005 and 2
opts.filters_path='filters\Bpfilters_70filters.mat'; % more filters means slower the algorihtm
opts.maxIter=20;
opts.savepath = 'Results_dataset\';
%%
if ~exist(opts.savepath,'dir')
    mkdir(opts.savepath);
end

path = 'datasets\Test\'; % path to test images
ext='*.png';
Dir = dir([path ext]);

opts.path_train = 'datasets\Train\'; % Path to train images.
opts.ext_train  = '*.pnm';
%%
k_size = [19, 17, 15, 27, 13, 21, 23, 23];

PSNR_im  = zeros(length(Dir),length(k_size));
PSNR_ker = zeros(length(Dir),length(k_size));

for idm=1:length(Dir)
    for idk=1:length(k_size)
        %% Read image and blur it.
        
        fprintf('\nimage =%d,  kernel = %d\n',idm, idk);
        im =imread([path Dir(idm).name]);
        opts.name = Dir(idm).name(1:end-4);
        if opts.synth == 1
            PSF=kernel(idk).ker;
            opts.kSizeMax=k_size(idk);    % Kernel size
            opts.kSizeMaxCentre = floor(opts.kSizeMax/2);
            imOriginal= imfilter(im,PSF,'circular','conv');
        else
            opts.kSizeMax=25;    % Has to be adjusted for real images.
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
            
            PSNR_im(idm, idk) = 10*log10(1/mean((DeIm(:)-im2double(im(:))).^2));
            PSNR_ker(idm, idk) = 10*log10(1/mean((ker(:)-PSF(:)).^2));
            
            fprintf('Image PSNR: %.2f and Kernel PSNR: %.2f\n',PSNR_im(idm, idk), PSNR_ker(idm, idk));
            save(fullfile(opts.savepath, 'PSNR_im.mat'), 'PSNR_im');
            save(fullfile(opts.savepath, 'PSNR_ker.mat'),'PSNR_ker');   
        end
        
        imwrite(DeIm, fullfile(opts.savepath, [ '\deblur_' Dir(idm).name(1:end-4) '_knum' num2str(idk) '.png']));
        kw=ker-min(ker(:));
        kw=kw./max(kw(:));
        imwrite(kw,fullfile(opts.savepath, ['\Ker_' Dir(idm).name(1:end-4)  '_knum' num2str(idk) '.png']));
    end
end
