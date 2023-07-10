%Samuel Rivera
%file: calcEyeDistribution.m
%date: may 14, 2009
% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)
% 
%     This file is part of the Deformable Shape Regressor (DSR).
% 
%
%notes:  This function loads up the errors from the eye CV, and calculates
%the distributions of the error (assumes Gaussian)

function [ CT mT ] = calcEyeDistribution(scale, robustErrPercent, YtrueMinusEstTotal)


    f1 = YtrueMinusEstTotal;
    

    CT = cov( f1');
    mT = mean( f1,2);
    
    preserve = robustErrPercent;
    [ B  IX] = sort( sum([f1].^2, 1).^(1/2),2 );
    N = length(IX);
    t = round( preserve.*N);
    IX(t+1:end) = [];

    if scale ~= 1
       [U S] = svd(CT);
       CT = U*( scale.*S)*U';

    end

end