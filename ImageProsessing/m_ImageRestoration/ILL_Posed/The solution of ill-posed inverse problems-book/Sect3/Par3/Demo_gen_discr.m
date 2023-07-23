% Demo_gen_discr
%
% ���������� ����� ������� � ����� ��������� ������������� ��������� 
% ����� ��������� C: �������������� ��� ind_sel=0, ������������� ��� ind_sel~=0.
% ���������� ������� ������������ � ��������� (�.146).

if ~exist('fmincon');disp(' ');
  disp('  ��������! ������������ �����������, �.�. �� ���� ���');
  disp('  �� ���������� ��������� ������� - Optimization Toolbox.');return;end

clear all
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vvv=ver('MATLAB');nmver=str2num(vvv.Version);if nmver>6;
warning('off','MATLAB:dispatcher:InexactMatch');end

disp(' ');
disp('--------------------------------------------------------------------------');
disp(' ');
disp('���������� ����� ������� � ����� ��������� ������������� ��������� (�.146)');
disp(' ');
%   ������ ���������� ��. ����� � ����
delta=0.03;delta_A=0.001;

disp(' ');
disp(['   ������ ���������� ������: h = ' num2str(delta_A) ' delta = ' num2str(delta)]);
disp('--------------------------------------------------------------------------');

disp(' ');disp('   ������� ����� ������ ��������� ������������� C');

% ����� ���������: �������������� ��� ind_sel=0, ������������� ��� ind_sel~=0.
ind_sel=input('    (0 - ��������������, 1 - �������������): ');
disp(' ');disp('  ������� ����� ������� � ���������!');
disp('   ���������� ����� ������ ������������ ������� �����!');disp(' ');pause
disp('--------------------------------------------------------------------------');

t=linspace(-1,1,125);x=t;del=1/sqrt(3);n=length(t);h=t(2)-t(1);[XX,TT]=meshgrid(x,t);p=10;
%   ��������� �������
z=(1-t.^2).^2';

%   ������� ���� ������������� ���������

K1=h./(1+p*(XX-TT).^2);

%K1=exp(-2*(XX-TT).^2)*h;


%   ��������� ������ �����
u=K1*z;

Delta=delta*del*norm(u);Delta_A=delta_A*del*norm(K1);nerr=0;
%
if nerr==0;load er_dem_gd1 RN1 RK1;else
RN1=randn(n,1);RK1=(randn(size(K1)));end
%
ud1=u+Delta*RN1/norm(RN1);KK1=K1+Delta_A*RK1/norm(RK1);

%options=foptions;options(14)=5000;%options(1)=1;
warning off
options=optimset('MaxIter',40,'Diagnostics','off','Display','off');% 'Diagnostics','off',
%options=optimset('MaxIter',27,'Display','iter');

z0=zeros(n,1);zr=z0;
lb=zeros(size(z0));ub=2*ones(size(z0));

C=200/(0.97^3);CC1=[];NZ=[];ER=[];GD=[];DIS=[];DN=[];

Ni=8;CD=1.01;
h7=waitbar(0,'Wait a minute!');tic
for kk=1:Ni;C=C*0.97;waitbar(kk/Ni,h7);
  %zr=constr('Gen_discr',z0,options,lb,ub,[],KK1,ud1,Delta,Delta_A,h,C); 
  zr=fmincon('Reldiscr',zr,[],[],[],[],lb,ub,'GDconstr',options,KK1,ud1,Delta,Delta_A,h,C);
   Dis=norm(KK1*zr-ud1)/norm(ud1);Dn=(Delta+Delta_A*norm(zr))/norm(ud1);
gd=Dis-CD*Dn;
er=norm(zr-z)/norm(z);Nz=norm(zr)^2+norm(diff(zr)/h)^2;
CC1=[CC1 C];NZ=[NZ Nz];ER=[ER er];GD=[GD gd];DIS=[DIS Dis];DN=[DN Dn];
end
close(h7);toc

