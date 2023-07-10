%Samuel Rivera
% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)


function cleanItUp( opt, dataFile )

if opt == 1
    display( 'Basic cleanup:  Rotated faces, temp files, shapeDetection.');
    system( [ 'rm ' dataFile 'Rotate*'] );
    system( [ 'rm ' dataFile '*temp* '] );
    system( [ 'rm ' dataFile 'shapeDetection* '] );
   system( [ 'rm ' dataFile 'AAMData/testing*' ] );
   system( [ 'rm ' dataFile 'AAMData/training*' ] );
    
elseif opt ==5
    display( 'CV anc PCA parameters erased.');
    system( [ 'rm ' dataFile 'CVResults/*'] );
    system( [ 'rm ' dataFile '*PCA* '] );
    system( [ 'rm ' dataFile 'AAMData/AAMRIKTrained*' ] );
    
elseif opt == 4
    display( 'PCA parameters erased.');
    system( [ 'rm ' dataFile '*PCA* '] );
    
elseif opt == 7
    display( 'Error results cleared.');
    system( [ 'rm ' dataFile 'ResultSummary/errorResults* '] );
    
else
    display( 'This cleanItUp option not coded. Define it yourself by editing cleanItUp.m' );    
end
