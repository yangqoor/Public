
%  Incomp_meas

%  Вычисление меры несовместности интегрального уравнения Фредгольма 1 рода
%  различными методами (с.130 - 132).
% 
% 
%  Модельная задача --  задача Коши для уравнения Лапласа = обратная задача Дирихле
%
% u"_xx+u"_yy=0,   u(x,0)=u(x,pi)=0, u'_y(x,pi/2)=0,  0<x<1
% u(0,y)=0, u'_x(0,y)=u_n(y),  0<y<pi
%
% Задана g(y)=pi*u_n(y)/2 . Найти z(y)=u(H,y) для H, 0<H<1
%
% Эквивалентное интегральное ур-ние 1-го рода:
% g(y)=int_0^pi{G(y,y1,H)z(y1)dy1},  (0<y<pi)
% с ядром
% G(y,y1,H)=sum_{n=1}^{\inf}n sin(ny)sin(n y1)[sh(nH)]^(-1)
%

clear all;close all;


disp(' ');
disp(' Вычисление оценки меры несовместности интегрального уравнения Фредгольма 1 рода');
disp('            в разрешимом и неразрешимом случае разными методами (с.130 - 132)');

%      Уровень ошибок данных
delta=0.01;hdelta=0.01;
disp(' ');
disp(['   Погрешности данных: ' 'delta = ' num2str(delta) '; h = ' num2str(hdelta)]);


n=60;x=1*[0:0.05:1];
y=[0:0.05:pi];h=y(2)-y(1);
[Y,Y1]=meshgrid(y,y);
n_end=50;nn=[2:2:n_end];[YY,YY1,NN]=ndgrid(y,y,nn);
SS=NN.*sin(NN.*YY).*sin(NN.*YY1);

% Ядро интегрального уравнения -- сумма только по четным собств. функциям
H=x(11);SSH=SS./sinh(NN.*H);GG=2*sum(SSH,3)/pi;

%   Вычисление правой части, для которой уравнение не разрешимо -- разложение по всем
%   собств. функциям
nnn=[1:n_end];[Y,N]=meshgrid(y,nnn);SU=sin(N.*Y)./N./sinh(N.*H);
UU=sum(SU,1)';

%   Вычисление правой части, для которой уравнение разрешимо -- сумма только по четным 
%   собств. функциям
nn2=[2:2:n_end];[Y,N]=meshgrid(y,nn2);SU2=sin(N.*Y)./N./sinh(N.*H);
UU2=sum(SU2,1)';

%   Точная мера несовместности
mu_exact=norm(UU2-UU);
%  Точное модельное решение
zex=exacsol(GG,UU2);

% Возмущение данных

RN1=randn(size(UU));RK1=(randn(size(GG)));
load stand_err0
u=UU+delta*norm(UU)*RN1/norm(RN1);
u2=UU2+delta*norm(UU2)*RN1/norm(RN1);
G=GG+hdelta*norm(GG)*RK1/norm(RK1);

%    Вычисление вспомогательных функций алгоритма ОПН 
tt=cputime;
Dis=[];Alf=[];Ga=[];Dis0=[];Ga0=[];
%          Нормирование уравнения так, чтобы ||A||=1
Dis1=[];Ga1=[];C=1;
alf0=1e4;q=0.5;nr=32;
for kk=1:nr;alf=alf0*q^kk;Alf=[Alf alf];
%          Для разрешимой задачи:   
[z,dis,gam]=tikh_re(G,u2,alf);Dis=[Dis dis];Ga=[Ga gam];
%          Для неразрешимой задачи:
[z,dis,gam]=tikh_re(G,u,alf);Dis0=[Dis0 dis];Ga0=[Ga0 gam];
end
ttt=cputime-tt;
disp(' ');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' ');disp('           Разрешимая задача -- мера несовместности mu0=0');
disp(' Оценка меры несовместности по методу регуляризации - априорный выбор');
mu0=Dis(end);
disp(['   mu0_apri = ',num2str(mu0) '; относ. ошибка = ' num2str(mu0/norm(u2))])
disp(' Оценка меры несовместности по методу регуляризации - апостериорный выбор');
ksi=Dis+hdelta*Ga;mu01=min(ksi)+delta*norm(u2);
disp(['   mu0_apоst = ',num2str(mu01) '; относ. ошибка = ' num2str(mu01/norm(u2))])
%disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' ');

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' ');
disp('             Неразрешимая задача -- обобщенная мера несовместности ');
disp('             как оценка меры несовместности ');
disp(' Точная мера несовместности неразрешимой задачи');
disp(['   mu_exact = ',num2str(mu_exact)])
disp(' Оценка обобщенной меры несовместности по методу регуляризации - априорный выбор');

%          Для неразрешимой задачи:
%    Оценка обобщенной меры несовместности по методу регуляризации (априорный выбор)
Blf=Alf-(delta*norm(u)+hdelta*norm(GG)).^2;ni=min(find(Blf<=0));
mu=Dis0(ni)+delta*norm(u)+hdelta*norm(GG)*Ga0(ni);
%if isempty(ni);mu=min(Dis0+delta*norm(u)+hdelta*norm(GG)*Ga0);end
disp(['   mu_apri = ' num2str(mu) '; относ. ошибка = ' num2str(abs(mu_exact-mu)/mu_exact)])
% 
%    Оценка меры несовместности (апостериорный выбор)
disp(' Оценка обобщенной меры несовместности по методу регуляризации - апостериорный выбор');

ksi=Dis0+hdelta*norm(GG)*Ga0;mu2=min(ksi)+delta*norm(u);
disp(['   mu_apost = ' num2str(mu2) '; относ. ошибка = ' num2str(abs(mu_exact-mu2)/mu_exact)])
disp(' ');
disp(['      Время расчета = ' num2str(ttt)]);disp(' ');


%  Вычисление меры несовместности прямой минимизацией
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' ');
disp(' Вычисление обобщенной меры несовместности прямой минимизацией');
disp('    Немного подождите!');disp(' ');

options=optimset('Display','off','MaxIter',70);%  ,'Diagnostics','off'  'iter'
warning off
m=size(G,2);tt=cputime;
%tic
[zmu,mu1]=fminunc('inc_func',zeros(m,1),options,G,u,delta,hdelta);ttt=cputime-tt;
disp(['   mu_direct = ',num2str(mu1) '; относ. ошибка = ' num2str(abs(mu_exact-mu1)/mu_exact)])
disp(' ');disp(['      Время расчета = ' num2str(ttt)]);disp(' ');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
%toc
disp(' ');%disp(' ');



