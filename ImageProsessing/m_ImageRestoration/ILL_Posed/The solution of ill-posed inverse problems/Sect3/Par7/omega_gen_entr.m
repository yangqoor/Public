function [Om,Dom]=Omega_gen_entr(c,AA,U,delta,s);
%ep=1e-8;
zz=c;hs=diff(s');
Dzx=diff(zz)./hs;
r0=sum(DFF(zz).*log(DFF(zz)).*[hs(1);hs]);
r1=sum(DFF(Dzx).*log(1+DFF(Dzx)).*hs);r2=DFF(zz(1)-12)+DFF(zz(end)-5);%+DFF(Dzx(end));
%r2=sqrt(sum((zz.^2).*[hs(1);hs]));
Om=r0+r1+r2;Dom=[];
