%  Ini_teplo

% Восстановление начального условия (температуры) по переопределению -- заданному  
% финальному распределению температуры в стержне, на концах которого поддерживается
% нулевая температура.

clear all;close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' ');disp(' Решение обратной ретроспективной задачи теплопроводности:');
disp(' восстановление начального условия (температуры) по переопределению --');
disp(' заданному финальному распределению температуры в стержне, на концах которого');
disp(' поддерживается нулевая температура (с.280).');disp(' ');

N=103;M=51;T=0.1;x=linspace(0,1,N);t=linspace(0,T,M);hx=x(2)-x(1);
% Точное начальное условие
v0=-(x-0.3).*(x-0.8);v0=0.5*(v0+abs(v0));
n=[1:30];% Число собственных функций
[nn,tt]=meshgrid(n,t);[nx,xx]=meshgrid(n,x);
vv0=repmat(v0,30,1);

% Решение начальной задачи
% U_t=U_xx, U(0,t)=U(1,t)=0, U(x,0)=v_0(x)
om=(pi*nn).^2;TT=exp(-om.*tt)';FF=sin(pi*nx.*xx)';% Строка - функция
Cn=trapz((vv0.*FF)')*hx;Un=diag(Cn)*FF;
u=sqrt(2)*Un'*TT;
%
disp(' ');disp(' Для просмотра точного решения прямой задачи нажмите <Ввод>');pause
disp('-----------------------------------------------------------------------------');
figure(1);mesh(t,x,u);set(gca,'FontName',FntNm);title('Решение прямой задачи v(x,t)');
xlabel('t');ylabel('x')

% U(x,t)|_{t=T} -- переопределение
U0=u(:,end);
delta=1e-4;load er_dat;
U=U0+delta*ru.*norm(U0)/norm(ru);

disp(' ');disp(' Для просмотра переопределения нажмите <Ввод>');pause
disp('-----------------------------------------------------------------------------');

figure(11);plot(x,U,'.-');set(gca,'FontName',FntNm);
title ('Переопределение -- финальное распределение температуры v(x,T)');xlabel('x');

disp(' ');disp(' Для решения обратной задачи без регуляризации нажмите <Ввод>');
disp(' ');pause
disp('-----------------------------------------------------------------------------');


% Базис для начального условия
bb=[];dun=[];U1=[];
Nbas=50;
for k=1:Nbas;b=zeros(1,N);b(2*k+1)=1;b(2*k)=0.5;b(2*k+2)=0.5;
  %  Просмотр базиса решения
  %figure(2);plot(x,b);hold on;pause
  bb=[bb;b];bas=repmat(b,30,1);
  Cn=trapz((bas.*FF)')*hx;Un=diag(Cn)*FF;u1=sqrt(2)*Un'*TT;
  U1=[U1 u1(:,end)];% базис 
end
%  Просмотр базиса данных
%  for k=1:Nbas;figure(2);plot(x,U1(:,k)');hold on;pause;end
%  Система для базисных коэффициентов: U1*c=U
c=U1\U;z=bb'*c;
figure(2);subplot(1,2,1);
plot(x,0.5*(z+abs(z)),x,v0,'r');set(gca,'YLim',[0 5],'FontName',FntNm);
title('Нерегуляризованное решение');
legend('Нерегуляриз. решение','Точное решение',1);
bas=repmat(z',30,1);
Cn=trapz((bas.*FF)')*hx;Un=diag(Cn)*FF;u1=sqrt(2)*Un'*TT;AU=u1(:,end);
subplot(2,2,4);plot(x,U,'r-',x(1:3:end),AU(1:3:end),'b.');xlabel('\alpha')
set(gca,'FontName',FntNm);title('Переопределение');legend('Заданное','Вычисленное',3);
disp(' ');
disp(['  Число обусловленности матрицы обратной задачи = ' num2str(cond(U1))]);

disp(' ');disp(' Для регуляризации обратной задачи нажмите <Ввод>');pause
disp('-----------------------------------------------------------------------------');
disp(' ');disp('   Решение обратной задачи методом регуляризации в W_2^1 ');
disp('   с автоматическим выбором параметра по ОПН.');pause(1)

L0=2*diag(ones(1,Nbas))/hx;L0(1,1)=2/hx;L0(Nbas,Nbas)=L0(1,1);
      L0=L0-diag(ones(1,Nbas-1),1)/hx-diag(ones(1,Nbas-1),-1)/hx;
      LL=L0+diag(ones(1,Nbas))*hx;
NV=[];ALF=[];OP=[];C=50;q=0.9;alf=1e-12*q;      
for k=1:30;alf=alf*q;
  c=inv(alf*LL+U1'*U1)*U1'*U;
  z=bb'*c;zz=0.5*(z+abs(z));bas=repmat(zz',30,1);
  Cn=trapz((bas.*FF)')*hx;Un=diag(Cn)*FF;u1=sqrt(2)*Un'*TT;AU=u1(:,end);
  nev=norm(AU-U)/norm(U);
  NV=[NV nev];ALF=[ALF alf];OP=[OP norm(zz'-v0)/norm(v0)];
  figure(3);subplot(1,2,1);plot(x,zz,x,v0,'r');set(gca,'FontName',FntNm);xlabel('x');
  title('Регуляризованное решение для данного \alpha');
  subplot(2,2,2);semilogx(ALF,NV,'r.-');set(gca,'FontName',FntNm);
  title(' Относит. невязка');
  subplot(2,2,4);loglog(ALF,OP,'r.-');set(gca,'FontName',FntNm);xlabel('\alpha')
  title(' Относит. наилучшая точность');pause(1);
end
mu=min(NV);ix=min(find((NV-mu)<=C*delta));alf1=ALF(ix);
c=inv(alf1*LL+U1'*U1)*U1'*U;z=bb'*c;zz=0.5*(z+abs(z));
bas=repmat(zz',30,1);
Cn=trapz((bas.*FF)')*hx;Un=diag(Cn)*FF;u1=sqrt(2)*Un'*TT;AU=u1(:,end);
figure(3);subplot(1,2,1);plot(x,zz,x,v0,'r');set(gca,'FontName',FntNm);xlabel('x');
hnd=legend('Прибл. решение','Точн. решение',2);
set(hnd,'Position',[ 0.1651 0.8673 0.2601 0.0870 ])
subplot(2,2,2);
semilogx(ALF,NV,'r.-',alf1,NV(ix),'or',[ALF(1) ALF(end)],[mu+delta mu+delta],...
  [ALF(1) ALF(end)],[mu+C*delta mu+C*delta],'b');set(gca,'FontName',FntNm);
title('Выбор параметра по ОПН');
subplot(2,2,4);plot(x,U,'r-',x(1:3:end),AU(1:3:end),'b.');xlabel('\alpha')
set(gca,'FontName',FntNm);title('Переопределение');legend('Заданное','Вычисленное',3);

disp(' ');disp('   Результаты применения алгоритма ОПН.');
disp([' Относительная ошибка данных = ' num2str(delta)]);
disp([' Параметр регуляризации = ' num2str(alf1)]);
disp([' Относительная точность приближенного решения (L_2)= ' num2str(OP(ix))]);
disp(' ');disp('%%%%%%%%%%%%%%%%%%%%%%% Конец %%%%%%%%%%%%%%%%%%%%%%%%%%%% ');




