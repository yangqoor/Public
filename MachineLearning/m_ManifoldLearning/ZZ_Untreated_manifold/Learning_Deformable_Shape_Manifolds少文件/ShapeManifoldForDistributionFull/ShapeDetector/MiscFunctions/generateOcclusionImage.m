% Samuel Rivera
% Date: November 9, 2009
% Notes: This function generates the Occlusion Image

function [ OccludedImage numOccludedPixels ]= generateOcclusionImage( number, parameters, type, imageSize )


parameters = parameters(:);
imageSize = imageSize(:);
OccludedImage = ones( imageSize' );
numOccludedPixels = 0;

if type == 0
    %do nothing

elseif type == 1 %random rectangles
    for i1 = 1:number
        X = round(rand(2,1).*(imageSize- [1;1] - parameters(1:2))) + [1;1];
        OccludedImage(X(1):X(1)+parameters(1)-1, X(2):X(2)+parameters(2)-1 ) = 0;
    end
    [I J ] = find( OccludedImage == 0 );
    numOccludedPixels = length(I);

elseif type == 2 %1 centered rectangle
    X = round(imageSize/2 - parameters(1:2)/2) + [1;1];
    OccludedImage(X(1):X(1)+parameters(1)-1, X(2):X(2)+parameters(2)-1 ) = 0;
    [I J ] = find( OccludedImage == 0 );
    numOccludedPixels = length(I);
    
elseif type == 3 %squares around the center object
    %random squares everywhere
    for i1 = 1:number
        X = round(rand(2,1).*(imageSize- [1;1] - parameters(1:2))) + [1;1];
        OccludedImage(X(1):X(1)+parameters(1)-1, X(2):X(2)+parameters(2)-1 ) = 0;
    end
    %then make the center white again
    if length( parameters ) < 3
        error( 'occlusion Parameters should be 4x1 vector. [ H, W, objectHeigh, objectWidth]');
    end
    
    X = round(imageSize/2 - parameters(3:4)/2) + [1;1];
    OccludedImage(X(1):X(1)+parameters(3)-1, X(2):X(2)+parameters(4)-1 ) = 1;
    [I J ] = find( OccludedImage == 0 );
    numOccludedPixels = length(I);
    
elseif type == 4 %random squares within the optimal feature space
    %random squares everywhere
    for i1 = 1:number
        X = round(rand(2,1).*(imageSize- [1;1] - parameters(1:2))) + [1;1];
        OccludedImage(X(1):X(1)+parameters(1)-1, X(2):X(2)+parameters(2)-1 ) = 0;
    end

    X = round(imageSize/2 - parameters(3:4)/2) + [1;1];
    tempRecoverMask = ones(  imageSize' );
    tempRecoverMask(X(1):X(1)+parameters(3)-1, X(2):X(2)+parameters(4)-1 ) = 0;
    OccludedImage( tempRecoverMask == 1 ) = 1;
    
    [I J ] = find( OccludedImage == 0 );
    numOccludedPixels = length(I);
    
elseif type > 4 %not yet coded
    error( 'Undefined Occlusion type' );
        
end            