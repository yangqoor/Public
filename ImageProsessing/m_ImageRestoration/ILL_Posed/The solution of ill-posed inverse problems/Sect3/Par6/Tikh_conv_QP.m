%
% Tikh_conv_QP
%
% ������� ������������� ��������� ���������� 1 ���� �� ������
% �������� (����) �������. ����� ������������� �������� 0-�� �������.
% ����� ��������� �� ��� (�.174).
if ~exist('fmincon');disp(' ');
  disp('  ��������! ������������ �����������, �.�. �� ���� ���');
  disp('  �� ���������� ��������� ������� - Optimization Toolbox.');return;end

clear all;close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vvv=ver('MATLAB');nmver=str2num(vvv.Version);if nmver>6;
warning('off','MATLAB:dispatcher:InexactMatch');end

disp(' ');disp('    ������� ������������� ��������� ���������� 1 ���� �� ������ ');
disp('    �������� � ������������ ����� ������� � �������������� ������������ ���������.');
disp('    ������������� -- ����� � L_2. ���������� ����� ��������� �� ���.');
disp('    �������� � ������ ������������� ���������������� �� ������ K^+ (�.174).');

% �������� ��������� �����
disp(' ');
disp(' �������� ��������� �����: 1) z(s)={{1-s}^{3/2} ��� 0<s<1;0 ��� 1<s<2}');
disp('                           2) z(s)=(s-1).^2 ��� 0<s<1 ');
disp('                           3) z(s)=(s-0.5).^2 ��� 0<s<1 ');

%   ������� ����������
%
numm=input(' ������� ����� ������ (1,2,3): ');numm=round(numm);
if isempty(numm)|abs(round(numm-2))>1;
    disp('     ����� ��������. ��������� ����!');return;end
new_er=0;% ������� ����� ���������� ������ ������ (new_er=1) ��� ������������ (new_er=0)? 
%   ������� ������ ������ ������
delta=0.03;% ������ ����� ���������
deltaA=0.01;% ������ ����
disp(' ');disp(['   �������� ��������� ������ � ' num2str(numm)]);disp(' ');
disp(' ');
disp(['    ������ ������: ������ ����� - ' num2str(100*delta)  ' %; ' '������� - ' num2str(100*deltaA) ' %; ']);
disp(' ');pause(1);

[a0,s,h,A,U0,u1,C_min,RU,RA]=mod_prob2_norm(numm);

% U0 -- ������ ������ ����� ���������, � -- ����

%% ������� ����� ������ ��� �����������?   
if new_er==1;
   RU=randn(size(U0));RA=randn(size(A));
   else end;

NRA=norm(RA);NRU=norm(RU);
U=U0+delta*norm(U0)*RU/NRU;% ������������ ������ ����� ���������
AA=A+deltaA*norm(A)*RA/NRA;% ������������ ������� ������

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       
n=size(AA,2);T1=tril(ones(n-1));T=[1 zeros(1,n-1);ones(n-1,1) T1*T1];
d=zeros(n,1);d(2)=C_min*h;
zz1=zeros(n,1);B=[AA*T];b=U-B*d;
% ����� � ��������� Bv=b, v>=0

% ���������� �������� �������, �� ������� ���������� ��������:
q=0.4;NN=25;C=1.01;
%     ������� ��������������
%reg=1;% ������������� 1-�� �������
reg=0;% ������������� 0-�� �������
%reg=2;% ������������� 2-�� �������

[Alf,Opt,Dis,Nz,VV,Tf,Ur]=func_calc_QP(B,b,h,h,deltaA,delta,C,q,NN,a0',s,T,d,reg);

Del=delta*norm(U)+deltaA*norm(AA)*Nz;
% ����� ��������� �� ���������:
ix=min(find(Dis<=C*Del));if isempty(ix);ix=min(find(Dis<=1.1*C*Del));end;

[vrd,dis1]=Tikh_alf_QP(B,b,h,delta,Alf(ix),reg);zrd=T*(vrd+d);


erd=norm(zrd-a0')/norm(a0');t=s;

UV=U;UV(1)=2*U(1);UV(end)=2*U(end);
figure(2);plot(s,u1,'r.-',s,UV,'b.');set(gca,'FontName',FntNm);
legend('������ ������ �����','������������ ������ �����',1);
title([' \delta=' num2str(delta) ' \delta_A=' num2str(deltaA)])
xlabel('x');ylabel('u(x)')


figure(23);plot(t,a0','k',t,zrd,'.-');%,t,zro,'.-')
set(gca,'FontName',FntNm,'YLim',[-0.05 1.1*max(a0')]);
xlabel('s');ylabel('z(s)');
h7=legend('������ �������','�����. ������� (���)',1);
%set(h7,'Position', [0.635952 0.788984 0.35 0.201095]);
hh=text(0.1,mean(a0),['���. �����a ������������� ������� = ' num2str(erd)]);
set(hh,'FontName',FntNm);

