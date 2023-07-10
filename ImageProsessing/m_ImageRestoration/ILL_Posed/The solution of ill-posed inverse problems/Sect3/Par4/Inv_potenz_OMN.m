%  Inv_potenz_OMN
%      ������� �������� ������ ����������� � ������� ���
%      ����������� ������� ����������� ������������ ��������� ��� ������������ ||z||<C
%      ��� ����� �������� � (�.158).

if ~exist('fmincon');disp(' ');
  disp('  ��������! ������������ �����������, �.�. �� ���� ���');
  disp('  �� ���������� ��������� ������� - Optimization Toolbox.');return;end

clear all
close all

vvv=ver('MATLAB');nmver=str2num(vvv.Version);if nmver>6;
warning('off','MATLAB:dispatcher:InexactMatch');end


disp(' ');
disp(' ������� �������� ������ ����������� � ������� ��� � ����� ')
disp(' ������ ������������� ����� (�.158).')
disp(' ');
disp('-----------------------------------------------------------------------------');
disp(' ');
disp('  1. ������� ��������������� ����� ��� ��������� �: ����������� ������� ��� ');
disp('     ����������� ||z||<C � � �������� ����������������� �������.');

rho=1;H=2;% ���������
n=51;m=2*n+1;
t=linspace(-2,2,n);x=linspace(-3,3,m);h=t(2)-t(1);% �����
D=abs(t)<1;
z=zeros(size(t));z(D)=((1-t(D).^2).^2);U=zeros(m,1);
C=ones(size(z));C(1)=0.5;C(end)=0.5;
% ������ ������ ����� ���������
for ii=1:m;S=0;for jj=1:n;
     S=S+C(jj)*h*(-1./((x(ii)-t(jj)).^2+(H-z(jj)).^2).*(-2.*H+2.*z(jj)));
  end
   U(ii)=S*rho/2/pi;
   end
delta=0.01;%dd=[0 0.001 0.01];% ��������������� ������ ������
z0=zeros(size(t'));D=abs(t')<1;z0(D)=(1-t(D).^2)';% ��������� �����������
z1=zeros(size(t'));%z0=z1;
disp(' ');disp(['     delta = ' num2str(delta)]);disp(' ');
RN=randn(size(U));
U1=U+delta*norm(U)*RN/norm(RN);

% ������� ��������� ��� ������ delta
warning off
disp(' ');disp('  ����������� ��������� ����� ��� ����������! ');
disp('     ���� �� 40 ��������.');disp(' ');
disp(' ');disp('  ������� ����� ������� � ���������!');pause
disp(' ');
disp('-----------------------------------------------------------------------------');

options=optimset('Display','iter','MaxIter',40,'TolFun',1e-9,'TolX',1e-9,'TolCon',1e-7);
%
Nev=[];ErrL=[];gamL=[];gamW=[];Alf=[];qq=1.8;Nq=5;LB=zeros(size(z0));ZZZ=[];

for k=1:Nq;
tic;
C=qq^(k-2)
alfa=C;
Alf=[Alf alfa];% ����� Alf -- ����� �������� �������
%[Z1,FF]=fminunc('invpot3',z0,options,x,t,H,rho,h,U1,n,m,alfa,z1);
% ����������� �����������
[Z1]=...
 fmincon('invpotomn',z0,[],[],[],[],LB,[],'OMN_con',options,x,t,H,rho,h,U1,n,m,alfa,z1);
[F1]=invpot(Z1,x,t,H,rho,h,U1,n,m);ZZZ=[ZZZ Z1];

ff=(F1);er=norm(Z1'-z)/norm(z);gam=norm(Z1)*sqrt(h);
gam1=(norm(Z1)*sqrt(h)+norm(diff(Z1)/sqrt(h)));
Nev=[Nev ff];ErrL=[ErrL er];gamL=[gamL gam];gamW=[gamW gam1];

disp(' ');toc
disp('-----------------------------------------------------------------------------');
disp(' ');
disp(['               ���������� ����������� ��� C = ' num2str(alfa)]);
disp(' ');
disp(['     ������������� ������� ��������� �� ��������� ������� = ' num2str(ff)]);
disp(['     ����� ������������ ������� (L_2, W_2^1)  = ' num2str(gam) '  ' num2str(gam1)]);
disp(['     ������������� ������ ������������ ������� (2-�����)  = ' num2str(er)]);
disp(' ');
disp('-----------------------------------------------------------------------------');

figure(k);subplot(2,1,2);plot(t,z,t',Z1,'r',x,zeros(size(x)),'k');xlabel('s')
ylabel ('z(x), z_{\delta}(x)');
text(-0.1,0.4,['C = ' num2str(alfa) '    Error = ' num2str(er)]);
legend('z(x)','z_{\delta}(x)',['H=' num2str(-H)],1)
subplot(2,1,1);plot(x',U,x',U1,'r');%set(gca,'YLim',[0.03 0.04]);
text(0,0.034,['\delta = ' num2str(delta)]);
title('u(x), u_{\delta}(x)');
legend('u(x)','u_{\delta}(x)',4);
set(gcf,'Name',['u(x) � ��� ��� �=' num2str(alfa)])
drawnow
end

disp(' ');
disp('-----------------------------------------------------------------------------');
disp(' ');

omn_constr_final
subplot(2,1,2);plot(t,z,t',ZZZ(:,3),'r*',x,zeros(size(x)),'k');xlabel('s')
ylabel ('z(x), z_{\delta}(x)');

disp(['               ���������� �������: ��������� C = ' num2str(Alf(3))]);
disp(['     ������������� ������� ��������� �� ��������� ������� = ' num2str(Nev(3))]);
disp(['     ����� ������������ ������� (L_2, W_2^1)  = ' num2str(gamL(3)) '  ' num2str(gamW(3))]);
disp(['     ������������� ������ ������������ ������� (2-�����)  = ' num2str(ErrL(3))]);
disp(' ');
set(gcf,'Name','����� ��������� � ��� � �������','NumberTitle','off')

disp('          �����');