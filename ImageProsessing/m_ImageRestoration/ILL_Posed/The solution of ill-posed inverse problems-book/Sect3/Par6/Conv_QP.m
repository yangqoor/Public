%   Conv_QP

%  Решение интегрального уравнения 1-го рода на классе выпуклых (вниз) функций 
%  с  ограниченной снизу числом C_min правой производной (с.176).

if ~exist('fmincon');disp(' ');
  disp('  ВНИМАНИЕ! Демонстрация прерывается, т.к. на этой ЭВМ');
  disp('  не установлен компонент МАТЛАБа - Optimization Toolbox.');return;end

clear all;close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vvv=ver('MATLAB');nmver=str2num(vvv.Version);if nmver>6;
warning('off','MATLAB:dispatcher:InexactMatch');end

disp(' ');
disp(' Решение интегрального уравнения Фредгольма 1 рода на классе выпуклых (вниз)');
disp(' функций с ограничением снизу на левую производную. Регуляризующий алгоритм: ')
disp(' ОПК с регуляризатором-вариацией. Реализация -- сведение к ');
disp(' задаче квадратичного программирования (с.176).');disp(' ');


%   Задание параметров
% Описание модельных задач
disp(' ');
disp(' Описание модельных задач: 1) z(s)={{1-s}^{3/2} при 0<s<1;0 при 1<s<2}');
disp('                           2) z(s)=(s-1).^2 при 0<s<1 ');
disp('                           3) z(s)=(s-0.5).^2 при 0<s<1 ');disp(' ');

numm=input(' Введите номер задачи (1,2,3): ');numm=round(numm);
if isempty(numm)|abs(round(numm-2))>1;
    disp('     Номер неверный. Повторите ввод!');return;end

new_er=0;% Выбрать новую реализацию ошибок данных (new_er=1) или стандартнные (new_er=0)? 
%   Задание уровня ошибок данных
delta=0.03;% правая часть уравнения
deltaA=0.01;% ошибки ядра

[a0,s,h,A,U0,u1,C_min,RU,RA]=mod_prob2(numm);

% U0 -- точная правая часть уравнения, А -- ядро

%% Выбрать новую помеху или стандартную?   
if new_er==1;
   RU=randn(size(U0));RA=randn(size(A));
   else end;

NRA=norm(RA);NRU=norm(RU);
U=U0+delta*norm(U0)*RU/NRU;% Приближенная правая часть уравнения
AA=A+deltaA*norm(A)*RA/NRA;% Приближенная матрица задачи
disp(' ');
disp(' 1) Решение задачи квадратичного программирования методом NNLS');pause(1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       Метод NNLS
n=size(AA,2);T1=tril(ones(n-1));T=[1 zeros(1,n-1);ones(n-1,1) T1*T1];
d=zeros(n,1);d(2)=C_min*h;
zz1=zeros(n,1);B=[AA*T];b=U-B*d;;
%
tic;zz1=lsqnonneg(B,b);disp(' ');disp('Time NNLS:');toc;zz1(end)=0;
zz=T*(zz1(1:n)+d);Umon=AA*zz;
disp(' ');
disp(' 2) Решение задачи квадратичного программирования квазиньютоновским методом');pause(1)
disp(' ');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            Квазиньютоновский метод
H=B'*B;f=-B'*b;G=T;g=ones(n,1)/h;
LB=zeros(n,1);warning off;
tic;w=quadprog(H,f,G,g,[],[],LB,[],zeros(n,1));disp(' ');disp('Time Quadr_Prog:');toc
%w(end)=0;
zzz=T*(w+d);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Error_NNLS =norm(zz-a0')/norm(a0);
Error_Quadr_Prog =norm(zzz-a0')/norm(a0);
disp(' ');disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ');disp(' ');
disp('               Ошибки решений (L_2)                          ');
disp(' ');disp([' Error_NNLS =' num2str(Error_NNLS)]);
disp(' ');disp([' Error_Quadr_Prog =' num2str(Error_Quadr_Prog)]);disp(' ');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ');disp(' ');
UV=U;UV(1)=2*U(1);UV(end)=2*U(end);
figure(2);plot(s,u1,'r.-',s,UV,'b.');set(gca,'FontName',FntNm);
legend('Точная правая часть','Приближенная правая часть',1);
title([' \delta=' num2str(delta) ' \delta_A=' num2str(deltaA)])
xlabel('x');ylabel('u(x)')

figure(1);plot(s,a0,'r.-',s,zz,'bo-',s,zzz,'k.-');set(gca,'FontName',FntNm);
legend('Точное решение','NNLS','Квазиньютоновский метод',1);
title(['Решение на классе монотонно не возрастающих функций; \delta=' num2str(delta) ' \delta_A=' num2str(deltaA)])
xlabel('s');ylabel('z(s)')
