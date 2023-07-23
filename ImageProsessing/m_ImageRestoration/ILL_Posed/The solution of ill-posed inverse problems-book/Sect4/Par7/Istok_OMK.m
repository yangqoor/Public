%  Istok_OMK

% ������������������ ����������� ����� ������������ �� ������� {(A'A)^(p/2)*v}
% �������������� ����� ���������� p, r (�.224).

% ������������ SVERT, FUN1 � GRFUN1(���������� ������������� �-�� � ���������)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ������� ������: ������� ��������� � ������������������ ��������
% zt=�*(1-s^2); � ���� ������ p=0.5;����� p0=0.032;r0=128;
%
%     ������������� ������ ������ (Leonov A.S. and Yagola A.G. Inverse Problems, 
%                                  V.14 1998, p.1546):
%  ||z_appr -z||<=D_p *r^(1/(p+1))*(delta+del_A*r)^(p/(p+1))
%    D_p=sup{2*(1+|ln(h)|)*h^(min(1,p)-p/(p+1))+k^(p/(p+1)),  0<h<=h_0}
%         k=C+3+2 - ��� del_A>0, k=2 - ��� del_A=0 ��� ���������� �����
%
if ~exist('fmincon');disp(' ');
  disp('  ��������! ������������ �����������, �.�. �� ���� ���');
  disp('  �� ���������� ��������� ������� - Optimization Toolbox.');return;end

clear all;close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ');
disp(' ������� ������������� ��������� ���������� 1-�� ���� � ����� ��������');
disp(' � � ������������������ �������� ���� z=�*(1-s^2) (�.224).');
disp(' � ���� ������ z=[(A^*A)^(p/2)]v, ��� p=1 � r=||v||=2/3.');
disp(' ������������ ������������������ �� ��� � �������������� ����������� ||v||<r0=128.');
disp(' ����� ������� p � r ������������ �������������.');
disp(' ������� ������� ������������ �������� �������.');disp(' ');
 
n=100;h=1/(n-1);xs=[0:h:1]';[xx,ss]=meshgrid(xs,xs);
% ������� ������������ � ��������� ���������
delU=0.01;delA=0.00;C=2.;

disp(['   ������ ������ ����� = ' num2str(delU*100) ' %']);disp(' ');pause(1)

% ������� ������� ������� (��� - ������������������ � p=0.5)
zt=(1/2*log(2+xs.^2-2*xs)-xs.*atan(xs-1)-1/2*log(1+xs.^2)+xs.*atan(xs));
% ������� ������� 
B=h./(1+(xx-ss).^2);
% ������� ������ ����� (SVERT - ������� �*Z(������))
in=zeros(1,n);
for k=1:n,xx=(k-1)/(n-1);in(k)=quad('svert',0,1,[],[],xx);
end;uu=in';
% ���������� ������� � ������ �����
DB=(2*rand(n,n)-1);sDB=norm(DB,'fro');nrB=norm(B,'fro');
B=B+delA*nrB*DB/sDB;s=2*norm(B);A=B/s;
nrU=norm(uu);
du=(2*rand(size(uu))-1);sdu=norm(du);u=(uu+delU*nrU*du/sdu)/s;
% ��������
[U,R,V]=svd(A);y=U'*u;
% ��������� ��������� p,r; ������ (p0=0.032;r0=32;)
p0=0.032;r0=128;pp=p0;rd=r0;m=10;mp=10;% ����� �������� �� p � r
z1=zeros(n,1);Disc=zeros(1,mp);pq=zeros(1,mp);zz=zeros(1,m);
DD=zeros(mp,m);nR=norm(R);
warning off
options=...
  optimset('MaxIter',30,'Display','off','GradObj','on','GradConstr','on');%'off' 30
% 
h00=waitbar(0,'Wait for the end of optimization!');
tic
for l=1:mp,p=p0*2^l;G=(R'*R).^(p/2);H=R*G;
for k=1:m  
  r=r0*(0.5)^k;waitbar(l*k/mp/m,h00);  %disp(['   p r: ' num2str(p) '  ' num2str(r)]);
  if p>4;options=optimset('MaxIter',7,'Display','off');end
x=fmincon('fun1_1',r*z1,[],[],[],[],[],[],'grfun1_1',options,H,y,r,[]);
DD(l,k)=norm(H*x-y)/norm(y);
zz(k)=norm(V*G*x);
end
end;toc;% �������� ������� ��� ������� p,r
close(h00)
mu=min(min(DD))*s;DEL=(C-1)*delU+delA+mu;
if min(DD)>DEL/s,disp(['WARNING!  �������>DEL']);else end;
% ����� ����������� ����������
%
K1=zeros(size(DD));L1=K1;for k=1:m;for l=1:mp;
Disc(l)=DD(l,k);P1(l,k)=p0*2^l;R1(l,k)=r0*(0.5)^k;
if Disc(l)<=DEL/s;K1(l,k)=k;L1(l,k)=l;else end
end;end
KKK=K1+L1;mmm=max(max(KKK));nr1=find(KKK==mmm);
pp=P1(round(nr1(2)));rd=R1(round(nr1(2)));
%  
disp(' ');
disp(' ');disp('----------------------------------------');
disp(['  ��������� ��������� ��������������������  '])
disp(['     p      r     '])
disp([pp rd]) % ����������� ���������
disp('----------------------------------------');disp(' ');

G=(R'*R).^(pp/2);H=R*G;
options=...
  optimset('MaxIter',30,'Display','off','GradObj','on','GradConstr','on','TolFun',1e-10,'TolCon',1e-10,'TolX',1e-10);

x=fmincon('fun1_1',rd*z1,[],[],[],[],[],[],'grfun1_1',options,H,y,rd,[]);
z=V*G*x;DDD=norm(H*x-y)/norm(y);ERR=max(abs(z-zt))/max(abs(zt));
% �������
figure(1);clf;mz=min(z);Mz=max(z);ytx=mz/2+0.05*(Mz-mz);
plot(xs,z,'r',xs,zt,xs,zeros(size(z)));set(gca,'FontName',FntNm);
legend('�����. �������','����. �������',2);
h5=text(0.05,ytx,'�������=');set(h5,'FontName',FntNm);
h5=text(0.2,ytx,num2str(DDD));set(h5,'FontName',FntNm);
h5=text(0.4,ytx,'���. ������:');set(h5,'FontName',FntNm);
h5=text(0.6,ytx,num2str(ERR));set(h5,'FontName',FntNm);
title('�������');xlabel('x');ylabel('�������');
k=[1:m];l=[1:mp];r1=k;p1=l;[yr,xp]=meshgrid(p1,r1);
disp('----------------------------------------');disp(' ');
disp('  ��� ����������� ������� ����� �������!');
disp('  ����� ������ ����������� ������� �� p � r');disp(' ');pause;
disp('----------------------------------------');disp(' ');


figure(2);clf
surfl(yr,xp,DD');set(gca,'FontName',FntNm);
xlabel('������� m �� p=p0*2^m');ylabel('������� k �� r=r0*(1/2)^k')
title('�������(p,r)')
disp('----------------------------------------');disp(' ');
disp('  ��� ����������� ������� ����� �������!');
disp('  ����� ������ ����� ������ ������� Nev=delta � ����������� �� p � r');
disp(' ');pause;
disp('----------------------------------------');disp(' ');


figure(3);clf
hold on;contour(yr,xp,DD',[DEL/s DEL/s],'k');grid on
plot(log2(pp/p0),log2(r0/rd),'ro');hold off;set(gca,'FontName',FntNm);
xlabel('������� m �� ������� p=p0*2^m (p0=0.032)');
ylabel('������� k �� ������� r=r0*(1/2)^k (r0=128)')
title('����� ������ �������: ������� = \delta; � - ����������� (p,r)')

disp('----------------------------------------');disp(' ');
disp([' ������������� ������ ����������� � (L_2) = ' num2str(ERR)]);disp(' ');
disp(' ������������� ������ ������ ����������� �������� ������� 25, (4.8):');
disp(['     �������. �������. ������ (L_2) = ' num2str(rd^(1/(pp+1))*(2*delU*norm(u)/s)^(pp/(pp+1))/norm(zt))]);
disp(' ');disp('----------------------------------------');
disp('%%%%%%%%%%%%%%%%%% ����� %%%%%%%%%%%%%%%%%%% ');