function [alf_opn]=gen_PN(t,A,u,U,V,sig,IL,X,y,w,delta,hdelta,C,q,NN,z);
% ��� Nonsatur
global meth

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

srr=char(['������� ����� ��������' 
          '������. ����� ��������' 
          '  ����� ������������  ' 
          '  ����� ��� ��������� ']);

H=hdelta*norm(A);Delta=delta*norm(u);

alf0=10*C*delta*norm(A)/(1-C*delta);
Alf=[];Dis=[];Dz=[];Nz=[];VV=[];Tf=[];Ur=[];Opt=[];Opt1=[];
Alf=alf0*q.^[0:NN-1];
for kk=1:NN;alf=Alf(kk);
  [zz,dis,gam,gamw]=method1(A,u,U,V,sig,IL,X,y,w,alf);
   Dis=[Dis dis];% ������� 
   Opt=[Opt norm(zz-z)/norm(z)];% ��� ������������ ������
   Opt1=[Opt1 norm(zz-z,inf)/norm(z,inf)];
   Nz=[Nz sqrt(gam)];% �����^2 ���������� � L
   Dz=[Dz gamw];% �����^2 ���������� � W
end   

mu=0;% ��������� ���������
% ���
gdis=Dis-(mu+Delta+H*sqrt(Nz));%figure(77);plot(log10(Alf),gdis,'.-')

ix=min(find(gdis<=0));
ix1=ix-1;% ������� >0
[mnb,iy]=min(Opt);alf_opt=Alf(iy);% �������� ������������ ������
[mnb1,iy1]=min(Opt1);

if isempty(ix);alf_opn=Alf(end);else
alf_opn=Alf(ix)-gdis(ix)*(Alf(ix1)-Alf(ix))/(gdis(ix1)-gdis(ix));end

[zgd,dis1,gam,gamw]=method1(A,u,U,V,sig,IL,X,y,w,alf_opn);
egdC=norm(zgd-z,inf)/norm(z,inf);egdL=norm(zgd-z)/norm(z);
if (mnb>egdL);lalf=log10(Alf);
  %disp('****** ����������� ����� ������� ����� ������ ����� �� alpha ******')
  aaa=polyfit(lalf([iy-1 iy iy+1]),Opt([iy-1 iy iy+1]),2);
  alf_opt=10.^(-0.5*aaa(2)/aaa(1));mna=polyval(aaa,log10(alf_opt));else mna=mnb;end
if (mnb1>egdC);lalf=log10(Alf);
  aaa1=polyfit(lalf([iy1-1 iy1 iy1+1]),Opt1([iy1-1 iy1 iy1+1]),2);
  alf_opt1=10.^(-0.5*aaa1(2)/aaa1(1));mna1=polyval(aaa1,log10(alf_opt1));
else mna1=mnb1;end

[zgo,dis1,gam,gamw]=method1(A,u,U,V,sig,IL,X,y,w,alf_opt);
egoC=min([mna1 norm(zgo-z,inf)/norm(z,inf)]);egoL=min([mna norm(zgo-z)/norm(z)]);

figure(43);subplot(2,2,meth);plot(t,z,'k',t(1:2:end),zgo(1:2:end),'b.');
set(gca,'FontName',FntNm,'YLim',[min(z) 1.1*max(z)]);
xlabel('t');ylabel('z(t), z^{\alpha_{opt}}(t)');title(srr(meth,:));
if meth==1;h7=legend('������ ���.','���. ����� ',1);end
set(gcf,'Name','����������� �������','NumberTitle','off')

figure(42);subplot(2,2,meth);plot(t,z,'k',t(1:2:end),zgd(1:2:end),'r.');
set(gca,'FontName',FntNm,'YLim',[min(z) 1.1*max(z)]);
xlabel('t');ylabel('z(t), z^{\alpha}(t)');title(srr(meth,:));
if meth==1;h7=legend('������ ���.','��� ',1);end
set(gcf,'Name','���������������� ������� (���)','NumberTitle','off')


disp('  ');
if meth<4;
disp('      ���. ������ � C[a,b]        ���. ������ � L2[a,b]');disp('  ');
disp(['      ���. �����:  ' num2str(egoC)   '       ���. �����:  ' num2str(egoL)]);
else
disp('      ���. ������ � C[a,b]                        ���. ������ � L2[a,b]');disp('  ');
disp(['���:  ' num2str(egdC) '  ���. �����:  ' num2str(egoC) '    ���:  ' num2str(egdL) '  ���. �����:  ' num2str(egoL)]);
end;disp('  ');
