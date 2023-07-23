% Test_reg

% Интерактивная демонстрация тихоновской регуляризации для задач nr1 - nr5
% (с.248).
% Описание задач -- см. с.133.
% Результаты демонстрации зависят от реализаций случайных ошибок
% приближенных данных!
%
clear all
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(' ');
disp('  Демонстрация тихоновской регуляризации с интерактивным выбором ');
disp('  параметра по ОПН и по методу L-кривой (с.248). Описание задач - см. с.133');
disp('  Результаты демонстрации зависят от реализаций случайных ошибок')
disp('  приближенных данных!');disp(' ');
disp('   Нажмите любую клавишу!');disp(' ');pause
disp('----------------------------------------------------------------');

% Задание номера задачи
disp(' ');Nom=input('  Введите номер рассматриваемой задачи (1 - 5): ');disp(' ');

problem=['nr' num2str(Nom)];

switch problem
   case 'nr1'
%  Задача 1    дифференцирование (уравнение Вольтерра с ядром K(x,t)=1)
t=linspace(0,1,125);
z0=((t.*(1-t.^2)).^2)';x=t;n=length(t);h=t(2)-t(1);K0=tril(ones(n));k1=ones(n);
[XX,TT]=meshgrid(x,t);K1=tril(ones(n));tt=t;k1=ones(n);

   case 'nr2'
%  Задача 2    уравнение Вольтерра с ядром K(x,t)=(x-t)^2*exp(-(x-t)^2)
t=linspace(0,1,125);x=t;n=length(t);h=t(2)-t(1);[XX,TT]=meshgrid(x,t);
z0=(t.*(1-t.^2))';K0=tril(((XX-TT)).^2*exp(-(XX-TT).^2))*h;
tt=linspace(0,2,125);;k1=(tt.^2).*exp(-tt.^2);

   case 'nr3'
% Задача 3     уравнение Фредгольма с ядром K(x,t)=1/(1+(x-t)^2)
t=linspace(-1,1,125);x=t;n=length(t);h=t(2)-t(1);[XX,TT]=meshgrid(x,t);
z0=(1-t.^2).^2';K0=h./(1+(XX-TT).^2);
tt=linspace(-2,2,125);;k1=1./(1+tt.^2);

   case 'nr4'
%  Задача 4    уравнение Фредгольма с ядром K(x,t)=exp(-(x-t)^2)
t=linspace(-1,1,125);x=t;n=length(t);h=t(2)-t(1);[XX,TT]=meshgrid(x,t);
z0=(1-t.^2).^2';K0=exp(-(XX-TT).^2)*h;
tt=linspace(-2,2,125);;k1=exp(-tt.^2);

   case 'nr5'
%  Задача 5    уравнение Вольтерра с ядром K(x,t)=m*l*exp(-(m*l)^2/(4*t))/sqrt(4*pi*t^3)
%     Восстановление импульсного сигнала в кабеле (Тихонов А.Н., Арсенин В.Я. с.164)
%     Она же - задача восстановления граничного условия в обратной задаче теплопроводности:
%     dT(x,t)/dt=a^2*T"(x,t), x>0, t>0, T(x,0)=0, T(x_0,t)=u(t) => T(0,t)=z(t)- ?
%         a=1, x_0=ml
t=linspace(0,2,125);x=t;n=length(t);h=t(2)-t(1);[XX,TT]=meshgrid(x,t);ml=2;
z0=(t.*exp(-(t*2).^2))';
vvv=ver('MATLAB');nmver=str2num(vvv.Version);
if nmver>6;
warning('off');else warning off;end
K0=tril(ml*exp(-ml^2./4./abs(XX-TT))./sqrt(4*pi*(abs(XX-TT)+eps).^3),-1)*h;
tt=linspace(0,2,125);;k1=ml*exp(-ml^2./4./(tt+eps))./sqrt(4*pi*(tt+eps).^3);
if nmver>6;
warning('on');else warning on;end

otherwise
   disp(' ');
   disp('Неизвестное уравнение. Измените номер задачи (1 - 5)!');disp(' ');return
end

