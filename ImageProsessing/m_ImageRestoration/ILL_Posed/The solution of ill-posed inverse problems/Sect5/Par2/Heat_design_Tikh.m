%  Heat_design_Tikh

%  ������� ����������� ������������� ��������� �������������� �����������
%  ��� gam=1/2 - ��� ������� ������� �� 1000 K^o
clear all
close all

if ~exist('fmincon');disp(' ');
  disp('  ��������! ������������ �����������, �.�. �� ���� ���');
  disp('  �� ���������� ��������� ������� - Optimization Toolbox.');return;end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

gam=1/2;C=2.5;
disp(' ');disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ');disp(' ');
disp('  ������� ����������� ������������� ��������� �������������� ');
disp(['  ����������� � gamma= ' num2str(gam) ' ������� ������������� ']);
disp('  �.�.�������� � ���������� ����������� �������������  (��.5, \S2, �.2).');
disp('  ������������� ����� ��������� �� ������ ����������� ����� ��������')
disp('  ������������ ��������� � �������������� ������������ �������� �������.')

disp(' ');disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ');
disp(' ');
disp('---------------------------------------------------------------------------------');
disp(' ');disp('   1. �������� ��������� ���������� ������� "����������� - �������" ');
          disp('         ������� ����� �������!');pause
heat_desgn;
%open Heat_design.fig;
set(gcf,'Name','��������� �������','NumberTitle','off');pause(3)
set(gcf,'Visible','off');
disp(' ');
disp('---------------------------------------------------------------------------------');
disp(' ');
disp(' 2. ������� ���������� alpha � ������ �������������. ');
disp('        ������� ����� �������!');pause
disp(' ');
disp('---------------------------------------------------------------------------------');
disp(' ');
%set(gcf,'Visible','on');pause(1)

[T_ep,lam_ep,ep,ep1,Tsig,esig,B]=inp_data;

N=8;M=3;
% ������� �� ������ ����� - "������ ����������"
x=linspace(0,1,2*N);y=x;h=x(2)-x(1);[X,Y]=meshgrid(x,y);


% �������� ������ ������
K=0.5*h*gam^2./((X-Y).^2+gam^2).^(3/2);
fi=(1./2.*(-(x.^2+gam.^2).^(1./2).*x+(x.^2+gam.^2).^(1./2)+...
   x.*(x.^2-2.*x+gam.^2+1).^(1./2))./(x.^2-2.*x+gam.^2+1).^(1./2)./(x.^2+gam.^2).^(1./2))';

% ������� ��� ����������� �� ���������� �������. ������ ����������� �� �����������.

options=optimset('Display','off','MaxIter',50,'GradObj','off','LargeScale','off',...
   'LineSearchType','quadcubic','TolFun',1e-12,'TolCon',1e-12,'MaxFunEvals',4000000,...
   'TolX',1e-12);% 'iter'  'off'
T0=ones(N,1);alf=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vvv=ver('MATLAB');nmver=str2num(vvv.Version);if nmver>6;
warning('off','MATLAB:dispatcher:InexactMatch');
else warning off;end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ALF=[];DIS=[];OMEGA=[];
for kk=1:8;alf=alf*0.1;
[T,nev_min]=fminunc('tikh_heatdesgn',T0,options,K,B,fi,Tsig,esig,T_ep,alf);
[F]=nev_hd(T,K,B,fi,Tsig,esig,T_ep);
F0=norm(F-1)/norm(ones(2*length(T),1));
disp(['  alpha=' num2str(alf)]);disp(' ');
disp(['  ������� = ' num2str(F0)]);
[Om,gom]=omega_hd(T,K,B,fi,Tsig,esig,T_ep,C);
disp(' ');disp(['  ���������� OMEGA = ' num2str(Om+C)]);

ALF=[ALF alf];DIS=[DIS F0];OMEGA=[OMEGA Om];
figure(3);subplot(2,1,1);stairs(x-h/2,[T;flipud(T)]);
hold on;plot([x(end)-h/2 x(end)],[T(1) T(1)],'b');hold off
set(gca,'FontName',FntNm,'YLim',[0 3],'XLim',[0 1]);ylabel('T^oK/1000');
text(0.5,2.5,['\gamma=' num2str(gam) '    \alpha=' num2str(alf)]);
title('������� - ����������� ���');

subplot(2,1,2);plot(x,F,'.-',x,[T0;T0],'r');set(gca,'FontName',FntNm,'YLim',[0 1.1]);
ylabel('T^oK/1000');
title('����������� �� ����������� �������');legend('�����������','���������',4);
set(gcf,'Name','����������� ������������� ������','NumberTitle','off')
disp(' ');
disp('---------------------------------------------------------------------------------');
disp(' ');
disp('   ��� ���������� ���������� ������� ����� ������� � ���������!');
disp(' ');pause;
end

figure(4);subplot(2,2,1);plot(log10(ALF),DIS,'.-');
set(gca,'FontName',FntNm);L1=get(gca,'YLim');
title('������� ���������');xlabel('log_{10}\alpha');
subplot(2,2,3);plot(log10(ALF),OMEGA+C,'.-');
set(gca,'FontName',FntNm);L2=get(gca,'YLim');
title('\Omega[T]');xlabel('log_{10}\alpha');
set(gcf,'Name','������� � OMEGA ��� ������� �� alpha','NumberTitle','off')
disp(' ');
disp('---------------------------------------------------------------------------------');
disp(' ');
disp('     �������� �������� alpha ����� �� ��������!');
disp(' ');pause;
[alf1,nbv]=ginput(1);alf=10^(alf1);

figure(4);subplot(2,2,1);plot(log10(ALF),DIS,'.-',[alf1 alf1],L1,'r');
set(gca,'FontName',FntNm);
title('������� ���������');xlabel('log_{10}\alpha');
subplot(2,2,3);plot(log10(ALF),OMEGA+C,'.-',[alf1 alf1],L2,'r');
set(gca,'FontName',FntNm);
title('\Omega[T]');xlabel('log_{10}\alpha');
set(gcf,'Name','������� � OMEGA ��� ������� �� alpha','NumberTitle','off')

[T,nev_min]=fminunc('tikh_heatdesgn',T0,options,K,B,fi,Tsig,esig,T_ep,alf);
[F]=nev_hd(T,K,B,fi,Tsig,esig,T_ep);
F0=norm(F-1)/norm(ones(2*length(T),1));
disp(['  alpha=' num2str(alf)]);disp(' ');
disp(['  ������� = ' num2str(F0)]);
[Om,gom]=omega_hd(T,K,B,fi,Tsig,esig,T_ep,C);
disp(' ');disp(['  ���������� OMEGA = ' num2str(Om+C)]);

figure(33);subplot(2,1,1);stairs(x-h/2,[T;flipud(T)]);
hold on;plot([x(end)-h/2 x(end)],[T(1) T(1)],'b');hold off
set(gca,'FontName',FntNm,'YLim',[0 3],'XLim',[0 1]);ylabel('T^oK/1000');
text(0.5,2.5,['\gamma=' num2str(gam) '    \alpha=' num2str(alf)]);
title('������� - ����������� ���');

subplot(2,1,2);plot(x,F,'.-',x,[T0;T0],'r');set(gca,'FontName',FntNm,'YLim',[0 1.1]);
ylabel('T^oK/1000');
title('����������� �� ����������� �������');legend('�����������','���������',4);
set(gcf,'Name','��������� ��� ���������� alpha','NumberTitle','off')
disp('---------------------------------------------------------------------------------');
disp(' ');
disp(' ');disp('%%%%%%%%%%%%%%%%%%%%% ����� %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ');
disp(' ');
