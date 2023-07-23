% Smooth_infl

%  Влияние стабилизатора на качество приближенных решений с различной гладкостью.
%  
clear all
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vvv=ver('MATLAB');nmver=str2num(vvv.Version);if nmver>6;
warning('off','MATLAB:dispatcher:InexactMatch');end

disp(' ');disp('  Нахождение решений интегрального уравнения с ядром Пуассона.');
disp('  Задание различных регуляризаторов и различных по гладкости решений (c.143).');
disp(' ');

t=linspace(-1,1,151);ht=t(2)-t(1);n=length(t);
x=linspace(-3,3,151);hx=x(2)-x(1);m=length(x);
%n=121;ht=2/n;t=-1+ht*([1:n]-0.5);
%m=121;hx=2/n;x=-3+hx*([1:n]-0.);

[TT,XX]=meshgrid(t,x);qu=[0.5 ones(1,n-2) 0.5]';
SS=[];%NRPR=0;

disp(' Описание регуляризаторов:')
disp('    1. Тихоновский регуляризатор 0-го порядка (L_2)')
disp('    2. Регуляризатор в W_2^1 -- с гр.условиями: z(a)=z(b)=0')
disp('    3. Регуляризатор 1-го порядка (W_2^1). Гр.условия: dz/ds(a)=dz/ds(b)=0')
disp('    4. Регуляризатор 2-го порядка (W_2^2) с условиями z(a)=z(b)=dz/ds(a)=dz/ds(b)=0')

warning off
disp(' ');Nom=input('    Задайте тип регуляризатора (1 - 4): ');
disp('-------------------------------------------------------------------');

%     Задание регуляризатора
if Nom==1;reg=0;% Тихоновский регуляризатор 0-го порядка (L_2)
elseif Nom==2;reg=1;% Регуляризатор в W_2^1 -- с гр.условиями: z(a)=z(b)=0
elseif Nom==3;reg=21;% Регуляризатор 1-го порядка (W_2^1). Гр.условия: z'(a)=z'(b)=0
elseif Nom==4;reg=22;% Регуляризатор 2-го порядка (W_2^2) с условиями
                       %z(a)=z'(a)=z(b)=z'(b)=0
else disp('    Регуляризатор по умолчанию - №3');reg=21;
end

warning on
for kii=1:100;
disp(' ');
disp(' Описание задач (вид решения):')
disp('    0) z(s)=(1-t.^2).^2; 1) z(s)=(1-t.^2); 2) z(s)=3*(1-t.^2).^4')
disp('    3) z(s)=t; 4) z(s)=2t; 5) z(s)=1-abs(t); 6) z(s)=4*abs(t)')
disp('    7)  z(s)=abs(t.*(1-t)); 8) z(s)=(t.*(1-t)).^2')
disp('    9) z(s)=sign(sin(pi*t)).*sin(pi*t).^2; 10) z(s)=sin(pi*t).^2; 11) z(s)=sign(t)')


disp(' ');Nom=input('    Выберите номер решаемой задачи (0 - 11): ');
kk=Nom;
%  Модельные решения различной гладкости
if kk==0;zstr='(1-t.^2).^2';elseif kk==1;zstr='(1-t.^2)';
      elseif kk==2;zstr='3*(1-t.^2).^4';elseif kk==3;zstr='t';...
      elseif kk==4;zstr='2*t';elseif kk==5;zstr='1-abs(t)';elseif kk==6;zstr='4*abs(t)';...
      elseif kk==7;zstr='abs(t.*(1-t))';elseif kk==8;zstr='(t.*(1-t)).^2';...
      elseif kk==9;zstr='sign(sin(pi*t)).*sin(pi*t).^2';...
      elseif kk==10;zstr='sin(pi*t).^2';
      elseif kk==11;zstr='sign(t)';else disp('   Такой задачи нет!');return; end

z=eval(zstr)';

