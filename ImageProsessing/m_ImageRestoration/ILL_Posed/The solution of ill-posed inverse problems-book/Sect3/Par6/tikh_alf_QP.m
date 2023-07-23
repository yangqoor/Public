function [z,dis]=Tikh_alf_QP(A,u,ht,delta,alf,reg);
%C=1.16;
[m,n]=size(A);
if isequal(reg,1);
   L1=2*diag(ones(1,n))/ht;L1(1,1)=1/ht;L1(n,n)=L1(1,1);
   L1=L1-diag(ones(1,n-1),1)/ht-diag(ones(1,n-1),-1)/ht;
else L1=zeros(n);end
L2=diag(ones(1,n))*ht;%L2(1,1)=0;L2(n,n)=0;
%L=L1+L2-diag(ones(1,n-1),1)/ht-diag(ones(1,n-1),-1)/ht;
L=L1+L2;

H=alf*L+A'*A;f=-A'*u;%G=T;g=ones(n,1)/h;
LB=zeros(n,1);warning off;
%tic;
options=optimset('Display','off','Diagnostics','off');
z=quadprog(H,f,[],[],[],[],LB,[],zeros(n,1),options);%disp(' ');disp('Time Quadr_Prog:');
dis=norm(A*z-u)/norm(u);