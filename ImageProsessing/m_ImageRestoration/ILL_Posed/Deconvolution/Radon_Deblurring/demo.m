% This is a demo script for deblurring photographs using "Blur kernel
% estimation using blurred edge profiles".  

% Taeg Sang Cho
% 18 Aug 2010
% 色彩增强效果优秀

clear; 

path(path, './FunctionPackage');

MAPOn = 1; %if 1, then RadonMAP, if 0, then just the inverse Radon transform.

% image number, runs from 1 to 33
% To add more images, edit loadImData_web.m to specify the blur kernel size
% for , for instance, image 34.
imNo = 1;

%% Loading image
[B, BLin, scaleFac, sliceSize] = loadImData_web(imNo);
 

%% Sampling edges

stdnoiseB = 0.005;

BIn = B;
perfectOrientation = 0; 
tic;
[xx, yy, thetaEstSS, numSamples, counter, BG] = ...
    edgePixelSamplingAuto(BIn, sliceSize, perfectOrientation, stdnoiseB, imNo);
tEdgeSamp = toc;


%% Taking projections
tic;
[PSlice, anglesEst, numActSamples, xxOut,  yyOut, errOutCand, epsColor] = kernelProjection(B,  xx, yy, thetaEstSS, sliceSize, numSamples);
tProjection = toc;  

%% Computing approximations - binning the projections according to
%% orientation angles

maxAng = 360;
angInd = zeros(1, length(anglesEst));
PSliceN = zeros(sliceSize, 360);
angInput = zeros(1, 360);
numSampOrientation = zeros(1, 360);
countSamp = 0;
for l = 1:maxAng
    idx = find((anglesEst > l-1) & (anglesEst <= l));
    if(~isempty(idx))
        countSamp = countSamp + 1;
        PSliceN(:, countSamp) = mean(PSlice(:, idx), 2);        
        angInput(countSamp) = l-0.5;
        numSampOrientation(countSamp) = length(idx);
    end 
end
angInput(countSamp + 1:end) = [];
PSliceN(:, countSamp + 1:end) = [];
numSampOrientation(:, countSamp + 1:end) = [];

%% Blur kernel reconstruction
tic;
% the inverse Radon transform of estimated projections
[KD, KFin] = kernelReconstruction(PSliceN, sliceSize, angInput, numSampOrientation);         

%% RadonMAP
if(MAPOn == 1)
    weightObs = 1000; % If the format of the input image is unscaled raw, then 1000; 
                      % If the input image is white balanced, then 10
    BIn = rgb2gray(B);
    KDR = KD;
    
    [KD, KProg,xMapProg] = kernelReconstruction_MAP ...
            (BIn,stdnoiseB, KDR, PSliceN, angInput, numSampOrientation, weightObs);
end
tKernelReconst = toc;
KD = KD/sum(KD(:));


%% Deblurring - deblur

stdnoiseB = 0.005;
D = imageDeblurring(B, KD, stdnoiseB);    
tDeconv = toc;

DWB = D./repmat(scaleFac, [size(D, 1), size(D, 2)]);
figure, imshow(DWB)

%% Saving routine
% outDir = './Results/';
% mkdir(outDir);
% fileName = sprintf('%s%s%s%s', outDir, num2str(imNo), '_outputIm.tiff');
% DWB = uint16(floor(2^16*DWB));
% imwrite(DWB, fileName, 'tif', 'Compression', 'None');
% 
% fileName = sprintf('%s%s%s%s', outDir, num2str(imNo), '_outputKernel.tiff');
% KD = KD/max(KD(:));
% KD = uint16(floor(2^16*KD));
% imwrite(KD, fileName, 'tif', 'Compression', 'None');

