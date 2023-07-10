%Samuel Rivera
% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz, Di You, and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)


function [allE]  = calcPercentError( true, detect, nonMissingMask )

    allE = zeros( size( true,2),1); 

    for i1 = 1:size(true,2)
        
        knownIndex = find( nonMissingMask(:,1) == 1);
        allE(i1) = norm( true(knownIndex,i1)- detect(knownIndex,i1), 'fro')/norm(true(knownIndex,i1), 'fro');  

    end 
    
end


