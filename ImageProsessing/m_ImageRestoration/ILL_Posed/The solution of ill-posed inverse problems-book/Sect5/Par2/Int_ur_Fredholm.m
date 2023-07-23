% Int_ur_Fredholm

%  Решение интегральных уравнений Фредгольма 1 рода методом
%  псевдообращения матрицы дискретизированной задачи -- неустойчивый метод. 
%  Анализ типа некоректности для рассматриваемых интегральных уравнений Фредгольма 1 рода.
%  (см. с.248)
clear all
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(' ');disp(' ');disp(' ')
delta=0.001; %- Среднеквадратичная относ. ошибка данных (0.1%)

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp(' ')
disp('   Решение интегральных уравнений Фредгольма 1 рода на сетке размера = 125');
disp('   методом псевдообращения матрицы дискретизированной задачи (см. с.248).')
disp(['    Относительная погрешность ядра и правой части уравнения = ' num2str(100*delta) ' %'])
disp(' ')
disp(' Нажмите любую клавишу ');pause
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp(' ')

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp(' ')
disp('    1) Уравнение Фредгольма 1 рода с ядром K(x,t)=1/(1+(x-t)^2)')
disp(' ')

%    Алгоритм обращения матрицы 
NN=2;
t=linspace(-1,1,125);x=t;n=length(t);h=t(2)-t(1);[XX,TT]=meshgrid(x,t);
z=(1-t.^2).^2';A=h./(1+(XX-TT).^2);u=A*z;
tt=linspace(-2,2,125);;k1=1./(1+tt.^2);

disp(' ');disp('   Для просмотра данных задачи нажмите любую клавишу!');
disp(' ');pause
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');


figure(20);subplot(2,2,1);plot(t,z,'.-');set(gca,'FontName',FntNm);
title('Точное решение');subplot(2,2,2);plot(tt,k1,'.-');set(gca,'FontName',FntNm);
title('Ядро');subplot(2,2,3);plot(t,u,'.-');set(gca,'FontName',FntNm);
title('Правая часть');
set(gcf,'Name','Данные задачи','NumberTitle','off')

RN1=randn(n,1);ud1=u+delta*RN1/norm(RN1);
RK1=tril(randn(size(A)));AA=A+delta*RK1/norm(RK1);

disp(' ');disp('   Для вычисления нормального псевдорешения нажмите любую клавишу!');
disp(' ');pause
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%');

%  Вычисление нормального псевдорешения
IAA=pinv(AA);IA=pinv(A);
zz=IA*u;zzap=IAA*ud1;
figure(2); subplot(2,1,1);
plot(t,z,t(1:NN:end),zz(1:NN:end),'r. ');
set(gca,'FontName',FntNm); 
title ( 'Решение интегрального уравнения с точными данными' ) ;
legend (' Точное решение ',' Вычисленное решение' , 2) ; 
subplot (2,1,2);
plot (t, zzap, 'r.-',t,z, 'k-')
set(gca,'FontName',FntNm);
legend (' Приближенное решение ' ,' Точное решение ' , 2 ) ;
title ( 'Решение интегрального уравнения с приближенными данными' );
set(gcf,'Name','Уравнение 1','NumberTitle','off')

S=svd(AA);s1=S/max(S);
%figure(11);plot(s1,'.-');hold on;set(gca,'FontName',FntNm);
%title('Сингулярные числа матриц задач')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp(' ')
disp('    2) Интегральное уравнение с ядром K(x,t)=(x-t)^2*exp(-(x-t)^2)');
disp(' ')

t=linspace(0,1,125);x=t;n=length(t);h=t(2)-t(1);z=(t.^2/2)'; % Точные данные
[XX,TT]=meshgrid(x,t);K=((XX-TT).^2).*exp(-(XX-TT).^2)*h;
tt=linspace(0,2,125);;k1=(tt.^2).*exp(-tt.^2);
u=K*z;

disp(' ');disp('   Для просмотра данных задачи нажмите любую клавишу!');
disp(' ');pause
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');


figure(20);subplot(2,2,1);plot(t,z,'.-');set(gca,'FontName',FntNm);
title('Точное решение');subplot(2,2,2);plot(tt,k1,'.-');set(gca,'FontName',FntNm);
title('Ядро');subplot(2,2,3);plot(t,u,'.-');set(gca,'FontName',FntNm);
title('Правая часть');
set(gcf,'Name','Данные задачи','NumberTitle','off')

disp(' ');disp('   Для вычисления нормального псевдорешения нажмите любую клавишу!');
disp(' ');pause
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%');

