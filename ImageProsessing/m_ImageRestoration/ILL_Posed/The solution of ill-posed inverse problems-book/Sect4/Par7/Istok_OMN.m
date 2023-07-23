%    Istok_OMN
% Алгоритм ОМН на классе z=(A'A)^(p/2)v
% Выбор оптимальной степени р (с.224)
% 

clear all
close all

if ~exist('fmincon');disp(' ');
  disp('  ВНИМАНИЕ! Демонстрация прерывается, т.к. на этой ЭВМ');
  disp('  не установлен компонент МАТЛАБа - Optimization Toolbox.');return;end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n=50;h=1/(n-1);xs=[0:h:1]';[xx,ss]=meshgrid(xs,xs);
% Задание погрешности и параметра алгоритма
delU=0.01;delA=0.0001;
C=1.1;

%  Задачи из примера 49
% Задание точного решения и точной правой части

disp(' ');disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' ');
disp('   Решается интегральное уравнение Фредгольма 1 рода с ядром -- функцией Грина (пример 49).');
disp('     Алгоритм -- специализированный обобщенный метод невязки');
disp('     для истокопредставимых решений с неизвестной степенью (с.224)');disp(' ');
disp(' ');
disp(['       Уровни возмущения данных: delta_u = ' num2str(delU*100) ' %; delta_A = ' num2str(delA*100) ' %']);
disp(' ');
disp('    Описание возможных задач: 1) точное решение z=2*(s-s.^3) (p<5/4)');
disp('                              2) точное решение z=s (p<1/4)');
disp('                              3) точное решение z=16*sin(4*pi*s) (любое p>0)');
disp(' ');
zad=input('          Введите номер задачи (1-3): ');
if isempty(zad)|abs((zad-2))>1;
    disp('     Номер неверный. Повторите ввод!');return;end
disp(['        Решается задача № ' num2str(zad)]);disp(' ');
if zad==1;zt=2*(xs-xs.^3);uu=(1/30)*(7*xs-10*xs.^3+3*xs.^5);r0=16;%  p<5/4
elseif zad==2;zt=xs;uu=(xs-xs.^3)/6;r0=32;% p<1/4
elseif zad==3;zt=16*sin(4*pi*xs);uu=sin(4*pi*xs)/pi^2;r0=512;% любое p>0
else disp('');return;end

% Задание матрицы 
xl=tril(xx);sl=tril(ss);zzz=(1-sl).*(xl);
zzd=diag(diag(zzz));xu=triu(xx);su=triu(ss);
B=h*(zzz-zzd+(1-xu).*(su));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Возмущение данных
%
ster=0;% Стандартная ошибка ster=0
if ster==0;
  if zad==1;load stand_err;elseif zad==2;load stand_err1;elseif zad==3;load stand_err2;end
else DB=randn(n,n);du=randn(size(uu));end
%
% load stand_err -- 1-я задача;  load stand_err -- 2-я задача;  load stand_err2 -- 3-я задача
sDB=norm(DB);nrB=norm(B);
B=B+delA*nrB*DB/sDB;s=norm(B);A=B/s;
nrU=norm(uu);
%
sdu=norm(du);u=(uu/nrU+delU*du/sdu)/s;

% Алгоритм
[U,R,V]=svd(A);y=U'*u;
x0=pinv(R)*y;mu=norm(R*x0-y);s1=norm(y);nR=norm(R);
p0=8;mp=7;q=0.5;
z1=zeros(n,1);

warning off
options=...
  optimset('MaxIter',40,'Diagnostics','off','Display','off','GradObj','on','GradConstr','on');
hhh = waitbar(0,'Please wait...');
tic
for l=1:mp,p=p0*(q)^l;G=(R'*R).^(p/2);H=R*G;
  DEL(l)=delU*s1+delA*nR^(1+p)*s^(p/2)*r0+mu;DLL=DEL(l);
   % Начальное приближение из условия inf(Невязка)
   x0=fmincon('fun1_1',r0*z1,[],[],[],[],[],[],'grfun1_1',options,H,y,r0,DLL);
   if norm(H*x0-y)<= DEL,ind=1;else ind=[];end;
   %
   if ~isempty(ind), % Случай невязка < DEL/s1
     x=fmincon('fun1_2',x0,[],[],[],[],[],[],'grfun1_2',options,H,y,r0,DLL);
DD(l)=norm(H*x-y)/s1;% Невязки на экстремали как F(p)
zz(l)=norm(V*G*x);% Норма прибл. решения как F(p)
else DD(l)=norm(H*x0-y)/s1;zz(l)=r0;end % Невязка > DEL/s1
waitbar(l/mp,hhh)
end;toc;close(hhh)

jj=find((C*DEL./s1-DD)>0);
jjm=min(jj);p=p0*(q)^jjm;

figure(1);clf;l=[1:mp];pp=p0*(q).^l;D0=zeros(size(pp));
D1=C*DEL./s1;hold on;
hhhh=plot(pp,DD,'.-',pp,D1,'r',pp,D0,'ko',p,C*DEL(jjm)/s1,'ro');
set(gca,'FontName',FntNm);
xlabel('p');ylabel('Невязка(p)');title('Выбор оптимального параметра p');
legend(hhhh,'Относ. невязка','Уровень DEL','сетка по p','Выбранное р');hold off
disp(' ');disp('     Выбор оптимального параметра p (см. график).');
disp([' Автоматически найденная оптимальная степень истокопредставимости: p= ' num2str(p)])
disp('       Для продолжения нажмите любую клавишу!');pause;
G=(R'*R).^(p/2);H=R*G;


DLL=DEL(jjm);
x0=fmincon('fun1_1',r0*z1,[],[],[],[],[],[],'grfun1_1',options,H,y,r0,DLL);
x=fmincon('fun1_2',x0,[],[],[],[],[],[],'grfun1_2',options,H,y,r0,DLL);

z=nrU*V*G*x;DDD=norm(H*x-y)/norm(y);ERR=max(abs(z-zt))/max(abs(zt));
% Графика
figure(2);clf;mz=min(z);Mz=max(z);ytx=mz/2+0.05*(Mz-mz);
plot(xs,z,'r',xs,zt,xs,-0.5*ones(size(z)),'w');set(gca,'FontName',FntNm);
legend('Прибл. решение','Точн. решение',2);
h5=text(0.04,ytx,'Отн. невязка: ');set(h5,'FontName',FntNm);
h5=text(0.25,ytx,num2str(round(DDD*1e4)*1e-4));set(h5,'FontName',FntNm);
h5=text(0.38,ytx,'Отн. ошибка: ');set(h5,'FontName',FntNm);
h5=text(0.59,ytx,num2str(round(ERR*1e4)*1e-4));set(h5,'FontName',FntNm);
h5=text(0.76,ytx,'p(oптим.):');set(h5,'FontName',FntNm);
h5=text(0.92,ytx,num2str(p));set(h5,'FontName',FntNm);
title('Решение');xlabel('x');ylabel('Решение');

disp(' ');

disp('%%%%%%%%%%%%%%%%%%%%%%%%% Конец %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
