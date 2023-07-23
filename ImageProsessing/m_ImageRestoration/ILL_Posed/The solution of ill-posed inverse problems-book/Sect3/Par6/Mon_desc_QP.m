%   Mon_desc_QP

% Решение интегрального уравнения Фредгольма 1 рода на классе
% монотонно не возрастающий функций. Регуляризующий алгоритм ОПК с 
% регуляризатором-вариацией. Реализация -- сведение к задаче 
% квадратичного программирования (с.170).

if ~exist('fmincon');disp(' ');
  disp('  ВНИМАНИЕ! Демонстрация прерывается, т.к. на этой ЭВМ');
  disp('  не установлен компонент МАТЛАБа - Optimization Toolbox.');return;end

clear all;close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vvv=ver('MATLAB');nmver=str2num(vvv.Version);if nmver>6;
warning('off','MATLAB:dispatcher:InexactMatch');end

N7=61;N3=N7;N=N3+N7-1;
s7=linspace(0,1,N7);s3=linspace(0,1,N3);% Для простоты сетки -- равномерные.
% Точное модельное решение
a0=[ 7*sqrt(abs(s7-1))+5  5*ones(size(s3(1:end-1)))];
s=[ s7 s7(end)+s3(2:end)];
hsf=s(2)-s(1);h=hsf;% Шаг сетки решения
% Априорная информация
C_min=4.8;

% Точные данные задачи
p=100;
[XX,TT]=meshgrid(s,s);K1=1./(1+p*(XX-TT).^2);u=righ_hand(s,p);

A=K1*h;A(:,1)=A(:,1)*0.5;A(:,end)=A(:,end)*0.5;
u1=u;% -- правая часть системы
delta=0.03;
deltaA=0.001;
U0=u1';
%load err_realization RU RA;
RU=randn(size(U0));RA=randn(size(A));
NRA=norm(RA);NRU=norm(RU);
U=U0+delta*norm(U0)*RU/NRU;% Приближенная правая часть уравнения
AA=A+deltaA*norm(A)*RA/NRA;% Приближенная матрица задачи
%%%
n=size(AA,2);T=triu(ones(n));
zz1=zeros(n,1);B=[AA*T];b=U-C_min*AA*ones(n,1);;
%
disp(' ');
disp(' Решение интегрального уравнения Фредгольма 1 рода на классе');
disp(' монотонно не возрастающих функций. Регуляризующий алгоритм ОПК с ')
disp(' регуляризатором-вариацией. Реализация -- сведение к задаче ');
disp(' квадратичного программирования (с.170).');disp(' ');
disp(['   Уровни возмущения данных: h = ' num2str(deltaA) ' delta = ' num2str(delta)]);
disp(' ');

disp(' ');disp('    1) Решение задачи квадратичного программирования методом');
disp('    наименьших квадратов с ограничением неотрицательности (NNLS)');
disp('    и без ограничения решения сверху.');disp(' ');pause(1);
tic;zz1=lsqnonneg(B,b);toc;zz1(end)=0;
zz=T*(zz1(1:n))+C_min;Umon=AA*zz;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
H=B'*B;f=-B'*b;G=T(1,:);g=12.5-C_min;
LB=zeros(n,1);warning off
disp(' ');

disp('    2) Решение задачи квадратичного программирования с ограничением решения сверху');
disp('    (квазиньютоновский метод)');pause(1);
tic;w=quadprog(H,f,G,g,[],[],LB,[],zeros(n,1));toc
w(end)=0;zzz=T*w+C_min;

figure(2);plot(s,u1,'r.-',s,U,'b.');set(gca,'FontName',FntNm);
legend('Точная правая часть','Приближенная правая часть',1);xlabel('x');ylabel('u(x)')
title([' \delta=' num2str(delta) ' \delta_A=' num2str(deltaA)])

figure(1);plot(s,a0,'r.-',s,zz,'bo-',s,zzz,'k.-');set(gca,'FontName',FntNm);
legend('Точное решение','NNLS','Квазиньютоновский метод',1);
xlabel('s');ylabel('z(s)')
title(['Решение на классе монотонно не возрастающих функций; \delta=' num2str(delta) ' \delta_A=' num2str(deltaA)])

Error_NNLS =norm(zz-a0')/norm(a0);
Error_Quadr_Prog =norm(zzz-a0')/norm(a0);
disp(' ');disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ');disp(' ');
disp('          Относительные ошибки решений (L_2)                          ');
disp(' ');disp([' Error_NNLS =' num2str(Error_NNLS)]);
disp(' ');disp([' Error_Quadr_Prog =' num2str(Error_Quadr_Prog)]);disp(' ');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ');disp(' ');

disp(' ');disp('           Конец');

