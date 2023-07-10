%Gram-Schmidt reorthonormalization
%
%Algorithm:
%   A = (a1,a2,...,an)
%   After GSR, we get Q = (q1,q2,...,qn)
%   1. Normalize a1 as q1
%   2. Project a(k+1) on Span(q1,q2,...,qk), pk is accquired.
%   3. Normalize a(k+1)-pk we derive q(k+1)
%   4. Loop till the end.
%
%Author: Xiawei Huai
%Date: 2015/5/31

function [Q]=GSR(A)

%   Construct a new orthogonal basis
[nr,nc] = size(A);
Q = zeros(size(A));

%   Normalize first vector
Q(:,1) = A(:,1)/norm(A(:,1),2);

for j=2:nc
    %   Project a(j) on Span(q1,...,q(j-1))
    p = zeros(nr,1);
    for i=1:j-1
        p = p + A(:,j)'*Q(:,i)*Q(:,i);
    end
    Q(:,j) = (A(:,j) - p)/norm(A(:,j) - p);
end
    