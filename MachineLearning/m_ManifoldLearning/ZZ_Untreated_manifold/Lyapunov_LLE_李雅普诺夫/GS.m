%GS.m
%Function of Gram-Schmidt process
%
%Input:
%   A: nr-by-nc matrix
%Output:
%   Q: Reorthogonalized matrix with the same size of A;
%   znorm: norm of each column with size nc*1
%
%Author: Xiawei Huai
%Date: 2015/6/3
%
%As a m-by-3 matrix, we have:
%	function A = ThreeGS(V)
%	v1 = V(:,1);
%	v2 = V(:,2);
%	v3 = V(:,3);
%	a1 = v1;
%	a2 = v2-((a1'*v2)/(a1'*a1))*a1;
%	a3 = v3-((a1'*v3)/(a1'*a1))*a1-((a2'*v3)/(a2'*a2))*a2;
%	A = [a1,a2,a3];
%-----------------------

function [Q,znorm]=GS(A)

%   Construct a new orthogonal basis
[nr,nc] = size(A);
Q = zeros(size(A));
znorm = zeros(nc,1);

%   Normalize first vector
znorm(1) = norm(A(:,1),2);
Q(:,1) = A(:,1)/znorm(1); 

for j=2:nc
    %   Project a(j) on Span(q1,...,q(j-1))
    p = zeros(nr,1);
    for i=1:j-1
        p = p + A(:,j)'*Q(:,i)*Q(:,i);
    end
    znorm(j) = norm(A(:,j) - p);
    Q(:,j) = (A(:,j) - p)/znorm(j);
end

