function [F]=reldiscr(z,A,u,Delta,Delta_A,h,C)
% Äëÿ Demo_gen_discr
F=norm(A*z-u)^2/norm(u)^2;
%Dz=diff(z);
%G=2*(abs(z(1))+abs(z(end))+abs(Dz(1))+abs(Dz(end)))+1*norm(z)^2+norm(Dz/h)^2-C;