disp(['   Решается задача ' num2str(Nom)]);disp(' ');pause(1);
disp('----------------------------------------------------------------');

u0=K0*z0;
K1=K0/norm(K0);u=u0/norm(u0);sc=norm(u0)/norm(K0);
z=z0/sc;

disp('  Просмотр данных задачи.');
disp('   Нажмите любую клавишу!');disp(' ');;pause
disp('----------------------------------------------------------------');

figure(20);subplot(2,2,1);plot(t,z0,'.-');set(gca,'FontName',FntNm);
title('Точное решение');
subplot(2,2,2);if Nom==1;mesh(t,t,K0);else plot(tt,k1,'.-');end
set(gca,'FontName',FntNm);
title('Ядро');subplot(2,2,3);plot(t,u0,'.-');
set(gca,'FontName',FntNm);
title('Правая часть');
set(gcf,'Name','Данные задачи','NumberTitle','off')


delta=0.01;% Уровень возмущения - не большой.
C=1.05;% Параметр алгоритма ОПН
disp(' ');disp(' Вводится небольшое возмущение данных.');
disp(['Уровень относительной ошибки данных: h=delta=' num2str(delta)]);disp(' ');
disp('----------------------------------------------------------------');
disp(' ');disp('Вычисления приближений с перебором параметра регуляризации.');
disp('   Нажимайте любую клавишу до конца перебора!');disp(' ');pause

RN1=randn(n,1);ud1=u+delta*norm(u)*RN1/norm(RN1);
if ismember(Nom,[1 2 5]); RK1=tril(randn(size(K1)));else RK1=(randn(size(K1)));end;
KK1=K1+delta*norm(K1)*RK1/norm(RK1);
Del=delta*C*norm(u);

alf0=0.3^3*1000*delta*norm(K1)/(norm(u)-Del);
Alf=[];Dis=[];Dz=[];Nz=[];Pz=[];
for kk=1:17;alf=alf0*(0.3).^(kk-1);
   [zr3,dis3]=tikh_alf(KK1,ud1,h,delta,alf);
   Alf=[Alf alf];Dis=[Dis dis3];
   dz=norm(zr3-z)/norm(z);Dz=[Dz dz];nz=norm(zr3);Nz=[Nz nz];
   Pz=[Pz Del+Del*nz*sqrt(h)];
figure(22);subplot (2,1,1);
plot (t,zr3*sc, 'r.-',t,z*sc, 'k-');set(gca,'FontName',FntNm);
legend (' Приближенное решение ' ,' Точное решение ' , 2 ) ;
subplot (2,2,3);
plot (log10(Alf),Dis-Pz, 'r.-',[-18 log10(alf0)],[0 0],'k');
xlabel('log_{10}(\alpha)');
set(gca,'FontName',FntNm,'XLim',[-18 log10(alf0)]);
title('Относительная обобщ. невязка');
subplot (2,2,4);plot (log10(Alf),Dz, 'r.-');xlabel('log_{10}(\alpha)');
set(gca,'FontName',FntNm,'XLim',[-18 log10(alf0)],'YLim',[0 1]);
title('Относительная ошибка решения');
set(gcf,'Name','Тихоновская  регуляризация: выбор параметра','NumberTitle','off')
pause;
end   
disp('----------------------------------------------------------------');

[mindz,iopt]=min(Dz);[ix]=min(find(Dis-Pz<=0));
Aop=log10(Alf(iopt));
Aomn=log10(Alf(ix));Ds1=Dis(ix)-Pz(ix);
subplot (2,2,3);hold on;plot (Aomn,Ds1, 'r*');hold off;
subplot (2,2,4);hold on;plot (Aop,mindz, 'r*');hold off;

% Интерактивный выбор параметра регуляризации 

