function [xi]=kriv1(Dis,Nz,ind);
%    k=|Nz''|/(1+Nz'^2)^(3/2)

% ���������� �������� ������� ���������: ind=1 - ������������������
% ind \neq 1 - �������� ������ ��������������� ����������
if ind==1;
Ds=diff(Dis);Dn=diff(Nz);D=Dn./Ds;
DD=diff(Dn)./Ds(2:end);
%Kr=abs(DD)./(1+D(2:end).^2).^(3/2);
Kr=abs(Ds(1:end-1).*diff(Dn)-Dn(1:end-1).*diff(Ds))./(Ds(1:end-1).^2+Dn(1:end-1).^2).^(3/2);
[mm,xi]=max(Kr);if xi==1;xi=2;end;
%y=Nz(xi);x=Dis(xi);
else
%     �������� ������ ���������� �������� �� ������� ��������������� ����������
Kr=direct_kriv1(Dis,Nz,0);[mm,xi]=max(Kr);if xi==1;xi=2;end;
%Kr=direct_kriv(Dis,Nz);
%figure(100);plot(Dis(3:end),Kr,'.-');
end