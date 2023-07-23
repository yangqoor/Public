% Teplo_istoch

% Решение линейной обратной задачи нахождения амплитуды источника f(x)
% для стационарного уравнения теплопроводности (с.282)

% -div(grad(u(x,y)))=f(x)g(y), -1<x<1,0<y<0.8;
%  u(x,y)=0 на верхней и нижней границе; du/dn=0 на левой и правой границе
%  u(x,y=0.08)=U(x) - переопределение 

% Описание области: 'pryamg' . Описание граничных условий: 'prya'
% Описание источника: 'istok1'

% Алгоритм решения прямой задачи -- проекционный метод относительно f(x) 
% и метод конечных элементов для u(x,y).
% Алгоритм решения обратной задачи -- метод регуляризации в W_2^1 с интерактивным 
% выбором параметра по ОПН или другим критериям.


clear all
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global xx yy XX YY a

%
N=41;M=51;

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' ');disp(' Решение линейной обратной задачи нахождения амплитуды источника f(x)');
disp(' для стационарного уравнения теплопроводности (с.282):');
disp('   -div(grad(u(x,y)))=f(x)g(y), -1<x<1,0<y<0.8;');
disp('     при условиях:');
disp('    u(x,y)=0 на верхней и нижней границе; du/dn=0 на левой и правой границе');
disp('    и переопределении  u(x,y=0.08)=U(x). ');
disp(' ');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Режимы
pred=0;% Проводить предварительные вычисления (да - 1, нет - 0)
MNK=0; % Не применять прямую минимизацию в МНК
derv=0; % Применять решение задачи на классе с отрицательной третьей производной (1)
lcurve=1; % Выбирать параметр регуляризации по L-кривой (1) или нет (0).
noopt=0;
% Область, где решается задача
xx=linspace(-1,1,N);yy=linspace(-0.8,0,M);
[XX,YY]=meshgrid(xx,yy);
x0=[-0.2 0.3 1 2 1 3];NN=6;% Точные данные для модели

% Модельная амплитуда источника f(x)=a0 и функция g(y)=G
z=x0(3)*exp(-x0(5)*(xx-x0(1)).^2)+x0(4)*exp(-x0(6)*(xx-x0(2)).^2);z=z';
a0=x0(3)*exp(-x0(5)*(XX-x0(1)).^2)+x0(4)*exp(-x0(6)*(XX-x0(2)).^2);
G=exp(-6*(YY+0.3).^2);f0=a0.*G;
a=a0;

if exist('initmesh');
  domain_isto;else disp(' ');pred=0;
  disp('    ВНИМАНИЕ! PDF toolbox не установлен на этом компьютере. ');
  disp('        Поэтому некоторые рисунки демонстрации будут опущены!');
  disp(' Нажмите любую клавишу!');  
pause
disp(' ');end
if ~exist('fminunc');disp(' ');
  disp('  ВНИМАНИЕ! ');
  disp('  На этом компьютере не установлен компонент МАТЛАБа - Optimization Toolbox.');
  disp('        Поэтому некоторые режимы демонстрации недоступны!');
    disp(' Нажмите любую клавишу!');noopt=1;  
pause
disp(' ');
  end
  
if noopt==1;MNK=0;derv=0;end;
  
disp(' ');
disp('-----------------------------------------------------------------------------');
disp(' ');

