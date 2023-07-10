function [F,G]=direct_nev(c,AA,Bg,U,u_k,delta,s)
% grad||A*c+Bg-U||^2 =>2*A'*(A*c+Bg-U)
UU=AA*c+Bg;
F=(norm(UU-U)/norm(U))^2-4*delta^2;
%G=(2*AA'*(UU-U))/norm(U)^2;
G=[];
