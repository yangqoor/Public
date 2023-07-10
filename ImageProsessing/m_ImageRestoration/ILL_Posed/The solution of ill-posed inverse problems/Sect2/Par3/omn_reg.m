% OMN_reg

options=optimset('Display','off','MaxIter',200,'GradObj','off',...
   'LineSearchType','quadcubic','TolFun',1e-12,'TolCon',1e-12,'MaxFunEvals',4000000,...
   'TolX',1e-12);% 'iter'  'off'
%  'iter'
z0=12*ones(size(a0'));
warning off
h4=waitbar(0,' Wait for the end of minimization!');waitbar(1,h4);
tic
[cm,nev_min]=...
  fmincon('Omega_gen_entr',z0,[],[],[],[],[],[],'Direct_nev',options,AA,U,delta,s);
toc;close(h4);
%  fmincon('Direct_nev',z0,[],[],[],[],[],[],'Omega_gen_entr',options,AA,Bg,U,u_k,delta,s);

UUU=AA*cm;nev_min=norm(U-UUU)/norm(U);C_error=norm(cm'-a0,inf)/norm(a0,inf);
disp(['   Residual=' num2str(nev_min) '   C_error=' num2str(C_error)]);

figure(104);subplot(1,2,1);plot(s,a0,'r',s,cm','.-');
set(gca,'FontName',FntNm);
title('������ � ������������ �������')
legend('������ �������','������������ �������',1);
subplot(1,2,2);plot(s,U0,'r',s,UUU,'.');
set(gca,'FontName',FntNm);legend('u_{\delta}','Az_{�������}',1);
title('�������. � ������. ������ �����')
set(gcf,'Name','��� � W_1^1','NumberTitle','off','Position',[435 237 560 420])

Var_error_OMN=Var1(cm'-a0)/Var1(a0)
%C_error_tk=norm(zrk'-a0,inf)/norm(a0,inf);
C_error_td=norm(zrd'-a0,inf)/norm(a0,inf);

% ����������� ��������� �������� �������
figure(27);plot(s,a0','k',s,zrk,'.',s,cm','r');
% s,zrd,'.-',s,zrk,'.-',s,zrl,'.-',s,zrs,'.-'
set(gca,'FontName',FntNm,'YLim',[0.95*min(z) 1.01*max(z)]);
xlabel('t');ylabel('z(t), z^{\alpha}(t)');
hhh=text(1,10,' ��������� ������ �������');set(hhh,'FontName',FntNm); 
hhh=text(1,9.5,'����� |  Var error  |  C error');
set(hhh,'FontName',FntNm); 
text(1,9,['    W_2^1   |   ' num2str(Var_error_td)   '    | ' num2str(C_error_td)] );
text(1,8.5,['    Var   |   ' num2str(Var_error_OMN)   '    | ' num2str(C_error)]);
%h7=legend('������ ���.','��. �������','�����. ��.���. �����','L-������','�����. �-�',1);
h7=legend('������ �������','���-��� 1-�� �������','���������� �� ���-���',1);
set(gcf,'Name','��������� ������� � W_2^1 � W_1^1','NumberTitle','off',...
   'Position',[232 102 560 576])
