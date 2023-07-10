
%  Incomp_solut

%   См. с.145.
%  1. Вычисление меры несовместности интегрального уравнения Фредгольма 1 рода
%  различными методами.
%  2. Решение этого уравнения по алгоритму ОПН для разрешимого и неразрешимого
%  случаев.
% 
%  Модельная задача -- специальная задача Коши для уравнения Лапласа = обратная задача Дирихле
%
% u"_xx+u"_yy=0,   u(x,0)=u(x,pi)=0, u'_y(x,pi/2)=0,   0<x<1
% u(0,y)=0, u'_x(0,y)=u_n(y),  0<y<pi
%
% Задана g(y)=pi*u_n(y)/2 . Найти z(y)=u(H,y) для H, 0<H<1
%
% Эквивалентное интегральное ур-ние 1-го рода:
% g(y)=int_0^pi{G(y,y1,H)z(y1)dy1},  (0<y<pi)
% с ядром
% G(y,y1,H)=sum_{n=1}^{\inf}2n sin(2ny)sin(2n y1)[sh(2nH)]^(-1)
%

clear all;close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vvv=ver('MATLAB');nmver=str2num(vvv.Version);if nmver>6;
warning('off','MATLAB:dispatcher:InexactMatch');end

disp(' ');
disp(' 1. Вычисление оценки меры несовместности интегрального уравнения Фредгольма ');
disp('    1 рода в разрешимом и неразрешимом случае разными методами ');

delta=0.01;hdelta=0.001;
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
UU=sum(SU,1)';MUU=norm(UU);

%   Вычисление правой части, для которой уравнение разрешимо -- сумма только по четным 
%   собств. функциям
nn2=[2:2:n_end];[Y,N]=meshgrid(y,nn2);SU2=sin(N.*Y)./N./sinh(N.*H);
UU2=sum(SU2,1)';MUU2=norm(UU2);

%   Точная мера несовместности
mu_exact=norm(UU2-UU);
%  Точное модельное решение
zex=exacsol(GG,UU2);

% Возмущение данных
RN1=randn(size(UU));%RN1=2*(rand(n,1)-0.5);
RK1=(randn(size(GG)));%RN1=2*(rand(size(K1))-0.5);
load stand_err1
u=UU+delta*MUU*RN1/norm(RN1);
u2=UU2+delta*MUU2*RN1/norm(RN1);
G=GG+hdelta*norm(GG)*RK1/norm(RK1);
%save stand_err0 RN1 RK1

%    Вычисление вспомогательных функций алгоритма ОПН 

Dis=[];Alf=[];Ga=[];Dis0=[];Ga0=[];Opt=[];Opt0=[];Opt1=[];
%          Нормирование уравнения так, чтобы ||A||=1
Dis1=[];Ga1=[];C=1;MGG=norm(G);G0=G/MGG;u0=u/MGG;
alf0=1e4;q=0.5;nr=32;
for kk=1:nr;alf=alf0*q^kk;Alf=[Alf alf];
%          Для разрешимой задачи:   
[z,dis,gam]=Tikh_re(G,u2,alf);Dis=[Dis dis];Ga=[Ga gam];Opt=[Opt norm(zex-z)/norm(zex)];
%          Для неразрешимой задачи:
[z,dis,gam]=Tikh_re(G,u,alf);Dis0=[Dis0 dis];Ga0=[Ga0 gam];Opt0=[Opt0 norm(zex-z)/norm(zex)];
%     Неразрешимое нормированное уравнение -- переход к симметризованному
[z1,dis,gam]=Tikh_re(G0'*G0,G0'*u0,alf);Dis1=[Dis1 dis];Ga1=[Ga1 gam];
Opt1=[Opt1 norm(zex-z)/norm(zex)];
end
disp(' ');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' ');disp('           Разрешимая задача -- мера mu0=0');
disp(' Оценка меры несовместности по методу регуляризации - априорный выбор');
mu0=Dis(end);
disp(['   mu0_apri = ',num2str(mu0) '; относ. ошибка = ' num2str(mu0/norm(u2))])
disp(' Оценка меры несовместности по методу регуляризации - апостериорный выбор');
ksi=Dis.^2+hdelta*Ga.^2;[ss,iy]=min(ksi);mu01=sqrt(ksi(iy));
disp(['   mu0_apоst = ',num2str(mu01) '; относ. ошибка = ' num2str(mu01/norm(u2))])
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
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
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Решение уравнений по алгоритму ОПН
disp(' ');
disp(' 2. Решение уравнений по алгоритму ОПН');
disp('    для разрешимого и неразрешимого случая');disp(' ');pause(1)

