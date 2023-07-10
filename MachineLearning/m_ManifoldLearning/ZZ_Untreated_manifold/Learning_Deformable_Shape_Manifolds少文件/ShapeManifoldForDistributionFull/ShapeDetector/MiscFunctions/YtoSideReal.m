% Samuel Rivera
% August 25, 2010
% This takes the Y in complex format and puts it s
% 
% [ x y x y ..
%   x y x y ... ]

function detectedFaceCoordinates =  YtoSideReal( Y )

    detectedFaceCoordinates = zeros( size(Y,1), 2*size(Y,2));
    detectedFaceCoordinates(:,1:2:end) = real(Y);
    detectedFaceCoordinates(:,2:2:end) = imag(Y);