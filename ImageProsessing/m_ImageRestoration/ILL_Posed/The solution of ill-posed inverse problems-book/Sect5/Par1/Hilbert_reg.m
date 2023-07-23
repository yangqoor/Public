%   Hilbert_reg

%   ������� ���� � �������� ��������� ������� ������������� (��. Ill_cond_matr)

clear all;close all 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N=25;t=[1:N];hx=0.01;ht=hx;
A=hilb(N);% A=1/(i+j-1) -- ������� ��������� N-�� �������
z=ones(size(A,1),1);
u=A*z;AA=A;

ca=cond(A);
disp('*********************************************************************');
disp(' ');
disp('   ������� ���� � �������� ��������� ������� �������������');
disp('   ����� ��������� �� �������� �������.');disp(' ');

disp(['     ������� ������� = ' num2str(N) ' ; ����� ��������������� = ' num2str(ca)])

disp(' ');disp('*********************************************************************');
disp(' ');
disp('         delta        �������. ������ �������');
%
%   ������ ����������� ������ (stand_err=1) ��� ������������ (stand_err=0)?
stand_err=1;
%  ���������� ������:
for kk=1:4;
delta=10^(kk-6);hdelta=0.000;DD=log10(delta);
C=1.1;
if stand_err==1;load Hilb_err;else
RN1=randn(size(u));end
u1=u+delta*norm(u)*RN1/norm(RN1);
%RA1=randn(size(A));AA=A+hdelta*norm(A)*RA1/norm(RA1);
%
%   ������� �� �����������

%     ������� ��������������
reg=0;% ������������� � L_2

%    ����������� ���������� �������
[L1,U,V,sig,X,y,w,sss]=L_reg1(reg,AA,u1,hx,ht);L=L1'*L1;

%    ����������� �������������: ����� ���������
q=0.94;NN=50;
[Alf,Opt,Dis,Nz,Nzw,Psi]=func_calc5(AA,u1,U,V,sig,X,y,w,delta,C,q,NN,z,[]);

Del=delta*norm(u)+hdelta*norm(AA)*Nz;
ix=min(find(Dis<=Del));if isempty(ix);ix=min(find(Dis<=10*Del));end
%figure(2);plot(log10(Alf),Dis,'.-',log10(Alf(ix)),Dis(ix),'ro',log10(Alf),Del);

%    ����������� �������������: ���������� �������
[zrd,dis,gam,dz,psi]=Tikh_inv55(AA,u1,U,V,sig,X,y,w,Alf(ix),[]);% SVD


figure(1);
subplot(1,2,1);plot(log10(Alf),Dis,'.-',log10(Alf),Del,'r',log10(Alf(ix)),Dis(ix),'ro');
text(log10(Alf(8)),Del(1),'\delta')
set(gca,'FontName',FntNm,'XLim',[min(log10(Alf)) max(log10(Alf))]);%,'YLim',[0 1]
xlabel('\alpha');%ylabel('lg||Az^{\alpha}-u_{\delta}||,  \delta');
title('����� \alpha(\delta) �� �������')
legend('||Az^{\alpha}-u_{\delta}||', '\delta',2);

subplot(1,2,2);plot(t,z,'r',t,zrd,'.-');%,t,zrd,'o')
set(gca,'FontName',FntNm,'YLim',[0 2],'XLim',[1 N]);
hhh=text(2,0.5,' ���������� ������� �');set(hhh,'FontWeight','bold','FontName',FntNm);
hhh=text(2,0.3,' ������� ����� �������!');set(hhh,'FontWeight','bold','FontName',FntNm);
xlabel('����� ���������� �������');%ylabel('z_k, z^{\alpha}_k');
title('������ � ������������ �������')
legend('������','������������',1)

Err=norm(z-zrd)/norm(z);
format long
disp([delta Err]);format short;pause
end
disp(' ');disp('*************** ����� ***********************************************');

