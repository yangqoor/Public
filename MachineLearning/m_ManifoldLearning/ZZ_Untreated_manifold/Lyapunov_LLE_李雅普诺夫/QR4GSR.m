%QR decomposition of Gram-Schmidt Reorthonormalization:
%To decompose a matrix of m-by-n size into a orthonormal matrix Q of
%size m-by-n and a upper-triangle matrix R of size n-by-n:
%   A = (a1,...,an)
%   Q = (q1,...,qn)
%       |r11 r12 ... r1n|
%   R = |0   r22 ... r2n|
%       |0   0   ... rmn|
%
%Algorithm:
%   1. Normalize first vector
%   2. Project a(k+1) on Span(q1,...,qk), in fact the project vector p has:
%      p(k) = r1k*q1+...+rkk*qk,
%      where rik=<a(k+1),qi>,i=1,...,k
%   3. Normalize vector a(k+1)-p(k) we derive q(k+1), here we have
%      Span(q1,...,q(k+1)) = Span(a1,...,a(k+1))
%   4. Loop till the end.
%
%Author: Xiaowei Huai
%Date: 2015/5/31
%
function [Q,R]=QR4GSR(A)

%   Construct new matrices
[m,n] = size(A);
Q =  zeros(m,n);
R = zeros(n,n);

%   Normalize the first vector
R(1,1)=norm(A(:,1));
Q(:,1)=A(:,1)/R(1,1);

for j=2:n
    p = zeros(m,1);
    for i=1:j-1
        R(i,j) = A(:,j)'*Q(:,i);
        p = p + R(i,j)*Q(:,i);
    end
    R(j,j) = norm(A(:,j) - p);
    Q(:,j) = (A(:,j) - p)/R(j,j);
end
        
        
        