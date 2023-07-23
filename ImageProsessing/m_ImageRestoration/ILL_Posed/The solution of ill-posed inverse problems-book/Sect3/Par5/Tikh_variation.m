
%   Tikh_variation

%  ���������� ������������ ��������� � ������� ��������� �� ��� ��� �������-�����������
%  ������������� �������� ����� � ���������� ��������� (�.163)

if ~exist('fmincon');disp(' ');
  disp('  ��������! ������������ �����������, �.�. �� ���� ���');
  disp('  �� ���������� ��������� ������� - Optimization Toolbox.');return;end

clear all;close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vvv=ver('MATLAB');nmver=str2num(vvv.Version);if nmver>6;
warning('off','MATLAB:dispatcher:InexactMatch');end

disp(' ');
disp(' ���������� ������������ ��������� � ������� ��������� �� ���');
disp(' ��� �������-����������� ������������� �������� ����� � ���������� ');
disp(' ��������� (�.163)');disp(' ');

disp('-----------------------------------------------------------------------------');
disp(' ');
disp('   �������� ��������� ���������� 1 ���� � ����� ��������.');disp(' ');
disp(' ');disp('    ��������� ������ (�������): 1) z(s)=1+sgn(s); 2) z(s)=sgn(s)(1-|s|)');
          disp('                                3) z(s)=sgn(s)(s^2-1); 4) z(s)=sgn(s-0.5)-2sgn(s+0.5)');
disp(' ');
disp('-----------------------------------------------------------------------------');
disp(' ');
%   ������� ���������� � ������
numm=input(' ������� ����� ������! ');
disp('-----------------------------------------------------------------------------');
disp(' ');
if isempty(numm);numm=1;disp(['  �������� �� ��������� ������ ' num2str(numm)]);
else disp(['  �������� ������ ' num2str(numm)]);end
%
new_er=0;% ������� ����� ���������� ������ ������ (new_er=1) ��� ������������ (new_er=0)? 
%   ������� ������ ������ ������
delta=0.01;% ������ ����� ���������
deltaA=0.0001;% ������ ����

[a0,s,h,A,U0,u1,C_min,RU,RA]=mod_prob_norm(numm);

%% ������� ����� ������ ��� �����������?   
if new_er==1;
   RU=randn(size(U0));RA=randn(size(A));
   else end;
NRA=norm(RA);NRU=norm(RU);
U=U0+delta*norm(U0)*RU/NRU;% ������������ ������ ����� ���������
AA=A+deltaA*norm(A)*RA/NRA;% ������������ ������� ������
disp(' ');
disp(['   ������ ���������� ������: h = ' num2str(deltaA) ' delta = ' num2str(delta)])
disp(' ');
% AT(a-b)=u;  v=[a;b];  Omega=sum(a_i+b_i) z=T*(a-b)=T*(v(1:n)-v(n+1:2*n));
n=length(s);T=tril(ones(n));
m=2*n;B=[AA*T -AA*T];b=U;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         ������� ������
%      ����� �������������   
% ���������� �������� �������, �� ������� ���������� ��������:
q=0.1;NN=10;C=1.01;d=[];
disp(' ');disp(' ���������� ��������������� �������');disp(' ');pause(1)
disp('-----------------------------------------------------------------------------');
disp(' ');

[Alf,Opt,Dis,Nz]=func_QP(B,b,h,deltaA,delta,C,q,NN,a0',s,T,C_min);

Del=delta*norm(U)+deltaA*norm(AA)*Nz;
% ����� ��������� �� ��������� ���������:
ix=min(find(Dis<C*Del));pri=0;
[zm,iz]=min(Opt);
if isempty(ix);ix=iz;pri=1;end

%graf_alf_select(Alf,Dis,Del,ix,delta,pri);

[vrd,dis1]=Tikh_QP(B,b,h,deltaA,delta,Alf(ix),T,C_min,1);

zrd=T*(vrd(1:n)-vrd(n+1:2*n));Ucalc=AA*zrd;
figure(1);plot(s,U,'.',s,Ucalc,'r');
set(gca,'FontName',FntNm);title(' ������')
legend('������������','������',1)
figure(2);plot(s,zrd,'.-',s,a0','r');
set(gca,'FontName',FntNm);title(' �������')
legend('������������','������',1)

Errr=norm(zrd-a0')/norm(a0');
disp(['    ������������� ������ ������� (L_2) = ' num2str(Errr)]);
disp(' ');
disp('        �����');