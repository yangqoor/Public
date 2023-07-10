% Samuel Rivera
% date: may 12, 2009
% file: storeCommonData.m
% 
% Deformable Shape Regressor, v1.0
% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)
% 
%     This file is part of the Deformable Shape Regressor (DSR).
% 
%     notes: this function loads up the databases to save them conveniently in
%     single .mat files
%     set maxRead to -1 if you don't want to specify that parameter
%     database = 'ASL', 'AR', 'LFW', or 'EKM'
%     isFigure =1 if you want to show images
%     imageSize = some integer value, images assumed square

function [ N imageMatrix coordinateMatrix X Y nameList eyeCoords imageFolder ] = storeCommonData( database, ...
                                imageSize, maxRead, storeFolder, ...
                                isFigure, reloadImagesEveryTime, imageFolder, ...
                                markingFolder130, base, oriNumCoords, ...
                                markingsVariableName, skipNormalization, ...
                                leftEyeCoords, rightEyeCoords, namePrefix, imageSuffix)
warning off all
imageSize = round(imageSize);
if length(imageSize ) == 1
    imageSize =  [imageSize; imageSize];
end
if strcmp( 'faceCoordinates', markingsVariableName);
    markingsVariableName = [];
end

imageSize = imageSize(:);
origiOutputFile = [ storeFolder database '_Origi.mat' ];
origiVectorFile = [ storeFolder database '_Vectorized.mat' ];


if strcmp( database, 'LFW')
    imageFolder = [ base 'LFW/lfwSortedImages/'];
    markingFolder130 = [ base 'LFW/lfwSortedMarkings/allPoints/'];

    % simple check for LFW, which is kind of a bad format for original 
    %   130 point format
    if oriNumCoords == 130
        markingFolder130 = [ base 'LFW/lfwSortedMarkings/130points/'];
    end
        
    
elseif isempty( markingFolder130 ) && isempty( imageFolder )
    imageFolder = [ base database '/formattedImages/'];
    markingFolder130 = [ base database '/formattedMarkings/'];    
    
elseif isempty( markingFolder130 ) 
    display( [ 'No markings for ' database ]);
    if isdir( imageFolder  )
        list = dir( [ imageFolder  namePrefix '*.' imageSuffix ]);
    else
        imageFolder = [ base database '/formattedImages/'] ;
        list = dir( [ imageFolder namePrefix '*.' imageSuffix  ] );
    end
    unknown = 1; 
%else
%    error( 'SR: wrongly specified markings/images file');
end

%make sure database is a string
if ischar( database )
    
    % if markingFolder specified, get markings list
    if ~isempty( markingFolder130 ) 
        list = dir( [ markingFolder130 namePrefix '*.mat' ]);
        unknown = 0;
    end
    
    N = size( list,1);
    
    %  Trying to sort this in alphanermical order, but this function
    %  still needs some work.  Breaks in some occasions, don't know why
    namesOfList = cell( N,1);
    for i2 = 1:N
        namesOfList{i2} = list(i2).name;
    end
    list2 = asort( namesOfList , 'ANR' );
    for i2 = 1:N
        if ~isempty( list2.snr )
            list(i2).name= list2.snr{i2};
        else
            list(i2).name= list2.anr{i2};
        end
    end
    
    % adjust N if necessary
    if maxRead >=0 && N > maxRead
        N = maxRead;
    end
    
    %standard training and testing within one database
    if ~exist( origiVectorFile , 'file') || reloadImagesEveryTime    

        %preallocate/initialize for speed
        imageMatrix = single( zeros( imageSize(1), imageSize(2), N));
        coordinateMatrix = single( zeros( oriNumCoords  , N));
        X = single( zeros(imageSize(1)*imageSize(2) , N));
        Y = single(zeros( 2*oriNumCoords, N));
        eyeCoords = single(zeros( 4,N));
        nameList = cell(N,1);
        oriScale =  [1 1];
        
        for i = 1:N
            
            %store image names
            nameList{i} = list(i).name;
            
            %load image and markings
            if strcmpi( database, 'LFW' )
                longName = list(i).name(1:end-4);
                shortName = list(i).name(19:end-4);
                A = imread( [ imageFolder shortName '.' imageSuffix  ]);
                if ~unknown
                    load( [ markingFolder130 longName '.mat' ]);
                end
                
            else
                longName = list(i).name(1:end-4);
                A = imread( [ imageFolder longName '.' imageSuffix  ]);
                if ~unknown
                    load( [ markingFolder130 longName '.mat' ]); 
                end
            end
            
            %if you have a different variable name (coordinates2D)
            %expecting [ x1 y1 ;
            %            x2 y2 ;
            %             ... ];
            
            if ~isempty( markingsVariableName )
                faceCoordinates = [];
                eval( [ 'faceCoordinates = ' markingsVariableName ';']); 
            end
            
            % Convert to grayscale
            if length( size(A)) == 3
                A = rgb2gray(A);
            end
            
            %--------------------
            %rescale section 
            if size( A,1) ~= imageSize(1)
                scale = [ imageSize(1)./size( A,1), imageSize(2)./size( A,2); ];
                oriScale = 1./scale;
                
                if ~unknown
                    faceCoordinates = faceCoordinates.*repmat( fliplr( scale), ...
                                    size(faceCoordinates,1) , 1);
                end
                A = imresize( A, imageSize', 'bicubic');
            end
            I = A;
            %--------------------
            
            imageMatrix(:,:,i) = I;
            if unknown
                faceCoordinates = rand( oriNumCoords, 2);
                coordinateMatrix(:,i) = complex( faceCoordinates(:,1), faceCoordinates(:,2));
            else
                coordinateMatrix(:,i) = complex( faceCoordinates(:,1), faceCoordinates(:,2));
            end
            
            %get eyeCoords
            if ~skipNormalization
                eye_position = [ mean( faceCoordinates(leftEyeCoords(:),1:2), 1); mean( faceCoordinates(rightEyeCoords(:), 1:2), 1)]';
                eyeCoords(:,i) = eye_position(:);
            end
            
            %vectorized images/coordinates
            X(:,i) = I(:);
            Y(:,i) = faceCoordinates(:);        

            if isFigure
                imagesc( I), colormap(gray);
                hold on
                plot( faceCoordinates(:,1), faceCoordinates(:,2), 'b.');
                pause(.3);
                %HERE
                
            end

        end
        
        save( origiOutputFile, 'imageMatrix', 'coordinateMatrix', 'nameList', 'eyeCoords', 'oriScale'  ,'-v7.3'); 
        save( origiVectorFile, 'X', 'Y'  ,'-v7.3'); 
    else
         load( origiVectorFile );
         load( origiOutputFile );
         N = size( Y,2);
    end
else
    error( 'SR: strange database specified');
end
warning on all
