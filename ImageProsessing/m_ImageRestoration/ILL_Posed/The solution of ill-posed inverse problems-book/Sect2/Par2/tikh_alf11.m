function [z,dis]=tikh_alf11(A,u,ht,delta,alf,reg);
% Äëÿ All_alfa
%
[m,n]=size(A);
if isequal(reg,1);
   L1=2*diag(ones(1,n))/ht;L1(1,1)=1/ht;L1(n,n)=L1(1,1);
   L1=L1-diag(ones(1,n-1),1)/ht-diag(ones(1,n-1),-1)/ht;
else L1=zeros(n);end
L2=diag(ones(1,n))*ht;%L2(1,1)=0;L2(n,n)=0;
%L=L1+L2-diag(ones(1,n-1),1)/ht-diag(ones(1,n-1),-1)/ht;
L=L1+L2;

%L1=2*diag(ones(1,n))/ht;L1(1,1)=1/ht;L1(n,n)=L1(1,1);
%L=L1+diag(ones(1,n))*ht-diag(ones(1,n-1),1)/ht-diag(ones(1,n-1),-1)/ht;
IA=inv(alf*L+A'*A);

z=IA*A'*u;dis=norm(A*z-u)/norm(u);