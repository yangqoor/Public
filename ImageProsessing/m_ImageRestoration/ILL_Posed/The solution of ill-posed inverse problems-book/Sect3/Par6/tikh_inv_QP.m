function [z,dis,gam,psi,ur_psi]=Tikh_inv_QP(A,u,hx,ht,hdelta,delta,alf,reg);
%

[m,n]=size(A);
%L=(2*diag(ones(1,n))-diag(ones(1,n-1),1)-diag(ones(1,n-1),-1))/h^2;
%L(1,1)=1/h^2;L(n,n)=L(1,1);
if isequal(reg,1);
   L1=2*diag(ones(1,n))/ht;L1(1,1)=1/ht;L1(n,n)=L1(1,1);
   L1=L1-diag(ones(1,n-1),1)/ht-diag(ones(1,n-1),-1)/ht;
   if isequal(reg,2);L1=L1*L1+L1;end
else L1=zeros(n);end
L2=diag(ones(1,n))*ht;%L2(1,1)=0;L2(n,n)=0;
%L=L1+L2-diag(ones(1,n-1),1)/ht-diag(ones(1,n-1),-1)/ht;
L=L1+L2;
H=alf*L+A'*A;f=-A'*u;%G=T;g=ones(n,1)/h;
LB=zeros(n,1);warning off;
%tic;
options=optimset('Display','off','Diagnostics','off');
z=quadprog(H,f,[],[],[],[],LB,[],zeros(n,1),options);%disp(' ');disp('Time Quadr_Prog:');
%toc
IA=inv(H);
v=-alf*IA*z;dis=norm(A*z-u);gam=(L*z)'*z;psi=norm(v);
w=IA*v;
ur_psi=psi*(1+(delta*norm(u)+hdelta*norm(A))/sqrt(alf));%*sqrt(gam)
