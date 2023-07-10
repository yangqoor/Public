%   Err_estimate

%  Поточечная апостериорная оценка точности приближенного решения обратной задачи 
%  на классе функций с ограниченной вариацией - минимизация невязки
%  (с.236).

if ~exist('fmincon');disp(' ');
  disp('  ВНИМАНИЕ! Демонстрация прерывается, т.к. на этой ЭВМ');
  disp('  не установлен компонент МАТЛАБа - Optimization Toolbox.');return;end


clear all;close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Описание моделей: 1) Интегральное уравнение Фредгольма с ядром Пуассона (p=100). Решение --
%                      функция класса W_1^1.
%                   2) Интегральное уравнение Вольтерра (вычисление u'(s)). Решение --
%                      функция z=(1-t.^2).^2.
%                   3) Интегральное уравнение Фредгольма с ядром Пуассона (p=20). Решение --
%                      (s-1).^2.

%
% Задание точного решения и точной правой части: 
disp(' ');disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' ');
disp(' Поточечная апостериорная оценка точности приближенного решения обратной задачи,');
disp(' которое принадлежит классу функций ограниченной вариации. Второй подход (с.236).');
disp(' ');
disp('   Решается интегральное уравнение 1 рода на классе функций V[a,b] (гл.3, \S 5). ');
disp('   Затем по методике из гл.4 \S8 (минимизация невязки) оценивается  ');
disp('   поточечная точность полученного решения ');disp(' ');
disp('       Описание задач. ');
disp('       1) Интегральное уравнение Фредгольма с ядром Пуассона (p=100);');
disp('          точное решение z={sqrt(1-s)+5, 0<s<1; 5, 1<s<2};');
disp('       2) Интегральное уравнение Вольтерра с ядром задачи дифференцирования;');
disp('          точное решение z=(1-s.^2).^2, 0<s<1');
disp('       3) Интегральное уравнение Фредгольма с ядром Пуассона (p=20);');
disp('          точное решение z=(s-1).^2, 0<s<1;');

disp(' ');
nummer=input('          Введите номер задачи (1,2,3): ');
if isempty(nummer)|abs((nummer-2))>1;
    disp('     Номер неверный. Повторите ввод!');return;end

disp(['        Задача ' num2str(nummer)]);disp(' ')


%nummer=2; % -- номер модели
[s,a0,hsf,A,u,N,C_min,C_max]=new_model(nummer);h=hsf;z=a0';U0=u';

% Уровень относительного возмущения данных
delta=0.01;
deltaA=0.0001;
disp(['   Уровень ошибки delta = ' num2str(delta) ]);disp(' ');pause(1);

sterr=1;
% sterr=1 -- стандартные возмущения данных 

% Возмущение данных 
if sterr==1;if nummer==1;load stand_er_poinwise1;;elseif nummer==2;
    load stand_er_poinwise2;else load stand_er_poinwise3;end;
else RU=randn(size(U0));RA=randn(size(A));
  end

NRA=norm(RA);NRU=norm(RU);
U=U0+delta*norm(U0)*RU/NRU;% Приближенная правая часть уравнения

% Приближенная матрица задачи
if (nummer == 2);AA=A;deltaA=delta;else AA=A+deltaA*norm(A)*RA/NRA;end
%  Для задачи дифференцирования матрица не возмущается!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%          Решение обратной задачи - РА на на классе монотонных функций

n=size(AA,2);
T=triu(ones(n));
zz1=zeros(n,1);B=[AA*T];b=U-C_min*AA*ones(n,1);
%
%         Алгоритм квадратичного программирования
options=optimset('Display','off');warning off
%options=optimset('Diagnostics','off','Display','off');

H=B'*B;f=-B'*b;G=T;g=(C_max-C_min)*ones(n,1);%g=ones(n,1)/h;
LB=zeros(n,1);warning off;
tic;w=quadprog(H,f,G,g,[],[],LB,[],zeros(n,1),options);disp(' ');disp('Time of solution');toc
wap=w;%w(end)=0;
zzz=T*w+C_min;zz=zzz;
%if nummer==1;load sol_w11 ssyy;zz=ssyy';zzz=zz;end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  EE - апостериорная оценка поточечной ошибки правой части 

Del=delta+deltaA*norm(zz)*sqrt(h);
EE=3*(U0)*Del;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%          Верхняя апостериорная оценка точности приближенного решения

%f=-B'*(b+EE);G=[T];g=[(C_max-C_min)*ones(n,1)];
z3=reshsm(s,zz,C_min,nummer);
cu=max([z3'; zz'])';
f=-B'*(b+EE);G=[T;-T];g=[(C_max-C_min)*ones(n,1);-cu+C_min];%g=ones(n,1)/h;
tic;[w,fw,exitflag]=quadprog(H,f,G,g,[],[],LB,[],zeros(n,1),options);disp(' ');%zeros(n,1)
disp('Time of upper error estimation:');toc
if exitflag<0;disp('    Программа МАТЛАБа quadprog не дает надежного решения');
   disp('    Повторите обращение к Err_estimate!');return;end
zzzu=T*w+C_min;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%          Нижняя апостериорная оценка точности приближенного решения

%f=-B'*(b-EE);G=[T];g=[(C_max-C_min)*ones(n,1)];
cl=min([z3'; zz'])';
f=-B'*(b-EE);G=[T;T];g=[(C_max-C_min)*ones(n,1);cl-C_min];
tic;w=quadprog(H,f,G,g,[],[],LB,[],zeros(n,1),options);disp(' ');
disp('Time of lower error estimation:');toc
w(end)=0;zzzl=T*w+C_min;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Формирование коридора ошибок
zfmin=zzzl';zfmax=zzzu';
ZL=[zfmin(2:end) zfmin(end)];ZU=[C_max zfmax(1:end-1)];
SL=s;SU=s;
u_up=AA*zfmax';u_lw=AA*zfmin';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(1);hold on;han=plot(s,U,'r.',s,u_lw,'g',s,u_up,'b');set(gca,'FontName','Arial Cyr');
hold off
set(han,'LineWidth',2);box on
set(gca,'FontName',FntNm);
title('Приближ. правая часть и апостериорные оценки точной правой части')
xlabel('x');ylabel('u(x)');
legend('Приближ. правая часть u_{\delta}(x)','Нижняя оценка для u(x)','Верхняя оценка для u(x)',1);

figure(2);
fill([SU fliplr(SL) SU(1)],[ZU fliplr(ZL) ZU(1) ],[ 0.85 0.85 0.85 ]);
hold on;
hd=plot(s,a0,'m');plot(s,zzz,'r.-');
hold off;set(hd,'LineWidth',2);set(gca,'FontName',FntNm);
title('Поточечная апостериорная оценка на классе функций ограниченной вариации')
xlabel('s');ylabel('z(s)');
vvv=ver('MATLAB');vvv1=round(str2num(vvv.Version));
if vvv1<7;
   legend('Точное решение','Приближ. решение','Коридор ошибок',1);
else
   legend('Коридор ошибок','Точное решение','Приближ. решение',1);
   end

disp('%%%%%%%%%%%%%%%%%%%%%%%%% Конец %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');


