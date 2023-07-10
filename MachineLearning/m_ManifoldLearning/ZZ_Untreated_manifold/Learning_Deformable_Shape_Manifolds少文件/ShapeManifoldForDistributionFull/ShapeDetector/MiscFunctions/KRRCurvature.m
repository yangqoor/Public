%Samuel Rivera
%nov, 12, 2008
%file KRR.m
% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)


function [f g] = KRRCurvature( X, Y, x , sigma, lambda, modelFile)
%X and Y contains columns of training data, x for testing

n = size( X,2);
nAll = size( [X x],2);

% Old way I was gettin Gram matrix
% tempG = rbf( [X x]', sigma );


% calculate the pairwise distance matrix
A = [X x]'*[X x];
dA = diag(A);
DD = repmat(dA,1,nAll) + repmat(dA',nAll,1) - 2*A;
tempG = exp( DD./(-1*2*sigma.^2));


DD = DD(1:n,1:n);     % pairwise distance matrix
G = tempG( 1:n, 1:n); % gram matrix

% This is penalty matrix related to the curvature
M = calcCurvPenaltyMatrixM( X', sigma, DD );


%added to deal with bad inversion step
%S = G + lambda.*eye(n);
%d = rank(S);
%[V,D] = eigs(S,d);

% saving thing not coded yet
if nargin == 6 && exist( modelFile, 'file')
    load( modelFile, 'g' )
else
    % Original formula
    %     g = Y*((G + lambda.*eye(n))\eye(n));   %*inv( G + lambda.*eye(n));

    % Curvature penalized formula
    g = Y*((G + lambda.*(G\eye(n))*M )\eye(n)); 
end

% Note:
%inv(G) ==  G\eye(n)

z = tempG( 1:n, n+1:end);
f =g*z; 
