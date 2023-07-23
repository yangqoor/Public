%  Refl_design

%  Оптимизация слоистой системы с фиксированным числом слоев по показателям
%  преломления в каждом слое. 
%  Целевая функция: коэффициент отражения R(lambda) -- минимальный (в различных нормах).

%  Модель с нормальным падением луча и с одинаковой толщиной слоев.

clear all;close all

if ~exist('fmincon');disp(' ');
  disp('  ВНИМАНИЕ! Демонстрация прерывается, т.к. на этой ЭВМ');
  disp('  не установлен компонент МАТЛАБа - Optimization Toolbox.');return;end

H=1;% Толщина покрытия
NL=20;% Число слоев в системе
NDL=12;% Число длин волн для оптимизации
z1=linspace(0,H,NL+1)';z=0.5*(z1(1:end-1)+z1(2:end));h=z(2)-z(1);n=size(z,1);% Слои

lam=linspace(H/2,7*H/2,NDL+1);h_lam=lam(2)-lam(1);% Длины волн
k=2*pi./lam;

R_ideal=zeros(size(k));% Идеальный коэффициент отражения, который хотим получить

nz1=1.52;nz2=1.1;NITER=40;
options=optimset('Display','off','MaxIter',NITER,'GradObj','off',...
   'LineSearchType','quadcubic','TolFun',1e-12,'TolCon',1e-12,'MaxFunEvals',4000000,...
   'TolX',1e-12);% 'iter' 'off'
LB=ones(size(z));UB=2.5*ones(size(z));warning off;
NZ=UB;NZ(2:2:end)=LB(2:2:end);NZ=LB;
disp(' ');disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

disp(' ');disp([' Оптимизация слоистой системы из NL = ' num2str(NL) ' слоев по показателям ']);
disp(' преломления для получения минимального коэф-та отражения R(k) (см. гл.5 \S3).');
disp(' Модель с нормальным падением луча и с одинаковой толщиной слоев.');
disp(' ');
disp(['      Показатели преломления подложки и внешней среды: n_1 = ' num2str(nz1) ';  n_2 = ' num2str(nz2)]);
disp(' ');
disp(' Целевые функции: задача 1 -- минимизация ||R(k)||_{L_2} ==> R_min_L2');
disp('                  задача 2 -- минимизация ||R(k)||_{C} ==> R_min_C');
disp('                  задача 3 -- минимизация оптич. пути \sum{n_j*h: j=1,...,NL}');
disp('                              при условии ||R(k)||_{L_2}<=R_min_L2');disp(' ');
disp(' Нормы оптимальных коэф-тов отражения:');

%  Оптимизация среднеквадратичного коэффициента отражения

hhhh = waitbar(0,'Problem 1. Wait a minute !');waitbar(1,hhhh);ris0=[0 1];
[NZ,R_min_L2]=...
   fmincon('refl_direct1',NZ,[],[],[],[],LB,UB,[],options,R_ideal,nz1,nz2,n,k,h,ris0);
 close(hhhh);NZ1=NZ;R_min_L2
 
z3=linspace(0,H,1001);nz3=interp1(z,NZ,z3,'nearest');
nr3=find(isnan(nz3));
if ~isempty(nr3);
nr31=nr3(nr3<500);if ~isempty(nr31);nz3(nr31)=nz3(nr31(end)+1);end;
nr32=nr3(nr3>500);if ~isempty(nr32);nz3(nr32)=nz3(nr32(1)-1);end
end
[F,G]=refl_direct1(NZ,R_ideal,nz1,nz2,n,k,h,[1 1]); 
figure(1);subplot(2,1,1);hn=plot(z3,nz3,[-h 0 0],[nz1 nz1 nz3(1)],'b');
mm=get(gca,'YLim');mm(1)=1;hold on;set(hn,'LineWidth',2);
hn=plot([0 0],mm,'r',[1 1],mm,'r',[1 1 1+h],[nz3(end) nz2 nz2],'b');
set(hn,'LineWidth',2);
hold off;set(gca,'XLim',[-h 1+h]);xlabel('z');ylabel('n(z)');

%  Оптимизация максимального коэффициента отражения

hhhh = waitbar(0,'Problem 2. Wait a minute !');waitbar(1,hhhh);ris0=[0 2];%NZ=LB;
[NZ,R_min_C]=...
   fmincon('refl_direct1',NZ,[],[],[],[],LB,UB,[],options,R_ideal,nz1,nz2,n,k,h,ris0);
 close(hhhh);NZ2=NZ;R_min_C
 
z3=linspace(0,H,1001);nz3=interp1(z,NZ,z3,'nearest');
if ~isempty(nr3);
nr31=nr3(nr3<500);if ~isempty(nr31);nz3(nr31)=nz3(nr31(end)+1);end;
nr32=nr3(nr3>500);if ~isempty(nr32);nz3(nr32)=nz3(nr32(1)-1);end
end
[F,G]=refl_direct1(NZ,R_ideal,nz1,nz2,n,k,h,[1 2]); 
figure(2);subplot(2,1,1);hn=plot(z3,nz3,[-h 0 0],[nz1 nz1 nz3(1)],'b');
mm=get(gca,'YLim');mm(1)=1;hold on;set(hn,'LineWidth',2);
hn=plot([0 0],mm,'r',[1 1],mm,'r',[1 1 1+h],[nz3(end) nz2 nz2],'b');
set(hn,'LineWidth',2);
hold off;set(gca,'XLim',[-h 1+h]);xlabel('z');ylabel('n(z)');

%  Оптимизация оптической длины системы при ограничении на коэффициент отражения,
%  полученный в задаче 1.

options=optimset('MaxIter',60);

hhhh = waitbar(0,'Problem 3. Wait a minute !');waitbar(1,hhhh);ris0=[0 1];NZ=NZ1;
[NZ,Optical_length_mi]=...
   fmincon('refl_direct2',NZ,[],[],[],[],LB,UB,'refl_constr1',options,R_ideal,R_min_L2,nz1,nz2,n,k,h,ris0);
 close(hhhh);Optical_length_min=Optical_length_mi*h
 
z3=linspace(0,H,1001);nz3=interp1(z,NZ,z3,'nearest');
if ~isempty(nr3);
nr31=nr3(nr3<500);if ~isempty(nr31);nz3(nr31)=nz3(nr31(end)+1);end;
nr32=nr3(nr3>500);if ~isempty(nr32);nz3(nr32)=nz3(nr32(1)-1);end
end
[F,G]=refl_direct2(NZ,R_ideal,R_min_L2,nz1,nz2,n,k,h,[1 3]); 
figure(3);subplot(2,1,1);hn=plot(z3,nz3,[-h 0 0],[nz1 nz1 nz3(1)],'b');
mm=get(gca,'YLim');mm(1)=1;hold on;set(hn,'LineWidth',2);
hn=plot([0 0],mm,'r',[1 1],mm,'r',[1 1 1+h],[nz3(end) nz2 nz2],'b');
set(hn,'LineWidth',2);
hold off;set(gca,'XLim',[-h 1+h]);xlabel('z');ylabel('n(z)');
disp(' ');
disp('%%%%%%%%%%%%%%%%%%%%%%%%% Конец %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' ');



