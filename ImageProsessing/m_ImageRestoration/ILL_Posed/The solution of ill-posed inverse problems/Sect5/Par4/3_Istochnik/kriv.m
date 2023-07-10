function [xi]=kriv(Dis,Nz);
%    k=|Nz''|/(1+Nz'^2)^(3/2)
Ds=diff(Dis);Dn=diff(Nz);D=Dn./Ds;
DD=diff(Dn)./Ds(2:end);
%Kr=abs(DD)./(1+D(2:end).^2).^(3/2);
Kr=abs(Ds(1:end-1).*diff(Dn)-Dn(1:end-1).*diff(Ds))./(Ds(1:end-1).^2+Dn(1:end-1).^2).^(3/2);
[mm,xi]=max(Kr);if xi==1;Kr=abs(DD(2:end))./(1+D(3:end).^2).^(3/2);
[mm,xi]=max(Kr);xi=xi+1;end;
%y=Nz(xi);x=Dis(xi);
%     ¬озможно пр€мое вычисление кривизны по радиусу соприкасающейс€ окружности
%Kr=direct_kriv(Dis,Nz);end;
%figure(100);plot(Dis(3:end),Kr,'.-');pause
