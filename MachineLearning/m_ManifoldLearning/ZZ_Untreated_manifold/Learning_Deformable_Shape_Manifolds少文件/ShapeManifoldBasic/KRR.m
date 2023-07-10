%Samuel Rivera
%nov, 12, 2008
%file KRR.m
% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)


function [f g] = KRR( X, Y, x , sigma, lambda, modelFile)
%X and Y contains columns of training data, x for testing

% Old way calculating gram matrix
% tempG = rbf( [X x]', sigma );


% Old way I was gettin Gram matrix
% tempG = rbf( [X x]', sigma );


% calculate the pairwise distance matrix
nAll = size( [X x],2);
A = [X x]'*[X x];
dA = diag(A);
DD = repmat(dA,1,nAll) + repmat(dA',nAll,1) - 2*A;
tempG = exp( DD./(-1*2*sigma.^2));


%size(tempG)
% 
% trainingdata=X';
% l=size(trainingdata,2);
% A = trainingdata'*trainingdata;
% dA = diag(A);
% DD = repmat(dA,1,l) + repmat(dA',l,1) - 2*A;


n = size( X,2);

G = tempG( 1:n, 1:n);





%size(G)

%size(Y

%added to deal with bad inversion step
%S = G + lambda.*eye(n);
%d = rank(S);
%[V,D] = eigs(S,d);

if nargin == 6 && exist( modelFile, 'file')
    load( modelFile, 'g' )
else
    g = Y*((G + lambda.*eye(n))\eye(n));   %*inv( G + lambda.*eye(n));
end

z = tempG( 1:n, n+1:end);

f =g*z; 
