% Hadamard_1
clear all
close all
% Решение задачи Коши для примера Адамара (аналитическое решение) (с.8)
%
% u"_xx+u"_yy=0, u(0,y)=0, u'_x(0,y)=sin(n*y))/n (0<x<1, 0<y<pi)

disp(' ');
disp('  Вычисление аналитического решения задачи Коши для примера Адамара (с.8):')
%
disp('    u"_xx+u"_yy=0, u(0,y)=0, du/dx(0,y)=sin(n*y))/n (0<x<1, 0<y<pi)');
disp(' ');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n=60;x=1*[0:0.05:1];y=[0:0.005:pi];[X,Y]=meshgrid(x,y);
u=sin(n*Y).*sinh(n*X)/n^2;% u(y,x)
%uu=sign(u).*log(abs(u)+eps);
figure(1);mesh(X,Y,u);xlabel('x');ylabel('y');zlabel('u = sin(ny)\cdot sh(nx)/n^2')
set(gcf,'Position',[232 105 560 573]);
hhhh=title(' Неустойчивость решения в примере Адамара');set(hhhh,'FontName',FntNm);
colormap gray;map=colormap;map1=1-map;colormap(map1)

figure(11);set(gcf,'Position', [232 136 560 542]);
subplot(5,1,1);plot(y,u(:,1));set(gca,'XTickLabel',[],'XLim',[0 pi]);
hhh=title('Пример Адамара. Аналитическое решение u=sin(ny)\cdot sh(nx)/n^2');
set(hhh,'FontName',FntNm);
h7=ylabel('u(x,y) при x=0');set(h7,'FontName',FntNm);
subplot(5,1,2);plot(y,u(:,2));set(gca,'XTickLabel',[],'XLim',[0 pi]);
ylabel(['x=' num2str(x(2))]);
subplot(5,1,3);plot(y,u(:,3));set(gca,'XTickLabel',[],'XLim',[0 pi]);
ylabel(['x=' num2str(x(3))]);
subplot(5,1,4);plot(y,u(:,11));set(gca,'XTickLabel',[],'XLim',[0 pi]);
ylabel(['x=' num2str(x(11))]);
subplot(5,1,5);plot(y,u(:,end));set(gca,'XLim',[0 pi]);
ylabel(['x=' num2str(x(end))]);xlabel('y')
