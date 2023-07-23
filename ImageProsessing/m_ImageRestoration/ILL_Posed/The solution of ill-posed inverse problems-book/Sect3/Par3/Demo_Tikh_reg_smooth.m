%  Demo_Tikh_reg_smooth
%
% ������������ ������ ������ ������� ������������� ��������� ������� 
% ���-��� �������� � ������� ��������� �� ����������� �������� ������������� �����������
% ������������ �������� ��� ����� ������������ ���������.

clear all
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vvv=ver('MATLAB');nmver=str2num(vvv.Version);if nmver>6;
warning('off','MATLAB:dispatcher:InexactMatch');end
%   ������, ���������� �������������

disp(' ');
disp(' ����� ������������� � ������� ��������� �� ����������� ');
disp('   �������� ������������� ����������� (�.137 - 138).');disp(' ');
disp('   ������� ����� �������!');disp(' ');pause
disp('-------------------------------------------------------------------');


% ������� ������ ������
disp(' ');Nom=input('  ������� ����� ��������������� ������ (1 - 4): ');disp(' ');

problem=['nr' num2str(Nom)];
p=10;del=1;

switch problem
   case 'nr1'
%  ������ 1    ����������������� (��������� ��������� � ����� K(x,t)=1)
t=linspace(0,1,125);
z=((t.*(1-t.^2)).^2)';x=t;n=length(t);h=t(2)-t(1);K1=tril(ones(n));k1=ones(n);% z=(t.^2)';
[XX,TT]=meshgrid(x,t);K0=tril(ones(n));tt=t;del=1/sqrt(3);k1=ones(n);CC=1.1;
case 'nr2'
%  ��������� ���������   
t=linspace(0,1,125);x=t;z=(t.*(1-t.^2))';[XX,TT]=meshgrid(x,t);h=t(2)-t(1);  
K0=tril(((XX-TT)).^2*exp(-(XX-TT).^2))*h;tt=linspace(0,2,125);k1=(tt.^2).*exp(-tt.^2);CC=1;
case 'nr3'
%  ��������� ����������  
t=linspace(-1,1,125);x=t;z=(1-t.^2).^2';[XX,TT]=meshgrid(x,t);h=t(2)-t(1);
K0=h./(1+p*(XX-TT).^2);tt=linspace(-2,2,125);k1=1./(1+tt.^2);CC=1;
case 'nr4'
%  ��������� ����������    
t=linspace(-1,1,125);x=t;z=(1-t.^2).^2';[XX,TT]=meshgrid(x,t);h=t(2)-t(1);
K0=exp(-(XX-TT).^2)*h;del=1/sqrt(3);tt=linspace(-2,2,125);k1=exp(-tt.^2);CC=1/sqrt(3);;

otherwise
   disp(' ');
  disp('����������� ���������. �������� ����� ������ (1 - 4)!');disp(' ');return
   end
disp(' ');
disp(['   �������� ������ � ' num2str(Nom)]);disp(' ');
disp('-------------------------------------------------------------------');
pause(1);

n=length(t);hh=sqrt(h);

u0=K0*z;u=u0/norm(K0);K1=K0/norm(K0);

delta=0.03;deltaA=0.001;% ������� ���������� ������
RN1=randn(n,1);ud1=u+delta*del*norm(u)*RN1/norm(RN1);
RK1=(randn(size(K1)));ud1=u+delta*del*RN1/norm(RN1);
if ismember(Nom,[1 2]);RK1=tril(RK1)-diag(diag(RK1));end

KK1=K1+deltaA*del*norm(K1)*RK1/norm(RK1);

disp(' ');disp('    ������ ������');
figure(20);subplot(2,2,1);plot(t,z,'.-');set(gca,'FontName',FntNm);
title('������ �������');
subplot(2,2,2);if Nom==1;mesh(t,t,K1);else plot(tt,k1,'.-');end
set(gca,'FontName',FntNm);
title('����');subplot(2,2,3);plot(t,u,'.-');set(gca,'FontName',FntNm);
title('������ �����');
set(gcf,'Name','������ ������ ������','NumberTitle','off')


disp(['   ������� ������������� ������ ������: delta=' num2str(delta) ]);
disp(' ');disp('    ����� ����������� ������ � ������������ u(x).');disp(' ');
figure(21);plot(t,u0,'r',t,ud1*norm(K0),'.b');title(' ');xlabel('x');
set(gca,'FontName',FntNm);
set(gcf,'Name','������ ������','NumberTitle','off')
legend(' ������ ������ �����',' ������������ ������ �����');

disp('-------------------------------------------------------------------');
disp(' ');disp('������������ ����������� ������������� � ������� ');
disp('��������� �� �������� ������������� �����������');
disp('   ������� ����� �������!');disp(' ');pause
disp('-------------------------------------------------------------------');


C=1.1;% �������� ���������
[zro,diso,alf]=tikh_reg_smooth(KK1,ud1,h,delta*CC,C);
ero=norm(zro-z)/norm(z);
figure(200);plot(t,z,'k',t,zro,'.-')
set(gca,'FontName',FntNm);xlabel('t');ylabel('z(t), z^{\alpha}(t)');
title('����� ��������� �� �������� ������������� �����������');
legend('������ ���.',['\alpha_{���. ����.}=' num2str(alf)],2)
hh=text(t(40),mean(z)/3,'���. �����a');set(hh,'FontName',FntNm);
text(t(80),mean(z)/3,num2str(ero));
hh=text(t(40),mean(z)/4,'���. �������');set(hh,'FontName',FntNm);
text(t(80),mean(z)/4,num2str(diso));
set(gcf,'Name','����������� �������������','NumberTitle','off')
disp('%%%%%%%%%%%%%%% ����� %%%%%%%%%%%%%%%%%%%%');

