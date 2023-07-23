function [F,G]=Direct_coeff(c,A,U,u_k)
% grad||A*c+Bg-U||^2 =>2*A'*(A*c+Bg-U)
UU=A*c;
F=(norm(UU-U')/norm(U))^2;
G=(2*A'*(UU-U'))/norm(U)^2;

