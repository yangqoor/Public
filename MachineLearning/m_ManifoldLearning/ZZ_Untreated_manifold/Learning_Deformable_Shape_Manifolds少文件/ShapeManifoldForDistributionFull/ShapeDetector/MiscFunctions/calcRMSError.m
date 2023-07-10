%Samuel Rivera
% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)


function [allE]  = calcRMSError( true, detect, nonMissingMask2 )

    allE = zeros( size( true,2),1);
    Error = abs( true - detect).*nonMissingMask2; 

    for i1 = 1:size(true,2)
         [ allE(i1) ] = sqrt( ( Error(:,i1)' * Error(:,i1) ) / sum(nonMissingMask2(:,i1)) );
         
    end 
    
end


