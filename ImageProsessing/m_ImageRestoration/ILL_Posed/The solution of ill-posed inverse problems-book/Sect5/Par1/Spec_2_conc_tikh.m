%  Spec_2_conc_tikh

%  Определение концентраций веществ в смеси (по их спектрам и спектру смеси) 
%  с помощью метода регуляризации (выбор параметра по ОПН)

clear all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N=7;t=[1:N]';hx=0.01;ht=hx;C=1.1;
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

NRU=norm(RU);u1=u+delta*norm(u)*RU/NRU;
AA=A+hdelta*RA*norm(A)/norm(RA);

reg=0;% Регуляризатор в L_2

%    Сингулярное разложение матрицы
[L1,U,V,sig,X,y,w,sss]=L_reg1(reg,AA,u1,hx,ht);L=L1'*L1;

%    Тихоновская регуляризация: выбор параметра
q=0.94;NN=50;
[Alf,Opt,Dis,Nz,Nzw,Psi]=func_calc51(AA,u1,U,V,sig,X,y,w,delta,C,q,NN,z,[]);

Del=delta*norm(u)+hdelta*norm(AA)*Nz;
ix=min(find(Dis<=Del));if isempty(ix);ix=min(find(Dis<=10*Del));end
%figure(2);plot(log10(Alf),Dis,'.-',log10(Alf(ix)),Dis(ix),'ro',log10(Alf),Del);

%    Тихоновская регуляризация: вычисление решения
[zrd,dis,gam,dz,psi]=Tikh_inv55(AA,u1,U,V,sig,X,y,w,Alf(ix),[]);% SVD

zrd=0.5*(zrd+abs(zrd));% Проектирование на конус неотрицательных векторов
figure(1);
subplot(1,2,1);plot(log10(Alf),Dis/norm(u),'.-',log10(Alf(ix)),Dis(ix)/norm(u),'ro');
set(gca,'FontName',FntNm,'XLim',[min(log10(Alf)) max(log10(Alf))]);%,'YLim',[0 1]
xlabel('lg\alpha');ylabel('||Az^{\alpha}-u_{\delta}||/||u_{\delta}||');
title('Выбор \alpha(h,\delta) по ОПН')

subplot(1,2,2);hnd=plot(t,z,'r');set(hnd,'LineWidth',2);
hold on;plot(t,zrd,'.-',t,zrd,'o');hold off
set(gca,'FontName',FntNm,'YLim',[0 0.8],'XLim',[1 N]);
xlabel('k');ylabel('z_k, z^{\alpha}_k');
legend('Точное','ОПН',1)
title('Решения')
xlabel('Номер вещества');ylabel('Концентрации веществ')

disp(' ');
disp('  Определение концентраций веществ в смеси');
disp(' ');
disp('-------------------------------------------------');
disp('    Применение метода регуляризации');disp('     (выбор параметра по ОПН)');
disp(' ');
disp('         delta        Относит. ошибка решения');
Err=norm(z-zrd)/norm(z);
format long
disp([delta Err]);format short;
disp('-------------------------------------------------');

