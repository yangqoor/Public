%  Alf_generalized

%  Сравнение различных способов выбора параметра регуляризации для линейных задач
%  с относительно большими погрешностями оператора и правой части
%  1) Выбор по невязке; 2) Выбор по обобщ. принципу невязки;
%  3) Выбор по принципу сглаживающего функционала; 4)Выбор по обобщ. принципу сглаж. функц-ла 

%  Выбор наилучшего параметра регуляризации из рассмотренных для данной задачи.
clear all
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(' ');
disp('-------------------------------------------------------------------');
disp('  Сравнение различных способов выбора параметра регуляризации');
disp('  с относительно большими погрешностями оператора и правой части (с.139):');
disp(' ');
disp('    1) Выбор по невязке; 2) Выбор по обобщ. принципу невязки;');
disp('    3) Выбор по принципу сглаживающего функционала; ');
disp('    4) Выбор по обобщ. принципу сглаж. функционала ');disp(' ')

disp('   Нажмите любую клавишу!');disp(' ');pause
disp('-------------------------------------------------------------------');

% Задание номера задачи
disp(' ');Nom=input('  Введите номер рассматриваемой задачи (1 - 4): ');disp(' ');
disp('-------------------------------------------------------------------');
problem=['nr' num2str(Nom)];
if ismember(Nom,[1 2]);t=linspace(0,1,125);x=t;z=(t.*(1-t.^2))';else 
  t=linspace(-1,1,125);x=t;z=(1-t.^2).^2';end
[XX,TT]=meshgrid(x,t);n=length(t);h=t(2)-t(1);del=1/sqrt(3);hh=sqrt(h);p=10;

switch problem
  case 'nr1'
%  Задача 1    дифференцирование (уравнение Вольтерра с ядром K(x,t)=1)
z=((t.*(1-t.^2)).^2)';x=t;n=length(t);h=t(2)-t(1);K0=tril(ones(n));k1=ones(n);
[XX,TT]=meshgrid(x,t);K1=tril(ones(n));tt=t;k1=ones(n);CC=10;
  case 'nr2'
%  Уравнение Вольтерра   
K0=tril(((XX-TT)).^2*exp(-(XX-TT).^2))*h;tt=linspace(0,2,125);k1=(tt.^2).*exp(-tt.^2);CC=10;
case 'nr3'
%  Уравнение Фредгольма  
K0=h./(1+p*(XX-TT).^2);tt=linspace(-2,2,125);k1=1./(1+tt.^2);CC=10;
case 'nr4'
%  Уравнение Фредгольма    
K0=exp(-(XX-TT).^2)*h;tt=linspace(-2,2,125);k1=exp(-tt.^2);CC=10;

otherwise
   disp(' ');
  disp('Неизвестное уравнение. Измените номер задачи (1 - 4)!');disp(' ');return
   end
disp(' ');
disp(['   Решается задача № ' num2str(Nom)]);disp(' ');pause(1);
disp('-------------------------------------------------------------------');
u0=K0*z;u=u0/norm(K0);K1=K0/norm(K0);

%
delta=0.05;delta_A=0.01;% Уровни возмущения пр. части и ядра
pome=1; %  Стандартные ошибки данных (pome=1) или произвольные ошибки (pome=0)

Delta=delta*norm(u)*del;Delta_A=delta_A*norm(K1)*del;C1=1;%CC=0.5;%CC=1;
%
if pome==0;RN1=randn(n,1);RK1=(randn(size(K1)));else
  load errors_alf_gen RN1 RK1;end

ud1=u+Delta*RN1/norm(RN1);
if ismember(Nom,[2]);RK1=tril(RK1)-diag(diag(RK1));end
KK1=K1+Delta_A*RK1/norm(RK1);

disp(['Уровень относительной ошибки данных: delta=' num2str(delta) ', h=' num2str(delta_A)]);
disp(' ');disp(' Можно просмотреть точную и приближенную u(x).');disp(' ');
figure(21);plot(t,u0,'r',t,ud1*norm(K0),'.b');title(' ');xlabel('x');
set(gca,'FontName',FntNm);
set(gcf,'Name','Данные задачи','NumberTitle','off')
legend(' Точная правая часть',' Приближенная правая часть');
disp('   Затем для решения нажмите любую клавишу!');disp(' ');pause
disp('-------------------------------------------------------------------');



alf0=CC*delta_A*norm(KK1)^2/(norm(ud1)-Delta);Del=Delta;%Del=delta*norm(u*h);
Alf=[];Dis=[];Dz=[];Nz=[];VV=[];Tf=[];
for kk=1:15;alf=alf0*(0.2).^(kk-1);
   [zr3,dis3,lz]=tikh_alf2(KK1,ud1,h,delta,alf);Alf=[Alf alf];Dis=[Dis dis3];
   dz=norm(zr3-z)/norm(z);Dz=[Dz dz];nz=norm(zr3);Nz=[Nz nz];VV=[VV lz];
   tf=(alf*norm(zr3)^2+(dis3*norm(ud1))^2)/norm(ud1)^2;
   Tf=[Tf tf];
end   
%
Dn=(Delta+Delta_A*Nz)/norm(ud1);C1=0.9;
Gdis=Dis-C1*Dn;C1=1;

TTf=Tf-C1*Dn.^2;

% Выбор параметров
%   Невязка
ix=min(find(Dis<=delta));ix1=max(find(Dis>=delta));
alfdis=Alf(ix)-(Alf(ix1)-Alf(ix))*(Dis(ix)-delta)/(Dis(ix1)-Dis(ix));
%   ОПН
ixg1=max(find(Gdis>=0));ixg2=min(find(Gdis<=0));
%   Сглаживающий ф-л
iix=min(find(Tf-C1*delta^2<=0));iix1=max(find(Tf-C1*delta^2>=0));
alfsm=Alf(iix)-(Alf(iix1)-Alf(iix))*(Tf(iix)-C1*delta^2)/(Tf(iix1)-Tf(iix));
%   ОПСФ
iv=min(find(TTf<=0));

