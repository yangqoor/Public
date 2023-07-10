% Samuel Rivera
% date: aug 1, 2010
% function srGCV
% notes: This function does generalized cross validation error for KRR
%   It approximates the leave one out cost efficiently
% 
% X pxN (inputs)
% Y dxN (outputs)


function V = srGCVCurveKRR( X, Y, lambda, sigma )

[d N] = size(Y);



% Gram matrix
% K = rbf( X', sigma ); 

A = X'*X;
dA = diag(A);
DD = repmat(dA,1,N) + repmat(dA',N,1) - 2*A; % pairwise distance matrix
K = exp( DD./(-1*2*sigma.^2));               % gram matrix

% This is penalty matrix related to the curvature
M = calcCurvPenaltyMatrixM( X', sigma, DD );


% Hat matrix
% A = K*((K + lambda*eye(N))\eye(N));  % Original KRR Hat matrix

% curvature penalty hat matrix
A = K*((K + lambda*(K\eye(N))*M )\eye(N));  % Original KRR Hat matrix

% GCV cost
V = 1/N*(norm( (eye(N)-A)*Y' ,'fro'))^2/(1/N*sum(diag(eye(N) -A)))^2;


