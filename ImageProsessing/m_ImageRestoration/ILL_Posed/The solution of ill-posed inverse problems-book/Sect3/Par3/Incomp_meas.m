
%  Incomp_meas

%  ���������� ���� �������������� ������������� ��������� ���������� 1 ����
%  ���������� �������� (�.130 - 132).
% 
% 
%  ��������� ������ --  ������ ���� ��� ��������� ������� = �������� ������ �������
%
% u"_xx+u"_yy=0,   u(x,0)=u(x,pi)=0, u'_y(x,pi/2)=0,  0<x<1
% u(0,y)=0, u'_x(0,y)=u_n(y),  0<y<pi
%
% ������ g(y)=pi*u_n(y)/2 . ����� z(y)=u(H,y) ��� H, 0<H<1
%
% ������������� ������������ ��-��� 1-�� ����:
% g(y)=int_0^pi{G(y,y1,H)z(y1)dy1},  (0<y<pi)
% � �����
% G(y,y1,H)=sum_{n=1}^{\inf}n sin(ny)sin(n y1)[sh(nH)]^(-1)
%

clear all;close all;


disp(' ');
disp(' ���������� ������ ���� �������������� ������������� ��������� ���������� 1 ����');
disp('            � ���������� � ������������ ������ ������� �������� (�.130 - 132)');

%      ������� ������ ������
delta=0.01;hdelta=0.01;
disp(' ');
disp(['   ����������� ������: ' 'delta = ' num2str(delta) '; h = ' num2str(hdelta)]);


n=60;x=1*[0:0.05:1];
y=[0:0.05:pi];h=y(2)-y(1);
[Y,Y1]=meshgrid(y,y);
n_end=50;nn=[2:2:n_end];[YY,YY1,NN]=ndgrid(y,y,nn);
SS=NN.*sin(NN.*YY).*sin(NN.*YY1);

% ���� ������������� ��������� -- ����� ������ �� ������ ������. ��������
H=x(11);SSH=SS./sinh(NN.*H);GG=2*sum(SSH,3)/pi;

%   ���������� ������ �����, ��� ������� ��������� �� ��������� -- ���������� �� ����
%   ������. ��������
nnn=[1:n_end];[Y,N]=meshgrid(y,nnn);SU=sin(N.*Y)./N./sinh(N.*H);
UU=sum(SU,1)';

%   ���������� ������ �����, ��� ������� ��������� ��������� -- ����� ������ �� ������ 
%   ������. ��������
nn2=[2:2:n_end];[Y,N]=meshgrid(y,nn2);SU2=sin(N.*Y)./N./sinh(N.*H);
UU2=sum(SU2,1)';

%   ������ ���� ��������������
mu_exact=norm(UU2-UU);
%  ������ ��������� �������
zex=exacsol(GG,UU2);

% ���������� ������

RN1=randn(size(UU));RK1=(randn(size(GG)));
load stand_err0
u=UU+delta*norm(UU)*RN1/norm(RN1);
u2=UU2+delta*norm(UU2)*RN1/norm(RN1);
G=GG+hdelta*norm(GG)*RK1/norm(RK1);

%    ���������� ��������������� ������� ��������� ��� 
tt=cputime;
Dis=[];Alf=[];Ga=[];Dis0=[];Ga0=[];
%          ������������ ��������� ���, ����� ||A||=1
Dis1=[];Ga1=[];C=1;
alf0=1e4;q=0.5;nr=32;
for kk=1:nr;alf=alf0*q^kk;Alf=[Alf alf];
%          ��� ���������� ������:   
[z,dis,gam]=tikh_re(G,u2,alf);Dis=[Dis dis];Ga=[Ga gam];
%          ��� ������������ ������:
[z,dis,gam]=tikh_re(G,u,alf);Dis0=[Dis0 dis];Ga0=[Ga0 gam];
end
ttt=cputime-tt;
disp(' ');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' ');disp('           ���������� ������ -- ���� �������������� mu0=0');
disp(' ������ ���� �������������� �� ������ ������������� - ��������� �����');
mu0=Dis(end);
disp(['   mu0_apri = ',num2str(mu0) '; �����. ������ = ' num2str(mu0/norm(u2))])
disp(' ������ ���� �������������� �� ������ ������������� - ������������� �����');
ksi=Dis+hdelta*Ga;mu01=min(ksi)+delta*norm(u2);
disp(['   mu0_ap�st = ',num2str(mu01) '; �����. ������ = ' num2str(mu01/norm(u2))])
%disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' ');

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' ');
disp('             ������������ ������ -- ���������� ���� �������������� ');
disp('             ��� ������ ���� �������������� ');
disp(' ������ ���� �������������� ������������ ������');
disp(['   mu_exact = ',num2str(mu_exact)])
disp(' ������ ���������� ���� �������������� �� ������ ������������� - ��������� �����');

%          ��� ������������ ������:
%    ������ ���������� ���� �������������� �� ������ ������������� (��������� �����)
Blf=Alf-(delta*norm(u)+hdelta*norm(GG)).^2;ni=min(find(Blf<=0));
mu=Dis0(ni)+delta*norm(u)+hdelta*norm(GG)*Ga0(ni);
%if isempty(ni);mu=min(Dis0+delta*norm(u)+hdelta*norm(GG)*Ga0);end
disp(['   mu_apri = ' num2str(mu) '; �����. ������ = ' num2str(abs(mu_exact-mu)/mu_exact)])
% 
%    ������ ���� �������������� (������������� �����)
disp(' ������ ���������� ���� �������������� �� ������ ������������� - ������������� �����');

ksi=Dis0+hdelta*norm(GG)*Ga0;mu2=min(ksi)+delta*norm(u);
disp(['   mu_apost = ' num2str(mu2) '; �����. ������ = ' num2str(abs(mu_exact-mu2)/mu_exact)])
disp(' ');
disp(['      ����� ������� = ' num2str(ttt)]);disp(' ');


%  ���������� ���� �������������� ������ ������������
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' ');
disp(' ���������� ���������� ���� �������������� ������ ������������');
disp('    ������� ���������!');disp(' ');

options=optimset('Display','off','MaxIter',70);%  ,'Diagnostics','off'  'iter'
warning off
m=size(G,2);tt=cputime;
%tic
[zmu,mu1]=fminunc('inc_func',zeros(m,1),options,G,u,delta,hdelta);ttt=cputime-tt;
disp(['   mu_direct = ',num2str(mu1) '; �����. ������ = ' num2str(abs(mu_exact-mu1)/mu_exact)])
disp(' ');disp(['      ����� ������� = ' num2str(ttt)]);disp(' ');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
%toc
disp(' ');%disp(' ');



