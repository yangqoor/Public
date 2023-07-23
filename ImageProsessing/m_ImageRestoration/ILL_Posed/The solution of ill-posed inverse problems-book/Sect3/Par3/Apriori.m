%  Apriori
%
% Сравнение априорного выбора параметра регуляризации и апостериорного
% выбора по ОПН (c.135 - 136).
% Перебор констант в априорном выборе.

clear all
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vvv=ver('MATLAB');nmver=str2num(vvv.Version);if nmver>6;
warning('off','MATLAB:dispatcher:InexactMatch');end

%   Данные, задаваемые пользователем

disp(' ');
disp(' Сравнение априорного выбора параметра регуляризации и ');
disp(' апостериорного выбора по ОПН (c.135 - 136).');
disp('');
disp('   Нажмите любую клавишу!');disp(' ');pause
disp('--------------------------------------------------------------');


% Задание номера задачи
disp(' ');Nom=input('  Введите номер рассматриваемой задачи (1 - 4): ');disp(' ');

problem=['nr' num2str(Nom)];
p=10;del=1;

switch problem
   case 'nr1'
%  Задача 1    дифференцирование (уравнение Вольтерра с ядром K(x,t)=1)
t=linspace(0,1,125);
z=((t.*(1-t.^2)).^2)';x=t;n=length(t);h=t(2)-t(1);K1=tril(ones(n));k1=ones(n);% z=(t.^2)';
[XX,TT]=meshgrid(x,t);K0=tril(ones(n));tt=t;k1=ones(n);CC=1.3;
case 'nr2'
%  Уравнение Вольтерра   
t=linspace(0,1,125);x=t;z=(t.*(1-t.^2))';[XX,TT]=meshgrid(x,t);h=t(2)-t(1);  
K0=tril(((XX-TT)).^2*exp(-(XX-TT).^2))*h;tt=linspace(0,2,125);k1=(tt.^2).*exp(-tt.^2);CC=0.5;
case 'nr3'
%  Уравнение Фредгольма  
t=linspace(-1,1,125);x=t;z=(1-t.^2).^2';[XX,TT]=meshgrid(x,t);h=t(2)-t(1);
K0=h./(1+p*(XX-TT).^2);tt=linspace(-2,2,125);k1=1./(1+tt.^2);CC=1;
case 'nr4'
%  Уравнение Фредгольма    
t=linspace(-1,1,125);x=t;z=(1-t.^2).^2';[XX,TT]=meshgrid(x,t);h=t(2)-t(1);
K0=exp(-(XX-TT).^2)*h;
tt=linspace(-2,2,125);k1=exp(-tt.^2);CC=0.2;;

otherwise
   disp(' ');
  disp('Неизвестное уравнение. Измените номер задачи (1 - 4)!');disp(' ');return
   end
disp(' ');
disp(['   Решается задача № ' num2str(Nom)]);disp(' ');
disp('--------------------------------------------------------------');
pause(1);

n=length(t);hh=sqrt(h);

u0=K0*z;u=u0/norm(K0);K1=K0/norm(K0);

delta=0.03;deltaA=0.001;% Уровень возмущения данных
RN1=randn(n,1);RK1=(randn(size(K1)));
load Err_apriori;
if ismember(Nom,[1 2]);RK1=tril(RK1)-diag(diag(RK1));end
%ud1=u+delta*del*norm(u)*RN1/norm(RN1);
ud1=u+delta*RN1/norm(RN1);
KK1=K1+deltaA*norm(K1)*RK1/norm(RK1);

disp(' ');disp('       Данные задачи');
figure(20);subplot(2,2,1);plot(t,z,'.-');set(gca,'FontName',FntNm);
title('Точное решение');
subplot(2,2,2);if Nom==1;mesh(t,t,K1);else plot(tt,k1,'.-');end
set(gca,'FontName',FntNm);
title('Ядро');subplot(2,2,3);plot(t,u,'.-');set(gca,'FontName',FntNm);
title('Правая часть');
set(gcf,'Name','Точные данные задачи','NumberTitle','off')


disp(['  Относительные ошибки данных: delta=' num2str(delta) ' deltaA=' num2str(deltaA)]);
disp(' ');disp('   Можно просмотреть точную и приближенную u(x).');disp(' ');
disp('--------------------------------------------------------------');

figure(21);plot(t,u0,'r',t,ud1*norm(K0),'.b');title(' ');xlabel('x');
set(gca,'FontName',FntNm);
set(gcf,'Name','Данные задачи','NumberTitle','off')
legend(' Точная правая часть',' Приближенная правая часть');
%disp('   Затем нажмите любую клавишу!');disp(' ');
%disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');pause


disp(' ');disp('Демонстрация тихоновской регуляризации с выбором ');
disp('параметра по обобщенному принципу невязки.');
disp('   Нажмите любую клавишу!');disp(' ');pause
disp('--------------------------------------------------------------');


C=1.;% Параметр алгоритма
[zro,diso,alf]=Tikh_reg_discr(KK1,ud1,h,delta*CC,C);ero=norm(zro-z)/norm(z);
figure(200);plot(t,z,'k',t,zro,'.-');hold on;set(gcf,'Visible','off');
strr=['r' 'g' 'm'];
for ih=1:3;C1=0.5^(ih-1);stt=strr(ih);
alf_apri=C1*(delta^2+deltaA^2);[zr1,dis1,v1]=Tikh_alf1(KK1,ud1,h,delta,alf_apri);
ero=norm(zro-z)/norm(z);er1=norm(zr1-z)/norm(z);
figure(200);plot(t,zr1,stt);set(gcf,'Visible','off');
end
figure(200);hold off;set(gcf,'Visible','on');
set(gca,'FontName',FntNm);xlabel('t');ylabel('z(t), z^{\alpha}(t)');
title('Выбор параметра по ОПН и априорный выбор \alpha_{\eta}=C(\delta^2+h^2)');
legend('точное реш.','ОПН','C=0.5','C=1','C=2',2)
hh=text(t(40),mean(z)/2,'ОПН: \alpha');set(hh,'FontName',FntNm);
text(t(80),mean(z)/2,num2str(alf));
hh=text(t(40),mean(z)/3,'   Отн. ошибкa');set(hh,'FontName',FntNm);
text(t(80),mean(z)/3,num2str(ero));
hh=text(t(40),mean(z)/4,'   Отн. невязка');set(hh,'FontName',FntNm);
text(t(80),mean(z)/4,num2str(diso));
set(gcf,'Name','Тихоновская регуляризация','NumberTitle','off')
disp('%%%%%%%%%%%%%%% Конец %%%%%%%%%%%%%%%%%%%%');

