%samuel rivera
%date: jun 30
%file: faceShapeDetector.m
% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)

function [ detectedFaceCoordinates shapeDetectionModes detections3D]  =...
                    faceShapeDetector( X, Y, ...
                    maskFile, regressionMode, kernel, ...
                    imgFeatureMode, parameters, showIt, shapeCoords, ...
                    W0,M, a, tol, maxIters, calcM, modelFile, PCAparameters, ...
                    shapeVersion, mode3D, zCoords )
warning off all             

detections3D = []; %in case not calculated
numCoords = length( shapeCoords);

doItFast = 1;
lambda = parameters(1);
sigma = parameters(2);
eyeCropPosition =  parameters(5:6);
eyeCropPosition = eyeCropPosition(:);
epsSvr = 1;
if regressionMode ==  4  %SVR ( || regressionMode == 6, GPR) 
    epsSvr = parameters( 9 );
end

%load up mask
load( maskFile );
showCrops = 0;
cropSize = parameters( 7:8);
cropSize = cropSize(:);

% eyeCropPosition will be the coordinates with which to center the object
% if you are using centerMode
% if centerMode
%     eyeCropPosition = shapeCoords; 
% end

[ X2 Y2cropped cropPosUnpadded ] = cropFiducial( X,  Y, shapeCoords, cropSize, 0, [], showCrops,...
                                  eyeCropPosition ); 
                                   
% convert from complex to vectorized, and normalize
if ~isempty( zCoords)
    zCoords = zCoords(shapeCoords ,:);
end
Y2 = [real( Y2cropped); imag(Y2cropped); zCoords] ;

% Use less shape modes if adaboost (90% shape variance)
if regressionMode == 7 %adaboost
    adaBoostdoItFast = 1;  %make sure modes the same, very important
    [ nX Yw  yMu V D Vimg V1 D1 yMu1] = normalizeDataUltimate90( PCAparameters, ... 
         X2 , Y2,  trainThis, adaBoostdoItFast,...
         imgFeatureMode, [], calcM, ...
         shapeVersion, mode3D ); 
else
    [ nX Yw  yMu V D Vimg V1 D1 yMu1] = normalizeDataUltimate( PCAparameters, ...
         X2 , Y2,  trainThis, doItFast,...
         imgFeatureMode, [], calcM, ...
         shapeVersion, mode3D ); 
end
  
%shape detection
[shapeParameterError W k YtrueMinusEst Yest ] = runRegressionUltimate(  nX(:,trainThis),  nX(:,testThis), ...
                    Yw(:,trainThis),  Yw(:,testThis), W0,M, a, tol, maxIters, kernel, ...
                    [lambda; sigma; epsSvr], regressionMode, calcM, modelFile);
shapeDetectionModes = Yest;
[ Yhat  ] = unparameterizeShape( Yest, yMu, V, D, shapeVersion, V1, D1, yMu1, mode3D );

% detections in format of colums with all [x1 y1 x2 y2 x3 y3 ... xN,yN]
detections = reshape( Yhat(1:numCoords*2,:), numCoords, [] ); 

% book keeping for 3D shape detection
if mode3D
    detections3D = Yhat(numCoords*2+1:end,:);
end

% % This is old way I was doing this...
% % The -[1;1] is essential to remove the single pixel bias
% % offsetOld = flipud( - [size(X2,1)/2; size(X2,2)/2] + eyeCropPosition -[1;1] )';  %tried 2*[1;1] (didn't work), normally just [1;1]
% % detectedFaceCoordinatesOld = detections + repmat( offsetOld, size(detections,1), size(detections,2)/2);

% Shift detections to rest on top of original image  
% The -[1;1] is essential to remove the single pixel bias
offset = [  real( cropPosUnpadded(1))-1 imag(cropPosUnpadded(1))-1 ]; 
detectedFaceCoordinates = detections + repmat( offset, size(detections,1), size(detections,2)/2);
   

% Here I want to check the detection error before I reposition on original
% Image to see if it corresponds properly.  Note that when dealing with
% missing landmarks, you have to consider not calculating error for unknown
% landmarks.  Example code below, but an extra argument 'nonMissingMask'
% will be needed by this function.

% 2D Euclidean pixel error calculation detections to true
% % estX = detections(:,1:2:end);
% % estY = detections(:,2:2:end);
% % trueX = real(Y2cropped(:,testThis));
% % trueY = imag(Y2cropped(:,testThis));
% % [ allE] = aveError( [trueX(:) trueY(:)] , [estX(:) estY(:)]);
% % allE(~nonMissingMask(:) ) = [];
% % mean(allE)
% % var(allE)
% % length(allE)


% display results (helpful for debugging)
if showIt
    figure(1)
    for i1 = 1:length( testThis )
       % plot in 2D or 3D
       if mode3D
           
           clf(gcf);
           
           subplot( 121)
           if numCoords == 20
                customHandPlots3D( [ detectedFaceCoordinates(:,i1*2-1:i1*2) detections3D(:,i1) ] )
           else
                plot3( detectedFaceCoordinates(:,i1*2-1),detectedFaceCoordinates(:,i1*2), detections3D(:,i1), 'g.');
           end
           title( '3D shape detection' );
           xlabel( 'x axis');
           ylabel( 'y axis');
           zlabel( 'z axis');
           
           subplot(122)
           imagesc( X(:,:,testThis(i1))), colormap(gray);
           hold on
           plot( real(Y(:,testThis(i1))), imag( Y(:,testThis(i1))), 'g.');
           
       else 
           title( 'Detected in blue, true in green.');
           imagesc( X(:,:,testThis(i1))), colormap(gray);
           axis equal
           hold on
           plot( detectedFaceCoordinates(:,i1*2-1), detectedFaceCoordinates(:,i1*2), 'b.');
           plot( real(Y(:,testThis(i1))), imag( Y(:,testThis(i1))), 'g.');
       end
       pause();
       
    end
    % movie2avi(MOV,  'OutputData/resultMovie.avi' ,'fps',1);
end

