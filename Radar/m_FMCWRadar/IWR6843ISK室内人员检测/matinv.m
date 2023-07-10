function [Ainv] = matinv(A)
%
% Matrix inverse of a 4x4 matrix using Cholesky decomposition
%
% Muhammad Ikram; July 3, 2013
%

n = size(A, 1);

Ac = cholesky(A);

% A = Ac * Ac'
% Ainv = Acinv' * Acinv

Acinv = zeros(n);
if n==3
    Acinv(1,1) = 1/Ac(1,1);
    Acinv(2,2) = 1/Ac(2,2);
    Acinv(3,3) = 1/Ac(3,3);
    
    Acinv(2,1) = -Ac(2,1)*Acinv(1,1)*Acinv(2,2);
    Acinv(3,2) = -Ac(3,2)*Acinv(2,2)*Acinv(3,3);

    Acinv(3,1) = (Ac(2,1)*Ac(3,2)-Ac(2,2)*Ac(3,1))*Acinv(1,1)*Acinv(2,2)*Acinv(3,3);

elseif n==4
    Acinv(1,1) = 1/Ac(1,1);
    Acinv(2,2) = 1/Ac(2,2);
    Acinv(3,3) = 1/Ac(3,3);
    Acinv(4,4) = 1/Ac(4,4);
    
    Acinv(2,1) = -Ac(2,1)*Acinv(1,1)/Ac(2,2);
    
    Acinv(3,1) = (-Ac(3,1)*Acinv(1,1) - Ac(3,2)*Acinv(2,1))/Ac(3,3);
    Acinv(3,2) = -Ac(3,2)*Acinv(2,2)/Ac(3,3);
    
    Acinv(4,1) = (-Ac(4,1)*Acinv(1,1) - Ac(4,2)*Acinv(2,1) - Ac(4,3)*Acinv(3,1))/Ac(4,4);
    Acinv(4,2) = (-Ac(4,2)*Acinv(2,2) - Ac(4,3)*Acinv(3,2))/Ac(4,4);
    Acinv(4,3) = -Ac(4,3)*Acinv(3,3)/Ac(4,4);
end
Ainv = Acinv' * Acinv;
