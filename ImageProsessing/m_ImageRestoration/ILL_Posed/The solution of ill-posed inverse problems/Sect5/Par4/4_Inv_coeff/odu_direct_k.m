function [FF,GG]=odu_direct_k(ku,n,x,A,B,uu,F,tt,U0,alf,re)

T0=10;%alf=9e-3;% 1e-3
u0=(x.*(1-x))';[T,U]=ode23('odu_ku',T0,u0,[],n,A,B,uu,ku,F,tt);
UU=interp1(T,U(:,[2 5 9]),tt);
%u=uu(uu<=max(max(UU)));kkk=ku(uu<=max(max(UU)));
kkk=ku(uu<=max(max(U)));
FF=(norm(UU-U0)/norm(U0))^2+alf*(norm(kkk)+norm(diff(kkk)));GG=[];

