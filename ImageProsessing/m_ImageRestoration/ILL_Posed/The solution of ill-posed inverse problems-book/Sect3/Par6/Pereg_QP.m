%   Pereg_QP 

%  ������� ������������� ��������� 1-�� ���� �� ������ ������� c ���������� z''(s)
%  (������������ ����� ������ C_min) (�.176).

if ~exist('fmincon');disp(' ');
  disp('  ��������! ������������ �����������, �.�. �� ���� ���');
  disp('  �� ���������� ��������� ������� - Optimization Toolbox.');return;end

clear all;close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vvv=ver('MATLAB');nmver=str2num(vvv.Version);if nmver>6;
warning('off','MATLAB:dispatcher:InexactMatch');end

disp(' ');disp(' ������� ������������� ��������� ���������� 1-�� ����');
disp(' �� ������ �������, ������������ ����� ������ C_min, � c ��������� ');
disp(' �� ��������� ������ �����������. �������� -- ���.');
disp(' �������� � ������ ������������� ���������������� (�.176). ');disp(' ');
%   ������� ����������
numm=1;
new_er=0;% ������� ����� ���������� ������ ������ (new_er=1) ��� ������������ (new_er=0)? 
%   ������� ������ ������ ������
delta=0.01;% ������ ����� ���������
deltaA=0.001;% ������ ����

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ');
disp(' ');disp('   ������ ������������� ������ ������');
disp(' ');
disp(['      delta = ' num2str(100*delta) ' %      delta_A = ' num2str(100*deltaA) ' %']);
disp(' ');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ');
pause(1);


[a0,s,h,A,U0,u1,C_min,RU,RA]=mod_prob3(numm);

% U0 -- ������ ������ ����� ���������, � -- ����

%% ������� ����� ������ ��� �����������?   
if new_er==1;
   RU=randn(size(U0));RA=randn(size(A));
else if nmver>7;load err_realization_211 RU RA;
    elseif (nmver>5)&(nmver<7);load err_realization_6 RU RA;end
end;

NRA=norm(RA);NRU=norm(RU);
U=U0+delta*norm(U0)*RU/NRU;% ������������ ������ ����� ���������
AA=A+deltaA*norm(A)*RA/NRA;% ������������ ������� ������

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n=size(AA,2);T1=tril(ones(n-2));T2=T1*T1*T1;T=[ones(n,1) [0:n-1]' [zeros(2,n-2); T2]];
T(:,3)=-T(:,3);
d=zeros(n,1);d(1)=C_min;
zz1=zeros(n,1);B=[AA*T];
b=U-B*d;;
zz=[];Umon=[];Error_NNLS=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            ����� ������������� ����������������
H=B'*B;f=-B'*b;G=[];g=[];
LB=zeros(n,1);warning off;
tic;w=quadprog(H,f,G,g,[],[],LB,[],zeros(n,1));disp(' ');disp('Time Quadr_Prog:');toc
%w(end)=0;
zzz=T*(w+d);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Error_Quadr_Prog_L2 =norm(zzz-a0')/norm(a0);
Error_Quadr_Prog_C =norm(zzz-a0',inf)/norm(a0,inf);
disp(' ');disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ');disp(' ');
disp('               ������ ������� (L_2 � �)                          ');
%disp(' ');disp([' Error_NNLS =' num2str(Error_NNLS)]);
disp(' ');
disp([' Error_Quadr_Prog_L2 =' num2str(Error_Quadr_Prog_L2) ' Error_Quadr_Prog_C  =' num2str(Error_Quadr_Prog_C )]);
disp(' ');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ');disp(' ');
UV=U;UV(1)=2*U(1);UV(end)=2*U(end);
figure(2);plot(s,u1,'r.-',s,UV,'b.');set(gca,'FontName',FntNm);
legend('������ ������ �����','������������ ������ �����',1);
title([' \delta=' num2str(delta) ' \delta_A=' num2str(deltaA)])
xlabel('x');ylabel('u(x)')

figure(1);plot(s,a0,'r.-',s,zzz,'k.-');set(gca,'FontName',FntNm);
legend('������ �������','����������������� �����',1);
title(['������� �� ������ ��������� �� ������������ �������; \delta=' num2str(delta) ' \delta_A=' num2str(deltaA)])
xlabel('s');ylabel('z(s)')
