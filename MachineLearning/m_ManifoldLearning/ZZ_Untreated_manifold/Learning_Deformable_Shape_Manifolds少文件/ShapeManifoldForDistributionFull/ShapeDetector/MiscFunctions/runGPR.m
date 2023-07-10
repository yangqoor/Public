function [ e YtrueMinusEst Yest ] = runGPR( X, x, Y, y, params )
%Code by Samuel Rivera, sriveravi@gmail.com, is just a wrapper for GPR
%X = p x n matrix of n samples, p parameters
%Y = d x n matrix of corresponding outputs

 
[d N ] = size( Y );
p = size( x,2);
mu = zeros( p,d); 
loghyper = cell( d, 1);

% loghyper = [ params(1);  params(2);  params(3)];

% sum of a squared exponential (SE) covariance term, and independent
% noise

covfunc = {'covSum', {'covSEiso','covNoise'}};

for i1 = 1: size(Y,1)
    loghyperInit = [-1; -1; -1];
    
    loghyper{i1} = minimize(loghyperInit, 'gpr', -100, covfunc, x, y);
    
    [mu(:,i1)] = gpr(loghyper, covfunc, X', Y(i1,:)', x');
end

Yest = mu'; 

YtrueMinusEst = y - Yest;
e = norm( YtrueMinusEst, 'fro').^2;

