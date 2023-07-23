%  Istok_OMK

% Специализированный обобощенный метод квазирешений на классах {(A'A)^(p/2)*v}
% Автоматический выбор параметров p, r (с.224).

% Используется SVERT, FUN1 и GRFUN1(вычисление квадратичного ф-ла и градиента)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Текущая задача: решение уравнения с истокопредставимым решением
% zt=А*(1-s^2); в этом случае p=0.5;здесь p0=0.032;r0=128;
%
%     Теоретическая оценка ошибки (Leonov A.S. and Yagola A.G. Inverse Problems, 
%                                  V.14 1998, p.1546):
%  ||z_appr -z||<=D_p *r^(1/(p+1))*(delta+del_A*r)^(p/(p+1))
%    D_p=sup{2*(1+|ln(h)|)*h^(min(1,p)-p/(p+1))+k^(p/(p+1)),  0<h<=h_0}
%         k=C+3+2 - при del_A>0, k=2 - при del_A=0 для разрешимых задач
%
if ~exist('fmincon');disp(' ');
  disp('  ВНИМАНИЕ! Демонстрация прерывается, т.к. на этой ЭВМ');
  disp('  не установлен компонент МАТЛАБа - Optimization Toolbox.');return;end

clear all;close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ');
disp(' Решение интегрального уравнения Фредгольма 1-го рода с ядром Пуассона');
disp(' и с истокопредставимым решением вида z=А*(1-s^2) (с.224).');
disp(' В этом случае z=[(A^*A)^(p/2)]v, где p=1 и r=||v||=2/3.');
disp(' Используется специализированный РА ОМК с дополнительной информацией ||v||<r0=128.');
disp(' Выбор величин p и r производится автоматически.');
disp(' Расчеты требуют сравнительно большого времени.');disp(' ');
 
n=100;h=1/(n-1);xs=[0:h:1]';[xx,ss]=meshgrid(xs,xs);
% Задание погрешностей и параметра алгоритма
delU=0.01;delA=0.00;C=2.;

disp(['   Ошибка правой части = ' num2str(delU*100) ' %']);disp(' ');pause(1)

% Задание точного решения (это - истокопредставимое с p=0.5)
zt=(1/2*log(2+xs.^2-2*xs)-xs.*atan(xs-1)-1/2*log(1+xs.^2)+xs.*atan(xs));
% Задание матрицы 
B=h./(1+(xx-ss).^2);
% Задание правой части (SVERT - функция А*Z(точное))
in=zeros(1,n);
for k=1:n,xx=(k-1)/(n-1);in(k)=quad('svert',0,1,[],[],xx);
end;uu=in';
% Возмущение матрицы и правой части
DB=(2*rand(n,n)-1);sDB=norm(DB,'fro');nrB=norm(B,'fro');
B=B+delA*nrB*DB/sDB;s=2*norm(B);A=B/s;
nrU=norm(uu);
du=(2*rand(size(uu))-1);sdu=norm(du);u=(uu+delU*nrU*du/sdu)/s;
% Алгоритм
[U,R,V]=svd(A);y=U'*u;
% Начальные параметры p,r; обычно (p0=0.032;r0=32;)
p0=0.032;r0=128;pp=p0;rd=r0;m=10;mp=10;% Число итераций по p и r
z1=zeros(n,1);Disc=zeros(1,mp);pq=zeros(1,mp);zz=zeros(1,m);
DD=zeros(mp,m);nR=norm(R);
warning off
options=...
  optimset('MaxIter',30,'Display','off','GradObj','on','GradConstr','on');%'off' 30
% 
h00=waitbar(0,'Wait for the end of optimization!');
tic
for l=1:mp,p=p0*2^l;G=(R'*R).^(p/2);H=R*G;
for k=1:m  
  r=r0*(0.5)^k;waitbar(l*k/mp/m,h00);  %disp(['   p r: ' num2str(p) '  ' num2str(r)]);
  if p>4;options=optimset('MaxIter',7,'Display','off');end
x=fmincon('fun1_1',r*z1,[],[],[],[],[],[],'grfun1_1',options,H,y,r,[]);
DD(l,k)=norm(H*x-y)/norm(y);
zz(k)=norm(V*G*x);
end
end;toc;% Значения невязки как функция p,r
close(h00)
mu=min(min(DD))*s;DEL=(C-1)*delU+delA+mu;
if min(DD)>DEL/s,disp(['WARNING!  Невязка>DEL']);else end;
% Выбор оптимальных параметров
%
K1=zeros(size(DD));L1=K1;for k=1:m;for l=1:mp;
Disc(l)=DD(l,k);P1(l,k)=p0*2^l;R1(l,k)=r0*(0.5)^k;
if Disc(l)<=DEL/s;K1(l,k)=k;L1(l,k)=l;else end
end;end
KKK=K1+L1;mmm=max(max(KKK));nr1=find(KKK==mmm);
pp=P1(round(nr1(2)));rd=R1(round(nr1(2)));
%  
disp(' ');
disp(' ');disp('----------------------------------------');
disp(['  Найденные параметры истокопредставимости  '])
disp(['     p      r     '])
disp([pp rd]) % Вычисленные параметры
disp('----------------------------------------');disp(' ');

G=(R'*R).^(pp/2);H=R*G;
options=...
  optimset('MaxIter',30,'Display','off','GradObj','on','GradConstr','on','TolFun',1e-10,'TolCon',1e-10,'TolX',1e-10);

x=fmincon('fun1_1',rd*z1,[],[],[],[],[],[],'grfun1_1',options,H,y,rd,[]);
z=V*G*x;DDD=norm(H*x-y)/norm(y);ERR=max(abs(z-zt))/max(abs(zt));
% Графика
figure(1);clf;mz=min(z);Mz=max(z);ytx=mz/2+0.05*(Mz-mz);
plot(xs,z,'r',xs,zt,xs,zeros(size(z)));set(gca,'FontName',FntNm);
legend('Прибл. решение','Точн. решение',2);
h5=text(0.05,ytx,'Невязка=');set(h5,'FontName',FntNm);
h5=text(0.2,ytx,num2str(DDD));set(h5,'FontName',FntNm);
h5=text(0.4,ytx,'Отн. ошибка:');set(h5,'FontName',FntNm);
h5=text(0.6,ytx,num2str(ERR));set(h5,'FontName',FntNm);
title('Решение');xlabel('x');ylabel('Решение');
k=[1:m];l=[1:mp];r1=k;p1=l;[yr,xp]=meshgrid(p1,r1);
disp('----------------------------------------');disp(' ');
disp('  Для продолжения нажмите любую клавишу!');
disp('  Будет выдана зависимость невязки от p и r');disp(' ');pause;
disp('----------------------------------------');disp(' ');


figure(2);clf
surfl(yr,xp,DD');set(gca,'FontName',FntNm);
xlabel('Степень m из p=p0*2^m');ylabel('Степень k из r=r0*(1/2)^k')
title('Невязка(p,r)')
disp('----------------------------------------');disp(' ');
disp('  Для продолжения нажмите любую клавишу!');
disp('  Будет выдана линия уровня невязки Nev=delta в зависимости от p и r');
disp(' ');pause;
disp('----------------------------------------');disp(' ');


figure(3);clf
hold on;contour(yr,xp,DD',[DEL/s DEL/s],'k');grid on
plot(log2(pp/p0),log2(r0/rd),'ro');hold off;set(gca,'FontName',FntNm);
xlabel('Степень m из формулы p=p0*2^m (p0=0.032)');
ylabel('Степень k из формулы r=r0*(1/2)^k (r0=128)')
title('Линия уровня невязки: невязка = \delta; о - оптимальные (p,r)')

disp('----------------------------------------');disp(' ');
disp([' Относительная ошибка приближения в (L_2) = ' num2str(ERR)]);disp(' ');
disp(' Апостериорная оценка ошибки приближения согласно теореме 25, (4.8):');
disp(['     относит. апостер. ошибка (L_2) = ' num2str(rd^(1/(pp+1))*(2*delU*norm(u)/s)^(pp/(pp+1))/norm(zt))]);
disp(' ');disp('----------------------------------------');
disp('%%%%%%%%%%%%%%%%%% Конец %%%%%%%%%%%%%%%%%%% ');