function [z,dis]=Tikh_alf11(A,u,ht,delta,alf,reg);
%C=1.16;
[m,n]=size(A);
%L=(2*diag(ones(1,n))-diag(ones(1,n-1),1)-diag(ones(1,n-1),-1))/h^2;
%L(1,1)=1/h^2;L(n,n)=L(1,1);
if isequal(reg,1);
   L1=2*diag(ones(1,n))/ht;L1(1,1)=1/ht;L1(n,n)=L1(1,1);
   L1=L1-diag(ones(1,n-1),1)/ht-diag(ones(1,n-1),-1)/ht;
   %if isequal(reg,2);L1=L1*L1+L1;end
 elseif isequal(reg,2);
   L1=2*diag(ones(1,n))/ht;L1(1,1)=1/ht;L1(n,n)=L1(1,1);
   L1=L1-diag(ones(1,n-1),1)/ht-diag(ones(1,n-1),-1)/ht;
   L1=L1'*L1+L1;
 else L1=zeros(n);end
L2=diag(ones(1,n))*ht;%L2(1,1)=0;L2(n,n)=0;
%L=L1+L2-diag(ones(1,n-1),1)/ht-diag(ones(1,n-1),-1)/ht;
L=L1+L2;

IA=inv(alf*L+A'*A);

z=IA*A'*u;dis=norm(A*z-u)/norm(u);