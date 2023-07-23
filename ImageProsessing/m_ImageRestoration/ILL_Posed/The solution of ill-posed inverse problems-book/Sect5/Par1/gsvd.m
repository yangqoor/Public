function [U,V,sm,X] = gsvd(A,L)
%GSVD Generalized SVD of a matrix pair.
%
% sm = gsvd(A,L)
% [U,V,sm,X] = gsvd(A,L) ,  sm = [sigma,mu]
%
% Computes the generalized SVD of the matrix pair (A,L):
%    [ A ] = [ U  0 ]*[ diag(sigma)      0    ]*inv(X)
%    [ L ]   [ 0  V ] [      0       eye(n-p) ]
%                     [  diag(mu)        0    ]
% where
%    U  is  m-by-n ,    sigma  is  p-by-1
%    V  is  p-by-p ,    mu     is  p-by-1
%    X  is  n-by-n .
%
% It is assumed that m >= n >= p .

% Reference: C. F. Van Loan, "Computing the CS and the generalized
% singular value decomposition", Numer. Math. 46 (1985), 479-491.

% Per Christian Hansen, UNI-C, 06/22/93.

% Initialization.
[m,n] = size(A); [p,n1] = size(L);
if (n1 ~= n | m < n | n < p)
  error('Incorrect dimensions of A and L')
end

% Compute the GSVD in compact form via the CS decomposition.
[Q,d,X] = svd([full(A);full(L)]); Q = Q(:,1:n); d = diag(d);
if (nargout > 1)
  [U,V,sm,Z] = csd(Q(1:m,:),Q(m+1:m+p,:));
  if (nargout==4)
    for j=1:n, X(:,j) = X(:,j)/d(j); end
    X = X*Z;
  end
else
  U = csd(Q(1:m,:),Q(m+1:m+p,:));
end
