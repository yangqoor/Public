function [alf_opn,alf_opsf]=nonlin_choice(t,A,u,U,V,sig,X,y,w,delta,hdelta,C,q,NN,z);

% ����� ��������� ��� �������� ����� �� ��������� ��� ���������� �����

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

H=hdelta*norm(A);
Delta=delta*norm(u);DDD=delta*norm(u)+hdelta*norm(A);

alf0=10*C*delta*norm(A)/(1-C*delta);
Alf=[];Dis=[];Dz=[];Nz=[];VV=[];Tf=[];Ur=[];Opt=[];
Alf=alf0*q.^[0:NN-1];
for kk=1:NN;alf=Alf(kk);
   [zz,dis,gam,psi,ur_psi,gamw]=Tikh_inv44(A,u,U,V,sig,X,y,w,alf,DDD);
   Dis=[Dis dis];% ������� 
   Opt=[Opt norm(zz-z)/norm(z)];% �������� ������������ ������
   Nz=[Nz sqrt(gam)];% �����^2 ���������� � L
   Dz=[Dz gamw];% �����^2 ���������� � W
   %VV=[VV psi];% Quasiopt
   tf=alf*gamw+dis^2;
   Tf=[Tf tf];% ���. �-�
end   

mu=0;% ��������� ���������
% ���
gdis=Dis-(mu+Delta+H*sqrt(Dz));

% ����
mu=min(Dis);
gsmu=Tf-C*(mu+Delta+H*sqrt(Dz)).^2+(C-1)*mu^2;

ix=min(find(gdis<=0));iix=min(find(gsmu<=0));% ������� < 0 -- a(delta)=b_1(delta)
ix1=ix-1;iix1=iix-1;% ������� > 0 -- b(delta)
ix2=ix1-1;iix2=iix1-1;% ������� > 0 -- b_2(delta)

N1=Dis(ix2);Ps1=H*sqrt(Dz(ix));% ���
N11=Dis(iix2);Ps11=H*sqrt(Dz(iix));% ����

if N1^2 >= C*(mu+Delta+Ps1)^2-(C-1)*mu^2;alf_opn=Alf(ix);else alf_opn=Alf(ix1);end

if N11^2 >= C*(mu+Delta+Ps11)^2-(C-1)*mu^2;alf_opsf=Alf(iix);else alf_opsf=Alf(iix1);end

%alf_opn=Alf(ix)-gdis(ix)*(Alf(ix1)-Alf(ix))/(gdis(ix1)-gdis(ix));
%alf_opsf=Alf(iix)-gsmu(iix)*(Alf(iix1)-Alf(iix))/(gsmu(iix1)-gsmu(iix));

figure(211);
subplot (2,2,1);plot(log10(Alf),gdis, 'r.-',log10(Alf),zeros(size(Alf)),'k-',... 
   log10(alf_opn),0,'bo');
xlabel('log_{10}(\alpha)');
set(gca,'FontName',FntNm,'XLim',[log10(min(Alf)) log10(max(Alf))],'YLim',[-0.2 0.2]);
title('���');
legend ('\rho (\alpha)',['\alpha_{���}=' num2str(alf_opn)],2 )

subplot (2,2,2);plot(log10(Alf),gsmu, 'r.-',log10(Alf),zeros(size(Alf)),'k-',... 
   log10(alf_opsf),0,'bo');
xlabel('log_{10}(\alpha)');
set(gca,'FontName',FntNm,'XLim',[log10(min(Alf)) log10(max(Alf))],'YLim',[-0.025 0.025]);
title('����');
legend ('\Phi (\alpha)',['\alpha_{����}=' num2str(alf_opsf)],2 )
set(gcf,'Name','��� � ���� (� ������� ����������)','NumberTitle','off')

pause(0.5);

[zgd,dis1,gam,psi,ur_psi,gamw]=Tikh_inv44(A,u,U,V,sig,X,y,w,alf_opn,DDD);
[zgs,dis2,gam,psi,ur_psi,gamw]=Tikh_inv44(A,u,U,V,sig,X,y,w,alf_opsf,DDD);
egd=norm(zgd-z)/norm(z);egs=norm(zgs-z)/norm(z);

figure(412);plot(t,z,'k',t,zgd,'.-',t,zgs,'.-');
set(gca,'FontName',FntNm,'YLim',[min(z) 1.1*max(z)]);
xlabel('t');ylabel('z(t), z^{\alpha}(t)');
h7=legend('������ ���.','��� ','����',1);
hh=text(-0.6,0.3,'���. ������ � C[a,b]');set(hh,'FontName',FntNm);
hh=text(-0.6,0.25,['��� :  ' num2str(egd)]);set(hh,'FontName',FntNm);
hh=text(-0.6,0.2, ['����:  ' num2str(egs)]);set(hh,'FontName',FntNm);
set(gcf,'Name','���������������� ������� (� ������� ����������)','NumberTitle','off')

