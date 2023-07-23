%  Inv_potenz
%      ������� �������� ������ ����������� -- ����������� ������������ ���������.
%      �������� (��� z>=0) ��� ����������� ����������� ������������ �����������
%      ����� ������ ��������� alf_opn.

if ~exist('fmincon');disp(' ');
  disp('  ��������! ������������ �����������, �.�. �� ���� ���');
  disp('  �� ���������� ��������� ������� - Optimization Toolbox.');return;end

clear all
close all

vvv=ver('MATLAB');nmver=str2num(vvv.Version);if nmver>6;
warning('off','MATLAB:dispatcher:InexactMatch');end

disp(' ');
disp(' ������� �������� ������ ����������� -- ����������� ������������ ���������.');
disp('      ����� ��������� ���������:');
disp('  1) ����� ��������� �� ��� � ������� ��������������� ��������������� �������');
disp('  2) �������� ����������� ������������ ����������� ��� ������� (z(s)>H)')

disp(' ');
disp('-----------------------------------------------------------------------------');
disp(' ');
disp('      ����������:');disp('  ����� ��������� ������������� �� ���');
graf_choi;pause(1)  % ����� �������� ������ ������ � ��������� �������� alf_opn

rho=1;H=2;% ���������
n=51;m=2*n+1;
t=linspace(-2,2,n);x=linspace(-3,3,m);h=t(2)-t(1);% �����
D=abs(t)<1;
z=zeros(size(t));z(D)=((1-t(D).^2).^2);%U=zeros(m,1);
C=ones(size(z));C(1)=0.5;C(end)=0.5;

delta=0.01;%��������������� ������ ������
z0=zeros(size(t'));D=abs(t')<1;z0(D)=(1-t(D).^2)';% ��������� �����������
z1=zeros(size(t'));Z1=z0;

warning off
disp(' ');disp(' ���������� ���������� ������������ ����������� ��� ���������� ���������.');
disp('  ����������� ����� ��� ����������! ');
disp('  ���� �� 30 ��������.');disp(' ');
options=optimset('Display','iter','MaxIter',30,'TolFun',1e-9,'TolX',1e-9,'TolCon',1e-9);%,'GradObj','on');
%'off'  'iter'  ,'MaxFunEvals',1000
Nq=1;

for k=1:Nq;tic;
%  �������� �������������
alfa=alf_opn;
%  ����� �� ������������ ����������� �����������������. ��. ��������� ������.
%[Z1,FF]=fminunc('invpot3',z0,options,x,t,H,rho,h,U1,n,m,alfa,z1);
%
[Z1]=...
   fmincon('invpot3',z0,[],[],[],[],zeros(size(z0)),[],[],options,x,t,H,rho,h,U1,n,m,alfa,z1);
[F1]=invpot(Z1,x,t,H,rho,h,U1,n,m);

ff=(F1);er=norm(Z1'-z)/norm(z);gam=norm(Z1)*sqrt(h);
gam1=(norm(Z1)*sqrt(h)+norm(diff(Z1)/sqrt(h)));

disp(' ');toc

disp('-----------------------------------------------------------------------------');
disp(' ');
disp('             ������:');disp(' ');
disp(['     delta = ' num2str(delta)]);disp(['     alfa = ' num2str(alfa)]);
disp(['     ������������� ������� ��������� �� ��������� ������� = ' num2str(ff)]);
disp(['     ����� ������������ ������� (L_2, W_2^1)  = ' num2str(gam) '  ' num2str(gam1)]);
disp(['     ������������� ������ ������������ ������� (2-�����)  = ' num2str(er)]);
disp(' ');
figure(k);subplot(2,1,2);plot(t,z,t',Z1,'r.-',x,zeros(size(x)),'k');
title('z(x), z_{\delta}(x)');
text(x(3),0.8,['\alpha = ' num2str(alfa) '  Error = ' num2str(er)]);
legend('z(x)','z_{\delta}(x)',['H=' num2str(-H)],1)
subplot(2,1,1);plot(x',U,x',U1,'r');%set(gca,'YLim',[0.03 0.04]);
text(0,0.3,['\delta = ' num2str(delta)]);
title('u(x), u_{\delta}(x)');
legend('u(x)','u_{\delta}(x)',4);
set(gcf,'Name','������ � �������','NumberTitle','off')
drawnow
end

disp(' ');
[F]=invpot(z',x,t,H,rho,h,U,n,m);
disp(['     ������������� ������� ��������� �� ������ ������� = ' num2str(F)]);
disp(' ');disp('         �����');

