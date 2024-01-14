function [KD, KFin] = kernelReconstruction(PSlice, sliceSize, anglesEst, numSampOrientation, KInit)

aK = [0.9, 0.9, 2, 2];%%[0.9, 0.9, 0.9, 0.9]; 
lambdaK = [8, 8, 50, 50];%[1.5, 1.5, 0.2, 0.2]; 
kernelThresh = 10;

%% setup gradient filters for kernel estimation
if ~exist('KInit', 'var')
    KInit = zeros(sliceSize, sliceSize);
    KInit(round((sliceSize+1)/2), round((sliceSize+1)/2)) = 1;  
    KInit = rand(sliceSize, sliceSize);
    KInit = KInit/sum(KInit(:));
end

filts = setup_filters_kernelEst(size(KInit),lambdaK);
%% Kernel estimation
stdnoise = 0.005;
stdnoiseKE = max(sqrt(2)*stdnoise, 0.008);
KFin = kernelEst_sparse(PSlice,KInit,anglesEst,stdnoiseKE,filts, aK, numSampOrientation);

%% Bilinear interpolation error deconvolution
%% setup gradient filters for deconvolution
lambda = 2;
aKR = 1.2; %1.2
gfF = fspecial('Gaussian', 5, 0.7);
rad = floor(size(gfF,1)/2);
filts = setup_filters(size(KFin)+2*rad,lambda);
stdnoiseP = 0.01;
iters = 5;
%% deblur 
KD = deblur_sparse(KFin,gfF,KInit,stdnoiseP,filts,rad, aKR, iters);
 
thresh = max(KD(:))/kernelThresh;
KD(KD<thresh) = 0;
KD = KD/sum(KD(:));


figure, imshown(KD)
