%  SVD_vs_Direct

% Метод регуляризации. Реализация с помощью синг. разложения и без него (c.137).

clear all;close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(' ');
disp('  Сравнение реализаций метода регуляризации:');
disp('          без SVD и с SVD (c.137)');
disp(' ');

M=input(' Введите размерность задачи (для быстроты рекомендуется < 301): N=M=');disp(' ');

if M>301;M=301;disp('   Нарушена рекомендация. Считаем N=M=301.'); end
% Сетки
t=linspace(-1,1,M);ht=t(2)-t(1);n=length(t);%x=t;hx=ht;
x=linspace(-3,3,M);hx=x(2)-x(1);m=length(x);
[TT,XX]=meshgrid(t,x);
% Задание операторного уравнения:
K1=1./(1+(XX-TT).^2);

%  Модельное решение и модельная правая часть:
zstr='(1-t.^2).^2';z=eval(zstr)';
uu=(-atan(x-1)+atan(x+1)).*x.^4+(2.*log(2+x.^2-2.*x)-...
   2.*log(2+x.^2+2.*x)).*x.^3+(6+8.*atan(x-1)-...
   8.*atan(x+1)).*x.^2+(-4.*log(2+x.^2-2.*x)+4.*log(2+x.^2+2.*x)).*x-...
   4.*atan(x-1)-16./3+4.*atan(x+1);
u0=uu';

%  Возмущения данных:
delta=0.02;hdelta=0.0001;
C=1.1;
RN1=randn(m,1);RN1(1)=0;RN1(end)=0;
RK1=(randn(size(K1)));%RN1=2*(rand(size(K1))-0.5);
%load SVD_vs
u1=u0+delta*norm(u0)*RN1/norm(RN1);
AA=K1+hdelta*norm(K1)*RK1/norm(RK1);

% Преобразование данных в матричную форму:
Hx=ones(1,m)*hx;Hx(1)=0.5*Hx(1);Hx(end)=Hx(1);
Ht=ones(1,n)*ht;Ht(1)=0.5*Ht(1);Ht(end)=Ht(1);
HHx=repmat(sqrt(Hx)',1,n);HHt=repmat(Ht,m,1);
A=AA.*HHx.*HHt;% -- матрица системы

%  Преобразованная правая часть:
u=u1.*sqrt(Hx');% -- правая часть системы
DDD=delta*norm(u)+hdelta*norm(A);

disp(' ');disp(['  Ошибки данных: delta = ' num2str(delta) '  h = ' num2str(hdelta)]);
disp(' ');disp(['  Число обусловленности матрицы = ' num2str(cond(A))]);disp(' ');
   
%     Задание регуляризатора
reg=21;% Регуляризатор в W_2^1 с условиями z'(a)=z'(b)=0

disp('  Реализация с сингулярным разложением:')
tic
[L1,U,V,sig,X,y,w,sss]=L_reg1(reg,A,u,hx,ht);L=L1'*L1;

%    Реализация с сингулярным разложением

% Вычисление основных функций, по которым выбирается параметр:
q=0.4;NN=25;
[Alf,Opt,Dis,Nz,Nzw]=func_calc5(A,u,U,V,sig,X,y,w,delta,C,q,NN,z,DDD);

Del=delta*norm(u)+hdelta*norm(A)*Nz;
ix=min(find(Dis<=Del));%[zm,iz]=min(Opt);
[zrd,dis,gam,dz]=Tikh_inv55(A,u,U,V,sig,X,y,w,Alf(ix),DDD);toc

%figure(101);plot(log10(Alf),Dis, 'b.-',log10(Alf),Del,'k-',...
%   log10(Alf(ix)),Dis(ix),'bo');hold on;

disp('  Реализация без сингулярного разложения:');
tic
[zro,diso,alf]=Tikh_reg_discr5(A,u,L,delta,hdelta,C,q,NN);
toc

erd=norm(zrd-z)/norm(z);ero=norm(zro-z)/norm(z);%

figure(32);plot(x,u0,'r',x,u1,'b.');%(2:end-2)
set(gca,'FontName',FntNm);   
legend('Точная правая часть','Приближ. правая часть',1);
set(gcf,'Name','Правые части','NumberTitle','off')

figure(1);plot(t,z,'k',t,zrd,'.-',t,zro,'.-')
set(gca,'FontName',FntNm,'YLim',[min(z) 1.1*max(z)]);
xlabel('t');ylabel('z(t), z^{\alpha}(t)');title(' Точное и приближенное решение')
legend('Точное решение','Прибл. решение (SVD)','Прибл. решение (без SVD)',1);



disp(' ');disp('                  Конец');