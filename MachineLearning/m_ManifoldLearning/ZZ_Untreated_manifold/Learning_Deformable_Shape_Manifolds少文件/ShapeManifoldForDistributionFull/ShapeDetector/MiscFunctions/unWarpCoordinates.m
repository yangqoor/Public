%Samuel Rivera
%date: aug 2, 2009
% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz, You Di, and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)
% 
%notes: this function takes the coordinates that are in the normalized
%faces and converts it to the face detection image

function unWarpedDetections = unWarpCoordinates( index, detectedFaceCoordinates, detectedCoordFolder,  isfigure, ...
                commonDataFolder, database, maskFile, saveIndividualCoordinates, ...
                VJDetectionsFolder, VJoriginalImageFolder, dataDirectory, ...
                skipScaleNormalization, shapeDetectionModes, testThis, ...
                imageMatrix, coordinateMatrix, detections3D, imageFolder )  

    
% Load up stored results
load( [ dataDirectory 'RotatedFaceDataEyeDetector' int2str(index) '.mat' ]); 
load( maskFile );
if ischar( database)
    load( [ commonDataFolder database '_Origi.mat' ], 'nameList', 'oriScale' ); %, 'imageMatrix',
else
    load( [ commonDataFolder 'combinedDatabases_Origi.mat'], 'nameList', 'oriScale' ); %, 'imageMatrix',
end

%Initialize
detectScalar = 250/sqrt( size( imageMatrix,1)*size( imageMatrix,2));
    %generalize this detectScalar eventually.  This is for my VJ faces system only
    
N = size( detectedFaceCoordinates, 2)/2;
unWarpedDetections = cell( N,1);

