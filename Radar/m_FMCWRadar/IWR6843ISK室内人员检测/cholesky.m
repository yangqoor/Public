function [G] = cholesky(A)
%
% Lower-traingular Cholesky decomposition
% Taken from Golub and Van Loan, Page 144
%
% Muhammad Ikram; July 2, 2013
%
% Input matrix is square

n = size(A, 1);

G = zeros(n);

for j = 1:n
    v(j:n,1) = A(j:n,j);
    for k = 1:j-1
        v(j:n,1) = v(j:n,1) - G(j,k)*G(j:n,k);
    end
    
    G(j:n,j) = v(j:n,1)/sqrt(v(j,1));
end

