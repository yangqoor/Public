%   V_quasisol

% Метод квазирешений на классе V[0,1] с условием неотрицательности (c.147)
clear all
close all

if ~exist('fmincon');disp(' ');
  disp('  ВНИМАНИЕ! Демонстрация прерывается, т.к. на этой ЭВМ');
  disp('  не установлен компонент МАТЛАБа - Optimization Toolbox.');return;end


disp(' ');disp(' Непосредственная реализация метода квазирешений')
disp(' на классе V[0,1] с условием неотрицательности (c.147).');disp(' ');
disp(' Решается интегральное уравнение Фредгольма 1-го рода с ядром Пуассона');
disp(' Приближенное решение z_eta находится из экстремальной задачи:');
disp('   z_eta = Arginf{||A_h z-u_delta||: V_0^1[z]<=1.3, z>=0}');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vvv=ver('MATLAB');nmver=str2num(vvv.Version);if nmver>6;
warning('off','MATLAB:dispatcher:InexactMatch');end

n=60;h=1/(n-1);x=[0:h:1];[xs,ys]=meshgrid(x,x);

A=h./(1+100*(xs-ys).^2);% Модельное ядро
A(:,1)=0.5*A(:,1);A(:,n)=0.5*A(:,n);

z0=x.^2;% Модельное решение
   b1=1/100+1/100*x.*log(101+100*x.^2-200*x)+1/1000*atan(10*x-10)- ...
      1/10*atan(10*x-10).*x.^2-1/100*x.*log(1+100*x.^2)- ...
      1/1000*atan(10*x)+1/10*atan(10*x).*x.^2;% Точная правая часть
    
del=0.01;delta_A=0;% Возмущение данных
%disp(['    Относительная ошибка правой части delta = ' num2str(del)]);
disp(' ');
rn=randn(size(b1));nrn=norm(rn);b=b1+del*norm(b1)*rn/nrn;

m=n;m=2*n; % Монотонные функции: m=n
c=1.3;% Априорная оценка вариации
d=1.1;% Априорная оценка решения сверху

T=tril(ones(n));
B=[A*T -A*T ];% Преобразование матрицы: для монотонных функций: [A*T];
z1=zeros(m,1);% Начальное приближение

%    Метод квазирешений
%clear options;options(14)=30;options(1)=1;tic
%z1=constr('fun3',z1,options,zeros(m,1),d*ones(m,1),'grfun3',B,b',c);toc
warning off;h00 = waitbar(0,'Wait a minute!');waitbar(1,h00)
options=optimset('Display','off','GradObj','on','GradConstr','on',...
  'MaxIter',50,'Diagnostics','off');% 'Display','iter',
tic;z1=fmincon('fun4',z1,[],[],[],[],zeros(m,1),d*ones(m,1),'grfun4',options,B,b',c);toc
close(h00)

zz=T*(z1(1:n)-z1(n+1:2*n));% Обратное преобразование; для монотонных функций: T*z1(1:n) ;

figure(1);plot(x,z0,x,zz,'r.');
set(gca,'FontName',FntNm);
title('Метод квазирешений на классе функции ограниченной вариации');
xlabel('x');ylabel('Решение');legend('Точное решение','Приближение',2)
Discrep=norm(B*z1-b')/norm(b);
error=norm(z0-zz')/norm(z0);
var=zz(1)+sum(abs(diff(zz)));
disp(' ');disp('     Данные и результаты.');
disp(' ');
disp([' Вариация точного решения = ' num2str(1.0)]);
disp([' Априорная оценка вариации = ' num2str(c)]);
disp([' Относительная ошибка данных = ' num2str(del)]);
disp([' Невязка приближенного решения = ' num2str(Discrep)]);
disp([' Относительная ошибка решения (в L_2)= ' num2str(error)]);
disp([' Вариация приближенного решения = ' num2str(var)]);
disp(' ');