for i = 1:N
    %get detected and true coordinates
    faceCoordinatesNormalized = detectedFaceCoordinates(:,i*2-1:i*2);
    faceCoordinates = [real(coordinateMatrix(:,testThis(i))) imag(coordinateMatrix(:,testThis(i))) ];

    %unwarping section------------------------------------------
    if ~skipScaleNormalization %if need to rotate and scale
        scale =  scaleAll(testThis(i)); % load up parameters for unwarping
        pos = posAll(:,testThis(i)); 
        rotationMatrix = rotationMatrixAll(:,:,testThis(i));  
        s2 = size(imageMatrix(:,:, testThis( i)));

        %shift and scale first  
        faceCoordinatesNormalized = [ faceCoordinatesNormalized + repmat( fliplr(pos'-[1 1] ), size(faceCoordinatesNormalized,1),1) ]./scale;

        %then rotate
        faceDataTemp = [ faceCoordinatesNormalized(:,1)-s2(2)/2 , faceCoordinatesNormalized(:,2)-s2(1)/2];
        faceDataTemp = (rotationMatrix*faceDataTemp')';
        faceCoordinatesUnwarped = [ faceDataTemp(:,1)+s2(2)/2 , faceDataTemp(:,2)+s2(1)/2];
    else
        faceCoordinatesUnwarped = faceCoordinatesNormalized;
    end
    

    %Now scale and shift from VJ detection to look like original
    if isdir( VJDetectionsFolder )
        load( [ VJDetectionsFolder  nameList{testThis(i)}(1:end-3) 'mat' ], 's', 'cropPos' );
        faceCoordinatesUnwarped = faceCoordinatesUnwarped.*detectScalar./s(1);
        faceCoordinatesUnwarped = faceCoordinatesUnwarped + repmat( fliplr( cropPos )-[1 1], ...
                                  size(faceCoordinatesUnwarped,1 ), 1);
    else
        %for plotting in original scale
        % faceCoordinatesUnwarped = faceCoordinatesUnwarped.*repmat( fliplr(oriScale), [ size(faceCoordinatesUnwarped,1),1] );
    end
    
    if isfigure  
        if isdir( VJoriginalImageFolder )
            if exist( [ VJoriginalImageFolder  nameList{testThis(i)}(1:end-3) 'jpg' ], 'file')
                I = imread(  [ VJoriginalImageFolder  nameList{testThis(i)}(1:end-3) 'jpg' ] );
            else
                I = imread(  [ VJoriginalImageFolder  nameList{testThis(i)}(1:end-3) 'bmp' ] );
            end
        else
            I = imageMatrix(:,:,testThis(i));
            
            % % get the unscaled image 
            % if exist( [ imageFolder  nameList{testThis(i)}(1:end-3) 'jpg' ], 'file')
            %     Iori = imread(  [ imageFolder  nameList{testThis(i)}(1:end-3) 'jpg' ] );
            % else
            %     Iori = imread(  [ imageFolder  nameList{testThis(i)}(1:end-3) 'bmp' ] );
            % end

        end 
        
        if isempty( detections3D ) %2D plot
            
            %Nice plotting
             beautifulFacePlots( faceCoordinatesUnwarped, I, [], faceCoordinates );
%              title( nameList{testThis(i)}(1:end-4));
            
            %---------------------------------------------            
            %---------------------------------------------
            % Results For paper
%             clf(gcf)
%             imagesc( I )  %, colormap(gray);
%             axis off equal;
%             hold on
%             customFacePlots( faceCoordinatesUnwarped, [] )
            % customHandPlots( faceCoordinatesUnwarped );
   
%             axis( [ mean(faceCoordinatesUnwarped(:,1))-65 mean(faceCoordinatesUnwarped(:,1))+65 ...
%                     mean(faceCoordinatesUnwarped(:,2))-80
%                     mean(faceCoordinatesUnwarped(:,2))+80] );   
%             axis( [ mean(faceCoordinatesUnwarped(:,1))-25 mean(faceCoordinatesUnwarped(:,1))+25 ...
%                     mean(faceCoordinatesUnwarped(:,2))-30 mean(faceCoordinatesUnwarped(:,2))+35] );   
            

%             filename = [ 'ASLInt/ASL_' int2str(i) '.eps'];
%             print2eps(filename, 1)

%             filename = [ 'ASLSFMDemoImages/ASL_' int2str(i) '.png'];
%             saveas(1,filename);
            %---------------------------------------------
            %---------------------------------------------
            
        else  %3D plot 
           
%            subplot( 141)
            figure(1);
            clf(1);
           if size(faceCoordinatesUnwarped,1) == 20
                customHandPlots3D( [ faceCoordinatesUnwarped detections3D(:,i) ] )
           else
                %plot3( faceCoordinatesUnwarped(:,1),faceCoordinatesUnwarped(:,2), detections3D(:,i), 'g.');
                customFacePlots3D( [faceCoordinatesUnwarped(:,1),faceCoordinatesUnwarped(:,2), detections3D(:,i)], 'g.');
           end
           % title( '3D shape detection' );
           xlabel( 'x axis'); ylabel( 'y axis');
           zlabel( 'z axis');
           set(gca,'YDir','reverse')
            axis vis3d equal off
            set(gcf,'Color',[0 0 0])
           view(0, 90)
           
%           subplot( 142) 
            
            figure(2);clf(2);
           if size(faceCoordinatesUnwarped,1) == 20
                customHandPlots3D( [ faceCoordinatesUnwarped detections3D(:,i) ] )
           else
                %plot3( faceCoordinatesUnwarped(:,1),faceCoordinatesUnwarped(:,2), detections3D(:,i), 'g.');
                customFacePlots3D( [faceCoordinatesUnwarped(:,1),faceCoordinatesUnwarped(:,2), detections3D(:,i)], 'g.');
           end
           % title( '3D shape detection' );
           xlabel( 'x axis'); ylabel( 'y axis');
           zlabel( 'z axis');
           set(gca,'YDir','reverse')
            axis vis3d equal off
            set(gcf,'Color',[0 0 0])
           view(0, 135)
           
                      
%           subplot( 143)
            
            figure(3);clf(3);
           if size(faceCoordinatesUnwarped,1) == 20
                customHandPlots3D( [ faceCoordinatesUnwarped detections3D(:,i) ] )
           else
                %plot3( faceCoordinatesUnwarped(:,1),faceCoordinatesUnwarped(:,2), detections3D(:,i), 'g.');
                customFacePlots3D( [faceCoordinatesUnwarped(:,1),faceCoordinatesUnwarped(:,2), detections3D(:,i)], 'g.');
           end
           % title( '3D shape detection' );
           xlabel( 'x axis'); ylabel( 'y axis');
           zlabel( 'z axis');
           set(gca,'YDir','reverse')
            axis vis3d equal off
            set(gcf,'Color',[0 0 0])
           view(0, 45)
           
%            subplot(144)
           
            figure(4); clf(4);
           imagesc( I), colormap(gray);
           axis equal off
           hold on
           if size(faceCoordinatesUnwarped,1) == 20
                customHandPlots( [ faceCoordinatesUnwarped detections3D(:,i) ] )
           else
                %plot3( faceCoordinatesUnwarped(:,1),faceCoordinatesUnwarped(:,2), detections3D(:,i), 'g.');
                customFacePlots( [faceCoordinatesUnwarped(:,1),faceCoordinatesUnwarped(:,2), detections3D(:,i)], 'g.');
           end
           title( 'Detected coordinates' );
           set(gcf,'Color',[0 0 0])
           
%            plot( faceCoordinates(:,1), faceCoordinates(:,2), 'g.');
%            title( 'True coordinates' );
        end
        pause(.1);
        
    end
     
    %save coordiantes individually, or in a cell
    if saveIndividualCoordinates
        if ~isempty( shapeDetectionModes )
            shapeModes = shapeDetectionModes(:,i);
        else
            shapeModes = [];
        end

        % final ori scale
        if ~isdir( VJDetectionsFolder )
            faceCoordinatesUnwarped = faceCoordinatesUnwarped.*repmat( fliplr(oriScale), [ size(faceCoordinatesUnwarped,1),1] );
        end
        save( [detectedCoordFolder nameList{testThis(i)}(1:end-3) 'mat' ] , 'faceCoordinatesUnwarped', 'shapeModes');

%     else
%         unWarpedDetections{i} = faceCoordinatesUnwarped; 
    end

end

% if ~saveIndividualCoordinates
%     save( [dataDirectory 'UnwarpedDetections/unwarpedDetections' int2str(index) '.mat' ], 'unWarpedDetections' );
% end


