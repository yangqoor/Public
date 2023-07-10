%
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz, Di You, and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)

%assumes x in first column, y in second colum, maybe z in 3rd column
%         (will check to see if transposed)

function  [ err] = aveError( v1, v2)
    
    if size( v1,1) > 3
        v1 = v1';
    end
    
    if size( v2,1) > 3
        v2 = v2';
    end 

    coords = size(v1,2);
    err = zeros( coords,1);
    
    for id1 = 1:coords
        err(id1) = norm( v1(:,id1)-v2(:,id1), 'fro'); 
    end
    
    
    
