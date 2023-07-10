%Samuel Rivera
% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)


function [AE , stdErr, variance, allE]  = calcAveError( rootName, whole )

allE = [];
tempE = [];

    %they are overloaded vectors 
    v1 =  rootName;
    v2 = whole; 
    
%     size(v1,2)
    for i1 = 1:size(v1,2)
         [ AE, err] = aveError( v1(:,i1), v2(:,i1));
         
         allE = [ allE; err];
         
    end

    AE = mean(  allE,1); 
    stdErr = sqrt(var( allE,1))/size(allE,1);
    variance =  var( allE,1);  


    
end


