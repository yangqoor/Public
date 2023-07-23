function [z,dis]=Tikh_alf(A,u,h,delta,alf);
global zadan
%C=1.16;
[m,n]=size(A);
L=(2*diag(ones(1,n))-diag(ones(1,n-1),1)-diag(ones(1,n-1),-1))/h^2;
L(1,1)=1/h^2;L(n,n)=L(1,1);

if zadan==2;L=L*L;end

z=inv(alf*L+A'*A)*A'*u;
%I=eye(n);z=inv(alf*I+A'*A)*A'*u;
dis=norm(A*z-u)/norm(u);