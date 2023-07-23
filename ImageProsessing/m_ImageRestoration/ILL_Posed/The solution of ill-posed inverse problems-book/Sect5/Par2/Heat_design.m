% Heat_design

% ������� ���������� �������� ������ �������������� ����������� ��� 
% ��������������� �����

clear all
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('fmincon');disp(' ');
  disp('  ��������! ������������ �����������, �.�. �� ���� ���');
  disp('  �� ���������� ��������� ������� - Optimization Toolbox.');return;end

% ���� ������

[T_ep,lam_ep,ep,ep1,Tsig,esig,B]=inp_data;

N=8;% ������� �� ������ ����� - "������ ����������" �� 2*N ��� 
M=3;% ��� ��������� ��������

x=linspace(0,1,2*N);y=x;h=x(2)-x(1);[X,Y]=meshgrid(x,y);

disp(' ');disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ');disp(' ');
disp(' ������� ���������� �������� ������ �������������� ����������� ��� ');
disp(' ��������������� ����� (��.5, \S2, �.2).');

disp(' ');disp('   �������� ��������� ���������� ������� "����������� - �������" ');
disp(' ������� ����� �������!');pause
%open Heat_design.fig;
heat_desgn;
set(gcf,'Name','��������� �������','NumberTitle','off');pause(3)
set(gcf,'Visible','off');

disp(' ');
disp(' ������� �������� �����. ������� ����� �������!');pause
%set(gcf,'Visible','on');pause(1)

for kgam=1:2;if kgam==1;gam=1;C=2.5;% � -- ����. ���������� �������, ���������� ������������
   else gam=1/2;C=1.5;end
   
disp(' ');
disp('---------------------------------------------------------------------------------');
disp(' ');
disp(['%%%%% ������� �������� ������ �������������� ����������� � gamma = ' num2str(gam) ...
      ' %%%%%%']);disp(' ')
disp('   ����� ����� ������������� ����������� �� �����������, ����� �� �������')
disp('   ����������� ����������� 1000 K^o ')
disp('   (��� ����������� ����������� ����������� 100 K^o < T < 3000 K^o)');disp(' ');
disp('%%%%% ������ 1. ������� ��� ����������� �� ���������� ������� %%%%%% ');
disp(' ');disp(' ������� ����� ������� � ���������!');pause

% �������� ������ ������
K=0.5*h*gam^2./((X-Y).^2+gam^2).^(3/2);
fi=(1./2.*(-(x.^2+gam.^2).^(1./2).*x+(x.^2+gam.^2).^(1./2)+...
   x.*(x.^2-2.*x+gam.^2+1).^(1./2))./(x.^2-2.*x+gam.^2+1).^(1./2)./(x.^2+gam.^2).^(1./2))';

% ������� ��� ����������� �� ���������� �������. ������ ����������� �� �����������.

options=optimset('Display','off','MaxIter',150,'GradObj','off','LargeScale','off',...
   'LineSearchType','quadcubic','TolFun',1e-12,'TolCon',1e-12,'MaxFunEvals',4000000,...
   'TolX',1e-12);% 'iter'  'off'
T0=ones(N,1);
LB=0.1*zeros(size(T0));UB=3*ones(size(T0));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vvv=ver('MATLAB');nmver=str2num(vvv.Version);if nmver>6;
warning('off','MATLAB:dispatcher:InexactMatch');
else warning off;end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic 
[T,nev_min]=fmincon('direct_hd',T0,[],[],[],[],LB,UB,[],options,K,B,fi,Tsig,esig,T_ep,C);
toc

disp(' ');disp(['  �������1=' num2str(nev_min)]);
[Om,gom]=omega_hd(T,K,B,fi,Tsig,esig,T_ep,C);
disp(' ');disp(['  ���������� OMEGA = ' num2str(Om+C)]);

figure(3+M*(kgam-1));subplot(2,1,1);stairs(x-h/2,[T;flipud(T)]);
hold on;plot([x(end)-h/2 x(end)],[T(1) T(1)],'b');hold off
set(gca,'FontName',FntNm,'YLim',[0 3],'XLim',[0 1]);ylabel('T^oK/1000');
text(0.5,2.5,['\gamma=' num2str(gam)]);title('������� - ����������� ���');

