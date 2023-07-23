function [F,UU]=invpot2(z,x,t,H,rho,h,U,n,m)
UU=zeros(m,1);
C=ones(size(z));C(1)=0.5;C(end)=0.5;
for ii=1:m;S=0;for jj=1:n;
      S=S+C(jj)*h*log(((x(ii)-t(jj)).^2+H^2)./((x(ii)-t(jj)).^2+(H-z(jj)).^2));end
   UU(ii)=S*rho/2/pi;
   end
F=norm(UU-U)/norm(U);
