% Samuel Rivera
% date: Nov 8, 2009
% file: generalShapeDetection.m
% notes: This is intended to be the general shape detection file, where
% images are specified in a big matrix, along with the 

function [error numOccludedPixels numPCA cropSize pError] = generalShapeDetection( dataFile, imageName, coordinateName, overwriteMask, ...
                    doItFast, showImages, percentTrain,  maskFileName, ... 
                    maskFileFolder, maxRead, regressionMode, imgFeatureMode, coordIndices, ...
                    maskType, PCAparameterFile, regressionParameterFile, ...
                    maxIters, a, tol, ridge, W0, kernel, M, nFold, ...
                    numberOcclusions, occlusionParameters, occlusionType, ...
                    debugCropFiducial, forceGradientDescent, cropPercentScale, offset, ...
                    params, coordIndicesCenter, localPartitionsFile)

% 
% dataFile  = 'formattedARData/croppedRotatedImages.mat';
% imageName = 'imageTensorSmall';
% coordinateName = 'coordinatesMatrix';
% 
% overwriteMask = 1;
% percentTrain = .5;
% showImages = 1;
% debugCropFiducial = 0;
% 
% coordIndices = 2:13;
% coordIndicesCenter = 2:13;
% doItFast = 1;
% 
% maskType = 0;  %1 for zero out unseen, 2 for actually remove unseen, 0 for don't use mask
% maskFileFolder = 'data/';
% maskFileName = 'trainingMask.mat';
% nFold = 5;
% 
% maxRead = 200; %448 is half all;
% regressionMode = 5;  %5 for KRR gradient descent, 2 for SVR
% imgFeatureMode = 1;  %1 for pixel, 2 for C1, 3 for Gabor, 4 for Haar
% PCAparameterFile = 'data/testPCAParams.mat';
% regressionParameterFile = 'data/testCVParams.mat';
% 
% maxIters = 5000;
% a = 1; %step size
% tol = .3; % norm of gradient should be bigger than this
% ridge = 1;  
% forceGradientDescent = 0;
% kernel = 1;   %1 if RBF kernel space, 0 of regular space
% %use M if you don't know the outputs
% %W0 = rand(p+1,d ); %initialize W
% 
% numberOcclusions = 15; 
% occlusionType = 0; %1 for squares
% occlusionParameters = [3;3];
% cropPercentScale = [ 2.9583; 3.0826 ];  %height, width
% offset = []; %for cropping images
%    params = [.01, .8];
% W0 = [];
% M = [];  %missing coordinates
%--------------------------------------
%-------------------------

%Load data
load( dataFile );
eval([ 'X = ' imageName ';'] );  % imageMatrix
eval([ 'Y = ' coordinateName ';'] );   %coordinateMatrix
display( 'Raw data loaded');

%-------------------------------------------------------
%load/generate maskfile
if ~exist( maskFileFolder, 'dir' )
    mkdir( maskFileFolder );
end
if ~exist( localPartitionsFile, 'dir' )
    mkdir( localPartitionsFile );
end

%copy mask from main mask folder if exists, and overwrite if necessary,
%making sure not to overwrite the file in the main directory
if maxRead > 0
    N = min( maxRead, size(Y,2) );
else
    N = size(Y,2);
end
if exist( [ maskFileFolder maskFileName ], 'file') 
    if ~strcmp( maskFileFolder, localPartitionsFile )
        copyfile( [ maskFileFolder maskFileName ] , localPartitionsFile);
        copyfile( [ maskFileFolder maskFileName(1:end-4) '*.mat' ] , localPartitionsFile );
        maskFileFolder = localPartitionsFile;
    end
    if overwriteMask
        generateMaskUltimate( percentTrain, N, [ maskFileFolder maskFileName ] ); 
        generateCVMaskUltimate( [ maskFileFolder maskFileName ] , nFold )
        display( 'Old maskfile overwritten in local data folder, and loaded');
    else
        display( 'Old maskfile copied into local data folder, and loaded');
    end
else
    generateMaskUltimate( percentTrain, N, [ maskFileFolder maskFileName ] ) ;
    generateCVMaskUltimate( [ maskFileFolder maskFileName ] , nFold )
    display( 'New maskfile generated and loaded');
