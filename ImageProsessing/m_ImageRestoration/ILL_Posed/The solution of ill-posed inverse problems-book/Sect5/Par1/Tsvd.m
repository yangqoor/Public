% Tsvd

%   ������� ���� � �������� ��������� ������� TSVD :
%   P. C. Hansen, "Regularization, GSVD and truncated GSVD",
%   BIT 29 (1989), 491-504.
%   � ������� ��������� ������ �� ������� � �� ������ L-������

clear all;close all 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N=25;t=[1:N];hx=0.01;ht=hx;
L=diag([1 ones(1,N-2) 1])*sqrt(ht);
A=hilb(N);% A=1/(i+j-1) -- ������� ��������� N-�� �������
z=ones(size(A,1),1);
u=A*z;

ca=cond(A);C=1.1;
disp('*********************************************************************');
disp(' ');
disp('   ������� ���� � �������� ��������� ������� TSVD.');
disp('         ����� ��������� TSVD �� ��� � L-������.');disp(' ');

disp(['     ������� ������� = ' num2str(N) ' ; ����� ��������������� = ' num2str(ca)])

disp(' ');disp('*********************************************************************');
disp(' ');
disp(' ����������� ������������� ������ ������ TSVD � �������');
disp('     ��������� �� ������� � �� L-������ �� delta');disp(' ');

disp('         delta             �������            L-������');

%
%   ������ ����������� ������ (stand_err=1) ��� ������������ (stand_err=0)?
stand_err=1;
%  ���������� ������:
for kk=1:4;
delta=10^(kk-6);hdelta=0.000;DD=log10(delta);
if stand_err==1;load Hilb_err;else
RN1=randn(size(u));end

b=u+delta*norm(u)*RN1/norm(RN1);

[U,V,sm,X] = gsvd(A,L);% ������ �������
Dis=[];xx_k=[];
for k=1:10;
  x_k = tgsvd(U,sm,X,b,k);% ������ �������
  dis=norm(A*x_k-b)/norm(b);Dis=[Dis dis];xx_k=[xx_k norm(x_k)];
end
%
[ix1] = l_curve1(U,sm,b,L,V,0);
DD=log10(C*(delta+hdelta*xx_k));ix=min(find(log10(Dis)<DD));
figure(20);
subplot(1,2,1);plot([1:10],log10(Dis),'.-',[1:10],[DD],'r',ix,log10(Dis(ix)),'ro',...
  ix1,log10(Dis(ix1)),'r*');

set(gca,'FontName',FntNm);%,'YLim',[0 1]
xlabel('k - �������� TSVD');%ylabel('lg{||Az_k-u_{\delta}||}, lg{C(\delta + h||z_k||)}');
title('����� k(\delta,h) �� ������� (o) � L-������ (*)')
legend('lg{||Az_k-u_{\delta}||}', 'lg{C(\delta + h||z_k||)}',1);

x_k = tgsvd(U,sm,X,b,ix);x_k1 = tgsvd(U,sm,X,b,ix1);
subplot(1,2,2);plot(t,z,'r',t,x_k,'o-',t,x_k1,'k.-');
set(gca,'FontName',FntNm);
hhh=text(2,0.5,' ���������� ������� �');set(hhh,'FontWeight','bold','FontName',FntNm);
hhh=text(2,0.3,' ������� ����� �������!');set(hhh,'FontWeight','bold','FontName',FntNm);
legend('������','���','L-������',1)
set(gca,'FontName',FntNm,'YLim',[0 2],'XLim',[1 N]);
title('�������')
xlabel('����� ���������� �������');

Err=norm(z-x_k)/norm(z);ErrL=norm(z-x_k1)/norm(z);
format long
disp([delta Err ErrL]);format short;pause
end
disp(' ');disp('*************** ����� ***********************************************');
