%Samuel Rivera
% march 19, 2010
% notes: converts W to Y, W is dx(2N) for d landmarks, N frames, 
%                         Y is dxN
% 
% Paulo's format:
% (W transpose) format is
% row1 : x1 y1 x2 y2 ... x36 y36 for track 1
% row2 : x1 y1 x2 y2 ... x36 y36 for track 2
%
% Y format is [ x+yi;   (every column is a complex shape vector)
%               x+yi;
%                ...

function Y = WtoY( W )
W = W';

X = W(:, 1:2:end);
Y = W(:, 2:2:end);

Y = X + 1i*Y;



