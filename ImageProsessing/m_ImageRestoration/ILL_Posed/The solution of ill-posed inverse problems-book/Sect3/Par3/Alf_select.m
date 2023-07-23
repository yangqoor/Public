%  Alf_select
%  Сравнение различных способов выбора параметра регуляризации
%  1) Выбор по невязке; 2) Выбор по критерию квазиоптимальности;
%  3) Метод L-кривой; 4) Выбор по принципу сглаживающего функционала
%  Выбор наилучшего параметра регуляризации для рассматриваемой задачи (с.138).
%  Описание задач - см. с.133.
clear all
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vvv=ver('MATLAB');nmver=str2num(vvv.Version);if nmver>6;
warning('off','MATLAB:dispatcher:InexactMatch');end

t=linspace(-1,1,125);x=t;n=length(t);h=t(2)-t(1);[XX,TT]=meshgrid(x,t);
z=(1-t.^2).^2';

disp(' ');
disp('  Сравнение различных способов выбора параметра регуляризации ');
disp('  при малых погрешностях оператора (с.138)');disp(' ');
disp('    1) Выбор по невязке; 2) Выбор по критерию квазиоптимальности;');
disp('    3) Метод L-кривой; ');
disp('    4) Выбор по принципу сглаживающего функционала');disp(' ')
disp('     Нажмите любую клавишу! ');disp(' ');pause
disp('-------------------------------------------------------------------');

% Задание номера задачи
disp(' ');
Nom=input('  Введите номер рассматриваемой задачи (2 - 5); описание задач - см. с.133 : ');
disp(' ');
if ~ismember(Nom,[2:5]);disp('    Неверный номер задачи! Обратитесь к модулю снова.');
  return;end

problem=['nr' num2str(Nom-1)];%Nom=Nom-1;

switch problem
   case 'nr1'
