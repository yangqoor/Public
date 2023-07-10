% Samuel Rivera
% date: november 8, 2009
%  function:  cropFiducial.m
% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz, Di You, and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)
% 
% expects coordinates are complex

function [ X2 Y2 ] = cropFiducialCenterPerturb( X, Y, coordIndicesShape, cropSize, maskType, ...
                                   offset, debugCropFiducial, coordIndicesCenter, centerPerturbationAmount )

coordIndicesShape = coordIndicesShape(:);
coordIndicesCenter = coordIndicesCenter(:);

%shift coordinates
prePad = [100 + 1i*100];
N = size( Y,2);
s = cropSize; 
Y = Y + repmat( prePad, size(Y,1), N);

%determine shape center (either exact position or mean of specific
%coordinates)
if length( coordIndicesCenter ) == 2
    shapeCenter = repmat( prePad + 1i*coordIndicesCenter(1)+coordIndicesCenter(2), 1,N );
else
    shapeCenter = mean( Y(coordIndicesCenter,:), 1 );
    if ~isempty( centerPerturbationAmount ) && (centerPerturbationAmount~=0)
        centerOffset = centerPerturbationAmount*randn([2,N]);
        shapeCenter = shapeCenter+centerOffset(1,:)+1i*centerOffset(2,:);
    end
end

Y =  Y(coordIndicesShape, :);
cropPos = round( shapeCenter - repmat( 1i*s(1)/2 + s(2)/2 , 1,N )) ;

% pre-allocate for speed
X2 = zeros( s(1), s(2), N);
Y2 = zeros( size(Y));

%1 for zero out unseen, 2 for actually remove unseen
if maskType == 1 ||  maskType ==  0
   
   %cropPos put y then x coordinate 
   for i1 = 1:N
       
       %for debugging
%        size( imcrop( padarray( X(:,:,i1), [imag(prePad), real(prePad) ], 'both'  ), ...
%              [ real(cropPos(i1)), imag(cropPos(i1)),  s(2)-1, s(1)-1 ] ))
%        size(X2(:,:,1))
                         
        X2(:,:,i1) = imcrop( padarray( X(:,:,i1), [imag(prePad), real(prePad) ], 'both'  ), ...
                             [ real(cropPos(i1)), imag(cropPos(i1)),  s(2)-1, s(1)-1 ] );
        Y2(:,i1) = Y(:,i1) - cropPos(i1) +1 +1i ;
        
        
        if debugCropFiducial
            imagesc( X2(:,:, i1)), axis equal, colormap(gray);
            hold on
            plot( real( Y2(:,i1)), imag( Y2(:,i1)), 'go');
            pause;
        end
   end
    
    
elseif maskType == 2
    error('Not finished coding maskType = 2');
    
else
    error( 'Incorrect maskType specified');
end
    
    
    
    