function [z,dis,gam]=Tikh_QP(A,u,hx,hdelta,delta,alf,T,C_min,ind);
%
n=size(A,2);
if ind>0;load init z0;else z0=zeros(n,1);end
H=A'*A;f=-A'*u+alf/2;%G=T;g=ones(n,1)/h;
LB=zeros(n,1);warning off;%tic;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  X=QUADPROG(H,f,A,b,Aeq,beq,LB,UB,X0,OPTIONS)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%G=-[T -T];g=-C_min*ones(n/2,1);% Возможные ограничения на решение
options=optimset('Display','off','Diagnostics','off','MaxIter',500);%off
z=quadprog(H,f,[],[],[],[],LB,[],z0,options);z(end)=0;%zeros(n,1)
z0=z;save init z0;
%%%%%%%%%%%%%%%%%%%% Вспомогательные функции %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dis=norm(A*z-u);gam=sum(abs(z));