% Иллюстрация выбора
figure(22);%subplot (2,2,1);
subplot (2,2,1);plot(log10(Alf),Dis, 'r.-',[-18 log10(alf0)],[delta delta], 'k-',...
   log10(alfdis),delta,'bo');%  Alf(ix)),Dis(ix)
%xlabel('log_{10}(\alpha)');
set(gca,'FontName',FntNm,'XLim',[-18 log10(alf0)]);
title('Принцип невязки');text(-15,delta,'\delta')
legend ('||Az^{\alpha}-u||/||u||=\delta')

subplot (2,2,2);plot (log10(Alf),Gdis, 'r.-',log10(Alf(ixg2)),Gdis(ixg2),'bo',...
   [-18 log10(alf0)],[0 0],'k');
set(gca,'FontName',FntNm,'XLim',[-18 log10(alf0)],'YLim',[min(Gdis) max(Gdis)]);
%xlabel('log_{10}(\alpha)');
title('Выбор по ОПН');
legend ('(||Az^{\alpha}-u||-C(\delta+\delta_A||z^{\alpha}||))/||u||')

subplot (2,2,4);plot (log10(Alf),TTf, 'r.-',log10(Alf(iv)),TTf(iv),'bo',...
   [-18 log10(alf0)],[0 0],'k');
set(gca,'FontName',FntNm,'XLim',[-18 log10(alf0)]);title('Выбор по ОПСФ');
legend('(M^{\alpha}[z^{\alpha}]-C(\delta+\delta_A||z^{\alpha}||)^2)/||u||^2');
xlabel('log_{10}(\alpha)');

subplot (2,2,3);plot(log10(Alf),Tf, 'r.-',[-18 log10(alf0)],[delta^2 delta^2], 'k-',...
   log10(alfsm),C1*delta^2,'bo');
xlabel('log_{10}(\alpha)');
set(gca,'FontName',FntNm,'XLim',[-18 log10(alf0)]);title('Принцип сгл. ф-ла');
text(-15,delta^2,'C\delta^2');
legend ('(\alpha||z^{\alpha}||^2+||Az^{\alpha}-u||^2)/||u||^2=C\delta^2')
set(gcf,'Name','Выбор параметра','NumberTitle','off')


% Сравнение качества решений
[zrd,dis1,v1]=tikh_alf1(KK1,ud1,h,delta,alfdis);% Невязка Alf(ix)
[zrgd,dis2,v1]=tikh_alf1(KK1,ud1,h,delta,Alf(ixg2));% ОПН
[zrs,dis3,v1]=tikh_alf1(KK1,ud1,h,delta,alfsm);% Сглаж. ф-л Alf(iix)
[zrgs,dis4,v1]=tikh_alf1(KK1,ud1,h,delta,Alf(iv));% ОПСФ
erd=norm(zrd-z)/norm(z);erk=norm(zrgd-z)/norm(z);
erl=norm(zrs-z)/norm(z);ers=norm(zrgs-z)/norm(z);
[nmm,ind]=min([erd erk erl ers]);

figure(23);plot(t,z,'k',t,zrd,'.-',t,zrgd,'.-',t,zrs,'.-',t,zrgs,'.-')
set(gca,'FontName',FntNm);xlabel('t');ylabel('z(t), z^{\alpha}(t)');
legend('точное реш.','принцип невязки','ОПН','сглаж. ф-л','ОПСФ',2)
hh=text(t(40),mean(z)/3,'Отн. ошибки');set(hh,'FontName',FntNm);
%text(-0.6,0.25,num2str(erd));
text(t(30),mean(z)/4,[num2str(erd) '; ' num2str(erk) '; ' num2str(erl) '; ' num2str(ers)]);
%text(-0.6,0.15,num2str(erl));text(-0.6,0.1,num2str(ers));
set(gcf,'Name','Сравнение решений','NumberTitle','off')

if ind==1;zre=zrd;alfa=Alf(ix);DS=dis1;sr='невязка';elseif ind==2;zre=zrgd;alfa=Alf(ixg2);...
    DS=dis2;sr='обоб. невязка';elseif ind==3;zre=zrs;alfa=Alf(iix);
    DS=dis3;sr='сглаж. ф-л';...
    else ind==4;zre=zrgs;alfa=Alf(iv);DS=dis4;sr='обобщ. сгл. ф-л';end
  Error=norm(zre-z)/norm(z);
figure(24);plot(t,z,'k',t,zre,'.-')
set(gca,'FontName',FntNm);xlabel('t');ylabel('z(t), z^{\alpha}(t)');
text(t(40),mean(z)/3,['\alpha = ' num2str(alfa)]);
hh=text(t(40),mean(z)/4,['Относ. ошибка = ' num2str(Error)]);
set(hh,'FontName',FntNm);legend('точное реш.',sr,2)
set(gcf,'Name','Тихоновская регуляризация: лучшее решения','NumberTitle','off')

disp(' ');disp(['                Результаты решения:  лучший метод -- ' sr]);disp(' ');
disp(['alpha = ' num2str(alfa) '   Невязка = ' num2str(DS) ' Ошибка решения = ' num2str(Error)]);
disp(' ');
disp('-------------------------------------------------------------------');
disp(' ');
disp('%%%%%%%%%%%%%%%%%%%%%% Конец %%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' ');
