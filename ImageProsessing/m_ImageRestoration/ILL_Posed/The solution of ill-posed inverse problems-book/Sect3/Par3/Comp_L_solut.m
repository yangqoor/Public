%  Comp_L_solut

% Нахождение L-псевдорешений с помощью синг. разложений
clear all;close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vvv=ver('MATLAB');nmver=str2num(vvv.Version);if nmver>6;
warning('off','MATLAB:dispatcher:InexactMatch');end

disp(' ');
disp('  Нахождение L-псевдорешений разных типов для интегрального уравнения (с.141).');
disp('  Сравнение при этом различных способов выбора параметра регуляризации');
disp('    Допустимые типы L-псевдорешений и их код:');
disp('      1 - псевдорешение в L_2 (регуляризация 0-го порядка)');
disp('      2 - L-псевдорешение с условиями z(a)=z(b)=0 (регуляризация 1-го порядка)');
disp('      3 - псевдорешение в W_2^1 с условиями dz/ds(a)=dz/ds(b)=0 (регуляризация 1-го порядка)');
disp('      4 - L-псевдорешение с условиями dz/ds(a)=dz/ds(b)=0 (регуляризация 2-го порядка)');
disp('      5 - псевдорешение в W_2^2 (регуляризация 2-го порядка)');
disp(' ');
disp('-------------------------------------------------------------------');


% Сетки
t=linspace(-1,1,121);ht=t(2)-t(1);n=length(t);%x=t;hx=ht;
x=linspace(-3,3,121);hx=x(2)-x(1);m=length(x);
[TT,XX]=meshgrid(t,x);
% Задание операторного уравнения:
p=4;
K1=1./(1+p*(XX-TT).^2);

%  Модельное решение и модельная правая часть:
zstr='(1-t.^2).^2';z=eval(zstr)';
[uu]=righ_hand(x,p,1);
u0=uu';

%  Возмущения данных:
delta=0.03;hdelta=0.0001;
C=1.2;ster=0;
RN1=randn(m,1);RN1(1)=0;RN1(end)=0;
RK1=(randn(size(K1)));%RN1=2*(rand(size(K1))-0.5);
if ster==1;load Error_Comp_L;end
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
   
figure(32);plot(x,u0,'r',x,u1,'b.');%(2:end-2)
set(gca,'FontName',FntNm);   
legend('Точная правая часть','Приближ. правая часть',1);
set(gcf,'Name','Правые части','NumberTitle','off')

disp(' ');Nom=input('    Задайте тип регуляризатора (тип L-псевдорешения) (1 - 5): ');

%     Задание регуляризатора
if Nom==1;reg=0;% Регуляризатор в L_2
elseif Nom==2;reg=1;% Регуляризатор в W_2^1 -- L-псевдорешение с нулевыми гр. условиями
elseif Nom==3;reg=21;% Регуляризатор в W_2^1 с условиями z'(a)=z'(b)=0
elseif Nom==4;reg=2;% Регуляризатор в W_2^2 -- L-псевдорешение с условиями z'(a)=z'(b)=0
elseif Nom==5;reg=22;% Регуляризатор в W_2^2 с условиями z'(a)=z'(b)=0
else disp(' Неопознанный регуляризатор. Повторите ввод.');return
end

[U,V,sig,X,y,w,sss]=L_reg(reg,A,u,hx,ht);
disp(['          Тип регуляризатора: ' sss]);
disp(' ');
disp('-------------------------------------------------------------------');

disp('    Нажмите любую клавишу для выбора alfa различными способами!');pause
disp(' ');

% Вычисление основных функций, по которым выбирается параметр:
q=0.4;NN=25;
[Alf,Opt,Dis,Nz,VV,Tf,Nzw,Ur]=func_calc4(A,u,U,V,sig,X,y,w,delta,C,q,NN,z,DDD);

Del=delta*norm(u)+hdelta*norm(A)*Nzw;%Nzw
% Выбор параметра по критериям:
[xxa,yya]=kriv4(log10(Dis),log10(Nzw));%xxa=xxa+1;
ix=min(find(Dis<=Del));iix=min(find(Tf<=C*Del.^2));
iv=min(find(Ur<=Del));
[zm,iz]=min(Opt);

% Графическое отображение правил выбора параметра:
NF=22;                             % VV
graphchoise(Alf,Dis,Del,ix,delta,Opt,Ur,iz,iv,[],[],Nzw,xxa,Tf,C,iix,NF,sss,Nom);

% Вычисление соответствующих приближений:
% Сравнение качества решений

[zrd,dis,gam,psi,ur_psi,dz]=Tikh_inv44(A,u,U,V,sig,X,y,w,Alf(ix),DDD);
[zrk,dis,gam,psi,ur_psi,dz]=Tikh_inv44(A,u,U,V,sig,X,y,w,Alf(iv),DDD);
[zrl,dis,gam,psi,ur_psi,dz]=Tikh_inv44(A,u,U,V,sig,X,y,w,Alf(xxa),DDD);
[zrs,dis,gam,psi,ur_psi,dz]=Tikh_inv44(A,u,U,V,sig,X,y,w,Alf(iix),DDD);

erd=norm(zrd-z)/norm(z);erk=norm(zrk-z)/norm(z);
erl=norm(zrl-z)/norm(z);ers=norm(zrs-z)/norm(z);ero=[];%

graphcompar(t,z,zrd,zrk,zrl,zrs,erd,erk,erl,ers,NF+1,sss,Nom);


disp(' ');disp('                  Конец');