disp(' ');disp('Интерактивный выбор параметра.');
disp('   Нажмите любую клавишу и выберите параметр');
disp('   регуляризации на любой из осей с меткой log_{10}(\alpha)');
disp('      Звездочками отмечены автоматический выбор по ОПН и оптимальный выбор.');
disp(' ');pause
[xa,ya]=ginput(1);
disp('----------------------------------------------------------------');
[mx,ix]=min(abs(log10(Alf)-xa));alpha=Alf(ix);
[zr30,dis30]=tikh_alf(KK1,ud1,h,delta,alpha);
dz0=norm(zr30-z)/norm(z);
disp('');
disp(['alpha = ' num2str(alpha) '   Невязка уравнения (%) = ' num2str(dis30) ' Ошибка решения (%) = ' num2str(dz0)]);
disp('');disp('----------------------------------------------------------------');
figure(22);subplot (2,1,1);
plot (t,zr30*sc, 'r.-',t,z*sc, 'k-');set(gca,'FontName',FntNm);
legend (' Приближенное решение ' ,' Точное решение ' , 2 ) ;
subplot (2,2,3);
plot (log10(Alf),Dis-Pz, 'r.-',[-18 log10(alf0)],[0 0], 'k-',log10(alpha),dis30-Pz(ix),'ob');
set(gca,'FontName',FntNm,'XLim',[-18 log10(alf0)]);xlabel('log_{10}(\alpha)');
title('Относительная обобщ. невязка');
subplot (2,2,4);plot (log10(Alf),Dz, 'r.-',log10(alpha),dz0,'ob');xlabel('log_{10}(\alpha)');
set(gca,'FontName',FntNm,'XLim',[-18 log10(alf0)],'YLim',[0 1]);
title('Относительная ошибка решения');
set(gcf,'Name','Решение для выбранного параметра','NumberTitle','off')

% Решение с выбором параметра методом L-кривой
 
disp(' ');disp('Решение с выбором параметра методом L-кривой.');
disp('   Нажмите любую клавишу и выберете точку на L-кривой!');
disp('      Звездочкой отмечен автоматический выбор.');
disp(' ');pause
disp('----------------------------------------------------------------');

figure(23);plot(log10(Dis),log10(Nz),'.-');set(gca,'FontName',FntNm);
title('L-кривая');xlabel('lg ||A_hz^{\alpha} - u_{\delta}||');ylabel('lg ||z^{\alpha}||');
hold on
if ~isequal(Nom,0);[xj]=kriv(log10(Dis),log10(Nz));hold on;
  plot(log10(Dis(xj)),log10(Nz(xj)),'r*');end  
hold on;
if ismember(Nom,[1 2]);axis equal;end
set(gcf,'Name','Выбор параметра методом L-кривой','NumberTitle','off')
[ax,ay]=ginput(1);plot(ax,ay,'ro');hold off
[mx,ix]=min(abs(log10(Dis)-ax));alpha=Alf(ix);
[zr31,dis31]=tikh_alf(KK1,ud1,h,delta,alpha);dz1=norm(zr31-z)/norm(z);
disp('');
disp(['alpha = ' num2str(alpha) '   Невязка уравнения (%) = ' num2str(dis31) ' Ошибка решения (%) = ' num2str(dz1)]);
%disp(' ');
disp('----------------------------------------------------------------');disp('');

figure(24);subplot (2,1,1);
plot (t,zr31*sc, 'r.-',t,z*sc, 'k-');set(gca,'FontName',FntNm);
legend (' Приближенное решение ' ,' Точное решение ' , 2 ) ;
subplot (2,2,3);
plot (log10(Alf),Dis-Pz, 'r.-',[-18 log10(alf0)],[0 0], 'k-',log10(alpha),dis31-Pz(ix),'ob');
set(gca,'FontName',FntNm,'XLim',[-18 log10(alf0)]);
title('Относительная обобщ. невязка');
subplot (2,2,4);plot (log10(Alf),Dz, 'r.-',log10(alpha),dz1,'ob');xlabel('log_{10}(\alpha)');
set(gca,'FontName',FntNm,'XLim',[-18 log10(alf0)],'YLim',[0 1]);
title('Относительная ошибка решения');
set(gcf,'Name','Решение с выбором параметра из L-кривой','NumberTitle','off')
disp(' ');disp('%%%%%%%%%%% Конец демонстрации %%%%%%%%%%%%')
   
