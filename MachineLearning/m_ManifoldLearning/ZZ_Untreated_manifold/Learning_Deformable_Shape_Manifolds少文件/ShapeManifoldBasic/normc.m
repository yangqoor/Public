%Samuel Rivera
% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)
% 

function Y = normc( X )

N = size( X,1);
Y = X./( repmat( sqrt( sum( X.^2,1) ), N,1));