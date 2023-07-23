%   Pereg_QP 

%  Решение интегрального уравнения 1-го рода на классе функций c монотонной z''(s)
%  (ограниченных снизу числом C_min) (с.176).

if ~exist('fmincon');disp(' ');
  disp('  ВНИМАНИЕ! Демонстрация прерывается, т.к. на этой ЭВМ');
  disp('  не установлен компонент МАТЛАБа - Optimization Toolbox.');return;end

clear all;close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vvv=ver('MATLAB');nmver=str2num(vvv.Version);if nmver>6;
warning('off','MATLAB:dispatcher:InexactMatch');end

disp(' ');disp(' Решение интегрального уравнения Фредгольма 1-го рода');
disp(' на классе функций, ограниченных снизу числом C_min, и c монотонно ');
disp(' не убывающей второй производной. Алгоритм -- ОМК.');
disp(' Сведение к задаче квадратичного программирования (с.176). ');disp(' ');
%   Задание параметров
numm=1;
new_er=0;% Выбрать новую реализацию ошибок данных (new_er=1) или стандартнные (new_er=0)? 
%   Задание уровня ошибок данных
delta=0.01;% правая часть уравнения
deltaA=0.001;% ошибки ядра

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ');
disp(' ');disp('   Уровни относительной ошибки данных');
disp(' ');
disp(['      delta = ' num2str(100*delta) ' %      delta_A = ' num2str(100*deltaA) ' %']);
disp(' ');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ');
pause(1);


[a0,s,h,A,U0,u1,C_min,RU,RA]=mod_prob3(numm);

% U0 -- точная правая часть уравнения, А -- ядро

%% Выбрать новую помеху или стандартную?   
if new_er==1;
   RU=randn(size(U0));RA=randn(size(A));
else if nmver>7;load err_realization_211 RU RA;
    elseif (nmver>5)&(nmver<7);load err_realization_6 RU RA;end
end;

NRA=norm(RA);NRU=norm(RU);
U=U0+delta*norm(U0)*RU/NRU;% Приближенная правая часть уравнения
AA=A+deltaA*norm(A)*RA/NRA;% Приближенная матрица задачи

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n=size(AA,2);T1=tril(ones(n-2));T2=T1*T1*T1;T=[ones(n,1) [0:n-1]' [zeros(2,n-2); T2]];
T(:,3)=-T(:,3);
d=zeros(n,1);d(1)=C_min;
zz1=zeros(n,1);B=[AA*T];
b=U-B*d;;
zz=[];Umon=[];Error_NNLS=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            Метод квадратичного программирования
H=B'*B;f=-B'*b;G=[];g=[];
LB=zeros(n,1);warning off;
tic;w=quadprog(H,f,G,g,[],[],LB,[],zeros(n,1));disp(' ');disp('Time Quadr_Prog:');toc
%w(end)=0;
zzz=T*(w+d);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Error_Quadr_Prog_L2 =norm(zzz-a0')/norm(a0);
Error_Quadr_Prog_C =norm(zzz-a0',inf)/norm(a0,inf);
disp(' ');disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ');disp(' ');
disp('               Ошибки решений (L_2 и С)                          ');
%disp(' ');disp([' Error_NNLS =' num2str(Error_NNLS)]);
disp(' ');
disp([' Error_Quadr_Prog_L2 =' num2str(Error_Quadr_Prog_L2) ' Error_Quadr_Prog_C  =' num2str(Error_Quadr_Prog_C )]);
disp(' ');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ');disp(' ');
UV=U;UV(1)=2*U(1);UV(end)=2*U(end);
figure(2);plot(s,u1,'r.-',s,UV,'b.');set(gca,'FontName',FntNm);
legend('Точная правая часть','Приближенная правая часть',1);
title([' \delta=' num2str(delta) ' \delta_A=' num2str(deltaA)])
xlabel('x');ylabel('u(x)')

figure(1);plot(s,a0,'r.-',s,zzz,'k.-');set(gca,'FontName',FntNm);
legend('Точное решение','Квазиньютоновский метод',1);
title(['Решение на классе монотонно не возрастающих функций; \delta=' num2str(delta) ' \delta_A=' num2str(deltaA)])
xlabel('s');ylabel('z(s)')
