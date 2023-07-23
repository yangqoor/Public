function [U1,U2,cs,V] = csd(Q1,Q2)
%CSD CS decomposition.
% cs = csd(Q1,Q2)
% [U1,U2,cs,V] = csd(Q1,Q2) ,  cs = [c,s]
%
% Computes the CS decomposition
%    [ Q1 ] = [ U1  0 ]*[ diag(c)     0     ]*V'
%    [ Q2 ]   [ 0  U2 ] [    0     eye(n-p) ]
%                       [ diag(s)     0     ]
% of a matrix with orthonormal columns.  The number of rows in Q1
% must be greater than or equal to the number of rows in Q2.
%    U1  is  m-by-n ,   c  is  p-by-1
%    U2  is  p-by-p ,   s  is  p-by-1
%    V   is  n-by-n .

% Reference: C. F. Van Loan, "Computing the CS and the generalized
% singular value decomposition", Numer. Math. 46 (1985), 479-491.

% Per Christian Hansen, UNI-C, 02/25/91.

% Initialization.
[m,n1] = size(Q1); [p,n] = size(Q2);
if (m<n | n<p | n1~=n)
  error('Incorrect dimensions of Q1 and Q2')
end
c = zeros(p,1); s = c; thr = .99;

% Compute SVD of Q2.
[U2,s,V] = svd(Q2); s = diag(s);
k = length(find(s <= thr)); pk = p-k;

% Compute U1.
[U1,R] = qr(Q1*V(:,n:-1:1)); U1 = U1(:,n:-1:1); R = R(1:n,:);
for i=1:n
  if (R(i,i) < 0)
    if (i > n-p+k), R(i,:) = -R(i,:); end
    U1(:,n+1-i) = -U1(:,n+1-i);
  end
end
c(p:-1:pk+1) = abs(diag(R(n-p+1:n-pk,n-p+1:n-pk)));
R = R(n:-1:n-pk+1,n:-1:n-pk+1);

% Compute c, U1 and V.
[U1t,gamma,Vt] = svd(R);
c(pk:-1:1) = diag(gamma); clear gamma;
U1(:,1:pk) = U1(:,1:pk)*U1t(:,pk:-1:1);
V(:,1:pk) = V(:,1:pk)*Vt(:,pk:-1:1);
R = Vt; for i=1:pk, R(i,:) = s(i)*R(i,pk:-1:1); end

% Compute s and U2.
U2t=zeros(size(R));
for i=1:pk,
  s(i) = norm(R(:,i));
  U2t(:,i) = R(:,i)/s(i);
end
U2(:,1:pk) = U2(:,1:pk)*U2t;

% Make sure that c and s do not exceed one.
ix = find(c>1); c(ix) = ones(length(ix),1);
ix = find(s>1); s(ix) = ones(length(ix),1);

% Return the desired quantities.
cs = [c,s];
if (nargout < 2), U1 = cs; end