%  Задача 1 Hахождение нагрузки тонкого стержня по измеряемому его прогибу
K1=h*(tril((XX+1).*(1-TT))+tril((XX+1).*(1-TT))');tt=linspace(-1,1,125);%k1=(1+tt).*(1-tt);  

   case 'nr2'
%  Задача 2 Интегральное уравнение задачи продолжения потенциала
K1=h./(1+(XX-TT).^2);tt=linspace(-2,2,125);k1=1./(1+tt.^2);

   case 'nr3'
% Задача 3 Интегральное уравнение Вольтерра. 
% Возможна плохая работа квазиопт. критерия и вырождение L-кривой
K1=tril(((XX-TT)).^2*exp(-(XX-TT).^2))*h;tt=linspace(0,2,125);k1=(tt.^2).*exp(-tt.^2);

   case 'nr4'
% Интегральное уравнение Фредгольма (ядро - гауссиан)
K1=exp(-(XX-TT).^2)*h;tt=linspace(-2,2,125);k1=exp(-tt.^2);
otherwise
   disp(' ');
   disp('Неизвестное уравнение. Измените номер задачи (2 - 5)!');disp(' ');return
   end
disp(' ');
disp(['   Решается задача № ' num2str(Nom)]);disp(' ');
disp('-------------------------------------------------------------------');
pause(1);Nom=Nom-1;

u=K1*z;
C=1.1;
disp(' ');disp('  Данные задачи');
disp('     Нажмите любую клавишу!');disp(' ');pause
disp('-------------------------------------------------------------------');


figure(20);subplot(2,2,1);plot(t,z,'.-');set(gca,'FontName',FntNm);
title('Точное решение');subplot(2,2,2);
if Nom==1;mesh(tt,tt,K1);set(gca,'FontName',FntNm);title('Ядро K(x,s)');else
  plot(tt,k1,'.-');set(gca,'FontName',FntNm);title('Ядро K(x-s)');end;

subplot(2,2,3);plot(t,u,'.-');set(gca,'FontName',FntNm);
title('Правая часть');
set(gcf,'Name','Данные задачи','NumberTitle','off')

delta=0.001;hh=sqrt(h);% Уровень возмущения - не большой.
disp(' ');disp('  Вводится небольшое возмущение данных.');
disp(['    Уровень относительной ошибки данных: h=delta=' num2str(delta)]);disp(' ');
disp('       Нажмите любую клавишу!');disp(' ');pause
disp('-------------------------------------------------------------------');


%
load error1
% RN1=randn(n,1);RK1=(randn(size(K1)));
if ismember(Nom,[3]); RK1=tril(RK1);end
ud1=u+delta*norm(u*hh)*RN1/norm(RN1);
KK1=K1+delta*norm(K1*hh*hh)*RK1/norm(RK1);
alf0=delta*norm(KK1)/(norm(ud1*hh)-delta*norm(u*hh));Del=delta;%Del=delta*norm(u*h);
Alf=[];Dis=[];Dz=[];Nz=[];VV=[];Tf=[];
for kk=1:15;alf=alf0*(0.1).^(kk-1);
   [zr3,dis3,v3]=Tikh_alf1(KK1,ud1,h,delta,alf);Alf=[Alf alf];Dis=[Dis dis3];
   dz=norm(zr3-z)/norm(z);Dz=[Dz dz];nz=norm(zr3);Nz=[Nz nz];VV=[VV v3];
   tf=(alf*norm(zr3)^2+(dis3*norm(ud1))^2)/norm(ud1)^2;
   Tf=[Tf tf];
end   
%
[xi]=kriv(log10(Dis),log10(Nz));%xxa=xxa+1;
ix=min(find(Dis<=Del));iix=min(find(Tf<=C*Del^2));
[vm,iv]=min(VV);

% Результаты разных выборов параметра
figure(22);subplot (2,1,1);
subplot (2,2,1);plot(log10(Alf),Dis, 'r.-',[-18 log10(alf0)],[Del Del], 'k-',...
   log10(Alf(ix)),Dis(ix),'bo');
xlabel('log_{10}(\alpha)');
set(gca,'FontName',FntNm,'XLim',[-18 log10(alf0)]);
title('Относительная невязка');text(-1,delta,'\delta')
legend ('||Az^{\alpha}-u||/||u||=\delta',2 )
subplot (2,2,2);plot (log10(Alf),Dz, 'r.-',log10(Alf),VV/max(VV),'.-b',...
   log10(Alf(iv)),VV(iv),'bo');
xlabel('log_{10}(\alpha)');
set(gca,'FontName',FntNm,'XLim',[-18 log10(alf0)],'YLim',[0 1]);
title('Относительная ошибка решения ');
legend ('~||z^{\alpha}-z_{exact}||' ,'~||\alpha dz^{\alpha}/d\alpha||' , 2 )
subplot (2,2,3);plot(log10(Dis),log10(Nz),'.-',log10(Dis(xi)),log10(Nz(xi)),'ro',...
   log10(Dis(xi)),log10(Nz(xi)),'r.');if Nom==3;axis equal;end
set(gca,'FontName',FntNm);legend('L-кривая',['\alpha=' num2str(Alf(xi))]);
xlabel('log_{10}(||Az^{\alpha}-u||)');
ylabel('log_{10}(||z^{\alpha}||)');
subplot (2,2,4);plot(log10(Alf),Tf, 'r.-',[-18 log10(alf0)],[C*Del^2 C*Del^2], 'k-',...
   log10(Alf(iix)),Tf(iix),'bo');
xlabel('log_{10}(\alpha)');
set(gca,'FontName',FntNm,'XLim',[-18 log10(alf0)]);
text(-1,delta^2,'C\delta^2');
title('ОПСФ');
legend ('(\alpha||z^{\alpha}||^2+||Az^{\alpha}-u||^2)/||u||^2=C\delta^2',2 )
set(gcf,'Name','Выбор параметра','NumberTitle','off')

% Сравнение качества решений
[zrd,dis1,v1]=Tikh_alf1(KK1,ud1,h,delta,Alf(ix));
[zrk,dis2,v1]=Tikh_alf1(KK1,ud1,h,delta,Alf(iv));
[zrl,dis3,v1]=Tikh_alf1(KK1,ud1,h,delta,Alf(xi));
[zrs,dis4,v1]=Tikh_alf1(KK1,ud1,h,delta,Alf(iix));
erd=norm(zrd-z)/norm(z);erk=norm(zrk-z)/norm(z);
erl=norm(zrl-z)/norm(z);ers=norm(zrs-z)/norm(z);
[nmm,ind]=min([erd erk erl ers]);

figure(23);plot(t,z,'k',t,zrd,'.-',t,zrk,'.-',t,zrl,'.-',t,zrs,'.-')
set(gca,'FontName',FntNm);xlabel('t');ylabel('z(t), z^{\alpha}(t)');
legend('точное реш.','невязка','квазиопт. ф-л','L-кривая','сглаж. ф-л',2)
hh=text(-0.6,0.3,'Отн. ошибки');set(hh,'FontName',FntNm);
text(-0.6,0.25,num2str(erd));text(-0.6,0.2,num2str(erk));
text(-0.6,0.15,num2str(erl));text(-0.6,0.1,num2str(ers));
set(gcf,'Name','Сравнение решений','NumberTitle','off')

if ind==1;zre=zrd;alfa=Alf(ix);sr='невязка';DS=dis1;elseif ind==2;zre=zrk;alfa=Alf(iv);...
      sr='квазиопт. ф-л';DS=dis2;elseif ind==3;zre=zrl;alfa=Alf(xi);sr='L-кривая';...
   DS=dis3;else ind==4;zre=zrs;alfa=Alf(iix);sr='сглаж. ф-л';DS=dis4;end
figure(24);plot(t,z,'k',t,zre,'.-')
set(gca,'FontName',FntNm);xlabel('t');ylabel('z(t), z^{\alpha}(t)');
text(-0.6,0.25,['\alpha=' num2str(alfa)]);
legend('точное реш.',sr,2)
set(gcf,'Name','Тихоновская регуляризация: лучшее решения','NumberTitle','off')

disp('');
disp(['alpha = ' num2str(alfa) '   Невязка = ' num2str(DS) ' Ошибка решения = ' num2str(nmm)]);
disp(' ');disp('-------------------------------------------------------------------');
disp(' ');
disp('%%%%%%%%%%%%%%%%%%%%%% Конец %%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' ');
