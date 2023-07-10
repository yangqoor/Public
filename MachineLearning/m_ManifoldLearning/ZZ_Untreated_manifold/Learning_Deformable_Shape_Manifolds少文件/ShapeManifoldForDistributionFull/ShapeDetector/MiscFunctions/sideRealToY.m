% Samuel Rivera
% August 25, 2010
% This takes the Y in complex format and puts it s
% 
% [ x y x y ..
%   x y x y ... ]

function Y =  sideRealToY( detectedFaceCoordinates )

    Y = detectedFaceCoordinates(:,1:2:end) + 1i*detectedFaceCoordinates(:,2:2:end);
 