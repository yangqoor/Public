% Samuel Rivera
% file: detectAndStandardizeFaces.m
% date: may 28, 2009
% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz, Di You, and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)


function detectAndStandardizeFaceOriScale( scaleNearest, DatabaseFolder, database, displayOn, ...
                reconcileMisdetected, displayReconciled, imageFolder, markingFolder, ...
                coordName, fixedSize)

%for input
% imageFolder =  [ DatabaseFolder database '/ImagesOriginal/' ];     % '../commonData/EKM/rawData/rawImages/jpgImages/';
% markingFolder = [ DatabaseFolder database '/MarkingsOriginal/'];    %'../commonData/EKM/rawData/rawMarkings130/';
%scaleNearest  = 350;

%for output
formattedImages = [ DatabaseFolder database '/AllformattedImages/']; %'../commonData/EKM/VJNormalized/';
detectionInfoFolder = [ DatabaseFolder database '/VJDetections/'];  %'../commonData/EKM/VJDetections/';

imagesKnownMarkingsCoordinates = [ DatabaseFolder database '/formattedMarkings/'];  % '../commonData/EKM/VJNormalizedKnownMarkings/';
imagesKnownMarkings = [ DatabaseFolder database '/formattedImages/']; %  %'../commonData/EKM/VJNormalizedKnown/';
imagesUnknownMarkings =  [ DatabaseFolder database '/unmarkedFormattedImages/'];


%---------------------------------------
tempDetectionFile = 'tempDetection.txt';
if ~exist( formattedImages, 'dir')
    mkdir( formattedImages )
    mkdir( imagesKnownMarkingsCoordinates )
    mkdir( detectionInfoFolder )
    mkdir( imagesUnknownMarkings )
    mkdir( imagesKnownMarkings)
end

upSize = 1.7;
targetImSize = 250;

misdetection_matrix=cell(1,1);
k1=1;

list = dir( [ imageFolder '*.jpg']);
if size(list,1) < 2
  list = dir( [ imageFolder '*.bmp']);  
end
    
N = size(list,1);
warning off all
for i = 1:N
    clear faceCoordinates
    
    baseName = list(i).name(1:end-4);
%     if ~exist( [formattedImages baseName '.jpg' ], 'file' )

        %for markings
        markingsExist = 0;
        if exist( [ markingFolder 'detailed_markings_' baseName '.mat' ], 'file');
            markingsExist = 1;
            load( [ markingFolder 'detailed_markings_' baseName '.mat' ], coordName ); 
        elseif exist( [ markingFolder baseName '.mat' ], 'file');
            markingsExist = 1;
            load( [ markingFolder baseName '.mat' ] , coordName); 
            
            %if using the whole coordinate system
            if ~exist( coordName, 'var' )
                error( 'Cannot find the coordinates, check coordName ');
            end
            eval( ['faceCoordinates = ' coordName ';'] );
        end
        
        %here add code which does the face detection
        % eval( ['!/media/Data/VJDetectorLinux/detectFace ' imageFolder list(i).name ' ' tempDetectionFile ]);
        eval( ['!/Users/stunna/Data/XCODE/ViolaJonesOSXFinal/build/Debug/detectFace ' imageFolder list(i).name ' ' tempDetectionFile ]);
        
        X = load( tempDetectionFile );

        
        if ~isempty(X) %&& max( X(:,3))>180,
            [C I ] = min( abs(X(:,3)-scaleNearest));
            facePos = X(I,:);
            facePosOriginal = X(I,:);
%             facePosOriginal
            
            %store first size information in case fixed size stuff
            if i == 1
                Xinit = facePos;
            end
            
            % make sure the size is the same for all
            if fixedSize
                facePos(3:4) = Xinit([3:4]);
                facePosOriginal(3:4) = Xinit([3:4]);
            end

            % This portion specifies the crop position and size
            % old way, based on Faces in Wild paper
            % facePos(1:2) = facePos(1:2) - facePos(3:4).*.6;
            %facePos(3:4) = facePos(3:4).*upSize;
            facePos(1:2) = facePos(1:2) - facePos(3:4).*(upSize -1)./2; % for upsize = 2.2, its .6
            facePos(3:4) = facePos(3:4).*upSize;
            
                                 
            % This necessary for the unwarping to original size
            cropPos = facePos(1:2);
            
            A = imread( [ imageFolder list(i).name ]);

            %display image and detected face
