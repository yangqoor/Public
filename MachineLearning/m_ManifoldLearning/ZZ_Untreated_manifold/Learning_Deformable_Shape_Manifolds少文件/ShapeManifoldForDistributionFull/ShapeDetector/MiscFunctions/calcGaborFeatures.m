% Samuel Rivera
% Date: Aug 23, 2010
% Notes: This function is a wrapper for that Gabor feature stuff

function calcGaborFeatures( I, scale, desiredNumFeatures)


% [C,S] = GABORMASK(SIZE, SIGMA, PERIOD, ORIENT) 
% [C, S] = gabormask( [25 25] , 


% % reduce dimensionality
% downSampleAmount = round( size(F,2)/desiredNumFeatures );
% F = F(:, 1:downSampleAmount:end);