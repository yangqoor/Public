%  Heat_design_Tikh

%  Решение нелинейного интегрального уравнения проектирования нагревателя
%  для gam=1/2 - для нагрева изделия до 1000 K^o
clear all
close all

if ~exist('fmincon');disp(' ');
  disp('  ВНИМАНИЕ! Демонстрация прерывается, т.к. на этой ЭВМ');
  disp('  не установлен компонент МАТЛАБа - Optimization Toolbox.');return;end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

gam=1/2;C=2.5;
disp(' ');disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ');disp(' ');
disp('  Решение нелинейного интегрального уравнения проектирования ');
disp(['  нагревателя с gamma= ' num2str(gam) ' методом регуляризации ']);
disp('  А.Н.Тихонова с различными параметрами регуляризации  (гл.5, \S2, п.2).');
disp('  Интерактивный выбор параметра на основе компромисса между невязкой')
disp('  операторного уравнения и регуляризующим функционалом качества системы.')

disp(' ');disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ');
disp(' ');
disp('---------------------------------------------------------------------------------');
disp(' ');disp('   1. Просмотр геометрии простейшей системы "нагреватель - изделие" ');
          disp('         Нажмите любую клавишу!');pause
heat_desgn;
%open Heat_design.fig;
set(gcf,'Name','Геометрия системы','NumberTitle','off');pause(3)
set(gcf,'Visible','off');
disp(' ');
disp('---------------------------------------------------------------------------------');
disp(' ');
disp(' 2. Перебор параметров alpha в методе регуляризации. ');
disp('        Нажмите любую клавишу!');pause
disp(' ');
disp('---------------------------------------------------------------------------------');
disp(' ');
%set(gcf,'Visible','on');pause(1)

[T_ep,lam_ep,ep,ep1,Tsig,esig,B]=inp_data;

N=8;M=3;
% Решение на грубой сетке - "зонный излучатель"
x=linspace(0,1,2*N);y=x;h=x(2)-x(1);[X,Y]=meshgrid(x,y);


% Сеточные данные задачи
K=0.5*h*gam^2./((X-Y).^2+gam^2).^(3/2);
fi=(1./2.*(-(x.^2+gam.^2).^(1./2).*x+(x.^2+gam.^2).^(1./2)+...
   x.*(x.^2-2.*x+gam.^2+1).^(1./2))./(x.^2-2.*x+gam.^2+1).^(1./2)./(x.^2+gam.^2).^(1./2))';

% Решение без ограничений на излучаемую энергию. Только ограничения на температуру.

options=optimset('Display','off','MaxIter',50,'GradObj','off','LargeScale','off',...
   'LineSearchType','quadcubic','TolFun',1e-12,'TolCon',1e-12,'MaxFunEvals',4000000,...
   'TolX',1e-12);% 'iter'  'off'
T0=ones(N,1);alf=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vvv=ver('MATLAB');nmver=str2num(vvv.Version);if nmver>6;
warning('off','MATLAB:dispatcher:InexactMatch');
else warning off;end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ALF=[];DIS=[];OMEGA=[];
for kk=1:8;alf=alf*0.1;
[T,nev_min]=fminunc('tikh_heatdesgn',T0,options,K,B,fi,Tsig,esig,T_ep,alf);
[F]=nev_hd(T,K,B,fi,Tsig,esig,T_ep);
F0=norm(F-1)/norm(ones(2*length(T),1));
disp(['  alpha=' num2str(alf)]);disp(' ');
disp(['  Невязка = ' num2str(F0)]);
[Om,gom]=omega_hd(T,K,B,fi,Tsig,esig,T_ep,C);
disp(' ');disp(['  Функционал OMEGA = ' num2str(Om+C)]);

ALF=[ALF alf];DIS=[DIS F0];OMEGA=[OMEGA Om];
figure(3);subplot(2,1,1);stairs(x-h/2,[T;flipud(T)]);
hold on;plot([x(end)-h/2 x(end)],[T(1) T(1)],'b');hold off
set(gca,'FontName',FntNm,'YLim',[0 3],'XLim',[0 1]);ylabel('T^oK/1000');
text(0.5,2.5,['\gamma=' num2str(gam) '    \alpha=' num2str(alf)]);
title('Решение - температура зон');

subplot(2,1,2);plot(x,F,'.-',x,[T0;T0],'r');set(gca,'FontName',FntNm,'YLim',[0 1.1]);
ylabel('T^oK/1000');
title('Температура на поверхности изделия');legend('Создаваемая','Требуемая',4);
set(gcf,'Name','Тихоновская регуляризация задачи','NumberTitle','off')
disp(' ');
disp('---------------------------------------------------------------------------------');
disp(' ');
disp('   Для дальнейших вычислений нажмите любую клавишу и подождите!');
disp(' ');pause;
end

figure(4);subplot(2,2,1);plot(log10(ALF),DIS,'.-');
set(gca,'FontName',FntNm);L1=get(gca,'YLim');
title('Невязка уравнения');xlabel('log_{10}\alpha');
subplot(2,2,3);plot(log10(ALF),OMEGA+C,'.-');
set(gca,'FontName',FntNm);L2=get(gca,'YLim');
title('\Omega[T]');xlabel('log_{10}\alpha');
set(gcf,'Name','Невязка и OMEGA как функции от alpha','NumberTitle','off')
disp(' ');
disp('---------------------------------------------------------------------------------');
disp(' ');
disp('     Выберите параметр alpha мышью на графиках!');
disp(' ');pause;
[alf1,nbv]=ginput(1);alf=10^(alf1);

figure(4);subplot(2,2,1);plot(log10(ALF),DIS,'.-',[alf1 alf1],L1,'r');
set(gca,'FontName',FntNm);
title('Невязка уравнения');xlabel('log_{10}\alpha');
subplot(2,2,3);plot(log10(ALF),OMEGA+C,'.-',[alf1 alf1],L2,'r');
set(gca,'FontName',FntNm);
title('\Omega[T]');xlabel('log_{10}\alpha');
set(gcf,'Name','Невязка и OMEGA как функции от alpha','NumberTitle','off')

[T,nev_min]=fminunc('tikh_heatdesgn',T0,options,K,B,fi,Tsig,esig,T_ep,alf);
[F]=nev_hd(T,K,B,fi,Tsig,esig,T_ep);
F0=norm(F-1)/norm(ones(2*length(T),1));
disp(['  alpha=' num2str(alf)]);disp(' ');
disp(['  Невязка = ' num2str(F0)]);
[Om,gom]=omega_hd(T,K,B,fi,Tsig,esig,T_ep,C);
disp(' ');disp(['  Функционал OMEGA = ' num2str(Om+C)]);

figure(33);subplot(2,1,1);stairs(x-h/2,[T;flipud(T)]);
hold on;plot([x(end)-h/2 x(end)],[T(1) T(1)],'b');hold off
set(gca,'FontName',FntNm,'YLim',[0 3],'XLim',[0 1]);ylabel('T^oK/1000');
text(0.5,2.5,['\gamma=' num2str(gam) '    \alpha=' num2str(alf)]);
title('Решение - температура зон');

subplot(2,1,2);plot(x,F,'.-',x,[T0;T0],'r');set(gca,'FontName',FntNm,'YLim',[0 1.1]);
ylabel('T^oK/1000');
title('Температура на поверхности изделия');legend('Создаваемая','Требуемая',4);
set(gcf,'Name','Результат для выбранного alpha','NumberTitle','off')
disp('---------------------------------------------------------------------------------');
disp(' ');
disp(' ');disp('%%%%%%%%%%%%%%%%%%%%% Конец %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ');
disp(' ');