[F]=nev_hd(T,K,B,fi,Tsig,esig,T_ep);
subplot(2,1,2);plot(x,F,'.-',x,[T0;T0],'r');set(gca,'FontName',FntNm,'YLim',[0 1.1]);
ylabel('T^oK/1000');
title('����������� �� ����������� �������');legend('�����������','���������',4);
set(gcf,'Name','��� ����������� �� ���������� �������','NumberTitle','off')

% ������� � ������������ �� ���������� ������� (OMEGA <= 1.5) � ������������� �� �����������.

disp(' ');
disp(['%%%%% ������ 2. ������� � ������������ �� ���������� �������: Omega < ' num2str(C) ' %%%%%% ']);
disp(' ');disp(' ������� ����� ������� � ���������!');pause


options=optimset('Display','off','MaxIter',70,'GradObj','off','LargeScale','off',...
   'LineSearchType','quadcubic','TolFun',1e-12,'TolCon',1e-12,'MaxFunEvals',4000000,...
   'TolX',1e-12);% 'iter'  'off'
%if nmver>6;options=optimset('LargeScale','off');end 

tic 
[T1,nev_min]=...
   fmincon('direct_hd',T0,[],[],[],[],LB,UB,'omega_hd',options,K,B,fi,Tsig,esig,T_ep,C);
toc

disp(' ');disp(['  �������2=' num2str(nev_min)]);
[Om,gom]=omega_hd(T1,K,B,fi,Tsig,esig,T_ep,C);
disp(' ');disp(['  ���������� OMEGA = ' num2str(Om+C)]);

figure(4+M*(kgam-1));subplot(2,1,1);subplot(2,1,1);stairs(x-h/2,[T1;flipud(T1)]);
hold on;plot([x(end)-h/2 x(end)],[T1(1) T1(1)],'b');hold off;ylabel('T^oK/1000');
%plot(x,T1,'.-');
set(gca,'FontName',FntNm,'YLim',[0 3],'XLim',[0 1]);
text(0.5,2.5,['\gamma=' num2str(gam)]);title('������� - ����������� ���');

[F]=nev_hd(T1,K,B,fi,Tsig,esig,T_ep);
subplot(2,1,2);plot(x,F,'.-',x,[T0;T0],'r');set(gca,'FontName',FntNm,'YLim',[0 1.1]);
ylabel('T^oK/1000');
title('����������� �� ����������� �������');legend('�����������','���������',4);
set(gcf,'Name','� ������������ �� ���������� �������','NumberTitle','off')

% ����������� ���������� ������� ��� ������������ �� �����������.

disp(' ');
disp('%%%%% ������ 3. ����������� ���������� �������: Omega - min %%%%%% ');
disp(' ');disp(' ������� ����� ������� � ���������!');pause

options=optimset('Display','off','MaxIter',120,'GradObj','off','LargeScale','off',...
   'LineSearchType','quadcubic','TolFun',1e-12,'TolCon',1e-12,'MaxFunEvals',4000000,...
   'TolX',1e-12);% 'iter'  'off'
%if nmver>6;options=optimset('LargeScale','off');end

tic 
[T2,nev_min]=...
   fmincon('omega_hd',T0,[],[],[],[],LB,UB,'constr_hd',options,K,B,fi,Tsig,esig,T_ep,C);
toc

disp(' ');disp(['  ���������� OMEGA = ' num2str(nev_min+1.5)]);
[F]=nev_hd(T2,K,B,fi,Tsig,esig,T_ep);
Dis=norm(F-1)/norm(ones(2*length(T),1));
disp(' ');disp(['  �������3=' num2str(Dis)]);disp(' ');

figure(5+M*(kgam-1));subplot(2,1,1);subplot(2,1,1);stairs(x-h/2,[T2;flipud(T2)]);
hold on;plot([x(end)-h/2 x(end)],[T2(1) T2(1)],'b');hold off;ylabel('T^oK/1000');
set(gca,'FontName',FntNm,'YLim',[0 3],'XLim',[0 1]);
text(0.5,2.5,['\gamma=' num2str(gam)]);title('������� - ����������� ���');

subplot(2,1,2);plot(x,F,'.-',x,[T0;T0],'r');set(gca,'FontName',FntNm,'YLim',[0 1.1]);
ylabel('T^oK/1000');
title('����������� �� ����������� �������');legend('�����������','���������',4);
set(gcf,'Name','����������� ���������� �������','NumberTitle','off')
end
disp(' ');
disp('---------------------------------------------------------------------------------');
disp(' ');disp('%%%%%% �����. ����������� �������� ������� � �������. %%%%%% ');disp(' ');
