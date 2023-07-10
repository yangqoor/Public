%Samuel Rivera
% march 19, 2010
% notes: converts Y to W, W is dx(2N) for d landmarks, N frames, 
%                         Y is dxN
% 
% (W Transpose ) format is
% row1 : x1 y1 x2 y2 ... x36 y36 for track 1
% row2 : x1 y1 x2 y2 ... x36 y36 for track 2
%
% Y format is [ x+yi;   (every column is a complex shape vector)
%               x+yi;
%                ...

function W = YtoW( Y )

W = zeros( size(Y,1), size(Y,2)*2);

W(:, 1:2:end) = real(Y);
W(:, 2:2:end) = imag(Y);
W = W';