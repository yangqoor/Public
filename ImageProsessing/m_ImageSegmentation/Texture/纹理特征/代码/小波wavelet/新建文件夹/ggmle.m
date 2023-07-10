function [ahat, bhat] = ggmle(x, options)
% GGMLE Parameter estimates for generalized Gaussian distributed data.
%	GGMLE(X, OPTIONS) Returns the maximum likelihood estimates of the  
%    	parameters of the generalized Gaussian distribution given the data in
%   	the vector, X.
%
%	OPTIONS (option) is set by OPTIMSET to be used with FZERO

if min(size(x)) > 1
    error('The first argument in GGMLE must be a vector.');
end

if nargin < 2
    options = [];
end

% Method of Moments Estimates (for beta only)
absx = abs(x);
m1 = mean(absx);
m2 = mean(x.^2);
bhat = estbeta(m1, m2);

% Method of Maximum Likelihood Estimates
% (using Moment Estimate as the initial guess)
bhat = fzeron('dggbeta', bhat, options, absx);
ahat = (bhat * sum(absx .^ bhat) / length(x)) ^ (1 / bhat);