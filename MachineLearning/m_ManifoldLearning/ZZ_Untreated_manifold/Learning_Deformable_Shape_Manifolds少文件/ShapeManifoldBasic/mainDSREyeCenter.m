




%   Copyright (C) 2009, 2010, 2011 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)

function detections = mainDSREyeCenter( imageMatrix, coordMatrix, trainThis, testThis, paramStruct, eyeCoords )
   
tic

showIt = 0; 
PCAparametersFirst = 'pcaDataFirst.mat';
PCAparametersSec = 'pcaDataSecond.mat';

regressionMode = 5;  % 5 for KRR
interEyeDistance = 15; %pixels
if nargin < 6 || isempty( eyeCoords )
    eyeCoords = 1:26; %  a vector which specifies the landmark indices associated with the eys
end
imgFeatureMode = 8; % 8 for PCA
shapeVersion = 4; % 4 for for DTS model
shapePercent = .99;

N = size( coordMatrix,2); % total number samples ( train + test);
numTest = length(testThis);

% tune sigma paramter
[ nX ] = normalizeDataMOG( PCAparametersFirst, ... % learn shape and texture models
                    imageMatrix , coordMatrix,  1:size(coordMatrix,2), ...
                    1, imgFeatureMode, [], 0, shapeVersion, 0, shapePercent, []); 
[ aveDist  ] = calcPairwiseDistances( nX );
paramStruct.sigma = sqrt(aveDist/2);

% set other paramaters
parameters(1) =paramStruct.lambda;
parameters(2) = paramStruct.sigma;
parameters(5:6) = paramStruct.centerCropPosition(:);
parameters( 7:8) = paramStruct.cropSize(:);

% 3D stuff
zCoords = [];
mode3D = 0;        

        
%------------------------------------------------
% misc do not touch
modelFile = [];
kernel = 1; %1 for rbf
calcM = 0; 
shapeCoords = 1:size(  coordMatrix,1);
fiducialCoordinates = [];
%optimization parameters        
maxSimplexIterations = [];
W0  = [];
M = [];
a = [];
tol = [];

% run shape detector
startTime = toc;
detections = faceShapeDetectorMOGDist( imageMatrix, coordMatrix, ...
    trainThis, testThis, regressionMode, kernel, imgFeatureMode, ...
    parameters, showIt, shapeCoords, ...
    W0,M, a, tol, maxSimplexIterations, ...
    calcM, modelFile, PCAparametersFirst, shapeVersion, ...
    mode3D, zCoords, shapePercent, fiducialCoordinates);
runTime = toc - startTime
fprintf( '%d images detected at %.2f seconds per image.\n', numTest,runTime/numTest);

%------------------------------------
% align the shapes by eye center
offset = ones(1, N).*(0 +1i*interEyeDistance); % negative is vertical offset
Ytemp = coordMatrix; Ytemp( :,testThis) = detections; %put detections for next cropping stage
showCrops = 0;
[ imageMatrix coordMatrix cropPosEyes ] = cropFiducial( imageMatrix,  Ytemp, ...
        1:size(coordMatrix,1), .85*paramStruct.cropSize, 0,offset, showCrops,eyeCoords ); %slightly smaller crop size 
% verifyMarkings( imageMatrix(:,:,testThis(1:10)), detections(:,(1:10) ) );    

% tune sigma paramter for next shape detector
[ nX ] = normalizeDataMOG( PCAparametersSec, ... % learn shape and texture models
                    imageMatrix , coordMatrix,  1:size(coordMatrix,2), ...
                    1, imgFeatureMode, [], 0, shapeVersion, 0, shapePercent, []); 
[ aveDist  ] = calcPairwiseDistances( nX );
paramStruct.sigma = sqrt(aveDist/2);
parameters(2) = paramStruct.sigma;

% run shape detector no cropping inside function
startTime = toc;
detections = faceShapeDetectorMOGDistNoCrop( imageMatrix, coordMatrix, ...
    trainThis, testThis, regressionMode, kernel, imgFeatureMode, ...
    parameters, showIt, shapeCoords, ...
    W0,M, a, tol, maxSimplexIterations, ...
    calcM, modelFile, PCAparametersSec, shapeVersion, ...
    mode3D, zCoords, shapePercent, fiducialCoordinates);
runTime = toc - startTime
fprintf( '%d images detected at %.2f seconds per image.\n', numTest,runTime/numTest);
%verifyMarkings( imageMatrix(:,:,testThis(1:10)), detections(:,(1:10) ));    

offset = [  cropPosEyes(testThis)-1-1i ];
detections = detections + repmat( offset, [size(detections,1),1]);
   
