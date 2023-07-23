%  Spec_2_conc_tikh

%  ����������� ������������ ������� � ����� (�� �� �������� � ������� �����) 
%  � ������� ������ ������������� (����� ��������� �� ���)

clear all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N=7;t=[1:N]';hx=0.01;ht=hx;C=1.1;
L=diag([1 ones(1,N-2) 1])*sqrt(ht);

load mod_2.mat
A=AB;z=[0 0.1 0 0.25 0 0 0.55]';u=A*z;% b=ub;
%  ��������� ������ ������������� ������
delta=1*10^(-2);hdelta=0.01;DD=log10(delta);

%  ����������
ind_err=0;% ����������� ������ ��� ��������� ������ ����������
% 
if ind_err==0;load err_spec;
else RU=randn(size(u));RA=randn(size(A));end

NRU=norm(RU);u1=u+delta*norm(u)*RU/NRU;
AA=A+hdelta*RA*norm(A)/norm(RA);

reg=0;% ������������� � L_2

%    ����������� ���������� �������
[L1,U,V,sig,X,y,w,sss]=L_reg1(reg,AA,u1,hx,ht);L=L1'*L1;

%    ����������� �������������: ����� ���������
q=0.94;NN=50;
[Alf,Opt,Dis,Nz,Nzw,Psi]=func_calc51(AA,u1,U,V,sig,X,y,w,delta,C,q,NN,z,[]);

Del=delta*norm(u)+hdelta*norm(AA)*Nz;
ix=min(find(Dis<=Del));if isempty(ix);ix=min(find(Dis<=10*Del));end
%figure(2);plot(log10(Alf),Dis,'.-',log10(Alf(ix)),Dis(ix),'ro',log10(Alf),Del);

%    ����������� �������������: ���������� �������
[zrd,dis,gam,dz,psi]=Tikh_inv55(AA,u1,U,V,sig,X,y,w,Alf(ix),[]);% SVD

zrd=0.5*(zrd+abs(zrd));% �������������� �� ����� ��������������� ��������
figure(1);
subplot(1,2,1);plot(log10(Alf),Dis/norm(u),'.-',log10(Alf(ix)),Dis(ix)/norm(u),'ro');
set(gca,'FontName',FntNm,'XLim',[min(log10(Alf)) max(log10(Alf))]);%,'YLim',[0 1]
xlabel('lg\alpha');ylabel('||Az^{\alpha}-u_{\delta}||/||u_{\delta}||');
title('����� \alpha(h,\delta) �� ���')

subplot(1,2,2);hnd=plot(t,z,'r');set(hnd,'LineWidth',2);
hold on;plot(t,zrd,'.-',t,zrd,'o');hold off
set(gca,'FontName',FntNm,'YLim',[0 0.8],'XLim',[1 N]);
xlabel('k');ylabel('z_k, z^{\alpha}_k');
legend('������','���',1)
title('�������')
xlabel('����� ��������');ylabel('������������ �������')

disp(' ');
disp('  ����������� ������������ ������� � �����');
disp(' ');
disp('-------------------------------------------------');
disp('    ���������� ������ �������������');disp('     (����� ��������� �� ���)');
disp(' ');
disp('         delta        �������. ������ �������');
Err=norm(z-zrd)/norm(z);
format long
disp([delta Err]);format short;
disp('-------------------------------------------------');

