function [z,dis,gam,psi,ur_psi,dz]=tikh_inv(A,u,hx,ht,hdelta,delta,alf,reg);
% Для All_alfa

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
IA=inv(alf*L+A'*A);
z=IA*A'*u;v=-alf*IA*z;dis=norm(A*z-u);gam=(L*z)'*z;psi=norm(v);
w=IA*v;
%ur_psi=psi*(1+(delta*norm(u)+hdelta*norm(A))/sqrt(alf));%*sqrt(gam)
ur_psi=psi+2*(delta*norm(u)+hdelta*norm(A))^2/sqrt(alf);
%sqrt(delta*norm(u)/sqrt(alf))+sqrt(hdelta*norm(A)/alf);
% Функция для корня обобщенного квазиопт. выбора
%ur_psi=2*alf*(norm(A'*A*w)^2-alf^2*norm(w)^2)-psi*(delta*sqrt(alf)+2*hdelta*norm(u));
%
% Псевдооптимальный выбор:
LL=(2*diag(ones(1,m))-diag(ones(1,m-1),1)-diag(ones(1,m-1),-1))/hx^2;
LL(1,1)=1/hx^2;LL(m,m)=L(1,1);LL=LL+diag(ones(1,m))*hx;
AI=alf*inv(alf*LL+A*A');
dz=sqrt((AI*AI*AI*u)'*u);

%I=eye(n);z=inv(alf*I+A'*A)*A'*u;
