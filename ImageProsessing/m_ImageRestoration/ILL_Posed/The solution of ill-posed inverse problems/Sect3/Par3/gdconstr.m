function [G,G1]=GDconstr(z,A,u,Delta,Delta_A,h,C)
% Äëÿ Demo_gen_discr
%F=norm(A*z-u)/norm(u);
Dz=diff(z);G1=[];
%G=2*(abs(z(1))+abs(z(end))+abs(Dz(1))+abs(Dz(end)))+1*norm(z)^2+norm(Dz/h)^2-C;
%G=2*((z(1))^2+(z(end))^2+(Dz(1))^2+(Dz(end))^2)+1*norm(z)^2+norm(Dz/h)^2-C;
G=[z(1)^2+z(end)^2+Dz(1)^2+Dz(end)^2-0.01;norm(z)^2+norm(Dz/h)^2-C];

