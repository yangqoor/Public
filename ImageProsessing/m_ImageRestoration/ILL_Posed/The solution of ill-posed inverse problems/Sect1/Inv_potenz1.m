%  Inv_potenz1
%      Решение обратной задачи гравиметрии (с.30)
%      Метод -- безусловная минимизация невязки нелинейного операторного уравнения
%      с помощью fminunc.
clear all
close all

if ~exist('fminsearch');
  disp('   Optimization toolbox для МАТЛАБа не установлен на данном компьютере. ');
     disp('   Демонстрация прерывается.');return;end

disp(' ');
disp(' Решение обратной задачи гравиметрии (с.30).');
disp(' Метод -- безусловная минимизация невязки нелинейного операторного уравнения');
disp(' с помощью fminunc. Начальное приближение - нулевое.');
disp(' ');
rho=1;H=10;% Параметры
n=51;m=2*n+1;
t=linspace(-1,1,n);x=linspace(-2,2,m);h=t(2)-t(1);% Сетки
z=(1-t.^2).^2;U=zeros(m,1);
C=ones(size(z));C(1)=0.5;C(end)=0.5;
% Точная правая часть уравнения
for ii=1:m;S=0;for jj=1:n;
      S=S+C(jj)*h*log(((x(ii)-t(jj)).^2+H^2)./((x(ii)-t(jj)).^2+(H-z(jj)).^2));end
   U(ii)=S*rho/2/pi;
   end
%dd=0.001;
dd=[0 0.001 0.01];% Рассматриваемые уровни ошибки
z0=0*(1-t.^2)';% Начальное приближение

% Решение уравнения для разных delta
warning off
disp(' ');disp('  Потребуется некоторое время для вычислений! ');disp(' ');

options=optimset('Display','iter','MaxIter',15,'TolFun',1e-9);%'iter'  'off'

for k=1:length(dd);%if k==1;st='r';elseif k==2;st='m';elseif k==3;st='g';else st='k';end
   delta=dd(k);
   disp('--------------------------------------------------------------------------');
   disp(['    Решение обратной задачи для delta = ' num2str(delta)]);
   disp('     Нажмите любую клавишу!');disp(' ');pause
   
   disp(' ');disp('  15 итераций');disp(' ');
tic;RN=randn(size(U));
U1=U+delta*norm(U)*RN/norm(RN);

[Z1,FF]=fminunc('invpot2',z0,options,x,t,H,rho,h,U1,n,m);%search

ff=(FF);er=norm(Z1'-z)/norm(z);disp(' ');toc
disp(['     delta = ' num2str(delta)]);
disp(['     Относительная невязка уравнения на найденном решении = ' num2str(ff)]);
disp(['     Относительная ошибка приближеного решения (2-норма)  = ' num2str(er)]);
disp(' ');
figure(k);subplot(2,1,2);plot(t,z,t',Z1,'r',x,zeros(size(x)),'k');
title('z(x), z_{\delta}(x)');
legend('z(x)','z_{\delta}(x)',['H=' num2str(-H)],1)
subplot(2,1,1);plot(x',U,x',U1,'r');set(gca,'YLim',[0.03 0.04]);
text(0,0.034,['\delta = ' num2str(delta)]);
title('u(x), u_{\delta}(x)');
legend('u(x)','u_{\delta}(x)',4);drawnow
end

disp(' ');
[F]=invpot2(z',x,t,H,rho,h,U,n,m);
disp(['     Относительная невязка уравнения на точном решении = ' num2str(F)]);
disp(' ');
disp(' Вывод: точное решение и найденное "приближенное" решение');
disp(' удовлетворяют с заданной точностью delta интегральному уравнению,');
disp(' хотя и значительно отличаются. Задача численно неустойчива.');
disp('--------------------------------------------------------------------------');
disp(' ');