% Teplo_istoch

% ������� �������� �������� ������ ���������� ��������� ��������� f(x)
% ��� ������������� ��������� ���������������� (�.282)

% -div(grad(u(x,y)))=f(x)g(y), -1<x<1,0<y<0.8;
%  u(x,y)=0 �� ������� � ������ �������; du/dn=0 �� ����� � ������ �������
%  u(x,y=0.08)=U(x) - ��������������� 

% �������� �������: 'pryamg' . �������� ��������� �������: 'prya'
% �������� ���������: 'istok1'

% �������� ������� ������ ������ -- ������������ ����� ������������ f(x) 
% � ����� �������� ��������� ��� u(x,y).
% �������� ������� �������� ������ -- ����� ������������� � W_2^1 � ������������� 
% ������� ��������� �� ��� ��� ������ ���������.


clear all
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global xx yy XX YY a

%
N=41;M=51;

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' ');disp(' ������� �������� �������� ������ ���������� ��������� ��������� f(x)');
disp(' ��� ������������� ��������� ���������������� (�.282):');
disp('   -div(grad(u(x,y)))=f(x)g(y), -1<x<1,0<y<0.8;');
disp('     ��� ��������:');
disp('    u(x,y)=0 �� ������� � ������ �������; du/dn=0 �� ����� � ������ �������');
disp('    � ���������������  u(x,y=0.08)=U(x). ');
disp(' ');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    ������
pred=0;% ��������� ��������������� ���������� (�� - 1, ��� - 0)
MNK=0; % �� ��������� ������ ����������� � ���
derv=0; % ��������� ������� ������ �� ������ � ������������� ������� ����������� (1)
lcurve=1; % �������� �������� ������������� �� L-������ (1) ��� ��� (0).
noopt=0;
% �������, ��� �������� ������
xx=linspace(-1,1,N);yy=linspace(-0.8,0,M);
[XX,YY]=meshgrid(xx,yy);
x0=[-0.2 0.3 1 2 1 3];NN=6;% ������ ������ ��� ������

% ��������� ��������� ��������� f(x)=a0 � ������� g(y)=G
z=x0(3)*exp(-x0(5)*(xx-x0(1)).^2)+x0(4)*exp(-x0(6)*(xx-x0(2)).^2);z=z';
a0=x0(3)*exp(-x0(5)*(XX-x0(1)).^2)+x0(4)*exp(-x0(6)*(XX-x0(2)).^2);
G=exp(-6*(YY+0.3).^2);f0=a0.*G;
a=a0;

if exist('initmesh');
  domain_isto;else disp(' ');pred=0;
  disp('    ��������! PDF toolbox �� ���������� �� ���� ����������. ');
  disp('        ������� ��������� ������� ������������ ����� �������!');
  disp(' ������� ����� �������!');  
pause
disp(' ');end
if ~exist('fminunc');disp(' ');
  disp('  ��������! ');
  disp('  �� ���� ���������� �� ���������� ��������� ������� - Optimization Toolbox.');
  disp('        ������� ��������� ������ ������������ ����������!');
    disp(' ������� ����� �������!');noopt=1;  
pause
disp(' ');
  end
  
if noopt==1;MNK=0;derv=0;end;
  
disp(' ');
disp('-----------------------------------------------------------------------------');
disp(' ');

