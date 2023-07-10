% 

% % superSimpleShapeDetector( imageSize,   dataFolder, numCoords, ...
% %                            showLoadingImages, showUnwarping, ...
% % 							 markingsVariableName, imageSuffix,
% % 							 trainImages, trainMarkings, 
% % 							 testImages, detectedCoordFolder, ...
% %                            leftEyeCoords, rightEyeCoords, skipEyeNormalization )
% % 
% %                        
                       
trainImages = '../DatabaseStores/AR/formattedImages/';
trainMarkings = '../DatabaseStores/AR/formattedMarkings/';

path(path, 'ShapeDetector/');
path(path, 'ShapeDetector/MiscFunctions/');
path(path, 'ParticleSwarm/psopt');
                       
showLoadingImages = 0; % to make sure images and markings loaded properly
showUnwarping = 1; % to show final result
skipEyeNormalization = 0;  % normalize by eye detection first

superSimpleShapeDetector( [150 150], 'tempData/' , 130, ...
                              showLoadingImages, showUnwarping, ...
							    'faceCoordinates', 'jpg', ...
								trainImages, trainMarkings, ...
							    trainImages,'outputDetectedCoordinates/', ...
                               1:13, 14:26, 0)