RN=randn(n,1);ud=u+delta*RN/norm(RN);
RK=(randn(size(K)));KK=K+delta*RK/norm(RK);
IK=pinv(K);IKK=pinv(KK);zt=IK*u;zd=IKK*ud;
NN=2;
figure(4); subplot(2,1,1);
plot(t,z,t(1:NN:end),zt(1:NN:end), 'r. ');set(gca,'FontName',FntNm); 
title ( 'Решение уравнения \int_{0}^{1}(x-t)*exp(-(x-t)^2)z(t)dt=u(x) с точными данными' ) ;
legend (' Точное решение ',' Вычисленное решение' , 2) ; 
subplot (2,1,2);
plot (t,zd, 'r.-',t,z, 'k-');set(gca,'FontName',FntNm);
legend (' Приближенное решение ' ,' Точное решение ' , 2 ) ;
title ( 'Решение интегрального уравнения с приближенными данными' );
set(gcf,'Name','Уравнение 2','NumberTitle','off')

disp(' ');disp('    Для сравнение сингулярных чисел задач 1) - 2) нажмите любую клавишу!');
disp(' ');pause
disp('%%%%%%%%%%%%%%%%%%%%%%%');


SK=svd(K);sk=SK/max(SK);

figure(11);semilogy(1:length(S),s1,'.-');hold on;semilogy(1:length(SK),sk,'.-r');
hold off
set(gca,'FontName',FntNm);
title('Логарифм сингулярных чисел матриц для задач \int_{0}^{1}K(x,t)z(t)dt=u(x)')
legend ('Ядро K(x,t)=1/(1+(x-t)^2)' ,'Ядро K(x,t)=(x-t)^2*exp(-(x-t)^2)' ,1) ;
set(gcf,'Name','Сравнение сингулярных чисел задач','NumberTitle','off')

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp(' ')
disp('    3) Интегральное уравнение с ядром K(x,t)=exp(-(x-t)^2)');
disp(' ')

t=linspace(-1,1,125);x=t;n=length(t);h=t(2)-t(1);[XX,TT]=meshgrid(x,t);
z=(1-t.^2).^2';
K1=exp(-(XX-TT).^2)*h;

disp(' ');disp('   Для просмотра данных задачи нажмите любую клавишу!');
disp(' ');
pause
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

u=K1*z;
tt=linspace(-2,2,125);;k1=exp(-tt.^2);
figure(20);subplot(2,2,1);plot(t,z,'.-');set(gca,'FontName',FntNm);
title('Точное решение');subplot(2,2,2);plot(tt,k1,'.-');set(gca,'FontName',FntNm);
title('Ядро');subplot(2,2,3);plot(t,u,'.-');set(gca,'FontName',FntNm);
title('Правая часть');
set(gcf,'Name','Данные задачи','NumberTitle','off')

disp(' ');disp('   Для вычисления нормального псевдорешения нажмите любую клавишу!');
disp(' ');pause
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%');

RN1=randn(n,1);ud1=u+delta*RN1/norm(RN1);
RK1=(randn(size(K1)));KK1=K1+delta*RK1/norm(RK1);
IK1=pinv(K1);IKK1=pinv(KK1);zt1=IK1*u;zd1=IKK1*ud1;
NN=2;
figure(5); subplot(2,1,1);
plot(t,z,t(1:NN:end),zt1(1:NN:end), 'r. ');set(gca,'FontName',FntNm); 
title ( 'Решение уравнения \int_{-1}^{1}exp(-(x-t)^2)z(t)dt=u(x) с точными данными' ) ;
legend (' Точное решение ',' Вычисленное решение' , 2) ; 
subplot (2,1,2);
plot (t,zd1, 'r.-',t,z, 'k-');set(gca,'FontName',FntNm);
legend (' Приближенное решение ' ,' Точное решение ' , 2 ) ;
title ( 'Решение интегрального уравнения с приближенными данными' );
set(gcf,'Name','Уравнение 3','NumberTitle','off')

disp(' ');disp('    Для сравнение сингулярных чисел задач 1) - 3) нажмите любую клавишу!');
disp(' ');pause
disp('%%%%%%%%%%%%%%%%%%%%%%%');

SK1=svd(K1);sk1=SK1/max(SK1);
tol=max(size(K1))*norm(K1)*eps;
figure(11);semilogy(1:length(S),s1,'.-');hold on;semilogy(1:length(SK),sk,'.-r');
semilogy(1:length(SK1),sk1,'.-k');semilogy(1:length(SK1),tol*ones(size(SK1)),'c');
hold off
set(gca,'FontName',FntNm);
title('Логарифм сингулярных чисел матриц для задач \int_{a}^{b}K(x,t)z(t)dt=u(x)')
legend ('Ядро K(x,t)=1/(1+(x-t)^2' ,...
   'Ядро K(x,t)=(x-t)^2*exp(-(x-t)^2)','Ядро K(x,t)=exp(-(x-t)^2)' ,1) ;
set(gcf,'Name','Сравнение сингулярных чисел задач','NumberTitle','off')
disp(' ');
disp('    Голубым показан уровень "обрезания" сингулярных чисел в модуле МАТЛАБа pinv.');
disp('    Из-за такой "регуляризации" результаты для 2-й и 3-й задач "лучше", чем для 1-й.');
disp(' ');
disp('%%%%%%%%%%%%%%%%%% Конец %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')


