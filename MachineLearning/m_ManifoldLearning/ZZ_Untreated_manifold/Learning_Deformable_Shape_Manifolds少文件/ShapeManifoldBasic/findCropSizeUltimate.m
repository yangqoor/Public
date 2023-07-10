%Samuel Rivera
%date: april 3, 2009
%file: findCropSize.m
% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)


function cropSize = findCropSizeUltimate( coordIndices, Y, percentScale )
coordIndices = coordIndices(:);
percentScale = percentScale(:);

X2 =  [ min(min( real(Y(coordIndices,:)), [], 1)); max(max( real( Y(coordIndices,:) ), [], 1)) ];
Y2 =  [ min(min( imag(Y(coordIndices,:)), [], 1)); max(max( imag( Y(coordIndices,:) ), [], 1)) ];

% maxW =  [ min(  abs(  min(  real(Y(coordIndices,:)), [], 1) - max( real( Y(coordIndices,:) ), [], 1)  ) ) ];
% maxH =  [ min(  abs(  min(  imag(Y(coordIndices,:)), [], 1) - max( imag( Y(coordIndices,:) ), [], 1)) ) ];


cropSize = round (percentScale.*[ max( 1, abs( Y2(2) - Y2(1) )) ; max(1, abs( X2(2) - X2(1) ))  ] );
% cropSize = round (percentScale.*[ max( 1, maxH) ; max(1, maxW)  ] );