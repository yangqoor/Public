% Samuel Rivera
% date: Nov 8, 2009
% file: generalShapeDetection.m
% notes: This is intended to be the general shape detection file, where
% images are specified in a big matrix, along with the 

function [ error numOccludedPixels numPCA cropSize pError ]   = generalShapeDetection3D( dataFile, imageName, coordinateName, overwriteMask, ...
                    doItFast, showImages, percentTrain,  maskFileName, ... 
                    maskFileFolder, maxRead, regressionMode, imgFeatureMode, coordIndices, ...
                    maskType, PCAparameterFile, regressionParameterFile, ...
                    maxIters, a, tol, ridge, W0, kernel, M, nFold, ...
                    numberOcclusions, occlusionParameters, occlusionType, ...
                    debugCropFiducial, forceGradientDescent, cropPercentScale, offset, ...
                    params, coordIndicesCenter)

 
%movieFile = 'data/3dDetectionFrom2DImageResults.avi';
% 
% dataFile  =  '/Users/stunna/Documents/Data/TeddybearAndDinosaur/Dinosaur/rivera3DDinosaurShapes.mat' ;
% imageName = 'imageTensor';
% coordinateName = 'shapeCoords';
% overwriteMask = 0;
% percentTrain = .8;
% 
% showImages = 1;
% debugCropFiducial = 0;
% 
% coordIndices = 1:36;
% doItFast = 1;
% 
% maskType = 1;  %1 for zero out unseen, 2 for actually remove unseen
% maskFileFolder = 'data/';
% maskFileName = 'trainingMask.mat';
% nFold = 2;
% 
% maxRead = 7; %36 is total dinosaur length
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
% numberOcclusions = 15; 
% occlusionType = 1; %1 for squares, 0 for none
% occlusionParameters = [3;3];
% cropPercentScale = [ 2.5; 2.5 ];  %height, width
% offset = []; %for cropping images
% 

%----------------
%Load data
load( dataFile );
eval([ 'X = ' imageName ';'] );
eval([ 'Y = ' coordinateName ';'] );
display( 'Raw data loaded');

%-------------------------------------------------------
%load/generate maskfile%copy mask from main mask folder if exists, and overwrite if necessary,
%making sure not to overwrite the file in the main directory
if ~exist( maskFileFolder, 'dir' )
    mkdir( maskFileFolder );
end
if maxRead > 0
    N = min( maxRead, size(Y,2) );
else
    N = size(Y,2);
end
if exist( [ maskFileFolder maskFileName ], 'file') 
    if ~strcmp( maskFileFolder, 'data/' )
        copyfile( [ maskFileFolder maskFileName ] , 'data/');
        copyfile( [ maskFileFolder maskFileName(1:end-4) '*.mat' ] , 'data/');
        maskFileFolder = 'data/';
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
cropSize = [size( X(:,:,1),1); size( X(:,:,1),2) ];
% cropSize = findCropSizeUltimate( coordIndices, Y(:,trainThis), cropPercentScale );
[ OcclusionImage numOccludedPixels ]= generateOcclusionImage( numberOcclusions, occlusionParameters, occlusionType, cropSize );
% [ X Y ] = cropFiducial( X(:,:,1:N), Y(:,1:N), coordIndices, cropSize, maskType, offset, debugCropFiducial); 
numOccludedPixels = 0;
%-------------------------------------------------------

%Occlude and Normalize Data
X = X.*repmat( OcclusionImage, [1,1, size(X,3) ] );
[ nX Yw yMu V D Vimg ] = normalizeDataUltimate( PCAparameterFile, X , ...
            Y,  trainThis, doItFast, imgFeatureMode, cropSize ); 
numPCA = size( Vimg,2);
nX = [ nX; ones( 1,size(nX,2)) ];
display( 'data Normalized and shape parameters learned/loaded' );

%------------------------------------------
% assume all data given and initlize if not provided
if isempty( M );
    M = ones( size(Yw,1), size(nX,2));
end
if isempty( W0 );
    %initialize W
    W0 = rand(length( trainThis), size(Yw,1) ); 
end

%--------------------------------------------

%If necessary, obtain regression parameters
if ~exist( regressionParameterFile, 'file')
    [params ,fval,exitflag,output] = CVSearchSimplexUltimate(  [ maskFileFolder maskFileName ] , nFold, ...
                nX, Yw, W0, M, a, tol, maxIters, ridge, kernel, params, regressionMode, ...
                forceGradientDescent);
    save( regressionParameterFile, 'params', 'fval', 'exitflag', 'output' );
    params
%     params = [.01, .4]
else 
    load( regressionParameterFile, 'params' );
    params
%     params = [.01, .4]
end

