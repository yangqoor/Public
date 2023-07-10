%Samuel Rivera
%file: generateMask
%date: feb 16, 2009
% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)
%
%notes: this funciton generates a mask file 

function trainTestSplits = generateCVMask( maskFileFolder, maskFile, i2, nFold )


percentTrain = 1/nFold;

load( maskFile );
trainThisOri = trainThis(:);
N = length( trainThis );
classLabels = 1:N;

p = randperm(N);
t = floor( percentTrain * N );
 
trainTestSplits.train = cell(nFold,1);
trainTestSplits.test = cell(nFold,1);

startIndex  = 1;
for j = 1:nFold
    
    trainThis = [];
    testThis = [];
    

    %take part for testing
    for i = startIndex:j*t
        g = find( classLabels == p(i) )';
        testThis= [testThis; g(:) ];
    end
 
    fullG = 1:N;
    for i = startIndex:j*t
        g = find( classLabels == p(i) )';
        fullG( g) = 0;
    end
    
    trainThis = fullG( fullG ~= 0 )';
    startIndex = startIndex + t;

     trainThis =  sort(trainThis);
     testThis = sort(testThis);

     trainTestSplits.train{j} = trainThis;
     trainTestSplits.test{j} = testThis;
     
     %this is needed if you're passing allll the data to the CV functions
     %instead, i am just passing the straight training data, so not necessary
     
%     trainThis = trainThisOri( trainThis );
%     testThis = trainThisOri( testThis);

    maskFile = [ maskFileFolder 'CVmaskFile' int2str(i2) '.' int2str(j) '.mat'];
    save( maskFile, 'trainThis', 'testThis' );
    
end