end
load( [ maskFileFolder maskFileName ] )

%-------------------------------------------------------
%crop wanted shape 
cropSize = findCropSizeUltimate( coordIndicesCenter, Y(:,1:448), cropPercentScale );
[ OcclusionImage numOccludedPixels ]= generateOcclusionImage( numberOcclusions, occlusionParameters, occlusionType, cropSize );
[ X Y ] = cropFiducial( X(:,:,1:N), Y(:,1:N), coordIndices, cropSize, maskType, offset, debugCropFiducial, coordIndicesCenter); 

%-------------------------------------------------------
%Occlude and Normalize Data
X = X.*repmat( OcclusionImage, [1,1, size(X,3) ] );
[ nX Yw yMu V D Vimg ] = normalizeDataUltimate( PCAparameterFile, X , ...
            [real(Y); imag(Y)],  trainThis, doItFast, imgFeatureMode, cropSize ); 
numPCA = size( Vimg,2);
nX = [ nX; ones( 1,size(nX,2)) ];
display( 'data Normalized and shape parameters learned/loaded' );


%------------------------------------------
% assume all data given and initlize if not provided
if isempty( M );
    M = ones( size(Yw,1), size(nX,2));
end

if isempty( W0 );
    W0 = rand(length( trainThis), size(Yw,1) ); %initialize W, don't do it now
end

%--------------------------------------------

%If necessary, obtain regression parameters
if ~exist( regressionParameterFile, 'file')
    [params ,fval,exitflag,output] = CVSearchSimplexUltimate(  [ maskFileFolder maskFileName ] , nFold, ...
                nX, Yw, W0, M, a, tol, maxIters, ridge, kernel, params, regressionMode, ...
                forceGradientDescent);
    save( regressionParameterFile, 'params', 'fval', 'exitflag', 'output' );
else 
    load( regressionParameterFile, 'params' );
end

%do regression and display results
display( 'Training regressor');
[e W k YtrueMinusEst Yest ] = runRegressionUltimate( nX(:,trainThis), nX(:,testThis),  Yw(:, trainThis), ...
                                    Yw(:, testThis), W0, M, a, tol, maxIters, ridge, kernel, params, ...
                                    regressionMode, forceGradientDescent );
display( 'Done training regressor' );            
                                
% Y put back in true shape estimate for testing data
Yhat = V*diag(diag(D).^(1/2))*Yest + repmat( yMu, 1,size(Yest,2) ); %estimate of Y
s = size( Yhat, 1);
YhatComplex = Yhat(1:s/2,:) +  1i*Yhat(s/2+1:end,:);

%calc ave coordinate euclidean error
errorVec = zeros(length(testThis),1);
errorVecNormalized = zeros(length(testThis),1);
for i1 = 1:length(testThis)
    tempYH = [ real( YhatComplex(:, i1)) imag( YhatComplex(:, i1))]';
    tempY =  [ real(Y(:,testThis(i1))) imag( Y(:,testThis(i1))) ]';
    errorVec(i1) = aveError( tempYH(:), tempY(:) );
    percentError(i1) = norm(tempYH(:) -  tempY(:), 'fro')/norm(tempY(:), 'fro');    
end
error = mean( errorVec );
pError = mean( percentError );

%show the results for testing
if showImages
    for i1 = 1:length(testThis)
        clf
        imagesc( X(:,:,testThis(i1))), colormap(gray);
%         size( X )
        hold on, axis equal
         plot( real( YhatComplex(:, i1)), imag( YhatComplex(:, i1)), 'b.', 'markersize' , 12 ); 
        plot( real( Y(:,testThis(i1) )), imag(Y(:,testThis(i1) )), 'g.' , 'markersize' , 12 );
        axis( [ min( [1, min(real( Y(:,testThis(i1) )))] ) max( [size(X(:,:,1),2), max(real( Y(:,testThis(i1) ))) ] ) ...
                  min( [1, min(imag( Y(:,testThis(i1) )))] ) max( [size(X(:,:,1),1), max(imag( Y(:,testThis(i1) ))) ])  ] );
        pause;
    end
end
    