%    Обобщенная невязка для разрешимого уравнения
gdis=Dis-(delta*norm(u2)+hdelta*norm(G)*Ga);
%    Обобщенная невязка для неразрешимого уравнения

%C=1.1;gdis1=Dis1.^2+(C-1)*mu^2-(C)*(mu+2*delta+2*hdelta*Ga1).^2;%*MGG/MUU  Alf.*(Ga1).^2+
%gdis1=Dis1-((delta+hdelta)*norm(G)*norm(u)+hdelta*norm(G)^2*(Ga1));
%gdis1=Dis1-2*((delta)*norm(u)+hdelta*norm(G)*(Ga1));%norm(G)*

%    Обобщенная невязка для симметризованного неразрешимого уравнения
gdis1=Dis1-(delta*norm(G0'*u0)+hdelta*norm(G0)^2*(Ga1))/C;


%figure(2);plot(log10(Alf),gdis,'.-',log10(Alf),gdis1,'.-',log10(Alf),zeros(size(log10(Alf))))

% Отделение корня
ix=min(find(gdis<=0));iix=min(find(gdis1<=0));
ix1=ix-1;iix1=iix-1;% функции >0
Lalf_opn=log10(Alf(ix))-gdis(ix)*(log10(Alf(ix1))-log10(Alf(ix)))/(gdis(ix1)-gdis(ix));
Lalf_opn1=log10(Alf(iix))-...
   gdis1(iix)*(log10(Alf(iix1))-log10(Alf(iix)))/(gdis1(iix1)-gdis1(iix));

figure(2);plot(log10(Alf),gdis,'.-',log10(Alf),gdis1*MGG,'.-',...
   log10(Alf),zeros(size(log10(Alf))),Lalf_opn,0,'bo',Lalf_opn1,0,'go');xlabel('lg \alpha')
set(gca,'FontName',FntNm);
title('Выбор параметра \alpha по ОПН');
legend('Разрешимое уравнение','Неразрешимое уравнение',4);set(gca,'FontName',FntNm);
pause(2)

alf1=10^(Lalf_opn);[zr,dis]=Tikh_re(G,u2,alf1);% Разрешимое уравнение
alf2=10^(Lalf_opn1);[zn,dis]=Tikh_re(G0'*G0,G0'*u0,alf2);% Неразрешимое уравнение
opt1=norm(zex-zn)/norm(zex);% Наилучшая точность решения с симметризацией
%   Наилучшее по точности решение неразрешимого уравнения (без симметризации)
[ooo,iii]=min(Opt0);alf11=Alf(iii);[znn,dis]=Tikh_re(G,u,alf11);
opt0=norm(zex-znn)/norm(zex);% Наилучшая точность решения (без симметризации)

disp([' alf OPN(разр.) = ' num2str(alf1)])
disp([' alf OPN(нераз.) = ' num2str(alf2)])

figure(3);subplot(1,2,1);plot(y,zr,'.-',y,zex,'r');
set(gca,'FontName',FntNm);title('Разрешимое уравнение');
hp=legend('z^{\alpha (\eta) опн}(y)','z_{exact}(y)',1);
subplot(1,2,2);plot(y,zn,'.',y,znn,'k',y,zex,'r');
set(gca,'FontName',FntNm);title('Неразрешимое уравнение');
hp=legend('z^{\alpha (\eta) symm}(y)','z^{best nosymm}(y)','z_{exact}(y)',1);
set(hp,'Position',[ 0.707 0.752 0.245 0.15 ])
set(gcf,'NumberTitle','off','Name','Решение уравнения по алгоритму ОПН')

disp(' ');disp('     Относительная точность получаемых решений');
disp([' Разрешимое уравнение: ' num2str(norm(zex-zr)/norm(zex))]);
disp([' Неразрешимое уравнение: ' num2str(norm(zex-zn)/norm(zex))]);
disp(' ')
disp(' ');disp('     Наилучшая относительная точность решений');
disp([' Разрешимое уравнение: ' num2str(min(Opt))]);
disp([' Неразрешимое уравнение c симметризацией: ' num2str(min([min(Opt1) opt1]))]);
disp([' Неразрешимое уравнение без симметризации: ' num2str(opt0)]);
disp(' ')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Конец %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
