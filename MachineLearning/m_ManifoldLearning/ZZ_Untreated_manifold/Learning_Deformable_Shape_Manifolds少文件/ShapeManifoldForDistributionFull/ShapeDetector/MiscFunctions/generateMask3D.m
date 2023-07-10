% Samuel Rivera
%  May 22, 2010
% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz, Di You, and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)


function k = generateMask3D( numFrames, maskFolder )

%Note we want this to give us 17 poses to compare to the dino data
% add +1, or +2, etc after 
%   for desiredNumTestSamples = round(numFramesPer20) HERE!!!
% to make it match up

degPerFrame = 360/numFrames;
numFramesPer20 = 20/degPerFrame;

if ~exist( maskFolder, 'dir')
    mkdir( maskFolder );
end

k = 0;
for desiredNumTestSamples = round(numFramesPer20):round(numFramesPer20/2):.5*numFrames
    
    for startIndex = 1:numFrames
        k = k+1;
        maskFile = [maskFolder 'maskFile' int2str(k) '.mat'];
        cvMaskFile1 = [ maskFolder 'CVmaskFile' int2str(k) '.' int2str(1) '.mat'];
        cvMaskFile2 = [ maskFolder 'CVmaskFile' int2str(k) '.' int2str(2) '.mat'];

        %update training/testing partitions
        trainThis = mod((startIndex:2:startIndex+desiredNumTestSamples*2)', numFrames );
        testThis = mod((startIndex+1:2:startIndex+desiredNumTestSamples*2-1)',  numFrames);
        trainThis( trainThis == 0 ) = numFrames;
        testThis( testThis == 0 ) = numFrames;
        
        %take care of duplicate last one
        if trainThis(end) == trainThis(1);
            trainThis(end) = [];
        end
        
        save( maskFile , 'trainThis', 'testThis');
        save( cvMaskFile1, 'trainThis', 'testThis' );
        
        temp = testThis;
        testThis = trainThis;
        trainThis = temp;      
        
        save( cvMaskFile2, 'trainThis', 'testThis' );
    end
end