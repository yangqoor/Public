%==========================================================================
% This is the testing code of a special case of SRMD (scale factor = 1) for real image <denoising & deblurring>.
% There are two models, "SRMDx1_gray.mat" for grayscale image, "SRMDx1_color.mat"
% for color image. The models can do:
%   1. Deblurring. (The kernel is assumed to be Gaussian-like!!! For other kernels, you should re-train the model!)
%      there are two types of kernels,
%      including isotropic Gaussian (width range: [0.1, 3]),
%      anisotropic Gaussian ([0.5, 8]).
%   2. Denoising. the noise level range is [0, 75].
%      For denoising only, set "kerneltype = 1; kernelwidth = 0.1." (i.e., delta kernel)
%
%==========================================================================
% The basic idea of SRMD is to learn a CNN to infer the MAP of general SISR (with special case of sf=1), i.e.,
% solve x^ = arg min_x 1/(2 sigma^2) ||kx - y||^2 + lamda \Phi(x)
% via x^ = CNN(y,k,sigma;\Theta) or x^ = CNN(y,kernel,noiselevel;\Theta).
%
% There involves two important factors, i.e., blur kernel (k; kernel) and noise
% level (sigma; nlevel).
%
% For more information, please refer to the following paper.
%    @article{zhang2017learningsrmd,
%    title={Learning a Single Convolutional Super-Resolution Network for Multiple Degradations},
%    author={Kai, Zhang and Wangmeng, Zuo and Lei, Zhang},
%    year={2017},
%    }
%
% If you have any question, please feel free to contact with <Kai Zhang (cskaizhang@gmail.com)>.
%
% This code is for research purpose only.
%
% by Kai Zhang (Nov, 2017)
%==========================================================================

% clear; clc;
format compact;

addpath('utilities');
imageSets    = {'Hilbert','Set5','Set14','BSD68','BSD100','Urban100'}; % testing dataset


%%======= ======= ======= degradation parameter settings ======= ======= =======

% For real image 'Hilbert', some examples of degradation setting are given as follows.
% sf = 1; nlevel =  8; kerneltype = 1; kernelwidth = 0.2; % denoising only
% sf = 1; nlevel = 10; kerneltype = 1; kernelwidth = 0.5; % denoising and sharpening(deblurring)

%%=======  ======= ======= ======= ======= ======= ======= ======= ======= =======


%% select testing dataset, use GPU or not, ...
setTest      = imageSets([3]); %
showResult   = 1; % 1, show results; 2, save restored images
pauseTime    = 1;
useGPU       = 1; % 1 or 0, true or false
method       = 'SRMD';
folderTest   = 'testsets';
folderResult = 'results';
if ~exist(folderResult,'file')
    mkdir(folderResult);
end

%% scale factor (it is fixed to 1)

sf          = 1; %{1}

%% load model with scale factor sf
folderModel = 'models';
load(fullfile(folderModel,['SRMDx',int2str(sf),'_gray.mat']));
%net.layers = net.layers(1:end-1);
net = vl_simplenn_tidy(net);
if useGPU
    net = vl_simplenn_move(net, 'gpu') ;
end

%% degradation parameter (noise level and kernel) setting
%############################# noise level ################################
% noise level, from a range of [0, 75]

nlevel     = 10;  % [0, 75]

kerneltype = 1;  % {1}

%############################### kernel ###################################
% there are tree types of kernels, including isotropic Gaussian,
% anisotropic Gaussian, and estimated kernel k_b for isotropic Gaussian k_d
% under direct downsampler (x2 and x3 only).

if kerneltype == 1
    % type 1, isotropic Gaussian---although it is a special case of anisotropic Gaussian.
    kernelwidth = 0.5; % from a range of [0.1, 3]. set kernelwidth from (0.001, 0.2) to generate delta kernel (no blur)
    kernel = fspecial('gaussian',15, kernelwidth); % Note: the kernel size is fixed to 15X15.
    tag    = ['_',method,'_x',num2str(sf),'_itrG_',int2str(kernelwidth*10),'_nlevel_',int2str(nlevel)];
    
elseif kerneltype == 2
    % type 2, anisotropic Gaussian
    nk     = 1;%randi(size(net.meta.AtrpGaussianKernel,4)); % randomly select one
    kernel = net.meta.AtrpGaussianKernel(:,:,:,nk);
    tag    = ['_',method,'_x',num2str(sf),'_atrG_',int2str(nk),'_nlevel_',int2str(nlevel)];
    
end

%##########################################################################

surf(kernel) % show kernel
view(45,55);
title('Assumed kernel');
xlim([1 15]);
ylim([1 15]);
pause(2)
close;

%% for degradation maps
global degpar;
degpar = single([net.meta.P*kernel(:); nlevel(:)/255]);


for n_set = 1 : numel(setTest)
    
    %% search images
    setTestCur = cell2mat(setTest(n_set));
    disp('--------------------------------------------');
    disp(['    ----',setTestCur,'-----Super-Resolution-----']);
    disp('--------------------------------------------');
    folderTestCur = fullfile(folderTest,setTestCur);
    ext                 =  {'*.jpg','*.png','*.bmp'};
    filepaths           =  [];
    for i = 1 : length(ext)
        filepaths = cat(1,filepaths,dir(fullfile(folderTestCur, ext{i})));
    end
    
    %% prepare results
    folderResultCur = fullfile(folderResult, [setTestCur,tag]);
    if ~exist(folderResultCur,'file')
        mkdir(folderResultCur);
    end
    
    %% perform denoising or/and deblurring (only support Gaussian-like kernel)
    for i = 1 : length(filepaths)
        
        input  = imread(fullfile(folderTestCur,filepaths(i).name));
        %label  = modcrop(label, 2);
        [h,w,C]   = size(input);
        input     = im_pad(input);
        if C == 3
            input = rgb2gray(input); % input = rgb2ycbcr(input); input = input(:,:,1); % another option
        end
        
        [~,imageName,ext] = fileparts(filepaths(i).name);
        input1 = im2single(input);
        %tic
        if useGPU
            input1 = gpuArray(input1);
        end
        res = vl_srmd(net, input1,[],[],'conserveMemory',true,'mode','test','cudnn',true);
        %res = vl_srmd_concise(net, input1); % a concise version of "vl_srmd".
        %res = vl_srmd_matlab(net, input1); % You should also set "useGPU = 0;" and comment "net = vl_simplenn_tidy(net);"
        
        output = im2uint8(gather(res(end).x));
        
        %toc;
        output = im_crop(output,h,w);
        input  = im_crop(input,h,w);
        %output2 = 0.8*output + 0.2*input; % add noise and structure back to make the output more visually plausible. or GAN?
        
        disp([setTestCur,'    ',int2str(i),'    ',filepaths(i).name]);
        if showResult
            imshow(cat(2,input,output));
            drawnow;
            title(['Denoising and deblurring     ',filepaths(i).name],'FontSize',12)
            pause(pauseTime)
            imwrite(output,fullfile(folderResultCur,[imageName,'_x',int2str(sf),'.png']));% save results
            
        end
    end
end



