% Модельная задача: интегральное уравнение задачи продолжения потенциала
p=4;
K1=1./(1+p*(XX-TT).^2);
u0=K1*(qu.*z)*ht;
C=1.1;
%
%  Возмущения данных:
delta=0.02;hdelta=0.0001;
C=1.1;ster=1;% ster=1 - фиксированная эталонная ошибка; ster=0 - произвольная ошибка
RN1=randn(m,1);RN1(1)=0;RN1(end)=0;
RK1=(randn(size(K1)));
if ster==1;load sm_inf;end
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


[U,V,sig,X,y,w,sss]=L_reg2(reg,A,u,hx,ht);
disp(['          Тип регуляризатора: ' sss]);
disp(' ');

% Вычисление основных функций, по которым выбирается параметр:
q=0.4;NN=25;
[Alf,Opt,Dis,Nz,VV,Tf,Nzw,Ur]=func_calc4(A,u,U,V,sig,X,y,w,delta,C,q,NN,z,DDD);

Nzw=Nz;
Del=delta*norm(u)+hdelta*norm(A)*Nzw;
% Выбор параметра по критериям:
[xxa]=kriv1(log10(Dis),log10(Nzw),0);%xxa=xxa+1;
ix=min(find(Dis<=Del));iix=min(find(Tf<=C*Del.^2));
iv=min(find(Ur<=Del));
[zm,iz]=min(Opt);

% Графическое отображение правил выбора параметра:
NF=22;
graphchoise(Alf,Dis,Del,ix,delta,Opt,Ur,iz,iv,[],[],Nzw,xxa,Tf,C,iix,NF,sss,kk);

% Вычисление соответствующих приближений:
% Сравнение качества решений

[zrd,dis,gam,psi,ur_psi,dz]=Tikh_inv44(A,u,U,V,sig,X,y,w,Alf(ix),DDD);
[zrk,dis,gam,psi,ur_psi,dz]=Tikh_inv44(A,u,U,V,sig,X,y,w,Alf(iv),DDD);
[zrl,dis,gam,psi,ur_psi,dz]=Tikh_inv44(A,u,U,V,sig,X,y,w,Alf(xxa),DDD);
[zrs,dis,gam,psi,ur_psi,dz]=Tikh_inv44(A,u,U,V,sig,X,y,w,Alf(iix),DDD);


erd=norm(zrd-z)/norm(z);erk=norm(zrk-z)/norm(z);
erl=norm(zrl-z)/norm(z);ers=norm(zrs-z)/norm(z);ero=[];%ero=norm(zro-z)/norm(z);
[nmm,ind]=min([erd erk erl ers ero]);

graphcompar(t,z,zrd,zrk,zrl,zrs,erd,erk,erl,ers,NF+1,sss);

if ind==1;zre=zrd;alfa=Alf(ix);sr='ОПН';elseif ind==2;zre=zrk;alfa=Alf(iv);...
      sr='псевдоопт.';elseif ind==3;zre=zrl;alfa=Alf(xxa);sr='L-кривая';...
   else ind==4;zre=zrs;alfa=Alf(iix);sr='ОПСФ';end
 
figure(24);plot(t,z,'k',t,zre,'.-')
set(gca,'FontName',FntNm);xlabel('t');ylabel('z(t), z^{\alpha}(t)');
hh=text(t(30),mean(z)/4,['\alpha=' num2str(alfa)]);set(hh,'FontName',FntNm);
hh=text(t(70),mean(z)/4,['Точность=' num2str(nmm)]);set(hh,'FontName',FntNm);
legend('точное реш.',sr,2)
set(gcf,'Name',['Тихоновский регуляризатор №' num2str(reg)],'NumberTitle','off')

resh=input('      Задача решена. Хотите решить другую? (y/n): ','s');
disp('-------------------------------------------------------------------');

if strcmp(resh,'n');disp(' ');disp('                  Конец');return;end

end


