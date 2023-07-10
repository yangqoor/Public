% reg_var

warning off
options=optimset('Display','off','MaxIter',450,'GradObj','off',...
   'LineSearchType','quadcubic','TolFun',1e-12,'TolCon',1e-12,'MaxFunEvals',4000000,...
   'TolX',1e-12);% 'iter'  'off'
%  
z0=5*ones(size(a0'));
z0=12*ones(size(a0'));
%z0=1.1*a0';

%       Начальное alpha
%alf=0.5e-6;q=0.5;  
alf=0.125e-6;q=0.7;
NV=[];RS=[];ALF=[];W=[];
autoc = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%     Минимизация тихоновского функционала для разных alpha
for ki=1:10;
   alf=q*alf;ALF=[ALF alf];
[cm2,nev_min]=fminunc('Tikh_func',z0,options,AA,U,delta,s,alf);
UUU=AA*cm2;nev_min=norm(U-UUU)/norm(U);NV=[NV nev_min];

if zadan==1;Error=norm(cm2'-a0,inf)/norm(a0,inf);else
   Error=Var1(diff(cm2)'./hsf-da0)/Var1(da0);end

RS=[RS Error];ww=Var1(cm2-a0')/Var1(a0);W=[W ww];

figure(111);subplot(1,2,1);plot(s,a0,'r',s,cm2','.-');
set(gca,'FontName',FntNm);title('Решение');

subplot(3,2,2);plot(log10(ALF),log10(NV),'r.-',log10(ALF),log10(delta)*ones(size(ALF)),'k')
set(gca,'FontName',FntNm);
title('Невязка и delta');ylabel('lg(Nev)');

subplot(3,2,4);plot(log10(ALF),W,'r.-',log10(ALF),Var_error_tk*ones(size(log10(ALF))),'k');
ylabel('Var error')

subplot(3,2,6);plot(log10(ALF),RS,'r.-');ylabel('C error');xlabel('lg(\alpha)');

set(gcf,'Name','Выбор параметра рег-ции','NumberTitle','off','Position',[435 237 560 420])
drawnow
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if autoc == 1;
% Выбор параметра регуляризации вручную
disp(' ');disp('***** Выберите параметр *****');disp(' ');
[aaa,bbb]=ginput(1);[my,iy]=min(abs(aaa-log10(ALF)));alf=ALF(iy);%alf=10^aaa;
else
   %iy=min(find(log10(NV)<=log10(delta)));
   [my,iy]=min(W);alf=ALF(iy)
   end

[cm2,nev_min]=fminunc('Tikh_func',z0,options,AA,U,delta,s,alf);
UUU=AA*cm2;nev_mi=norm(U-UUU)/norm(U);
if zadan==1;Error=norm(cm2'-a0,inf)/norm(a0,inf);else
   Error=Var1(diff(cm2)'./hsf-da0)/Var1(da0);end
   ww0=Var1(cm2-a0')/Var1(a0);

figure(111);subplot(1,2,1);plot(s,a0,'r',s,cm2','.-');
set(gca,'FontName',FntNm);title('Решение');

subplot(3,2,2);
plot(log10(ALF),log10(NV),'r.-',log10(ALF),log10(delta)*ones(size(ALF)),'k',...
   log10(alf),log10(nev_mi),'o')
set(gca,'FontName',FntNm);
title('Невязка и delta');ylabel('lg(Nev)');

subplot(3,2,4);plot(log10(ALF),W,'r.-',log10(alf),ww0,'o',...
   log10(ALF),Var_error_tk*ones(size(log10(ALF))),'k');
ylabel('Var error')

subplot(3,2,6);plot(log10(ALF),RS,'r.-',log10(alf),Error,'o');
ylabel('C error');xlabel('lg(\alpha)');

if zadan==1;set(gcf,'Name','Регуляризатор в W_1^1','NumberTitle','off',...
      'Position',[435 237 560 420]);else
   set(gcf,'Name','Регуляризатор в W_1^2','NumberTitle','off',...
      'Position',[435 237 560 420]);end

disp(['   alpha = ' num2str(alf)]);
disp(['   Residual = ' num2str(nev_mi) '   C error = ' num2str(Error)]);

figure(105);subplot(1,2,1);plot(s,a0,'r',s,cm2','.-');
xlabel('x');ylabel('z(x)');
set(gca,'FontName',FntNm);
title('Точное и приближенное решение')
%subplot(1,2,2);plot(s,U0,'r',s,UUU,'.');
old_val(s,U,UUU);
xlabel('s');ylabel('u(s)');
set(gca,'FontName',FntNm);
title('Приближ. и вычисл. правая часть ')
if zadan==1;set(gcf,'Name','Регуляризатор в W_1^1','NumberTitle','off',...
      'Position',[435 237 560 420]);else
   set(gcf,'Name','Регуляризатор в W_1^2','NumberTitle','off',...
      'Position',[435 237 560 420]);end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Различные меры ошибок решения
Var_error_w=Var1(cm2'-a0)/Var1(a0)
%Del_L2_w1=norm(cm2'-a0)/norm(a0)
%V_1_w1=Var1(diff(cm2)'./hsf-da0)/Var1(da0)
C_error_tk=norm(zrk'-a0,inf)/norm(a0,inf);
C_error_w=norm(cm2'-a0,inf)/norm(a0,inf);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Графическое сравнение качества решений
figure(27);plot(s,a0','k',s,zrk,'.',s,cm2','r');
% s,zrd,'.-',s,zrk,'.-',s,zrl,'.-',s,zrs,'.-'
set(gca,'FontName',FntNm,'YLim',[0.95*min(z) 1.01*max(z)]);
label('t');ylabel('z(t), z^{\alpha}(t)');
hhh=text(1,10,' Сравнение ошибок методов');set(hhh,'FontName','Arial Cyr'); 
hhh=text(1,9.5,'Метод |  Var error  |  C error');
set(hhh,'FontName',FntNm); 
text(1,9,['    W_2^1   |   ' num2str(Var_error_tk)   '    | ' num2str(C_error_tk)] );
text(1,8.5,['    Var   |   ' num2str(Var_error_w)   '    | ' num2str(C_error_w)]);
%h7=legend('точное реш.','об. невязка','модиф. кв.опт. выбор','L-кривая','сглаж. ф-л',1);
h7=legend('Точное решение','Рег-ция 1-го порядка','Сходимость по вар-ции',1);
set(gcf,'Name','Сравнение решений в W_2^1 и W_1^1','NumberTitle','off',...
   'Position',[232 102 560 576])