%                 if displayOn
%                     rectangle = [ facePos(2) facePos(2)+facePos(4) facePos(2)+facePos(4) facePos(2) facePos(2) ;
%                                   facePos(1) facePos(1) facePos(1)+facePos(3) facePos(1)+facePos(3) facePos(1)];
% 
%                     figure(1)
%                     imshow( A);
%                     hold on
%                     plot( rectangle(1,:), rectangle(2,:) , 'g-');
%                     pause;    
%                 end

            %crop larger face region and update corresponding coordinates
            pad = [300,300];
            A = padarray( A, pad, 'both');
            facePos(1,1:2) = facePos(1,1:2) + pad;
            
            
            B = A( facePos(1):facePos(1)+facePos(3),facePos(2):facePos(2)+facePos(4), :);
            
            % since not changing the scale
            s = 1; %targetImSize/size(B,1);
            B2 = B; %imresize(B, [targetImSize targetImSize], 'bilinear'); 

            if markingsExist
                faceCoordinates = faceCoordinates + repmat(pad,size( faceCoordinates,1),1 );
                faceCoordinates = faceCoordinates - repmat(fliplr(facePos(1:2)),size( faceCoordinates,1),1)+ repmat([1 1], size( faceCoordinates,1),1);
                
                % since not changing scale
                %faceCoordinates = s.*faceCoordinates;
            end

            %display formatted imaged and coordinates
            if displayOn
                 imshow( B2 );
                 hold on
                 axis equal
                 if markingsExist
                    plot( faceCoordinates(:,1), faceCoordinates(:,2) , 'g*');
                 end
                 pause(.01);  
            end


            imwrite( B2, [formattedImages baseName '.jpg'], 'jpeg')
            save( [ detectionInfoFolder  baseName '.mat' ], 'facePosOriginal', 's', 'cropPos');

            if markingsExist
                imwrite( B2, [imagesKnownMarkings baseName '.jpg'], 'jpeg')
                save( [ imagesKnownMarkingsCoordinates baseName '.mat'], 'faceCoordinates' ); 

            else
                imwrite( B2, [imagesUnknownMarkings baseName '.jpg'], 'jpeg')
            end


        else %if face not detected in that image
            fprintf( 'image %s face not detected\n', baseName );
            misdetection_matrix{k1}=baseName;
            k1=k1+1;
        end
%     end
end

% for the images with no face detection,
%get mean shape detection and use that for all non-detected faces
if reconcileMisdetected
    list2 = dir( [detectionInfoFolder '*.mat'] );
    N2 = size(list2,1);
    X2 = zeros( N2, size( facePosOriginal,2));
    for i3 = 1:N2
        load( [ detectionInfoFolder  list2(i3).name ], 'facePosOriginal');
        X2(i3,:) = facePosOriginal;
    end
    X = mean( X2,1);

    for i4 = 1:N
        baseName = list(i4).name(1:end-4);
        if ~exist( [formattedImages baseName '.jpg' ], 'file' )

            display( [ 'reconciling image ' baseName ]);

            %for markings
            markingsExist = 0;
            if exist( [ markingFolder 'detailed_markings_' baseName '.mat' ], 'file');
                markingsExist = 1;
                load( [ markingFolder 'detailed_markings_' baseName '.mat' ], coordName ); 
            elseif exist( [ markingFolder baseName '.mat' ], 'file');
                markingsExist = 1;
                load( [ markingFolder baseName '.mat' ] , coordName); 

                %if using the whole coordinate system
                if ~exist( coordName, 'var' )
                    error( 'Cannot find the coordinates, check coordName ');
                end
                eval( ['faceCoordinates = ' coordName ';'] );
            end
        
                    
            facePos = X;
            facePosOriginal = X; 

            facePos(1:2) = facePos(1:2) - facePos(3:4).*(upSize -1)./2;
            facePos(3:4) = facePos(3:4).*upSize;
            cropPos = facePos(1:2);
            
            A = imread( [ imageFolder list(i4).name ]);

            %display image and detected face
%                 if displayOn
%                     rectangle = [ facePos(2) facePos(2)+facePos(4) facePos(2)+facePos(4) facePos(2) facePos(2) ;
%                                   facePos(1) facePos(1) facePos(1)+facePos(3) facePos(1)+facePos(3) facePos(1)];
%                     figure(1)
%                     imshow( A);
%                     hold on
%                     plot( rectangle(1,:), rectangle(2,:) , 'g-');
%                     pause;    
%                 end

            %crop larger face region and update corresponding coordinates
            pad = [300,300];
            A = padarray( A, pad, 'both');
            facePos(1,1:2) = facePos(1,1:2) + pad;
            B = A( facePos(1):facePos(1)+facePos(3),facePos(2):facePos(2)+facePos(4), :);
            s = targetImSize/size(B,1);
            B2 = imresize(B, [targetImSize targetImSize], 'bilinear'); 

            if markingsExist
                faceCoordinates = faceCoordinates + repmat(pad,size( faceCoordinates,1),1 );
                faceCoordinates = faceCoordinates - repmat(fliplr(facePos(1:2)),size( faceCoordinates,1),1)+ repmat([1 1], size( faceCoordinates,1),1);
                faceCoordinates = s.*faceCoordinates;
            end

            %display formatted imaged and coordinates
            if displayReconciled
                 imshow( B2 );
                 hold on
                 axis equal
                 if markingsExist
                    plot( faceCoordinates(:,1), faceCoordinates(:,2) , 'g*');
                 end
                 pause(.01);  
            end


            imwrite( B2, [formattedImages baseName '.jpg'], 'jpeg')
            save( [ detectionInfoFolder  baseName '.mat' ], 'facePosOriginal', 's', 'cropPos');

            if markingsExist
                imwrite( B2, [imagesKnownMarkings baseName '.jpg'], 'jpeg')
                save( [ imagesKnownMarkingsCoordinates baseName '.mat'], 'faceCoordinates' ); 

            else
                imwrite( B2, [imagesUnknownMarkings baseName '.jpg'], 'jpeg')
            end
        end
    end
end
        

warning on all