% Базис в пространстве решений
u_k=[];
for k=1:N;ab=zeros(1,N);
   ab(k)=1; 
   u_k=[u_k ab'];
end

% Реакция на базисные векторы в пространстве переопределений
if pred==1;
disp('  Предварительные вычисления.');disp(' ');
disp(' Нажмите любую клавишу!');
pause
disp('-----------------------------------------------------------------------------');

U0=dir_istoch(NN);% Вычисление переопределения в модельной задаче

A=[];u_k=[];gg=0;ind=0;

h4=waitbar(0,' Wait!');tic;
for k=1:N;ab=zeros(1,N);
   waitbar(k/N,h4);
   ab(k)=1; 
   u_k=[u_k ab'];%Нахождение базиса 
   a=repmat(ab,M,1);
   A_uk=dir_istoch(NN)';A=[A A_uk];
end
toc;close(h4);
else load istoch_data A U0;end

delta=0.0005;% Модельная ошибка переопределения

RU=randn(size(U0));NRU=norm(RU);
U=U0+delta*RU/NRU;
deltaA=0.0001;% Ошибка аппроксимации по МКЭ
RA=randn(size(A));NRA=norm(RA);
AA=A+deltaA*RA/NRA;
disp(' ');disp('    Уровни возмущения данных в L_2:');
disp(['    Ошибка матрицы: ' num2str(100*deltaA) ' %']);
disp(['    Ошибка правой части: ' num2str(100*delta) ' %']);
disp(' ');
disp('-----------------------------------------------------------------------------');
disp(' ');disp('  Убедимся в неустойчивости обратной задачи');disp(' ');
disp('   Решим обратную задачу с точным переопределением, обращая матрицу системы,');
disp('   и затем решим обратную задачу с приближенным переопределением,');
disp('   используя псевдообратную матрицу.');disp(' ');
disp(' Нажмите любую клавишу и подождите!');
pause
disp('-----------------------------------------------------------------------------');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Решение путем обращения матрицы -- нерегуляризованное решение
%c=AA\(U');% Коэфициенты разложения
c0=A\(U0');
c=pinv(AA)*(U');
% Вычисление решения обратной задачи
u_sol=u_k*c;u_0=u_k*c0;
UU=AA*c;UU0=A*c0;
Residual_exact=norm(U0'-UU0)/norm(U0);
Residual_appr=norm(U'-UU)/norm(U0);

disp(['  Относ. невязка уравнения на точном решении (L_2) = ' num2str(Residual_exact)]);
disp(['  Относ. невязка уравнения на приближенном решении (L_2) = ' num2str(Residual_appr)]);

figure(111);subplot(1,2,1);plot(xx,a0(1,:),'r',xx,u_0,'.');
set(gca,'YLim',[0 3],'FontName',FntNm)
title('Pешение - амплитуда источника');xlabel('x');
legend('Точное','Приближ.',2);
subplot(1,2,2);plot(xx,U0,'r',xx,UU0,'.');set(gca,'FontName',FntNm,'FontSize',9)
title(['Переопределение - температура при y=' num2str(yy(NN)+0.8)]);xlabel('x');
legend('Точное','Приближ.',2);
set(gcf,'Name','Решение с точными данными (амплитуда)','NumberTitle','off')
pause(1)
if exist('initmesh');
a=repmat(u_0',M,1);
[p,e,t]=initmesh('pryamg');[p,e,t]=refinemesh('pryamg',p,e,t);
[p,e,t]=refinemesh('pryamg',p,e,t);[p,e,t]=refinemesh('pryamg',p,e,t);
u=assempde('prya',p,e,t,1,0,'istok1');% Гр. условия, ур-ние Лапласа, источник
figure(113);pdeplot(p,e,t,'xydata',u);hold on;
plot(xx,yy(NN)*ones(size(xx)),'r');hold off;set(gca,'FontName',FntNm,'FontSize',9)
set(gca,'YTickLabel',char(num2str([0:0.1:0.8]')))
title('Температура для найденного источника (на красном отрезке задано переопределение)');
xlabel('x');ylabel('y');
set(gcf,'Name','Температура (по решению с точными данными)','NumberTitle','off')
end
pause(1)

figure(11);subplot(1,2,1);plot(xx,a0(1,:),'r',xx,u_sol,'.-');
set(gca,'FontName',FntNm)
title('Pешение - амплитуда источника');xlabel('x');
legend('Точное','Приближ.',2);
subplot(1,2,2);plot(xx,U0,'r',xx,UU,'.-');set(gca,'FontName',FntNm,'FontSize',9)
title(['Переопределение - температура при y=' num2str(yy(NN)+0.8)]);xlabel('x');
legend('Точное','Приближ.',2);
set(gcf,'Name','Решение с приближенными данными (амплитуда)','NumberTitle','off')
pause(1)

if exist('initmesh');
a=repmat(u_sol',M,1);
[p,e,t]=initmesh('pryamg');[p,e,t]=refinemesh('pryamg',p,e,t);
[p,e,t]=refinemesh('pryamg',p,e,t);[p,e,t]=refinemesh('pryamg',p,e,t);
u=assempde('prya',p,e,t,1,0,'istok1');% Гр. условия, ур-ние Лапласа, источник
figure(13);pdeplot(p,e,t,'xydata',u);hold on;
plot(xx,yy(NN)*ones(size(xx)),'r');hold off;set(gca,'FontName',FntNm)
set(gca,'YTickLabel',char(num2str([0:0.1:0.8]')))
title('Температура для найденного источника');xlabel('x');ylabel('y');
set(gcf,'Name','Температура (по нерегуляриз. решению)','NumberTitle','off')
end
pause(1)

if MNK~=0;
   disp(' ');
   disp('-----------------------------------------------------------------------------');
disp(' ');disp('  Вместо псевдообращения матрицы применим прямую минимизацию в МНК.');
disp(' ');
disp('  Решение методом наименьших квадратов с прямой минимизацией');disp(' ');
disp(' Нажмите любую клавишу и подождите!');
pause
disp('-----------------------------------------------------------------------------');

% МНК-решение 
options=optimset('Display','off','MaxIter',400,'GradObj','on',...
   'LineSearchType','quadcubic','TolFun',1e-12,'TolCon',1e-12,'MaxFunEvals',4000000,...
   'TolX',1e-12);% 'iter'
z0=0.5*ones(size(c));
tic 
 [cm,nev_min]=fminunc('direct_coeff',z0,options,AA,U,u_k);
toc
u_in=u_k*cm;UUU=AA*cm;
disp(['   Невязка уравнения (L_2) =' num2str(nev_min)]);

figure(12);subplot(1,2,1);plot(xx,a0(1,:),'r',xx,u_in,'.-');
set(gca,'FontName',FntNm)
title('Pешение - амплитуда источника');xlabel('x');
legend('Точное','Приближ.',2);
subplot(1,2,2);plot(xx,U0,'r',xx,UUU,'.-');set(gca,'FontName',FntNm,'FontSize',9)
title(['Переопределение - температура при y=' num2str(yy(NN)+0.8)]);xlabel('x');
legend('Точное','Приближ.',2);
set(gcf,'Name','МНК-решение с прибл. данными (амплитуда)','NumberTitle','off')
pause(1)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if derv~=0;
% Решение на классе функций c монотонной третьей производной
disp(' ');
disp('-----------------------------------------------------------------------------');
disp(' ');disp('  Решение на классе функций с монотонной третьей производной');disp(' ');
disp(' Нажмите любую клавишу и подождите!');
pause
disp('-----------------------------------------------------------------------------');

options=optimset('Display','off','MaxIter',80,'GradObj','on',...
   'LineSearchType','quadcubic','TolFun',1e-12,'TolCon',1e-12,'MaxFunEvals',4000000,...
   'TolX',1e-12);% 'iter'  'off'
z0=0*ones(size(c));
LB=zeros(size(z0));UB=3*ones(size(z0));warning off
tic 
[cm1,nev_min]=fmincon('direct_coeff',z0,[],[],[],[],LB,UB,'conv1',options,AA,U,u_k);
options=optimset('Display','off','MaxIter',75,'GradObj','on',...
   'LineSearchType','quadcubic','TolFun',1e-12,'TolCon',1e-12,'MaxFunEvals',4000000,...
   'TolX',1e-12);% 'iter'  'off'
 [cm1,nev_min]=fmincon('direct_coeff',cm1,[],[],[],[],LB,UB,'conv1',options,AA,U,u_k);
 [cm1,nev_min]=fmincon('direct_coeff',cm1,[],[],[],[],LB,UB,'conv1',options,AA,U,u_k);
 %[cm1,nev_min]=fmincon('Direct_coeff',cm1,[],[],[],[],LB,UB,'Conv1',options,AA,U,u_k);
toc

u_in1=u_k*cm1;UUU1=AA*cm1;
disp(['   Невязка уравнения  (L_2) =' num2str(nev_min)]);

figure(14);subplot(1,2,1);plot(xx,a0(1,:),'r',xx,u_in1,'.-');
set(gca,'FontName',FntNm)
title('Pешение - амплитуда источника');xlabel('x');
legend('Точное','Приближ.',2);
subplot(1,2,2);plot(xx,U0,'r',xx,UUU1,'.-');set(gca,'FontName',FntNm,'FontSize',9)
title(['Переопределение - температура при y=' num2str(yy(NN)+0.8)]);xlabel('x');
legend('Точное','Приближ.',2);
set(gcf,'Name','Решение из специального класса ','NumberTitle','off')
pause(1)

if exist('initmesh');
a=repmat(u_in1',M,1);
[p,e,t]=initmesh('pryamg');[p,e,t]=refinemesh('pryamg',p,e,t);
[p,e,t]=refinemesh('pryamg',p,e,t);[p,e,t]=refinemesh('pryamg',p,e,t);
u=assempde('prya',p,e,t,1,0,'istok1');% Гр. условия, ур-ние Лапласа, источник
figure(15);pdeplot(p,e,t,'xydata',u);hold on;
plot(xx,yy(NN)*ones(size(xx)),'r');hold off;set(gca,'FontName',FntNm)
set(gca,'YTickLabel',char(num2str([0:0.1:0.8]')))
title('Температура для найденного источника');xlabel('x');ylabel('y');
set(gcf,'Name','Температура (по решению из специального класса)','NumberTitle','off')
end
pause(1)
end

disp(' ');
disp('-----------------------------------------------------------------------------');
disp(' ');disp('  Тихоновская регуляризация обратной задачи в W_2^1.');disp(' ');
disp(' Нажмите любую клавишу!');
pause

tikh_istochn

disp(' ');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Конец %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ');
disp(' ');