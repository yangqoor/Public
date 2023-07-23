function [x,y]=kriv4(Dis,Nz);
%k=|Nz''|/(1+Nz'^2)^(3/2)

Ds=diff(Dis);Dn=diff(Nz);D=Dn./Ds;
DD=diff(Dn)./Ds(2:end);
%Kr=abs(DD)./(1+D(2:end).^2).^(3/2);
Kr=abs(Ds(1:end-1).*diff(Dn)-Dn(1:end-1).*diff(Ds))./(Ds(1:end-1).^2+Dn(1:end-1).^2).^(3/2);
[mm,x]=max(Kr);if x==1;[mm,x]=max(Kr(3:end));end
y=Nz(x+2);x=x+2;
%figure(100);plot(Dis(3:end),Kr,'.-');
%save tst_kriv Dis Nz 