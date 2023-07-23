% OMN_reg

if ~exist('fmincon');disp(' ');
  disp('  ВНИМАНИЕ! Демонстрация прерывается, т.к. на этой ЭВМ');
  disp('  не установлен компонент МАТЛАБа - Optimization Toolbox.');return;end

options=optimset('Display','off','MaxIter',200,'GradObj','off',...
   'LineSearchType','quadcubic','TolFun',1e-12,'TolCon',1e-12,'MaxFunEvals',4000000,...
   'TolX',1e-12);% 'iter'  'off'
%  'iter'
if zadan==1;z0=12*ones(size(a0'));else
z0=1*ones(size(a0'));end
warning off
h4=waitbar(0,' Wait for the end of the minimization!');waitbar(1,h4);
tic
[cm,nev_min]=...
  fmincon('Omega_GE',z0,[],[],[],[],[],[],'Direct_nev',options,AA,U,delta,s,C);
toc;close(h4);%  Omega_gen_entr
%  fmincon('Direct_nev',z0,[],[],[],[],[],[],'Omega_gen_entr',options,AA,Bg,U,u_k,delta,s);

UUU=AA*cm;nev_min=norm(U-UUU)/norm(U);C_error=norm(cm'-a0,inf)/norm(a0,inf);
disp(['   Residual=' num2str(nev_min) '   C_error=' num2str(C_error)]);

figure(104);subplot(1,2,1);plot(s,a0,'r',s,cm','.-');
set(gca,'FontName',FntNm);
title('Точное и приближенное решение')
subplot(1,2,2);plot(s,U,'r',s,UUU,'.');
set(gca,'FontName',FntNm);
title('Приближ. и вычисл. правая часть')
set(gcf,'Name','ОМН в W_1^1','NumberTitle','off','Position',[435 237 560 420])

Var_error_OMN=Var1(cm'-a0)/Var1(a0)
C_error_td=norm(zrd'-a0,inf)/norm(a0,inf);

% Графическое сравнение качества решений
figure(27);plot(s,a0','k',s,zrd,'.',s,cm','r');
% s,zrd,'.-',s,zrk,'.-',s,zrl,'.-',s,zrs,'.-'
set(gca,'FontName',FntNm,'YLim',[0.95*min(z) 1.01*max(z)]);
xlabel('s');ylabel('z(s), z_{\eta}^{OMN}(s)');
hhh=text(1,10,' Сравнение ошибок методов');set(hhh,'FontName','Arial Cyr'); 
hhh=text(1,9.5,'Метод |  Var error  |  C error');
set(hhh,'FontName',FntNm); 
if zadan==1;wst='    W_2^1   |   ';else wst='    W_2^2   |   ';end
if zadan==1;wst1='    W_1^1   |   ';else wst1='    W_1^2   |   ';end
if zadan==1;wst2=' W_1^1';else wst2=' W_1^2';end
if zadan==1;wwst='W_2^1: ';else wwst='W_2^2: ';end
text(1,9,[wst num2str(Var_error_td)   '    | ' num2str(C_error_td)] );
text(1,8.5,[wst1 num2str(Var_error_OMN)   '    | ' num2str(C_error)]);
%h7=legend('точное реш.','об. невязка','модиф. кв.опт. выбор','L-кривая','сглаж. ф-л',1);
h7=legend('Точное решение','Рег-ция 1-го порядка (W_2^1)','Сходимость по вар-ции (W_1^1)',1);
set(gcf,'Name','Сравнение решений в W_2^1 и W_1^1','NumberTitle','off',...
  'Position',[232 102 560 576])
Var_error_deriv_W=Var1(diff(zrd')-diff(a0))/Var1(diff(a0));
Var_error_deriv_V=Var1(diff(cm')-diff(a0))/Var1(diff(a0));

disp('--------------------------------------------------------------------------');
disp(' ');
disp(['    Сравнительная иллюстрация точности алгоритма ОМН в ' wst2 ' (регуляризатор']);
disp(['    обобщенной энтропии) и тихоновского метода (выбор alpha по ОПН) в ' wwst]);
disp(' ');
disp(' 1) Равномерная сходимость приближений. Относит. ошибка приближения в С');
disp(['     для метода в ' wwst ': '  num2str(C_error_td) ]);
disp(['     для ОМН в ' wst2 ' ' num2str(C_error)]);
disp(' ');
disp(' 2) Сходимость приближений по вариации. Относит. вариация ошибки приближения');
disp(['     для метода в ' wwst ': '  num2str(Var_error_td) ]);
disp(['     для ОМН в ' wst2 ' ' num2str(Var_error_OMN)]);
disp(' ');
if zadan==2;
disp(' ');
disp(' 3) Сходимость по вариации приближений для производной. Относит. вариация ошибки производной.');
disp(['     для метода в ' wwst ': '  num2str(Var_error_deriv_W) ]);
disp(['     для ОМН в ' wst2 ' ' num2str(Var_error_deriv_V)]);
disp(' ');end
disp('--------------------------------------------------------------------------');
