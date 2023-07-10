% Ill_cond_matr

%   ������� ��������� ���� � �������� ��������� - ������ ����� �������������
%   ������ �������� �������. ��������� � �������� Ҹ����� ������� ���������������
%   (�.32 - 36).
clear all
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=25;
disp(' ');disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ');disp(' ');
disp(' ������ ����� ������������� ������ �������� �������.');
disp(' ');disp('  ������� ���� � �������� ��������� A=[1/(i+j-1)]');
disp(['  ������� ' num2str(N) ' ��� ������ ������� ������ delta']);disp(' ');
disp(' ');
disp(' ��� ��������� �������� ���� � �������� Ҹ����� A=[1/(1+|i-j|/N)]');
disp(' ������� ��������������� ��� ������ delta (��. �.32 - 36)');disp(' ');

disp(' ');disp('  ��������� ������ ������� z=1');disp(' ');
disp('--------------------------------------------------------------------------');
disp(' ������� ����� ������� ��� ������ ����������!');disp(' ');
pause

A=hilb(N);ca=cond(A);% A=1/(i+j-1) -- ������� ��������� N-�� �������
B=toeplitz([1./(1+([0:N-1]))]);cb=cond(B);
%B=toeplitz([1./(1+abs([0:N-1]./N))]);cb=cond(B);
disp(['   ����� ��������������� ������� ���������= ' num2str(ca)]);disp(' ');
disp(['   ����� ��������������� ������� Ҹ�����= ' num2str(cb)]);disp(' ');


z=ones(size(A,1),1);
u=A*z;u1=B*z;
%zz=invhilb(N)*u;
rr=randn(size(u));RA=randn(size(A));
del=0.01;Del=[];ER=[];ERP=[];ERT=[];CA=[];ERt=[];ERPt=[];ERTi=[];
warning off

for kk=1:8;del=del*0.1;Del=[Del del];
   ud=(u+del*rr/norm(rr));% ���������� ������ ����� ����
   ud1=(u1+del*rr/norm(rr));% ���������� ������ ����� ����
   AA=A+0.00001*del*RA/norm(RA);% ����� ���������� ����� ������� ���������
   zz=invhilb(N)*ud;% ������ ��������� ������� ���������
   zp=pinv(AA)*ud;% ���
Er=norm(z-zz)/norm(z);ER=[ER Er];Erp=norm(z-zp)/norm(z);ERP=[ERP Erp];
   BB=B+del*RA/norm(RA);% ����� ���������� ����� ������� Ҹ�����
   zzt=inv(BB)*ud1;% ������ o�������� ������� Ҹ�����
   zpt=pinv(BB)*ud1;% ���
Ertt=norm(z-zzt)/norm(z);ERt=[ERt Ertt];Erpt=norm(z-zpt)/norm(z);ERPt=[ERPt Erpt];

disp('--------------------------------------------------------------------------');
disp(' ');disp(['     ������� � ����������� delta = ' num2str(del)]);disp(' ');
disp('         ������� ����� ������� ��� ��������� ����������!')
pause;

Mzz=max(abs(zp));
figure(1);subplot(2,1,1);plot([1:N],z,'kx-',[1:N],zz,'b-',[1:N],zp,'ro-');
set(gca,'YLim',[-Mzz Mzz]);
set(gca,'FontName',FntNm,'XLim',[1 N]);
title('������� ������� � �������� ���������. ');
legend('z=1','z_{\delta}=A^{-1}u_{\delta}',' z_{���}',2);
subplot(2,1,2);plot([1:N],z,'kx-',[1:N],zzt,'b.',[1:N],zpt,'ro-');
set(gca,'FontName',FntNm,'XLim',[1 N]);%'YLim',HL,
title('������� ������� � �������� Ҹ�����. ');
legend('z=1','z_{\delta}=A^{-1}u_{\delta}',' z_{���}',2);
set(gcf,'Name',['������� ��������� � Ҹ�����. delta=' num2str(del)],'NumberTitle','off')


end

warning on
disp(' ');disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ');
disp(' ');disp('  ������ ������ ���������� �������');disp(' ');
disp(' ������� ����� �������!');
pause

figure(2);subplot(1,2,2);%plot(log10(Del),log10(ERt),'o-',log10(Del),log10(ERPt),'k.-')%,...
loglog((Del),(ERt),'.-',(Del),(ERPt),'ko-')
set(gca,'FontName',FntNm);xlabel('\delta');
title('������� Ҹ�����');ylabel('������������� ������ �������');
legend('������ z_{\delta}','������ z_{���}',2)%...
subplot(1,2,1);%plot(log10(Del),log10(ER),'o-',log10(Del),log10(ERP),'k.-')%,...
loglog((Del),(ER),'.-',(Del),(ERP),'ko-')
set(gca,'FontName',FntNm);xlabel('\delta');
ylabel('������������� ������ �������');title('������� ���������');
set(gcf,'Name',' ������ � ����������� �� delta','NumberTitle','off')


disp(' ');disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ');
disp(' ');disp('  ������ ���� ��������������');disp(' ');
disp(' ������� ����� �������!');
pause
%
s1=svd(A);
s2=svd(B);
figure(3);plot(log10(s1),'r.-');hold on;plot(log10(s2),'.-');hold off
set(gca,'FontName',FntNm);
title('��������� ����������� ����� s_i ������ ��������� � Ҹ�����');
ylabel('lg s_i');xlabel(' ����� i ������������ �����')
legend(['������� ��������� ������� N=' num2str(N)],...
   '������� [1/(1+|i-j|/N)]_{i,j=1,...,N}' ,1);
set(gcf,'Name',' ������ ���� ��������������','NumberTitle','off')

disp(' ');disp('%%%%%%%%%%%% ����� %%%%%%%%%%%%%%%%%%%%%%%% ');
disp(' ');
%
