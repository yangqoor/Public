function [z,dis,v]=Tikh_alf5(A,u,L,alf);
%C=1.16;
%[m,n]=size(A);
%L=(2*diag(ones(1,n))-diag(ones(1,n-1),1)-diag(ones(1,n-1),-1))/h^2;
%L(1,1)=2/h^2;L(n,n)=L(1,1);
IA=inv(alf*L+A'*A);
z=IA*A'*u;%v=norm(-alf*IA*z);
%I=eye(n);z=inv(alf*I+A'*A)*A'*u;
dis=norm(A*z-u);v=z'*L*z;