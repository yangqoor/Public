%  Alf_stabil
%
%   ������������ ������������ ������� ��� ����� ����������
%   ��������� ������������� (�.138). �������� �������� ����������
%   �� �������� ������� (�������������) ����������� � ����� �����������
%   � ������������� 'mas' � ���.
%
%   ����� ��� ������������� ��������� ��������������� ���������
%   ���������� ������ ������. �����������. ��� �������� �������
%   ��-�� ���������� ������ ��������� ������������� � ��-�� 
%   ��������� ���������� ������ ��������.

clear all
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

t=linspace(-1,1,125);x=t;n=length(t);h=t(2)-t(1);[XX,TT]=meshgrid(x,t);
z=(1-t.^2).^2';K1=h./(1+(XX-TT).^2);hh=sqrt(h);
   u=K1*z;delta=0.001;C=1.1;
   tt=linspace(-2,2,125);;k1=1./(1+tt.^2);
   mas=2;
disp(' ');
disp('  ������������ ������������ ������� ��� ����� ����������');
disp('          ��������� ������������� (�.138)');   
disp(' ');disp('    ������ ������');
disp('        ������� ����� �������!');disp(' ');pause
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');


figure(20);subplot(2,2,1);plot(t,z,'.-');set(gca,'FontName',FntNm);
title('������ �������');subplot(2,2,2);plot(tt,k1,'.-');set(gca,'FontName',FntNm);
title('����');subplot(2,2,3);plot(t,u,'.-');set(gca,'FontName',FntNm);
title('������ �����');
set(gcf,'Name','������ ������','NumberTitle','off')

disp(' ');disp('   �������� ��������� ���������� ������.');
disp(['     ������� ������������� ������ ������: h=delta=' num2str(delta)]);disp(' ');
disp('        ������� ����� �������!');disp(' ');pause
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

disp(' ');disp('  ������������ ������� ������������ ��������� alpha');disp(' ');
disp('     ���������� ���� ���������������� �������');
disp(['     ��� ����������, ������������ � ' num2str(mas) ' ����']);
disp('     �� ���������� �� ���');disp(' ');
disp('       ������� ����� �������!');disp(' ');pause
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');


RN1=randn(n,1);ud1=u+delta*norm(u*hh)*RN1/norm(RN1);
RK1=(randn(size(K1)));KK1=K1+delta*norm(K1*hh*hh)*RK1/norm(RK1);
alf0=delta*norm(K1)/(norm(ud1*hh)-delta*norm(u*hh));Del=delta;%Del=delta*norm(u*h);
Alf=[];Dis=[];Dz=[];Nz=[];VV=[];Tf=[];
for kk=1:15;alf=alf0*(0.1).^(kk-1);
   [zr3,dis3,v3]=Tikh_alf1(KK1,ud1,h,delta,alf);Alf=[Alf alf];Dis=[Dis dis3];
   dz=norm(zr3-z)/norm(z);Dz=[Dz dz];nz=norm(zr3);Nz=[Nz nz];VV=[VV v3];
   tf=(alf*norm(zr3)^2+(dis3*norm(u))^2)/norm(u)^2;
   Tf=[Tf tf];
end   
%[zm,iz]=min(Dz);iz=min(find(Tf<=C*Del^2));
iz=min(find(Dis<=Del));

alf=Alf(iz);alf1=alf/mas;alf2=alf*mas;
[zro,diso,vo]=Tikh_alf1(KK1,ud1,h,delta,alf);
[zr1,dis1,v1]=Tikh_alf1(KK1,ud1,h,delta,alf1);
[zr2,dis2,v2]=Tikh_alf1(KK1,ud1,h,delta,alf2);
ero=norm(zro-z)/norm(z);er1=norm(zr1-z)/norm(z);
er2=norm(zr2-z)/norm(z);

figure(25);plot(t,z,'k',t,zro,'.-',t,zr1,'.-',t,zr2,'.-')
set(gca,'FontName',FntNm);xlabel('t');ylabel('z(t), z^{\alpha}(t)');
H1=get(gca,'YLim');
legend('������ ���.',['\alpha_{���}=' num2str(alf)],['\alpha_{���}/2=' num2str(alf1)],...
   ['2\alpha_{���}=' num2str(alf2)],2)
hh=text(-0.6,0.3,'���. ������');set(hh,'FontName',FntNm);
text(-0.6,0.25,num2str(ero));text(-0.6,0.2,num2str(er1));
text(-0.6,0.15,num2str(er2));%text(-0.6,0.1,num2str(ers));
set(gcf,'Name','������������ ������� ������������ alpha','NumberTitle','off')

disp(' ');disp(' ������������ ������� � ����������� ������ ������. ');
disp(' ');disp('    ���������� ���������������� �������');
disp('    ��� ���� ���������� ������ ������.');disp(' ');
disp('      ������� ����� �������!');disp(' ');pause
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');


RN1=randn(n,1);ud1=u+delta*norm(u*h)*RN1/norm(RN1);
RK1=(randn(size(K1)));KK1=K1+delta*norm(K1*h*h)*RK1/norm(RK1);
[zr01,dis01,vo]=Tikh_alf1(KK1,ud1,h,delta,alf);
RN1=randn(n,1);ud1=u+delta*RN1/norm(RN1);
RK1=tril(randn(size(K1)));KK1=K1+delta*RK1/norm(RK1);
[zr02,dis02,vo]=Tikh_alf1(KK1,ud1,h,delta,alf);
er01=norm(zr01-z)/norm(z);er02=norm(zr02-z)/norm(z);

figure(26);plot(t,z,'k',t,zro,'.-',t,zr01,'.-',t,zr02,'.-')
set(gca,'FontName',FntNm);xlabel('t');ylabel('z(t), z^{\alpha}(t)');
set(gca,'YLim',H1);
legend('������ ���.','� 1','� 2','� 3',2)
hh=text(-0.6,0.3,'���. ������');set(hh,'FontName',FntNm);
text(-0.6,0.25,num2str(ero));text(-0.6,0.2,num2str(er01));
text(-0.6,0.15,num2str(er02));%text(-0.6,0.1,num2str(ers));
set(gcf,'Name','������������ � ���������� ������ ������','NumberTitle','off')
disp(' ');
disp('   �����: �������� ������� ��-�� ���������� ������'); 
disp('   ��������� ������������� �������� � �� ���������');
disp('   ��-�� �������� ��������� ��������� ������ ������.');disp(' ');
%     
disp('%%%%%%%%%%%%%%%%%%%%%% ����� %%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' ');