%  Quasiopt

%  ������� ���� Az=u � ����������� �������� ������� ������������� 0-�� ������� 
%  (���������� ����������� �������������).
%  ����� ��������� ������������� �� ������������ ������������ �������: 
%  ����������� �������� �������, ����������� �������� ������������� �����������.
%  ��������� � ������������ ��������� ������� ��������� �� L-������.
%  ��������� ������������ ������������� ����������� ����������������� ������ ���������
%  � �������� ����������������� ������, ����������� �� ������ (�.55).
%  

clear all;close all
warning off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  ������, ����� ����� L-������ ���� ������ ���������. 
%  ��� ���� ���������� ������� ������� (� ������� pinv �������) �������� ������.


BB=[];CC=[];DD=[];mu=0.4;AA=diag(ones(1,20))+diag(ones(1,19),1);
u1=ones(20,1);
hx=1;ht=1;[n,m]=size(AA);t=[1:n];x=[1:m];
z=pinv(AA)*u1;nr=norm(z);
%

disp(' ');disp(' ��������� ������������ ���������� ������ L-������ � ������������');
disp('    ������������ �������� ������ ��������� �������������');
disp('    ��� ������� ���� ������� ������������� �.�.�������� (�.55)');disp(' ');
disp('      ������� ����� ������� ��� ������ ��������� ������� �������. ');
disp(' ');pause
figure(21);A0=zeros(size(AA));A0(20,1)=1;spy(AA);
hold on;spy(A0,'r');hold off;title('');
set(gcf,'Name',' ��������� ������ � ������������ �������','Number','off');


disp(['      cond(A) = ' num2str(cond(AA))]);
disp('      �������� �� ���� �������� ������ ������� -- ����� �����. ');
disp('      ����������, ��������� � ������ ������� -- ������� �����. ');

delta=0.001;hdelta=0.001;C=1.1;
RN1=randn(m,1);%RN1=2*(rand(n,1)-0.5);
u=u1+delta*norm(u1)*RN1/norm(RN1);
RK1=(randn(size(AA)));%RN1=2*(rand(size(K1))-0.5);
A=AA+hdelta*norm(AA)*RK1/norm(RK1);
disp(' ');disp(['  �����. ������ ������: delta = ' num2str(delta) '  h = ' num2str(hdelta)]);
disp(' ');
disp(' ');
disp('      ������� ����� ������� ��� ������ ��������� alpha. ');disp(' ');pause

% ���������� �������� �������, �� ������� ���������� ��������:
q=0.4;NN=25;
%     ������� ��������������
reg=0;% ������������� 0-�� �������
[Alf,Opt,Dis,Nz,VV,Tf,Dz,Ur]=func_calc(A,u,hx,ht,hdelta,delta,C,q,NN,z,reg);

Del=delta*norm(u)+hdelta*norm(A)*Nz;

% ����� ��������� �� ��������� ���������:
[xxa,yya]=kriv(log10(Dis),log10(Nz));xxa=xxa+1;
ix=min(find(Dis<=Del));iix=min(find(Tf<=C*Del.^2));
[vm,iv]=min(VV);
[um,iu]=min(Ur);
[zm,iz]=min(Opt);


% ����������� ����������� ������ ������ ���������:
figure(22);
subplot (2,2,1);plot(log10(Alf),Dis, 'r.-',log10(Alf),Del,'k-',... %[-18 log10(max(Alf))],[Del Del], 'k-',...
   log10(Alf(ix)),Dis(ix),'bo');
xlabel('log_{10}(\alpha)');
set(gca,'FontName',FntNm,'XLim',[-18 log10(max(Alf))],'YLim',[0 0.2]);
title('���');text(-1,delta,'\delta')
h6=legend ('||Az^{\alpha}-u||','\Delta (\delta,h,z^{\alpha})',['\alpha=' num2str(Alf(ix))],2 );
set(h6,'FontSize',8);

subplot (2,2,2);plot(log10(Alf),Opt/max(Opt), 'r.-',log10(Alf),VV/max(VV),'-b',...
   log10(Alf),Ur/max(Ur),'.-k',...
  log10(Alf(iz)),Opt(iz),'r*',log10(Alf(iu)),Ur(iu)/max(Ur),'ok',...
  log10(Alf(iv)),VV(iv)/max(VV),'bo');%
