% Hadamard_finit
%
%  Решение задачи Коши из примера Адамара обычными методами и их 
%                  неустойчивость (с.41 -- 44).
clear all
close all

% Решение задачи Коши для примера Адамара (c.8):
%
% u"_xx+u"_yy=0,  u(x,0)=u(x,1)=0,
% u(0,y)=0, u'_x(0,y)=sin(n*y))/n,  (0<x<1, 0<y<pi)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ');
disp('------------------------------------------------------------------');
disp(' ');
disp(' Демонстрация решения задачи Коши из примера Адамара (c.8) обычными методами.');
disp(' ');
disp('------------------------------------------------------------------');
disp('    1) Аналитическое решение');disp('    Нажмите любую клавишу! ');pause

n=60;x=1*[0:0.05:1];y=[0:0.005:pi];[X,Y]=meshgrid(x,y);
u=sin(n*Y).*sinh(n*X)/n^2;% u(y,x)
%
figure(1);mesh(X,Y,u);xlabel('x');ylabel('y')
hhhh=title(' Неустойчивость решения');set(hhhh,'FontName',FntNm);
colormap gray;map=colormap;map1=1-map;colormap(map1)

figure(11);set(gcf,'Position', [232 136 560 542]);
subplot(5,1,1);plot(y,u(:,1));set(gca,'XTickLabel',[],'XLim',[0 pi]);
hhh=title('Пример Адамара. Аналитическое решение u=sin(ny)\cdot sh(nx)/n^2');
set(hhh,'FontName',FntNm);
ylabel('x=0');
subplot(5,1,2);plot(y,u(:,2));set(gca,'XTickLabel',[],'XLim',[0 pi]);
ylabel(['x=' num2str(x(2))]);
subplot(5,1,3);plot(y,u(:,3));set(gca,'XTickLabel',[],'XLim',[0 pi]);
ylabel(['x=' num2str(x(3))]);
subplot(5,1,4);plot(y,u(:,11));set(gca,'XTickLabel',[],'XLim',[0 pi]);
ylabel(['x=' num2str(x(11))]);
subplot(5,1,5);plot(y,u(:,end));set(gca,'XLim',[0 pi]);
ylabel(['x=' num2str(x(end))]);xlabel('y')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Решение задачи Коши для примера Адамара методом эволюционной задачи
%  u"_xx+u"_yy=0,  u_y(0,y)=0, u'(0,y)=sin(n*y))/n^2,  (0<x<1, 0<y<pi)
%  u"_xx=-u"_yy => [u_{k}]'_x=v_{k}, [v_{k}]'_x=-(u_{k+1}-2*u_{k}+u{k-1})/h^2
%                  u_{k}(0)=0, v_{k}(0)=sin(n*y(k)))/n^2, u_{1}=u{end}=0
%
% Матрица для системы ОДУ
%  (u) (0  I) (u)
% D( )=(    )*( )    U=(u v)^T
%  (v) (-B 0) (v)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('------------------------------------------------------------------');
disp(' ');disp('    2) Решение методом эволюционной уравнения (с.42).');
disp('    Нажмите любую клавишу! ');pause
N=150;
y=1*linspace(0,pi,N)';m=length(y);h=y(2)-y(1);
B=-2*diag(ones(m,1))+diag(ones(m-1,1),1)+diag(ones(m-1,1),-1);
A=[zeros(m) eye(m);-B/h^2 zeros(m)];%A(1,m+1)=0;A(m,2*m)=0;
x=[0:0.1:1];U0=[zeros(m,1);sin(n*y)/n^2];
disp(' ')
disp('         Mетод эволюционной задачи')
tic;[x1,U]=ode45('a_matr1',x,U0');toc

[X,Y]=meshgrid(x,y);
figure(2);mesh(X,Y,U(:,1:m)');colormap gray
set(gca,'FontName',FntNm);
xlabel('x');ylabel('y');title('Численное решение задачи Коши')

um=max(abs(U'));M=max(2,um(1));
figure(3);subplot(4,1,1);plot(y,U0(1:m));
set(gca,'XTickLabel',[],'YLim',[-M M],'XLim',[0 pi]);%(1,1:m)
hhh=title('Mетод эволюционной задачи. Решение для разных x');set(hhh,'FontName',FntNm);
ylabel('x=0');
subplot(4,1,2);plot(y,U(4,1:m));set(gca,'XTickLabel',[],'XLim',[0 pi]);
ylabel(['x=' num2str(x(4))]);
subplot(4,1,3);plot(y,U(8,1:m));set(gca,'XTickLabel',[],'XLim',[0 pi]);
ylabel(['x=' num2str(x(8))]);
subplot(4,1,4);plot(y,U(end,1:m));set(gca,'XLim',[0 pi]);
ylabel(['x=' num2str(x(end))]);xlabel('y')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Решение методом матричной экспоненты
%
% DU=A*U => U(t)=U0*exp(A*t) 
%
disp('------------------------------------------------------------------');
disp(' ');
disp('    3) Решение методом матричной экспоненты - в некоторых версиях MATLAB работает медленно.');
disp('    Нажмите любую клавишу! ');pause

t0=[0 0.3 0.7 1];nt=length(t0);figure(4);
disp(' ')
disp('Mетод матричной экспоненты');disp(' ')
tic;for k=1:nt;t=t0(k);
   Ut=expm(A*t)*U0;
   figure(4);subplot(nt,1,k);plot(y,Ut(1:m),'.-');if k~=nt;
      set(gca,'XTickLabel',[],'XLim',[0 pi]);else set(gca,'XLim',[0 pi]);end
ylabel(['x=' num2str(t)]);
if k==1;hhh=title('Решение методом матричной экспоненты');
   set(hhh,'FontName',FntNm);end
end
toc
xlabel('y')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Решение итерационным методом (неявная схема)
%
% DU=A*U => U(x+h)=U(x)+hx*A*U(x+h) => (I-hx*A)*U(x+h)=U(x)
NN=100;
hx=1/NN;UU=zeros(2*m,NN+1);UU(:,1)=[zeros(m,1);sin(n*y)/n^2];
disp('------------------------------------------------------------------');
disp(' ');disp('   4) Решение итерационным методом (неявная схема)')
disp('    Нажмите любую клавишу! ');pause
disp(' ');disp('Итерационый метод ');disp(' ')
xxx=zeros(1,NN+1);
tic
for k=2:NN+1;C=eye(size(A))-hx*A;UU(:,k)=inv(C)*UU(:,k-1);xxx(k)=xxx(k-1)+hx;
end
toc
figure(5);
subplot(4,1,1);plot(y,UU(1:m,1));set(gca,'XTickLabel',[],'YLim',[-M M],'XLim',[0 pi]);
hhh=title('   Решение итерационным методом (неявная схема)');set(hhh,'FontName',FntNm);
ylabel('x=0');
subplot(4,1,2);plot(y,UU(1:m,31));set(gca,'XTickLabel',[],'XLim',[0 pi]);
ylabel(['x=' num2str(xxx(31))]);
subplot(4,1,3);plot(y,UU(1:m,71));set(gca,'XTickLabel',[],'XLim',[0 pi]);
ylabel(['x=' num2str(xxx(71))]);
subplot(4,1,4);plot(y,UU(1:m,end));set(gca,'XLim',[0 pi]);
ylabel(['x=' num2str(xxx(end))]);xlabel('y')
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Решение методом интегральных уравнений
% Эквивалентное интегральное ур-ние 1-го рода
%
% u"_xx+u"_yy=0,   u(x,0)=u(x,1)=0,
% u(0,y)=0, u'_x(0,y)=sin(n*y))/n^2=u_n(y),  (0<x<1, 0<y<pi)
%
%  a=pi, b=1
% G(y,y1,H)=sum_{n=1}^{\inf}n sin(ny)sin(n y1)[sh(nx)]^(-1)
% g(y)=pi*u_n(y)/2

% g(y)=int_0^pi{G(y,y1)u(H,y1)dy1},  (0<y<pi)

[Y,Y1]=meshgrid(y,y);UU1=zeros(length(y),length(x));g=sin(n*y)/n^2;
n_end=40;nn=[1:n_end];[YY,YY1,NN]=ndgrid(y,y,nn);
SS=NN.*sin(NN.*YY).*sin(NN.*YY1);UU1=zeros(length(y),length(x));
disp('------------------------------------------------------------------');
disp(' ');disp('   5) Решение методом интегральных уравнений');
disp('    Нажмите любую клавишу! ');pause
disp(' ')
disp('Решение интегрального уравнения')
disp(' ')

tic
for k=2:11;H=x(k);
   SSH=SS./sinh(NN.*H);G=2*sum(SSH,3)/pi;
   UU1(:,k)=inv(G+eps*eye(size(G)))*g;   
end
toc
figure(6);
subplot(4,1,1);plot(y,UU1(1:m,1));set(gca,'XTickLabel',[],'XLim',[0 pi]);
hhh=title('Решение методом интегральных уравнений');set(hhh,'FontName',FntNm);
ylabel('x=0');
subplot(4,1,2);plot(y,UU1(1:m,4));set(gca,'XTickLabel',[],'XLim',[0 pi]);
ylabel(['x=' num2str(x(4))]);
subplot(4,1,3);plot(y,UU1(1:m,8));set(gca,'XTickLabel',[],'XLim',[0 pi]);
ylabel(['x=' num2str(x(8))]);
subplot(4,1,4);plot(y,UU1(1:m,end));set(gca,'XLim',[0 pi]);
ylabel(['x=' num2str(x(end))]);xlabel('x')
%
disp('------------------------------------------------------------------');
disp(' ');
rr=input(' Показать график ядра G(y,y1;x) интегрального уравнения для x = 1 ? (y/n) ','s');
if strcmp(rr,'y');figure(33);mesh(G);else end

disp('-------------------------- Конец ---------------------------------');


