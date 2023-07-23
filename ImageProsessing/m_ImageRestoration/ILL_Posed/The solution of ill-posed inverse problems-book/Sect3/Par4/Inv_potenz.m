%  Inv_potenz
%      Решение обратной задачи гравиметрии -- нелинейного операторного уравнения.
%      Условная (при z>=0) или безусловная минимизация тихоновского функционала
%      после выбора параметра alf_opn.

if ~exist('fmincon');disp(' ');
  disp('  ВНИМАНИЕ! Демонстрация прерывается, т.к. на этой ЭВМ');
  disp('  не установлен компонент МАТЛАБа - Optimization Toolbox.');return;end

clear all
close all

vvv=ver('MATLAB');nmver=str2num(vvv.Version);if nmver>6;
warning('off','MATLAB:dispatcher:InexactMatch');end

disp(' ');
disp(' Решение обратной задачи гравиметрии -- нелинейного операторного уравнения.');
disp('      Будет проделано следующее:');
disp('  1) Выбор параметра по ОПН с помощью предвычисленных вспомогательных функций');
disp('  2) Условная минимизация тихоновского функционала при условии (z(s)>H)')

disp(' ');
disp('-----------------------------------------------------------------------------');
disp(' ');
disp('      Реализация:');disp('  Выбор параметра регуляризации по ОПН');
graf_choi;pause(1)  % Здесь вводятся данные задачи и находится параметр alf_opn

rho=1;H=2;% Параметры
n=51;m=2*n+1;
t=linspace(-2,2,n);x=linspace(-3,3,m);h=t(2)-t(1);% Сетки
D=abs(t)<1;
z=zeros(size(t));z(D)=((1-t(D).^2).^2);%U=zeros(m,1);
C=ones(size(z));C(1)=0.5;C(end)=0.5;

delta=0.01;%Рассматриваемые уровни ошибки
z0=zeros(size(t'));D=abs(t')<1;z0(D)=(1-t(D).^2)';% Начальное приближение
z1=zeros(size(t'));Z1=z0;

warning off
disp(' ');disp(' Вычисление экстремали тихоновского функционала для выбранного параметра.');
disp('  Потребуется время для вычислений! ');
disp('  Счет до 30 итераций.');disp(' ');
options=optimset('Display','iter','MaxIter',30,'TolFun',1e-9,'TolX',1e-9,'TolCon',1e-9);%,'GradObj','on');
%'off'  'iter'  ,'MaxFunEvals',1000
Nq=1;

for k=1:Nq;tic;
%  Параметр регуляризации
alfa=alf_opn;
%  Можно не использовать ограничения неотрицательности. См. следующую строку.
%[Z1,FF]=fminunc('invpot3',z0,options,x,t,H,rho,h,U1,n,m,alfa,z1);
%
[Z1]=...
   fmincon('invpot3',z0,[],[],[],[],zeros(size(z0)),[],[],options,x,t,H,rho,h,U1,n,m,alfa,z1);
[F1]=invpot(Z1,x,t,H,rho,h,U1,n,m);

ff=(F1);er=norm(Z1'-z)/norm(z);gam=norm(Z1)*sqrt(h);
gam1=(norm(Z1)*sqrt(h)+norm(diff(Z1)/sqrt(h)));

disp(' ');toc

disp('-----------------------------------------------------------------------------');
disp(' ');
disp('             Резюме:');disp(' ');
disp(['     delta = ' num2str(delta)]);disp(['     alfa = ' num2str(alfa)]);
disp(['     Относительная невязка уравнения на найденном решении = ' num2str(ff)]);
disp(['     Нормы приближеного решения (L_2, W_2^1)  = ' num2str(gam) '  ' num2str(gam1)]);
disp(['     Относительная ошибка приближеного решения (2-норма)  = ' num2str(er)]);
disp(' ');
figure(k);subplot(2,1,2);plot(t,z,t',Z1,'r.-',x,zeros(size(x)),'k');
title('z(x), z_{\delta}(x)');
text(x(3),0.8,['\alpha = ' num2str(alfa) '  Error = ' num2str(er)]);
legend('z(x)','z_{\delta}(x)',['H=' num2str(-H)],1)
subplot(2,1,1);plot(x',U,x',U1,'r');%set(gca,'YLim',[0.03 0.04]);
text(0,0.3,['\delta = ' num2str(delta)]);
title('u(x), u_{\delta}(x)');
legend('u(x)','u_{\delta}(x)',4);
set(gcf,'Name','Данные и решения','NumberTitle','off')
drawnow
end

disp(' ');
[F]=invpot(z',x,t,H,rho,h,U,n,m);
disp(['     Относительная невязка уравнения на точном решении = ' num2str(F)]);
disp(' ');disp('         Конец');