xlabel('log_{10}(\alpha)');
set(gca,'FontName',FntNm,'FontSize',8,'XLim',[-18 log10(max(Alf))],'YLim',[0 1]);
title('O����. (�������.) ����� ');
h6=legend ('~||z^{\alpha}-z_{exact}||' ,'~||\alpha dz^{\alpha}/d\alpha||',...
   '~�����. ��������.',...
   ['\alpha_{opt}=' num2str(Alf(iz))] , ['\alpha_{m.q.opt}=' num2str(Alf(iu))] ,2 );
set(h6,'FontSize',8);

subplot (2,2,3);plot(log10(Dis),log10(Nz),'.-',log10(Dis(xxa)),log10(Nz(xxa)),'ro',...
   log10(Dis(xxa)),log10(Nz(xxa)),'r.');axis equal;
set(gca,'FontName',FntNm);h6=legend('L-������',['\alpha=' num2str(Alf(xxa))],3);
set(h6,'FontSize',8);
xlabel('log_{10}(||Az^{\alpha}-u||)');
ylabel('log_{10}(||z^{\alpha}||)');

subplot (2,2,4);plot(log10(Alf),Tf, 'r.-',log10(Alf),C*Del.^2,'k-',... %[-18 log10(max(Alf))],[C*Del^2 C*Del^2], 'k-',...
   log10(Alf(iix)),Tf(iix),'bo');
xlabel('log_{10}(\alpha)');
set(gca,'FontName',FntNm,'XLim',[-18 log10(max(Alf))],'YLim',[0 0.02]);
title('O���');
text(-1,delta^2,'C\delta^2');
h6=legend ('\alpha||z^{\alpha}||^2+||Az^{\alpha}-u||^2',...
   'C\Delta^2 (\delta,h,z^{\alpha})',['\alpha=' num2str(Alf(iix))],2 );
set(h6,'FontSize',8);
set(gcf,'Name','����� ���������','NumberTitle','off')

disp('      ������� ����� ������� ��� ������ ������� ����. ');disp(' ');pause


% ���������� ��������������� �����������:
% ��������� �������� �������
[zrd,dis1]=tikh_alf11(A,u,ht,delta,Alf(ix),reg);
[zrk,dis1]=tikh_alf11(A,u,ht,delta,Alf(iu),reg);%iv
[zrl,dis1]=tikh_alf11(A,u,ht,delta,Alf(xxa),reg);
[zrs,dis1]=tikh_alf11(A,u,ht,delta,Alf(iix),reg);

erd=norm(zrd-z)/norm(z);erk=norm(zrk-z)/norm(z);
erl=norm(zrl-z)/norm(z);ers=norm(zrs-z)/norm(z);ero=[];
[nmm,ind]=min([erd erk erl ers ero]);

%if ~isequal(show_comp,0);
figure(23);plot(t,z,'k.-',t,zrd,'bo',t,zrk,'g^',t,zrl,'r.',t,zrs,'rx');
set(gca,'FontName',FntNm,'YLim',[-0.5 1.1*max(z)]);
xlabel('t');ylabel('z(t), z^{\alpha}(t)');
h7=legend('������ ���.','��. �������','�����. ��.���. �����','L-������','�����. �-�',1);
set(h7,'Position', [0.543095 0.119936 0.35 0.201095],'FontSize',8);
hh=text(1,-0.15,'���. ������');set(hh,'FontName',FntNm,'FontSize',8);
hh=text(1,-0.25,['��.�������: ' num2str(erd)]);set(hh,'FontName',FntNm,'FontSize',8);
hh=text(1,-0.32, ['���.��.���:  ' num2str(erk)]);set(hh,'FontName',FntNm,'FontSize',8);
hh=text(1,-0.39,['L-������:    ' num2str(erl)]);set(hh,'FontName',FntNm,'FontSize',8);
hh=text(1,-0.46, ['��.���.�-�:  ' num2str(ers)]);set(hh,'FontName',FntNm,'FontSize',8);
set(gcf,'Name','��������� �������','NumberTitle','off')
% end
disp(' ');disp(' �����');

