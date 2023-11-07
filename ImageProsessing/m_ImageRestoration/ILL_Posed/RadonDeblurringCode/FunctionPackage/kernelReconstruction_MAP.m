function [KD, KProg,xMapProg] = kernelReconstruction_MAP ...
    (B,stdnoiseB, KIn, PSlice, anglesEst, numSampOrientation, weightObs)
%  
aK = [0.9,0.9,0.9, 0.9];  
lambdaK = [1.5, 1.5, 0.2,0.2]; 
 
kernelThresh = 10;

% edgetaper to better handle circular boundary conditions
ks = floor((size(KIn, 1) - 1)/2);
B = padarray(B, [1 1]*ks, 'replicate', 'both');
for l=1:4
  B = edgetaper(B, KIn);
end 


%% For deconvolving the gaussian blur due to bilinear interpolation
stdnoiseP = 0.01;
gaussDeconvIters = 3;
lambda = 2;
aKR = 1.2;
gfF = fspecial('Gaussian', 5, 0.2);
rad = floor(size(gfF,1)/2);

%% For kernel estimation
stdnoise = 0.005;
stdnoiseKE = max(sqrt(2)*stdnoise, 0.008);

%% for Fast deconvolution
lambFD = 5000; 
alphaFD = 0.5; 

% %% 
noIter = 5; 
KProg = zeros(size(KIn, 1), size(KIn, 2), noIter);
xMapProg = zeros(size(B, 1), size(B, 2), noIter);
stdnoiseBIn = stdnoiseB; 
se = strel('ball',5,5); 

for l = 1:noIter
    l
     %%%%%%%%%% Deconvolution
    [xMap] = fast_deconv(B, KIn, lambFD, alphaFD);
        
    xMap(xMap(:)<0) = 0;
    xMapB = bilateralFilter( xMap, xMap, 0, max(xMap(:)));%,sigmaSpatial, sigmaRange);
  
    edgeMaskT = edge(xMapB, 'canny');
    edgeMaskTT = im2double(edgeMaskT);
    edgeMaskTTT = imdilate(edgeMaskTT, se);
    edgeMaskTTT = edgeMaskTTT - min(edgeMaskTTT(:));
    edgeMask = edgeMaskTTT > 0.1;

    edgeMask = edgeMask(ks+1:end-ks, ks+1:end-ks);
    
    %%%%%%%%%%% Kernel estimation
    %% setup gradient filters for kernel estimation
    filts = setup_filters_kernelEst(size(KIn),lambdaK);
    KFin = kernelEst_sparse_MAP ...
        (xMapB, B, PSlice,KIn,anglesEst,stdnoiseKE,stdnoiseBIn,filts, aK, numSampOrientation, edgeMask, weightObs);
 
    filts = setup_filters(size(KFin)+2*rad,lambda);
    %% deblur 
    KD = deblur_sparse(KFin,gfF,KFin,stdnoiseP,filts,rad, aKR, gaussDeconvIters);
 
    thresh = max(KD(:))/kernelThresh;    
    KD(KD<thresh) = 0;
    KD = KD/sum(KD(:));
    
    KIn = KD;
    KProg(:, :, l) = KD;
    xMapProg(:, :, l) = xMapB;
    
    imshown(KD)
end
 
figure, imshown(KD)
