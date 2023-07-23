function [F,G]=Direct_nev(c,AA,U,delta,s,C)
% grad||A*c+Bg-U||^2 =>2*A'*(A*c+Bg-U)

UU=AA*c;
F=(norm(UU-U)/norm(U))^2-C*delta^2;
%G=(2*AA'*(UU-U))/norm(U)^2;
G=[];
