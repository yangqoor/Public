%   Err_estimate

%  ���������� ������������� ������ �������� ������������� ������� �������� ������ 
%  �� ������ ������� � ������������ ��������� - ����������� �������
%  (�.236).

if ~exist('fmincon');disp(' ');
  disp('  ��������! ������������ �����������, �.�. �� ���� ���');
  disp('  �� ���������� ��������� ������� - Optimization Toolbox.');return;end


clear all;close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% �������� �������: 1) ������������ ��������� ���������� � ����� �������� (p=100). ������� --
%                      ������� ������ W_1^1.
%                   2) ������������ ��������� ��������� (���������� u'(s)). ������� --
%                      ������� z=(1-t.^2).^2.
%                   3) ������������ ��������� ���������� � ����� �������� (p=20). ������� --
%                      (s-1).^2.

%
% ������� ������� ������� � ������ ������ �����: 
disp(' ');disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' ');
disp(' ���������� ������������� ������ �������� ������������� ������� �������� ������,');
disp(' ������� ����������� ������ ������� ������������ ��������. ������ ������ (�.236).');
disp(' ');
disp('   �������� ������������ ��������� 1 ���� �� ������ ������� V[a,b] (��.3, \S 5). ');
disp('   ����� �� �������� �� ��.4 \S8 (����������� �������) �����������  ');
disp('   ���������� �������� ����������� ������� ');disp(' ');
disp('       �������� �����. ');
disp('       1) ������������ ��������� ���������� � ����� �������� (p=100);');
disp('          ������ ������� z={sqrt(1-s)+5, 0<s<1; 5, 1<s<2};');
disp('       2) ������������ ��������� ��������� � ����� ������ �����������������;');
disp('          ������ ������� z=(1-s.^2).^2, 0<s<1');
disp('       3) ������������ ��������� ���������� � ����� �������� (p=20);');
disp('          ������ ������� z=(s-1).^2, 0<s<1;');

disp(' ');
nummer=input('          ������� ����� ������ (1,2,3): ');
if isempty(nummer)|abs((nummer-2))>1;
    disp('     ����� ��������. ��������� ����!');return;end

disp(['        ������ ' num2str(nummer)]);disp(' ')


%nummer=2; % -- ����� ������
[s,a0,hsf,A,u,N,C_min,C_max]=new_model(nummer);h=hsf;z=a0';U0=u';

% ������� �������������� ���������� ������
delta=0.01;
deltaA=0.0001;
disp(['   ������� ������ delta = ' num2str(delta) ]);disp(' ');pause(1);

sterr=1;
% sterr=1 -- ����������� ���������� ������ 

% ���������� ������ 
if sterr==1;if nummer==1;load stand_er_poinwise1;;elseif nummer==2;
    load stand_er_poinwise2;else load stand_er_poinwise3;end;
else RU=randn(size(U0));RA=randn(size(A));
  end

NRA=norm(RA);NRU=norm(RU);
U=U0+delta*norm(U0)*RU/NRU;% ������������ ������ ����� ���������

% ������������ ������� ������
if (nummer == 2);AA=A;deltaA=delta;else AA=A+deltaA*norm(A)*RA/NRA;end
%  ��� ������ ����������������� ������� �� �����������!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%          ������� �������� ������ - �� �� �� ������ ���������� �������

n=size(AA,2);
T=triu(ones(n));
zz1=zeros(n,1);B=[AA*T];b=U-C_min*AA*ones(n,1);
%
%         �������� ������������� ����������������
options=optimset('Display','off');warning off
%options=optimset('Diagnostics','off','Display','off');

H=B'*B;f=-B'*b;G=T;g=(C_max-C_min)*ones(n,1);%g=ones(n,1)/h;
LB=zeros(n,1);warning off;
tic;w=quadprog(H,f,G,g,[],[],LB,[],zeros(n,1),options);disp(' ');disp('Time of solution');toc
wap=w;%w(end)=0;
zzz=T*w+C_min;zz=zzz;
%if nummer==1;load sol_w11 ssyy;zz=ssyy';zzz=zz;end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  EE - ������������� ������ ���������� ������ ������ ����� 

Del=delta+deltaA*norm(zz)*sqrt(h);
EE=3*(U0)*Del;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%          ������� ������������� ������ �������� ������������� �������

%f=-B'*(b+EE);G=[T];g=[(C_max-C_min)*ones(n,1)];
z3=reshsm(s,zz,C_min,nummer);
cu=max([z3'; zz'])';
f=-B'*(b+EE);G=[T;-T];g=[(C_max-C_min)*ones(n,1);-cu+C_min];%g=ones(n,1)/h;
tic;[w,fw,exitflag]=quadprog(H,f,G,g,[],[],LB,[],zeros(n,1),options);disp(' ');%zeros(n,1)
disp('Time of upper error estimation:');toc
if exitflag<0;disp('    ��������� ������� quadprog �� ���� ��������� �������');
   disp('    ��������� ��������� � Err_estimate!');return;end
zzzu=T*w+C_min;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%          ������ ������������� ������ �������� ������������� �������

%f=-B'*(b-EE);G=[T];g=[(C_max-C_min)*ones(n,1)];
cl=min([z3'; zz'])';
f=-B'*(b-EE);G=[T;T];g=[(C_max-C_min)*ones(n,1);cl-C_min];
tic;w=quadprog(H,f,G,g,[],[],LB,[],zeros(n,1),options);disp(' ');
disp('Time of lower error estimation:');toc
w(end)=0;zzzl=T*w+C_min;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     ������������ �������� ������
zfmin=zzzl';zfmax=zzzu';
ZL=[zfmin(2:end) zfmin(end)];ZU=[C_max zfmax(1:end-1)];
SL=s;SU=s;
u_up=AA*zfmax';u_lw=AA*zfmin';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(1);hold on;han=plot(s,U,'r.',s,u_lw,'g',s,u_up,'b');set(gca,'FontName','Arial Cyr');
hold off
set(han,'LineWidth',2);box on
set(gca,'FontName',FntNm);
title('�������. ������ ����� � ������������� ������ ������ ������ �����')
xlabel('x');ylabel('u(x)');
legend('�������. ������ ����� u_{\delta}(x)','������ ������ ��� u(x)','������� ������ ��� u(x)',1);

figure(2);
fill([SU fliplr(SL) SU(1)],[ZU fliplr(ZL) ZU(1) ],[ 0.85 0.85 0.85 ]);
hold on;
hd=plot(s,a0,'m');plot(s,zzz,'r.-');
hold off;set(hd,'LineWidth',2);set(gca,'FontName',FntNm);
title('���������� ������������� ������ �� ������ ������� ������������ ��������')
xlabel('s');ylabel('z(s)');
vvv=ver('MATLAB');vvv1=round(str2num(vvv.Version));
if vvv1<7;
   legend('������ �������','�������. �������','������� ������',1);
else
   legend('������� ������','������ �������','�������. �������',1);
   end

disp('%%%%%%%%%%%%%%%%%%%%%%%%% ����� %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');


