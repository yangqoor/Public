%  Spec_2_conc_tsvd

%  Определение концентраций веществ в смеси (по их спектрам и спектру смеси) 
%  с помощью алгоритма TSVD

clear all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vvv=ver('MATLAB');nmver=str2num(vvv.Version);if nmver>6;
warning('off','MATLAB:dispatcher:InexactMatch');end

N=7;t=[1:N]';hx=0.01;ht=hx;C=1.5;
L=diag([1 ones(1,N-2) 1])*sqrt(ht);

load mod_2.mat
A=AB;z=[0 0.1 0 0.25 0 0 0.55]';u=A*z;% b=ub;
%  Априорные уровни относительных ошибок
delta=1*10^(-2);hdelta=0.01;DD=log10(delta);

%  Возмущения
ind_err=0;% Стандартная ошибка для сравнения разных алгоритмов
% 
if ind_err==0;load err_spec;
else RU=randn(size(u));RA=randn(size(A));end

NRU=norm(RU);b=u+delta*norm(u)*RU/NRU;
AA=A+hdelta*RA*norm(A)/norm(RA);

[U,V,sm,X] = gsvd(AA,L);% модуль Хансена
Dis=[];NT=6;xx_k=[];
for k=1:NT;
  x_k = tgsvd(U,sm,X,b,k);% модуль Хансена
  dis=norm(AA*x_k-b)/norm(b);Dis=[Dis dis];xx_k=[xx_k norm(x_k)];
end
%ix=min(find(Dis<delta));
[ix1] = l_curve1(U,sm,b,L,V,1);%pause
DD=log10(C*(delta+hdelta*xx_k));ix=min(find(log10(Dis)<DD));
figure(20);
subplot(2,2,3);plot([1:NT],log10(Dis),'.-',[1:NT],[DD],'r',ix,log10(Dis(ix)),'ro',...
  ix1,log10(Dis(ix1)),'r*');
%text(0.5,DD,'\delta')
set(gca,'FontName',FntNm,'FontSize',9);%,'YLim',[0 1]
xlabel('k - параметр TSVD');%ylabel('lg{||Az_k-u_{\delta}||}, lg{C(\delta + h||z_k||)}');
title('Выбор k(\delta,h) по ОПН (o) и по L-кривой (*)')
legend('lg{||Az_k-u_{\delta}||}','lg{C(\delta + h||z_k||)}',3)

x_k = tgsvd(U,sm,X,b,ix);x_k1 = tgsvd(U,sm,X,b,ix1);

%  Проектирование на конус неотрицательных векторов
x_k=0.5*(x_k+abs(x_k));x_k1=0.5*(x_k1+abs(x_k1));

subplot(1,2,2);hnd=plot(t,z,'r');set(hnd,'LineWidth',2);
hold on;plot(t,x_k,'.-',t,x_k1,'ko-');hold off
set(gca,'FontName',FntNm);
legend('Точное','ОПН','L-кривая',1)
set(gca,'FontName',FntNm,'YLim',[0 0.8],'XLim',[1 N]);
title('Точное и приближенные решения')
xlabel('Номер вещества');ylabel('Концентрации веществ')

Err=norm(z-x_k)/norm(z);ErrL=norm(z-x_k1)/norm(z);
disp(' ');
disp('  Определение концентраций веществ в смеси');
disp(' ');
disp('-----------------------------------------------------------');
disp('        Применение метода TSVD');
disp('        (выбор параметра по ОПН  и по L-кривой)');
disp(' ');
disp('         delta         Относительные ошибки решений по TSVD');
disp('                            ОПН              L-кривая');

format long
disp([delta Err ErrL]);format short;
disp('-----------------------------------------------------------');

