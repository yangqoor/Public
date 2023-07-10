function [z,dis,v]=tikh_alf(A,u,h,u_k,d2u_k,alf);
%
[m,n]=size(A);
L=(2*diag(ones(1,n))-diag(ones(1,n-1),1)-diag(ones(1,n-1),-1))/h^2;
L(1,1)=0.95/h^2;L(n,n)=1/h^2;
L(1,1)=1/h^2;L(n,n)=L(1,1);
L=L+diag(ones(1,n));
%B=inv(alf*(eye(n)+L)+A'*A);
%z=B*A'*u;vv=B*(-alf*(eye(n)+L)*z);
z=(alf*(eye(n)+L)+A'*A)\A'*u;vv=(alf*(eye(n)+L)+A'*A)\(-alf*(eye(n)+L)*z);
v=norm(vv)/norm(u);
dis=norm(A*z-u)/norm(u);