% Samuel Rivera
% file: rmse
% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)

% this function returns RMSE of 2 vectors

function error = rmse(x1, x2)
    
error = sqrt(norm( x1 -x2)^2/length(x1));
    