%do regression and display results
display( 'Training regressor');
[e W k YtrueMinusEst Yest ] = runRegressionUltimate( nX(:,trainThis), nX(:,testThis),  Yw(:, trainThis), ...
                                    Yw(:, testThis), W0, M, a, tol, maxIters, ridge, kernel, params, ...
                                    regressionMode, forceGradientDescent );
display( 'Done training regressor' );            
                                
% Y put back in true shape estimate for testing data
Yhat = V*diag(diag(D).^(1/2))*Yest + repmat( yMu, 1,size(Yest,2) ); %estimate of Y       
YhatReshaped = reshape( Yhat, [ size( Yhat,1)/3, 3*length(testThis)] );
YReshaped = reshape( Y, size( Y,1)/3, [] );

%calc ave coordinate euclidean error
errorVec = zeros(length(testThis),1);
percentError  = zeros(length(testThis),1);
for i1 = 1:length(testThis)
    tempYH = [ YhatReshaped(:,i1*3-2:i1*3)]';
    tempY =  [ YReshaped(:,testThis(i1)*3-2:testThis(i1)*3)]';
    errorVec(i1) = aveError3D( tempYH(:), tempY(:) );
    percentError(i1) = norm(tempYH(:)-tempY(:), 'fro')/norm(tempY(:), 'fro');  
    
end
error = mean( errorVec );
pError = mean( percentError );

% show the results for testing, simple 2D
if showImages
    YReshaped = YReshaped';       
    YhatReshaped = YhatReshaped';
    for i1 = 1:length(testThis)
        clf
        imagesc( X(:,:,testThis(i1))), colormap(gray);
        hold on
        plot(YhatReshaped(i1*3-2,:), YhatReshaped(i1*3-1,:), 'b.', 'markersize', 13)
        plot(YReshaped(testThis(i1)*3-2,:), YReshaped(testThis(i1)*3-1,:), 'g.', 'markersize', 13 );
        pause;
    end
end

%3D visualization for paper
if showImages
    for i1 = 1:length(testThis)
        figure(1)
        imagesc( X(:,:,testThis(i1))), colormap(gray);
        
        figure(2)
        clf
        hold on, axis equal
        plot3(YhatReshaped(i1*3-2,:), YhatReshaped(i1*3-1,:), YhatReshaped(i1*3,:), 'b.')
        xlabel( 'x'), ylabel( 'y'), zlabel( 'z');
        set(gca,'YDir','reverse')
        view(0, 90)   
        
        figure(3)
        clf
        hold on, axis equal
        plot3(YhatReshaped(i1*3-2,:), YhatReshaped(i1*3-1,:), YhatReshaped(i1*3,:), 'b.')
        xlabel( 'x'), ylabel( 'y'), zlabel( 'z');
%         set(gca,'YDir','reverse')
        view(-20, 90)  
        
        figure(4)
        clf
        hold on, axis equal
        plot3(YhatReshaped(i1*3-2,:), YhatReshaped(i1*3-1,:), YhatReshaped(i1*3,:), 'b.')
        xlabel( 'x'), ylabel( 'y'), zlabel( 'z');
%         set(gca,'YDir','reverse')
        view(20, 90)  
        
%         imagesc( X(:,:,testThis(i1))), colormap(gray);
%         hold on
%         plot(YhatReshaped(i1*3-2,:), YhatReshaped(i1*3-1,:), 'b.')
%         plot(YReshaped(testThis(i1)*3-2,:), YReshaped(testThis(i1)*3-1,:), 'g*' );
        pause;
    end
end
        



%this is old stuff for preliminary tests
%show the results for testing
%movieFile = 'data/3dDetectionFrom2DImageResults.avi';
% if showImages
%     
%     for i1 = 1:length(testThis)
%     
%         %side by side 3D 
%         figure(1)  
%         subplot(1,2,1)
%         plot3(YhatReshaped(i1*3-2,:), YhatReshaped(i1*3-1,:), YhatReshaped(i1*3,:), 'g.')
%         set(gca,'YDir','reverse')
%         axis vis3d  equal %off
%         axis( [ 1 size(imageTensor,2) 1 size(imageTensor,1) ] );
%         xlabel( 'x'), ylabel( 'y'), zlabel( 'z');
%         view(0, 90)
%         subplot(122)
%         imagesc(X(:,:,testThis(i1))), colormap(gray);
%         axis equal
%         axis( [ 1 size(imageTensor,2) 1 size(imageTensor,1) ] );
%     % %     F(i1) = getframe( 1,  [50 100 485 245] );
%     % %     %superimposed on 2D
%     % %      figure(2);
%     % %      imagesc(X(:,:,testThis(i1))), colormap(gray);
%     % %      hold on
%     % %      plot(YhatReshaped(i1*3-2,:), YhatReshaped(i1*3-1,:), 'g.');
%          pause();
% %     
% %     
%     end
% end

% if exist( 'movieFile', 'var' )
%     movie2avi(F, movieFile, 'fps', 2, 'quality', 25)
% end


    
