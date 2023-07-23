function [F,Gr]=invpot3(z,x,t,H,rho,h,U,n,m,alfa,z1)
UU=zeros(m,1);
C=ones(size(z));C(1)=0.5;C(end)=0.5;
for ii=1:m;S=0;for jj=1:n;
      %S=S+C(jj)*h*log(((x(ii)-t(jj)).^2+H^2)./((x(ii)-t(jj)).^2+(H-z(jj)).^2));
      S=S+C(jj)*h*(-1./((x(ii)-t(jj)).^2+(H-z(jj)).^2).*(-2.*H+2.*z(jj)));
   end
   UU(ii)=S*rho/2/pi;
   end
   F=(norm(UU-U)/norm(U))^2+0*z(1)^2+0*z(n)^2+alfa*(norm(z-z1)^2*(h)+norm(diff(z-z1))^2/(h));
   
   
for k=1:n;S=0;for ii=1:m;
      S=S+C(k)*h*(C(k)*h*((-1./((x(ii)-t(k)).^2+(H-z(k)).^2).*(-2.*H+2.*z(k))))-...
         U(ii)).*(1./((x(ii)-t(k)).^2+(H-z(k)).^2).^2.*(-2.*H+2.*z(k)).^2-...
         2./((x(ii)-t(k)).^2+(H-z(k)).^2));end
   if k==1;L=2*(z(1)-z1(1))-(z(2)-z1(2))+0*z(1)*h/alfa;elseif k==n;L=2*(z(n)-z1(n))...
         -(z(n-1)-z1(n-1))+0*z(n)*h/alfa;
      else L=2*(z(k)-z1(k))-(z(k-1)-z1(k-1))-(z(k+1)-z1(k+1));end
      Gr(k)=-4*S*rho/2/pi/norm(U)^2+2*alfa*(h*z(k)+L/h);
   end
   
