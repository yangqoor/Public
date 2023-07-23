% Num_integr
clear
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    ��������� �������������� (u(x)=int_{0}^{x}z(t)dt ) �� ������� ��������

disp('��������� �������������� ��� ��������� ������������ ������ (�.28).');
disp('  ���������� ������������� ��������� (1.2) �� ������� ��������. ');
t=[0:0.001:1];n=length(t);h=0.001;y=t.^2/2; % ������ ������ 
% 
z_ex=t(2:end);
%
A=h*tril(ones(n-1));B=A-0.5*diag(diag(A));%B(2:end,1)=0.5*A(2:end,1);
y_ex=B*z_ex';dd=[0.01 0.05 0.1];err(1)=norm(y(2:end)-y_ex',inf)/norm(y,inf);
figure(11);plot(t(2:end),y(2:end),t(2:20:end),y_ex(1:20:end-1),'.r');hold on
for k=1:3;delta=dd(k);if k==1;st='g';elseif k==2;st='m';else st='k';end
  RZ=randn(size(t(2:end)));z_dist=z_ex+delta*norm(z_ex)*RZ/norm(RZ);
  y_dist=B*z_dist';err(k+1)=norm(y(2:end)-y_dist',inf)/norm(y,inf);
  figure(11);plot(t(2:20:end),y_dist(1:20:end-1),st)
end
  set(gca,'FontName',FntNm);
  title(' ������ � ������������ ������� ������ ������');xlabel('x');
  ylabel('u(x)=\int_{0}^{x}z(t)dt')
  legend(' ������ �������',' ����������� ��� \delta = 0',' ����������� ��� \delta = 0.01',' ����������� ��� \delta = 0.05',' ����������� ��� \delta = 0.1',2)
  hold off;
  disp(' ')
  disp('  ������������� ������ ���������� ��������� � ����������� �� delta')
  disp(num2str(['    delta' '     Error ']));disp([[0 dd]' err']);
 