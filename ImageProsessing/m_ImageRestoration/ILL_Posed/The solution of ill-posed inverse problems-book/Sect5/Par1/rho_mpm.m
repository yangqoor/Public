function [new_rho,innew_rho]=rho_mpm(lam,lamk,rho_k)
% lam=lam(h)
NZ=length(rho_k);new_rho=zeros(1,NZ);
nl=find(lamk>=lam);
  for kk=nl(1):nl(end);lk=lamk(kk);%
     if lam==0;new_rho(kk)=rho(kk);
     else c=[1 -1 0 0 -lam*rho_k(kk)^(-4)];Rt=roots(c);rt=Rt(1);
       new_rho(kk)=rt*rho_k(kk);innew_rho(kk)=1/new_rho(kk);
     end
  end




  