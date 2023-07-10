% Samuel Rivera
% file: generateMask
% date: feb 16, 2009
% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)

% notes: this funciton generates train and testing partitions 
% percentTrain = .7;
% classList = 'data/classLabels.mat';  %loads classLabels
% maskFile = 'data/maskFile.mat';


function  [testThis trainThis] = generateMask( percentTrain, numClasses, maskFile )


p = randperm(numClasses);
t = round( percentTrain*numClasses );

%set train and test parts
trainThis = p(1:t);
testThis = p(t+1:end);
trainThis = sort(trainThis);
testThis = sort(testThis);
trainThis = trainThis(:);
testThis = testThis(:);

if length( trainThis) < length(testThis)
    display( 'SR Warning: Less training samples than test samples.');
end

% Save it
if ~isempty( maskFile )
    save( maskFile, 'testThis', 'trainThis' );
end