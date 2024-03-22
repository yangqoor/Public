clear all
addpath('lib/');

params.gammaCorrection = false;
params.gamma = 0;
params.iters = 1000;
params.visualize = 1;
params.sigma2 = 0.001;
dataFolder = '../BSDS';
kernelFolder = '../BSDS';
resultFolder = './results';
if(~exist(resultFolder,'dir'))
    mkdir(resultFolder);
end


lambda = 0.016;
numIm = 12;
numKer = 6;

for im = 1:12
    for ker = 1:6
        if exist([resultFolder '/img',num2str(im),'_kernel',num2str(ker),'_MeiguangTVL2_kernel.png'],'file') ~=2
                    disp(['im ' num2str(im) ' ker ' num2str(ker)])
        
        name = [dataFolder '/Blurry' num2str(im) '_' num2str(ker) '.png'];
        if ~exist(name,'file')
            error(['No image.']);
        end
        name
        blurred = im2double(imread(name));
        load([kernelFolder ,'/test_kernel',num2str(ker),'.mat'])
        k_ground = kernel;
        
        [MK, NK] = size(k_ground);
        tic
        [fe, k] = deblur(blurred, MK, NK, lambda, params);
        t = toc;
        % imwrite(k./max(k(:)),[resultFolder '/img',num2str(im),'_kernel',num2str(ker),'_MeiguangTVL2_kernel.png']);
        end
    end
end
