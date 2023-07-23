%    Aposter1

% ����������� ������������� ������ �������� (�� ����� � L_2) ��������������� ��������� -- 
% ������������������� ��������� ��� �� ������ z=(A'A)^(p/2)v c �������� p (�.228).
% ������� ������������� ��������� �� ������� 49 (������ 1,3).


clear all;
%close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n=50;h=1/(n-1);xs=[0:h:1]';[xx,ss]=meshgrid(xs,xs);
% ������� ����������� � ��������� ���������
delU=0.05;
C=1.1;


%  ������ �� ������� 49
% ������� ������� ������� � ������ ������ �����: �������� zad

disp(' ');disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' ');
disp(' ������������ ����������� ������������� ������ �������� ��������� ���� -- ');
disp(' ������� ������������� ��������� �� ������ z=(A^*A)^(p/2)v c �������� p (�.228).');
disp(' ');
disp('   �������� ������������ ��������� 1 ���� � ����� -- �������� ����� (������ 49).');
disp('     �������� -- ������������������ ���������� ����� �������');
disp('     ��� ������������������ ������� � ��������� ��������');disp(' ');
disp('       �������� �����: 1) ������ ������� z=2*(s-s.^3) (p=1);');
disp('                       2) ������ ������� z=16*sin(4*pi*s) (p=3)');
disp(' ');
zad=input('          ������� ����� ������ (1,2): ');

if isempty(zad)|abs((zad-1.5))>1;
    disp('     ����� ��������. ��������� ����!');return;end

disp(['            ������ ' num2str(zad)]);disp(' ');

if zad==1;zt=2*(xs-xs.^3);uu=(1/30)*(7*xs-10*xs.^3+3*xs.^5);r0=16;p=1;%  p<5/4
   lb=zeros(size(zt));ub=ones(size(zt));ub(1:2)=[0.01; 0.2];ub(end-1:end)=[0.2; 0.01];
elseif zad==2;zt=16*sin(4*pi*xs);uu=sin(4*pi*xs)/pi^2;r0=512;p=3;% ����� p>0
   lb=-15.3*ones(size(zt));ub=15.3*ones(size(zt));ub(1:2)=[0.5; 6.1667];
   lb(end-1:end)=[-6.1667;-0.5];
else disp(' ');return;end
% ������� ������� 
xl=tril(xx);sl=tril(ss);zzz=(1-sl).*(xl);
zzd=diag(diag(zzz));xu=triu(xx);su=triu(ss);
B=h*(zzz-zzd+(1-xu).*(su));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ���������� ������
%
ster=0;% ����������� ������ ster=0
if ster==0;
  if zad==1;load stand_err;elseif zad==2;load stand_err1;elseif zad==3;load stand_err2;end
else DB=randn(n,n);du=randn(size(uu));end
%
% load stand_err -- 1-� ������;  load stand_err -- 2-� ������;  load stand_err2 -- 3-� ������
sDB=norm(DB);nrB=norm(B);delA=0.0001;
B=B+delA*nrB*DB/sDB;s=norm(B);A=B/s;
nrU=norm(uu);
%
sdu=norm(du);u=(uu/nrU+delU*du/sdu)/s;uv=(uu+delU*nrU*du/sdu);

% ��������
[U,R,V]=svd(A);y=U'*u;
x0=pinv(R)*y;mu=norm(R*x0-y);s1=norm(y);nR=norm(R);
z1=zeros(n,1);


DEL=delU*s1+delA*nR^(1+p)*s^(p/2)*r0+mu;

disp(' ');
disp(['   ������� ������ delta = ' num2str(delU) ]);
disp(' ');
disp('%%%%%%%%%%%%%%%%%%%%%%% ������� ������ %%%%%%%%%%%%%%%%%%%%%%%%%%');

warning off
options=...
  optimset('MaxIter',40,'Diagnostics','off','Display','off','GradObj','on','GradConstr','on');


G=(R'*R).^(p/2);H=R*G;

DLL=DEL;tic
x0=fmincon('fun1_1',r0*z1,[],[],[],[],[],[],'grfun1_1',options,H,y,r0,DLL);
x=fmincon('fun1_2',x0,[],[],[],[],[],[],'grfun1_2',options,H,y,r0,DLL);toc

z=nrU*V*G*x;DDD=norm(H*x-y)/norm(y);ERR=max(abs(z-zt))/max(abs(zt));

% �������
figure(2);clf;mz=min(z);Mz=max(z);ytx=mz/2+0.05*(Mz-mz);
plot(xs,z,'r',xs,zt,xs,-0.5*ones(size(z)),'w');set(gca,'FontName',FntNm);
legend('�����. �������','����. �������',2);
h5=text(0.04,ytx,['���. ������� = ' num2str(round(DDD*1e4)*1e-4)]);
set(h5,'FontName',FntNm);
h5=text(0.4,ytx,['���. ������ � C = ' num2str(round(ERR*1e4)*1e-4)]);
set(h5,'FontName',FntNm);
h5=text(0.85,ytx,['p = ' num2str(p)]);set(h5,'FontName',FntNm);
title('�������');xlabel('x');ylabel('�������');

disp(' ');
%
disp('%%%%%%%%%%%%%%%%%% ������������� ������ ������ %%%%%%%%%%%%%%%%%%%%%%%%%');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ������������� ������ ������
%   ����� ������������  [x9,ReR]=apos_estimation(ze,lb,ub,B,uv,nrU,delU,delA,h,zt,xs)
options=...
optimset('MaxIter',150,'Display','off','GradObj','off','GradConstr','off','MaxFunEvals',1e6);

ze=z;%rE=sqrt(norm(zt)^2*h+norm(diff(zt))^2/h);
rE=sqrt(norm(ze)^2*h+norm(diff(ze))^2/h);
C=1.;DDD=C*(delU*nrU+delA*norm(B)*norm(ze));
hhh = waitbar(0,'Please wait for error estimate');waitbar(1,hhh);pause(1)
tic
[x9,epsi]=fmincon('fun1_3',zt,[],[],[],[],lb,ub,'grfun1_3',options,B,uv,ze,rE,DDD,h);
%options=optimset('MaxIter',200,'Display','iter','MaxFunEvals',1e6);
%r00=sqrt(norm(ze)^2*h+norm(diff(ze))^2/h);
%DL=delU*s1+delA*nR^(1+p)*s^(p/2)*r00/nrU+mu
%x7=fmincon('fun1_4',x,[],[],[],[],[],[],'grfun1_4',options,H,y,r00,DL,x,G,V,nrU,h);
%x7=fmincon('fun1_4',x,[],[],[],[],[],[],'grfun1_4',options,B,uv,r00,DDD,x,G,V,nrU,h);
%zze=nrU*V*G*x7;
toc
close(hhh)
Relative_apost_error_L2_Z=norm(x9-ze)/norm(ze);
ReR=Relative_apost_error_L2_Z;
disp(' ')
disp(['  ������������� ����������� ������������� ������ ������� = ' num2str(ReR)]);
disp(' ')

%Relative_apost_error_L2_Mr=norm(zze-ze)/norm(ze)

figure(3);%hold on;
plot(xs,zt,'k',xs,z,'k.-',xs,x9,'ko-');set(gca,'FontName',FntNm);
xlabel('s');ylabel('z(s), z_{\eta}(s)')
legend('������ �������','�������. �������','���������� ������',1)

disp('%%%%%%%%%%%%%%%%%%%%%%%%% ����� %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
