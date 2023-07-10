%samuel rivera
%date: dec 8, 2008
% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)

%notes:  This function reads the  marking files from liya's files which were 
%transferred to my files and crops and save eyebrow area in order to train
%an eyebrow detector

function cropFaceForAAM(i, maskFile, debugFlag, eyeDist, dataFolder, shapeCoords)

warning off all

dataFile = [ dataFolder 'RotatedFaceDataEyeDetector' int2str(i) '.mat'];
load( dataFile);
N = size( rotatedCoordinateMatrix,2);

load( maskFile )
AAMDataDirectory = [ dataFolder, 'AAMData/'];
mkdir( AAMDataDirectory );
AAMTrainImages = cell( length(trainThis),1);
AAMTrainCoords = cell( length(trainThis),1);
AAMTestImages = cell( length(testThis),1);
AAMTestCoords = cell( length(testThis),1);

AAMtrainIndex = 1;
AAMtestIndex = 1;

for j = 1:N 
    
    %Pad and store       
    AAMpad = [0 0]; %round( [ eyeDist/2, eyeDist/2]); 
    face =   padarray(rotatedImageMatrix(:,:,j), AAMpad, 'both');
    faceCoordinates = [ real( rotatedCoordinateMatrix(:,j)), ...
                                    imag(rotatedCoordinateMatrix(:,j)) ] + ...
                                    repmat( AAMpad, size(rotatedCoordinateMatrix,1), 1 );
    if sum( trainThis == j )
       AAMTrainImages{AAMtrainIndex} = face;
       AAMTrainCoords{AAMtrainIndex} = faceCoordinates(shapeCoords,:);
       AAMtrainIndex = AAMtrainIndex +1;
    
    elseif sum( testThis == j )
        AAMTestImages{ AAMtestIndex} =  face;
        AAMTestCoords{ AAMtestIndex} = faceCoordinates(shapeCoords,:);
        AAMtestIndex = AAMtestIndex+1;
    end

    if debugFlag
        imagesc(face), colormap(gray)
        axis equal on
        hold on
        plot( faceCoordinates(shapeCoords,1), faceCoordinates(shapeCoords,2), '*');
        pause(.3)
        clf(gcf)
    end
end
warning on all

save( [ AAMDataDirectory 'training' int2str(i) '.mat'  ] , ...
                       'AAMTrainImages', 'AAMTrainCoords' , '-v7.3');   
save( [ AAMDataDirectory 'testing' int2str(i) '.mat'  ] ,  ...
                        'AAMTestImages', 'AAMTestCoords' , '-v7.3');   
    