% ����� � ������������ �������
u_k=[];
for k=1:N;ab=zeros(1,N);
   ab(k)=1; 
   u_k=[u_k ab'];
end

% ������� �� �������� ������� � ������������ ���������������
if pred==1;
disp('  ��������������� ����������.');disp(' ');
disp(' ������� ����� �������!');
pause
disp('-----------------------------------------------------------------------------');

U0=dir_istoch(NN);% ���������� ��������������� � ��������� ������

A=[];u_k=[];gg=0;ind=0;

h4=waitbar(0,' Wait!');tic;
for k=1:N;ab=zeros(1,N);
   waitbar(k/N,h4);
   ab(k)=1; 
   u_k=[u_k ab'];%���������� ������ 
   a=repmat(ab,M,1);
   A_uk=dir_istoch(NN)';A=[A A_uk];
end
toc;close(h4);
else load istoch_data A U0;end

delta=0.0005;% ��������� ������ ���������������

RU=randn(size(U0));NRU=norm(RU);
U=U0+delta*RU/NRU;
deltaA=0.0001;% ������ ������������� �� ���
RA=randn(size(A));NRA=norm(RA);
AA=A+deltaA*RA/NRA;
disp(' ');disp('    ������ ���������� ������ � L_2:');
disp(['    ������ �������: ' num2str(100*deltaA) ' %']);
disp(['    ������ ������ �����: ' num2str(100*delta) ' %']);
disp(' ');
disp('-----------------------------------------------------------------------------');
disp(' ');disp('  �������� � �������������� �������� ������');disp(' ');
disp('   ����� �������� ������ � ������ ����������������, ������� ������� �������,');
disp('   � ����� ����� �������� ������ � ������������ ����������������,');
disp('   ��������� �������������� �������.');disp(' ');
disp(' ������� ����� ������� � ���������!');
pause
disp('-----------------------------------------------------------------------------');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    ������� ����� ��������� ������� -- ������������������ �������
%c=AA\(U');% ����������� ����������
c0=A\(U0');
c=pinv(AA)*(U');
% ���������� ������� �������� ������
u_sol=u_k*c;u_0=u_k*c0;
UU=AA*c;UU0=A*c0;
Residual_exact=norm(U0'-UU0)/norm(U0);
Residual_appr=norm(U'-UU)/norm(U0);

disp(['  �����. ������� ��������� �� ������ ������� (L_2) = ' num2str(Residual_exact)]);
disp(['  �����. ������� ��������� �� ������������ ������� (L_2) = ' num2str(Residual_appr)]);

figure(111);subplot(1,2,1);plot(xx,a0(1,:),'r',xx,u_0,'.');
set(gca,'YLim',[0 3],'FontName',FntNm)
title('P������ - ��������� ���������');xlabel('x');
legend('������','�������.',2);
subplot(1,2,2);plot(xx,U0,'r',xx,UU0,'.');set(gca,'FontName',FntNm,'FontSize',9)
title(['��������������� - ����������� ��� y=' num2str(yy(NN)+0.8)]);xlabel('x');
legend('������','�������.',2);
set(gcf,'Name','������� � ������� ������� (���������)','NumberTitle','off')
pause(1)
if exist('initmesh');
a=repmat(u_0',M,1);
[p,e,t]=initmesh('pryamg');[p,e,t]=refinemesh('pryamg',p,e,t);
[p,e,t]=refinemesh('pryamg',p,e,t);[p,e,t]=refinemesh('pryamg',p,e,t);
u=assempde('prya',p,e,t,1,0,'istok1');% ��. �������, ��-��� �������, ��������
figure(113);pdeplot(p,e,t,'xydata',u);hold on;
plot(xx,yy(NN)*ones(size(xx)),'r');hold off;set(gca,'FontName',FntNm,'FontSize',9)
set(gca,'YTickLabel',char(num2str([0:0.1:0.8]')))
title('����������� ��� ���������� ��������� (�� ������� ������� ������ ���������������)');
xlabel('x');ylabel('y');
set(gcf,'Name','����������� (�� ������� � ������� �������)','NumberTitle','off')
end
pause(1)

figure(11);subplot(1,2,1);plot(xx,a0(1,:),'r',xx,u_sol,'.-');
set(gca,'FontName',FntNm)
title('P������ - ��������� ���������');xlabel('x');
legend('������','�������.',2);
subplot(1,2,2);plot(xx,U0,'r',xx,UU,'.-');set(gca,'FontName',FntNm,'FontSize',9)
title(['��������������� - ����������� ��� y=' num2str(yy(NN)+0.8)]);xlabel('x');
legend('������','�������.',2);
set(gcf,'Name','������� � ������������� ������� (���������)','NumberTitle','off')
pause(1)

if exist('initmesh');
a=repmat(u_sol',M,1);
[p,e,t]=initmesh('pryamg');[p,e,t]=refinemesh('pryamg',p,e,t);
[p,e,t]=refinemesh('pryamg',p,e,t);[p,e,t]=refinemesh('pryamg',p,e,t);
u=assempde('prya',p,e,t,1,0,'istok1');% ��. �������, ��-��� �������, ��������
figure(13);pdeplot(p,e,t,'xydata',u);hold on;
plot(xx,yy(NN)*ones(size(xx)),'r');hold off;set(gca,'FontName',FntNm)
set(gca,'YTickLabel',char(num2str([0:0.1:0.8]')))
title('����������� ��� ���������� ���������');xlabel('x');ylabel('y');
set(gcf,'Name','����������� (�� �����������. �������)','NumberTitle','off')
end
pause(1)

if MNK~=0;
   disp(' ');
   disp('-----------------------------------------------------------------------------');
disp(' ');disp('  ������ ��������������� ������� �������� ������ ����������� � ���.');
disp(' ');
disp('  ������� ������� ���������� ��������� � ������ ������������');disp(' ');
disp(' ������� ����� ������� � ���������!');
pause
disp('-----------------------------------------------------------------------------');

% ���-������� 
options=optimset('Display','off','MaxIter',400,'GradObj','on',...
   'LineSearchType','quadcubic','TolFun',1e-12,'TolCon',1e-12,'MaxFunEvals',4000000,...
   'TolX',1e-12);% 'iter'
z0=0.5*ones(size(c));
tic 
 [cm,nev_min]=fminunc('direct_coeff',z0,options,AA,U,u_k);
toc
u_in=u_k*cm;UUU=AA*cm;
disp(['   ������� ��������� (L_2) =' num2str(nev_min)]);

figure(12);subplot(1,2,1);plot(xx,a0(1,:),'r',xx,u_in,'.-');
set(gca,'FontName',FntNm)
title('P������ - ��������� ���������');xlabel('x');
legend('������','�������.',2);
subplot(1,2,2);plot(xx,U0,'r',xx,UUU,'.-');set(gca,'FontName',FntNm,'FontSize',9)
title(['��������������� - ����������� ��� y=' num2str(yy(NN)+0.8)]);xlabel('x');
legend('������','�������.',2);
set(gcf,'Name','���-������� � �����. ������� (���������)','NumberTitle','off')
pause(1)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if derv~=0;
% ������� �� ������ ������� c ���������� ������� �����������
disp(' ');
disp('-----------------------------------------------------------------------------');
disp(' ');disp('  ������� �� ������ ������� � ���������� ������� �����������');disp(' ');
disp(' ������� ����� ������� � ���������!');
pause
disp('-----------------------------------------------------------------------------');

options=optimset('Display','off','MaxIter',80,'GradObj','on',...
   'LineSearchType','quadcubic','TolFun',1e-12,'TolCon',1e-12,'MaxFunEvals',4000000,...
   'TolX',1e-12);% 'iter'  'off'
z0=0*ones(size(c));
LB=zeros(size(z0));UB=3*ones(size(z0));warning off
tic 
[cm1,nev_min]=fmincon('direct_coeff',z0,[],[],[],[],LB,UB,'conv1',options,AA,U,u_k);
options=optimset('Display','off','MaxIter',75,'GradObj','on',...
   'LineSearchType','quadcubic','TolFun',1e-12,'TolCon',1e-12,'MaxFunEvals',4000000,...
   'TolX',1e-12);% 'iter'  'off'
 [cm1,nev_min]=fmincon('direct_coeff',cm1,[],[],[],[],LB,UB,'conv1',options,AA,U,u_k);
 [cm1,nev_min]=fmincon('direct_coeff',cm1,[],[],[],[],LB,UB,'conv1',options,AA,U,u_k);
 %[cm1,nev_min]=fmincon('Direct_coeff',cm1,[],[],[],[],LB,UB,'Conv1',options,AA,U,u_k);
toc

u_in1=u_k*cm1;UUU1=AA*cm1;
disp(['   ������� ���������  (L_2) =' num2str(nev_min)]);

figure(14);subplot(1,2,1);plot(xx,a0(1,:),'r',xx,u_in1,'.-');
set(gca,'FontName',FntNm)
title('P������ - ��������� ���������');xlabel('x');
legend('������','�������.',2);
subplot(1,2,2);plot(xx,U0,'r',xx,UUU1,'.-');set(gca,'FontName',FntNm,'FontSize',9)
title(['��������������� - ����������� ��� y=' num2str(yy(NN)+0.8)]);xlabel('x');
legend('������','�������.',2);
set(gcf,'Name','������� �� ������������ ������ ','NumberTitle','off')
pause(1)

if exist('initmesh');
a=repmat(u_in1',M,1);
[p,e,t]=initmesh('pryamg');[p,e,t]=refinemesh('pryamg',p,e,t);
[p,e,t]=refinemesh('pryamg',p,e,t);[p,e,t]=refinemesh('pryamg',p,e,t);
u=assempde('prya',p,e,t,1,0,'istok1');% ��. �������, ��-��� �������, ��������
figure(15);pdeplot(p,e,t,'xydata',u);hold on;
plot(xx,yy(NN)*ones(size(xx)),'r');hold off;set(gca,'FontName',FntNm)
set(gca,'YTickLabel',char(num2str([0:0.1:0.8]')))
title('����������� ��� ���������� ���������');xlabel('x');ylabel('y');
set(gcf,'Name','����������� (�� ������� �� ������������ ������)','NumberTitle','off')
end
pause(1)
end

disp(' ');
disp('-----------------------------------------------------------------------------');
disp(' ');disp('  ����������� ������������� �������� ������ � W_2^1.');disp(' ');
disp(' ������� ����� �������!');
pause

tikh_istochn

disp(' ');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ����� %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ');
disp(' ');