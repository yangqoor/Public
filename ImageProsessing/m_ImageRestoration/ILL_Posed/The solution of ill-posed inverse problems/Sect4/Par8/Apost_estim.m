%    Apost_estim

% ���������� ����������� ������������� ��������� ������� ��� ��������� ����.
% ������� ������������� ��������� �� ������� 49 (������ 3) (�.229)
% �������� ��� �� ������ z=(A'A)^(p/2)v c �������� p

% ��������� ������� ������������� ������ (� ����� � L_2) 
% 
if ~exist('fmincon');disp(' ');
  disp('  ��������! ������������ �����������, �.�. �� ���� ���');
  disp('  �� ���������� ��������� ������� - Optimization Toolbox.');return;end

clear all
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n=50;h=1/(n-1);xs=[0:h:1]';[xx,ss]=meshgrid(xs,xs);
C=1.1;


%  ������ �� ������� 49
% ������� ������� ������� � ������ ������ �����: 
disp(' ');disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' ');
disp(' ���������� ����������� ������������� ��������� ������� ��� ��������� ����');
disp(' � ����������� �� ������ ������ ������ delta.');
disp('        ��������� ������� �����.');
disp(' ');
disp('   �������� ������������ ��������� 1 ���� � ����� -- �������� ����� (������ 49).');
disp('     �������� -- ������������������ ���������� ����� �������');
disp('     ��� ������������������ ������� � ��������� �������� p');disp(' ');
disp('       �������� �����: 1) ������ ������� z=2*(s-s.^3) (p=1);');
disp('                       2) ������ ������� z=16*sin(4*pi*s) (p=3)');
disp(' ');
zad=input('          ������� ����� ������ (1,2): ');
if isempty(zad)|abs((zad-1.5))>1;
    disp('     ����� ��������. ��������� ����!');return;end

disp(['        ������ ' num2str(zad)]);disp(' ');
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


% ��������
[U,R,V]=svd(A);nR=norm(R);
z1=zeros(n,1);

G=(R'*R).^(p/2);H=R*G;
warning off
options=...
  optimset('MaxIter',40,'Diagnostics','off','Display','off','GradObj','on','GradConstr','on');

DELT=[0.005 0.01 0.05 0.1 0.15 0.2];
hhh = waitbar(0,'Please wait for the error estimate');

for ndel=1:length(DELT);delU=DELT(ndel);waitbar(ndel/6,hhh);
   sdu=norm(du);u=(uu/nrU+delU*du/sdu)/s;uv=(uu+delU*nrU*du/sdu);
   y=U'*u;x0=pinv(R)*y;mu=norm(R*x0-y);s1=norm(y);
   DEL=delU*s1+delA*nR^(1+p)*s^(p/2)*r0+mu;

disp(' ');
disp(['   ������� ������ delta = ' num2str(delU) ]);
disp(' ');
%%%%%%%%%%%%%%%%%%%%% ������� � ������ ��������� ���� %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DLL=DEL;
x0=fmincon('fun1_1',r0*z1,[],[],[],[],[],[],'grfun1_1',options,H,y,r0,DLL);
x=fmincon('fun1_2',x0,[],[],[],[],[],[],'grfun1_2',options,H,y,r0,DLL);

z=nrU*V*G*x;DDD=norm(H*x-y)/norm(y);ERR=max(abs(z-zt))/max(abs(zt));

%%%%%%%%%%%%%%%%%%%%% ������������� ������ ������ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   
options=...
optimset('MaxIter',250,'Display','off','GradObj','off','GradConstr','off','MaxFunEvals',1e6);

ze=z;rE=sqrt(norm(zt)^2*h+norm(diff(zt))^2/h);
C=1.;DDD=C*(delU*nrU+delA*norm(B)*norm(ze));
%hhh = waitbar(0,'Please wait for error estimate');waitbar(1,hhh);pause(1)

[x9,epsi]=fmincon('fun1_3',zt,[],[],[],[],lb,ub,'grfun1_3',options,B,uv,ze,rE,DDD,h);
%close(hhh)
Relative_apost_error_L2=norm(x9-ze)^2/norm(ze)^2
%figure(3);plot(xs,zt,'k',xs,z,'r',xs,x9,'o-');xlabel('s');ylabel('z(s), z_{\eta}(s)')
%legend('Exact solution','Appr. solution','Error Minimizer',1)
epsilon(ndel)=Relative_apost_error_L2;
end
close(hhh)
figure(1);plot(DELT,epsilon,'ko-');set(gca,'FontName',FntNm);
title('������������� ������ ��������� ���� � ����������� �� ������ ������');
xlabel('\delta');ylabel('\epsilon(\delta)')

disp('%%%%%%%%%%%%%%%%%%%%%%%%% ����� %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
