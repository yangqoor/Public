function [z,dis]=tikh_alf(A,u,h,delta,alf);
%  –егул€ризатор в W_2^1 с граничными услови€ми z'(a)=z'(b)
[m,n]=size(A);
L=(2*diag(ones(1,n))-diag(ones(1,n-1),1)-diag(ones(1,n-1),-1))/h^2;
L(1,1)=1/h^2;L(n,n)=L(1,1);
L=L+diag(ones(1,n));
z=inv(alf*L+A'*A)*A'*u;
dis=norm(A*z-u)/norm(u);