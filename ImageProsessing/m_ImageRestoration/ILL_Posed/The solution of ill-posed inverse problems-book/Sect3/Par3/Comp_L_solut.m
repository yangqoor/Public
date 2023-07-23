%  Comp_L_solut

% ���������� L-������������� � ������� ����. ����������
clear all;close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vvv=ver('MATLAB');nmver=str2num(vvv.Version);if nmver>6;
warning('off','MATLAB:dispatcher:InexactMatch');end

disp(' ');
disp('  ���������� L-������������� ������ ����� ��� ������������� ��������� (�.141).');
disp('  ��������� ��� ���� ��������� �������� ������ ��������� �������������');
disp('    ���������� ���� L-������������� � �� ���:');
disp('      1 - ������������� � L_2 (������������� 0-�� �������)');
disp('      2 - L-������������� � ��������� z(a)=z(b)=0 (������������� 1-�� �������)');
disp('      3 - ������������� � W_2^1 � ��������� dz/ds(a)=dz/ds(b)=0 (������������� 1-�� �������)');
disp('      4 - L-������������� � ��������� dz/ds(a)=dz/ds(b)=0 (������������� 2-�� �������)');
disp('      5 - ������������� � W_2^2 (������������� 2-�� �������)');
disp(' ');
disp('-------------------------------------------------------------------');


% �����
t=linspace(-1,1,121);ht=t(2)-t(1);n=length(t);%x=t;hx=ht;
x=linspace(-3,3,121);hx=x(2)-x(1);m=length(x);
[TT,XX]=meshgrid(t,x);
% ������� ������������ ���������:
p=4;
K1=1./(1+p*(XX-TT).^2);

%  ��������� ������� � ��������� ������ �����:
zstr='(1-t.^2).^2';z=eval(zstr)';
[uu]=righ_hand(x,p,1);
u0=uu';

%  ���������� ������:
delta=0.03;hdelta=0.0001;
C=1.2;ster=0;
RN1=randn(m,1);RN1(1)=0;RN1(end)=0;
RK1=(randn(size(K1)));%RN1=2*(rand(size(K1))-0.5);
if ster==1;load Error_Comp_L;end
u1=u0+delta*norm(u0)*RN1/norm(RN1);
AA=K1+hdelta*norm(K1)*RK1/norm(RK1);

% �������������� ������ � ��������� �����:
Hx=ones(1,m)*hx;Hx(1)=0.5*Hx(1);Hx(end)=Hx(1);
Ht=ones(1,n)*ht;Ht(1)=0.5*Ht(1);Ht(end)=Ht(1);
HHx=repmat(sqrt(Hx)',1,n);HHt=repmat(Ht,m,1);
A=AA.*HHx.*HHt;% -- ������� �������

%  ��������������� ������ �����:
u=u1.*sqrt(Hx');% -- ������ ����� �������
DDD=delta*norm(u)+hdelta*norm(A);

disp(' ');disp(['  ������ ������: delta = ' num2str(delta) '  h = ' num2str(hdelta)]);
disp(' ');disp(['  ����� ��������������� ������� = ' num2str(cond(A))]);disp(' ');
   
figure(32);plot(x,u0,'r',x,u1,'b.');%(2:end-2)
set(gca,'FontName',FntNm);   
legend('������ ������ �����','�������. ������ �����',1);
set(gcf,'Name','������ �����','NumberTitle','off')

disp(' ');Nom=input('    ������� ��� �������������� (��� L-�������������) (1 - 5): ');

%     ������� ��������������
if Nom==1;reg=0;% ������������� � L_2
elseif Nom==2;reg=1;% ������������� � W_2^1 -- L-������������� � �������� ��. ���������
elseif Nom==3;reg=21;% ������������� � W_2^1 � ��������� z'(a)=z'(b)=0
elseif Nom==4;reg=2;% ������������� � W_2^2 -- L-������������� � ��������� z'(a)=z'(b)=0
elseif Nom==5;reg=22;% ������������� � W_2^2 � ��������� z'(a)=z'(b)=0
else disp(' ������������ �������������. ��������� ����.');return
end

[U,V,sig,X,y,w,sss]=L_reg(reg,A,u,hx,ht);
disp(['          ��� ��������������: ' sss]);
disp(' ');
disp('-------------------------------------------------------------------');

disp('    ������� ����� ������� ��� ������ alfa ���������� ���������!');pause
disp(' ');

% ���������� �������� �������, �� ������� ���������� ��������:
q=0.4;NN=25;
[Alf,Opt,Dis,Nz,VV,Tf,Nzw,Ur]=func_calc4(A,u,U,V,sig,X,y,w,delta,C,q,NN,z,DDD);

Del=delta*norm(u)+hdelta*norm(A)*Nzw;%Nzw
% ����� ��������� �� ���������:
[xxa,yya]=kriv4(log10(Dis),log10(Nzw));%xxa=xxa+1;
ix=min(find(Dis<=Del));iix=min(find(Tf<=C*Del.^2));
iv=min(find(Ur<=Del));
[zm,iz]=min(Opt);

% ����������� ����������� ������ ������ ���������:
NF=22;                             % VV
graphchoise(Alf,Dis,Del,ix,delta,Opt,Ur,iz,iv,[],[],Nzw,xxa,Tf,C,iix,NF,sss,Nom);

% ���������� ��������������� �����������:
% ��������� �������� �������

[zrd,dis,gam,psi,ur_psi,dz]=Tikh_inv44(A,u,U,V,sig,X,y,w,Alf(ix),DDD);
[zrk,dis,gam,psi,ur_psi,dz]=Tikh_inv44(A,u,U,V,sig,X,y,w,Alf(iv),DDD);
[zrl,dis,gam,psi,ur_psi,dz]=Tikh_inv44(A,u,U,V,sig,X,y,w,Alf(xxa),DDD);
[zrs,dis,gam,psi,ur_psi,dz]=Tikh_inv44(A,u,U,V,sig,X,y,w,Alf(iix),DDD);

erd=norm(zrd-z)/norm(z);erk=norm(zrk-z)/norm(z);
erl=norm(zrl-z)/norm(z);ers=norm(zrs-z)/norm(z);ero=[];%

graphcompar(t,z,zrd,zrk,zrl,zrs,erd,erk,erl,ers,NF+1,sss,Nom);


disp(' ');disp('                  �����');