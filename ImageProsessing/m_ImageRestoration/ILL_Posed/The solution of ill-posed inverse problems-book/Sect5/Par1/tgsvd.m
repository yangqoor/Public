function x_k = tgsvd(U,sm,X,b,k)
%TGSVD Truncated GSVD regularization.
%
% x_k = tgsvd(U,sm,X,b,k) ,  sm = [sigma,mu]
%
% Computes the truncated GSVD solution
%            [ 0              0                 0    ]
%    x_k = X*[ 0  inv(diag(sigma(p-k+1:p)))     0    ]*U'*b .
%            [ 0              0             eye(n-p) ]
% If k is a vector, then x_k is a matrix such that
%    x_k = [ x_k(1), x_k(2), ... ] .

% Reference: P. C. Hansen, "Regularization, GSVD and truncated GSVD",
% BIT 29 (1989), 491-504.

% Per Christian Hansen, UNI-C, 11/18/91.

% Initialization.
[n,n] = size(X); p = length(sm(:,1)); lk = length(k);
if (min(k)<1 | max(k)>p)
  error('Illegal truncation parameter k')
end

% Treat each k separately.
x_k = zeros(n,lk); xi = (U(:,1:p)'*b)./sm(:,1);
x_0 = X(:,p+1:n)*U(:,p+1:n)'*b;
for j=1:lk
  i = k(j); pi1 = p-i+1;
  x_k(:,j) = X(:,pi1:p)*xi(pi1:p) + x_0;
end
