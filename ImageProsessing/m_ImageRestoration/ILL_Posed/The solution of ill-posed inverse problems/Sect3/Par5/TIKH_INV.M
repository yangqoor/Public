function [zw,disw,gamw,zl,disl,gaml]=Tikh_inv(A,u,ht,alf);
%

[m,n]=size(A);
L1=zeros(n);

   L1=2*diag(ones(1,n))/ht;L1(1,1)=1/ht;L1(n,n)=L1(1,1);
   L1=L1-diag(ones(1,n-1),1)/ht-diag(ones(1,n-1),-1)/ht;
   
L2=diag(ones(1,n))*ht;

L=L1+L2;
H=alf*L+A'*A;f=A'*u;
zw=H\f;zl=(alf*L2+A'*A)\f;
disw=norm(A*zw-u);gamw=(L*zw)'*zw;disl=norm(A*zl-u);gaml=(L*zl)'*zl;