[CO,iCO]=min(ER);C1=CC1(iCO);iCD=max(find(GD<=0));

% ����� ���������: �������������� ��� ind_sel=0, ������������� ��� ind_sel~=0.
if ind_sel==0;
  if iCD==Ni;C2=CC1(iCD);elseif isempty(iCD);C2=CC1(1);
  else C2=interp1(GD(iCD:iCD+1),CC1(iCD:iCD+1),0);end;
else
figure(31);plot(CC1,GD,'.-',[CC1(1) CC1(end)],[0 0],'k');set(gca,'FontName',FntNm);
xlabel('C');legend('���������� �������',1);title('    �������� �������� � �����!')
disp(' ');disp('    �������� �������� � �����!');[C2,nnn]=ginput(1);disp(' ');
end

if isnan(C2);disp('C2=NaN');pause;end
disp('--------------------------------------------------------------------------');

h7=waitbar(0,'Final calculations. Wait a minute!');waitbar(1,h7);
options=optimset('MaxIter',50,'Diagnostics','off','Display','off');
%options=optimset('MaxIter',40,'Display','iter');
%zrop=constr('Gen_discr',z0,options,lb,ub,[],KK1,ud1,Delta,Delta_A,h,C1); 
%zrgd=constr('Gen_discr',z0,options,lb,ub,[],KK1,ud1,Delta,Delta_A,h,C2); 
zrop=fmincon('Reldiscr',z0,[],[],[],[],lb,ub,'GDconstr',options,KK1,ud1,Delta,Delta_A,h,C1);
zrgd=fmincon('Reldiscr',z0,[],[],[],[],lb,ub,'GDconstr',options,KK1,ud1,Delta,Delta_A,h,C2);


close(h7);

CC=sqrt(CC1);

disp(' ');
disp('    ����������� ����������� ������������ ������ ��������� � ��  ');
disp('    ����������� ������ ������� � ��������� ������������� ���������.');
disp(' ');disp('        ������� ����� �������!');disp(' ');pause
disp('--------------------------------------------------------------------------');


figure(31);subplot(3,1,1);plot(CC,DIS,'.-',CC,DN,'.-');
set(gca,'FontName',FntNm);
hh=title('����� ������������� ��������� - ����� ��������� C_{\eta} � ����������� ||z||\leq C_{\eta}');
set(hh,'FontSize',9);
legend('||Az^{C}-u||/||u||','(\delta+\delta_A||z^{C}||)/||u||',1)

% erC2=norm(zrgd-z)/norm(z);
erC2=interp1(CC,ER,sqrt(C2));
subplot(3,1,2);
plot(CC,GD,'.-',[CC(1) CC(end)],[0 0],'k',sqrt(C2),0,'ro');set(gca,'FontName',FntNm);
legend('���������� �������',1);

subplot(3,1,3);plot(CC,ER,'.-',CC(iCO),ER(iCO),'r*',sqrt(C2),erC2,'ro');
set(gca,'FontName',FntNm);
legend('������������� ������ �������',1);
xlabel('�������� C �� ����������� ||z||\leq C')
set(gcf,'Name','����� ��������� C � ���','NumberTitle','off')

disp(' ');
disp('   ���������� ������������ ������� � ��������� �  ');
disp('   ��������� �� �������� ������������.');
disp(' ');disp('      ������� ����� �������!');disp(' ');pause
disp('--------------------------------------------------------------------------');


figure(30);plot(t,z,'k',t,zrop,'.-',t,zrgd,'.-')
set(gca,'FontName',FntNm);xlabel('t');ylabel('z(t), z_{opt}(t), z_{gdicr}(t)');
hh=text(t(30),mean(z)/3,[' �����. ������ = ' num2str(erC2)]);set(hh,'FontName',FntNm);
legend('������ ���.','������. ���.','�����. ���.',2)
set(gcf,'Name','����� ������������� ���������','NumberTitle','off')
disp(' ');disp('%%%%%%%%%%%% ����� %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ');


