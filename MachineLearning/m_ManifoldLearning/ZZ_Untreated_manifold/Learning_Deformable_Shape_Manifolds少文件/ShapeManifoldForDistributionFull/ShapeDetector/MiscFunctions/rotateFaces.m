%samuel rivera
%date: jun 30
%file: rotateFaces.m
% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz, Di You, and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)

function  [ rotatedImageMatrix rotatedCoordinateMatrix ] = rotateFaces( imageMatrix, Y, i, ...
                    targetScale, expFactor, oriNumCoords, eyeCoords, ...
                    eyeDistParams, debugRotation, detections, trainThis, testThis, dataDirectory)

% debugRotation = 1;


%warnings are annoying and plentiful
warning off all

% Get eye error distribution parameters
CT = eyeDistParams.CT;
mT = eyeDistParams.mT;

%use detected eye positions and add noise to the training eye positions
N2 = size(imageMatrix,3);
eyeCoords( :,testThis) = detections;
Enoise = mvnrnd( mT', CT, length(trainThis))';
eyeCoords( :,trainThis) = eyeCoords(:,trainThis) + Enoise;
    
%pre-allocate for speed
faceData = single( zeros( oriNumCoords, 2*N2) );
detectedEyePositionData = single( zeros( 4, N2) );
rotatedImageTensor = cell(N2,1);

%-----------------------------------------------------------------------

%Rotate the images

% Initialize variables
s1 = round([ 6*targetScale; 5*targetScale]);
rotatedImageMatrix =  single( zeros( s1(1), s1(2), N2));
rotatedCoordinateMatrix = single( zeros( oriNumCoords, N2) );
rotationMatrixAll = single( zeros( 2,2,N2) );
scaleAll = single( zeros( N2,1) );
posAll = single( zeros(2,N2));

for t2 = 1:N2  
    
    clear I II 

    %get image, eye data and face data
    eye_position = reshape( eyeCoords(:,t2), [2 2]);
    faceCoordinates = reshape( Y(:,t2), [size(Y,1)/2 2] );
    faceDataTemp = faceCoordinates;
    I = imageMatrix(:,:, t2);
    s = size(I);

    %rotate
    angle = atan( (eye_position(2,2)-eye_position(2,1))/(eye_position(1,2)-eye_position(1,1)) );   
    faceDataTempRotated = [ faceDataTemp(:,1)-s(2)/2 , faceDataTemp(:,2)-s(1)/2];

    rotationMatrix = [cos(-1*angle) sin(-1*angle);-sin(-1*angle) cos(-1*angle)];
    rotationMatrixAll(:,:,t2) = rotationMatrix;

    faceDataTempRotated = rotationMatrix'*faceDataTempRotated';
    faceDataTempRotated = faceDataTempRotated';
    faceDataTempRotated = [ faceDataTempRotated(:,1)+s(2)/2 , faceDataTempRotated(:,2)+s(1)/2];
    faceDataTemp = faceDataTempRotated;

    eye_positionTempRotated = [eye_position(1,:)- s(2)/2 ; eye_position(2,:)- s(1)/2 ];
    eye_positionTempRotated = rotationMatrix'*eye_positionTempRotated;
    eye_positionTempRotated = [eye_positionTempRotated(1,:) + s(2)/2 ; eye_positionTempRotated(2,:)+ s(1)/2 ];
    eye_position = eye_positionTempRotated;

    I = imrotate(I ,double(angle*180/pi),'bilinear','crop');
%     I = fast_rotate(uint8(I) ,angle*180/pi); %this does the cropping
    
    %scale
    scale = real(targetScale/(eye_position(1,2) - eye_position(1,1)));
    scaleAll(t2) = scale;

    % HERE IS WHERE I AM WORKING
    imTargetSize = round(scale.*size(I));
    
    % I2 = imresize(I, imTargetSize, 'bicubic' );
    
    I = imresize(I, imTargetSize, 'bicubic' );
    faceDataTemp = scale.*faceDataTemp; 
    eye_position = scale.*eye_position;

    %save rotated image and eye coordinates
    rotatedImageTensor{t2} = I;
    
    %for fast detection
    prePad = round([ targetScale*3 targetScale*3]);
    I = padarray(I, prePad, 'both');
    
    s2 = size( I);
    pos = [ (s2(1) - s1(1))/2; (s2(2) - s1(2))/2]; 
    posAll(:,t2) = ( pos - prePad(:) );
    
    I2 = imcrop(I, [ pos(2) pos(1) s1(2)-1  s1(1)-1 ]);
    rotatedImageMatrix(:,:,t2) = single(I2);
    
    %following line the +1 for offset
    rotatedCoordinateMatrix(:,t2) = complex(faceDataTemp(:,1) -pos(2)+prePad(2)+1, faceDataTemp(:,2) - pos(1)+prePad(1) +1);

    if debugRotation
        imagesc( rotatedImageMatrix(:,:,t2) );
        hold on
        plot(real( rotatedCoordinateMatrix(:,t2)), imag( rotatedCoordinateMatrix(:,t2) ) ,'b*' );
        colormap(gray)
        pause;
    end
    
    faceData(:, t2*2-1:t2*2) =  faceDataTemp;
    detectedEyePositionData(:,t2) = eye_position(:);
end

warning on all

save( [ dataDirectory 'RotatedFaceDataEyeDetector' int2str(i) '.mat'], 'faceData', ...
                    'detectedEyePositionData', 'rotatedImageTensor', 'rotatedImageMatrix', ... 
                    'rotatedCoordinateMatrix', 'rotationMatrixAll', 'scaleAll', 'posAll' ,'-v7.3' );

 