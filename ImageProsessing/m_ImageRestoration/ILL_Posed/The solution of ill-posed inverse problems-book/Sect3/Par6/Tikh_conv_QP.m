%
% Tikh_conv_QP
%
% Решение интегрального уравнения Фредгольма 1 рода на классе
% выпуклых (вниз) функций. Метод регуляризации Тихонова 0-го порядка.
% Выбор параметра по ОПН (с.174).
if ~exist('fmincon');disp(' ');
  disp('  ВНИМАНИЕ! Демонстрация прерывается, т.к. на этой ЭВМ');
  disp('  не установлен компонент МАТЛАБа - Optimization Toolbox.');return;end

clear all;close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vvv=ver('MATLAB');nmver=str2num(vvv.Version);if nmver>6;
warning('off','MATLAB:dispatcher:InexactMatch');end

disp(' ');disp('    Решение интегрального уравнения Фредгольма 1 рода на классе ');
disp('    выпуклых и ограниченных снизу функций с использованием тихоновского алгоритма.');
disp('    Регуляризатор -- норма в L_2. Применятся выбор параметра по ОПН.');
disp('    Сведение к задаче квадратичного программирования на конусе K^+ (с.174).');

% Описание модельных задач
disp(' ');
disp(' Описание модельных задач: 1) z(s)={{1-s}^{3/2} при 0<s<1;0 при 1<s<2}');
disp('                           2) z(s)=(s-1).^2 при 0<s<1 ');
disp('                           3) z(s)=(s-0.5).^2 при 0<s<1 ');

%   Задание параметров
%
numm=input(' Введите номер задачи (1,2,3): ');numm=round(numm);
if isempty(numm)|abs(round(numm-2))>1;
    disp('     Номер неверный. Повторите ввод!');return;end
new_er=0;% Выбрать новую реализацию ошибок данных (new_er=1) или стандартнные (new_er=0)? 
%   Задание уровня ошибок данных
delta=0.03;% правая часть уравнения
deltaA=0.01;% ошибки ядра
disp(' ');disp(['   Решается модельная задача № ' num2str(numm)]);disp(' ');
disp(' ');
disp(['    Уровни ошибок: правая часть - ' num2str(100*delta)  ' %; ' 'матрица - ' num2str(100*deltaA) ' %; ']);
disp(' ');pause(1);

[a0,s,h,A,U0,u1,C_min,RU,RA]=mod_prob2_norm(numm);

% U0 -- точная правая часть уравнения, А -- ядро

%% Выбрать новую помеху или стандартную?   
if new_er==1;
   RU=randn(size(U0));RA=randn(size(A));
   else end;

NRA=norm(RA);NRU=norm(RU);
U=U0+delta*norm(U0)*RU/NRU;% Приближенная правая часть уравнения
AA=A+deltaA*norm(A)*RA/NRA;% Приближенная матрица задачи

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       
n=size(AA,2);T1=tril(ones(n-1));T=[1 zeros(1,n-1);ones(n-1,1) T1*T1];
d=zeros(n,1);d(2)=C_min*h;
zz1=zeros(n,1);B=[AA*T];b=U-B*d;
% Свели к уравнению Bv=b, v>=0

% Вычисление основных функций, по которым выбирается параметр:
q=0.4;NN=25;C=1.01;
%     Задание регуляризатора
%reg=1;% регуляризатор 1-го порядка
reg=0;% регуляризатор 0-го порядка
%reg=2;% регуляризатор 2-го порядка

[Alf,Opt,Dis,Nz,VV,Tf,Ur]=func_calc_QP(B,b,h,h,deltaA,delta,C,q,NN,a0',s,T,d,reg);

Del=delta*norm(U)+deltaA*norm(AA)*Nz;
% Выбор параметра по критериям:
ix=min(find(Dis<=C*Del));if isempty(ix);ix=min(find(Dis<=1.1*C*Del));end;

[vrd,dis1]=Tikh_alf_QP(B,b,h,delta,Alf(ix),reg);zrd=T*(vrd+d);


erd=norm(zrd-a0')/norm(a0');t=s;

UV=U;UV(1)=2*U(1);UV(end)=2*U(end);
figure(2);plot(s,u1,'r.-',s,UV,'b.');set(gca,'FontName',FntNm);
legend('Точная правая часть','Приближенная правая часть',1);
title([' \delta=' num2str(delta) ' \delta_A=' num2str(deltaA)])
xlabel('x');ylabel('u(x)')


figure(23);plot(t,a0','k',t,zrd,'.-');%,t,zro,'.-')
set(gca,'FontName',FntNm,'YLim',[-0.05 1.1*max(a0')]);
xlabel('s');ylabel('z(s)');
h7=legend('точное решение','прибл. решение (ОПН)',1);
%set(h7,'Position', [0.635952 0.788984 0.35 0.201095]);
hh=text(0.1,mean(a0),['Отн. ошибкa приближенного решения = ' num2str(erd)]);
set(hh,'FontName',FntNm);

