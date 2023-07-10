function [beta,ind]=bet_mpm(lam,lamk,rho_k)
NZ=length(rho_k);xsi=zeros(1,NZ);
nl=find(lamk==lam);
if isempty(nl);% lambda \neq  lambda_k
  for kk=1:NZ;lk=lamk(kk);
    if lam==0;rt=1;
    else c=[1 -1 0 0 -lam*rho_k(kk)^(-4)];Rt=roots(c);rt=Rt(1);
    end
    if lam <= lk;xsi(kk)=((rt-1)*rho_k(kk))^2;else xsi(kk)=rho_k(kk)^2;end
  end
  beta=sum(xsi);ind=0;
else           % lambda = lambda_k
  for kk=1:NZ;lk=lamk(kk);xsi1=0;
    if ~isequal(kk,nl);
     if lam==0;rt=1;
     else c=[1 -1 0 0 -lam*rho_k(kk)^(-4)];Rt=roots(c);rt=Rt(1);
     end
     if lam <= lk;xsi(kk)=((rt-1)*rho_k(kk))^2;else xsi(kk)=rho_k(kk)^2;end
    else
    xsi(nl)=rho_k(nl)^2/4;xsi1=rho_k(nl)^2;
    end
  beta0=sum(xsi);beta1=beta0-xsi(nl)+xsi1;beta=[beta0 beta1];ind=1;
  end
end



  