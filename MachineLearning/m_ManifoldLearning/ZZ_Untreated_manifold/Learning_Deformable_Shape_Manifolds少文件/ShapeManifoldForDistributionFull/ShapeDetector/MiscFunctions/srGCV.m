% Samuel Rivera
% date: aug 1, 2010
% function srGCV
% notes: This function does generalized cross validation error for KRR
%   It approximates the leave one out cost efficiently
% 
% X pxN (inputs)
% Y dxN (outputs)


function V = srGCV( X, Y, lambda, sigma )

[d N] = size(Y);

% Gram matrix
K = rbf( X', sigma ); 

% Hat matrix
A = K*((K + lambda*eye(N))\eye(N));

% GCV cost
V = 1/N*(norm( (eye(N)-A)*Y' ,'fro'))^2/(1/N*sum(diag(eye(N) -A)))^2;


