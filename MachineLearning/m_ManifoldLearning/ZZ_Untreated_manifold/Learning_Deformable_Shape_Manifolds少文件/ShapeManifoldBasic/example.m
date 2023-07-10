% Samuel Rivera May 7, 2011
%   This example shows you how to use the the shape detection code.
%   It defines the necessary paramters, and does the shape detection.
%   It first detects the eye positions, and aligns the shapes based on the
%   eye positions.  Then detects the whole shape.
%    You will need:
%    trainImages: ( Height x Width x numTrain ) grayscale images
%    testImages: ( Height x Width x numTest ) grayscale images
%    trainMarkings: ( d x numTrain ) complex landmarks
%    testMarkings:  ( d x numTest ) complex landmarks 
% load( 'trainTestImageMarkingAR.mat', 'trainImages', 'testImages', 'trainMarkings', 'testMarkings' )
% define train/test label 

load testImages.jpg
load trainImages.jpg
load trainTestImageMarkingAR.mat
load trainMarkings
load testMarkings

numTrain = size(trainImages,3);
numTest = size(testImages,3);
trainThis = 1:numTrain;
testThis = numTrain+(1:numTest);
% define eye coordinate indices (for aligning shape)
eyeCoords = 1:26;
%put data in matrices
imageMatrix = cat(3,  trainImages , testImages);
coordMatrix = [ trainMarkings, testMarkings ];
% define parameters
percentSize = 1; % 1 for finding a crop size that encompasses the whole shape
paramStruct.lambda = .01;
paramStruct.centerCropPosition = size(trainImages(:,:,1))./2;
paramStruct.cropSize =findCropSizeUltimate( 1:size(coordMatrix,1), coordMatrix, percentSize.*[1;1] );
% detect shape
detections = mainDSREyeCenter( imageMatrix, coordMatrix, trainThis, testThis, paramStruct, eyeCoords );
%show results
verifyMarkings( imageMatrix(:,:,testThis), detections );