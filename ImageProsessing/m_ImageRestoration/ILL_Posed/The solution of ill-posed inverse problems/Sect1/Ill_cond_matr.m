% Ill_cond_matr

%   Решение модельной СЛАУ с матрицей Гильберта - пример плохо обусловленной
%   задачи линейной алгебры. Сравнение с матрицей Тёплица средней обусловленности
%   (с.32 - 36).
clear all
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=25;
disp(' ');disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ');disp(' ');
disp(' Пример плохо обусловленной задачи линейной алгебры.');
disp(' ');disp('  Решение СЛАУ с матрицей Гильберта A=[1/(i+j-1)]');
disp(['  порядка ' num2str(N) ' для разных уровней ошибки delta']);disp(' ');
disp(' ');
disp(' Для сравнения решается СЛАУ с матрицей Тёплица A=[1/(1+|i-j|/N)]');
disp(' средней обусловленности для разных delta (см. с.32 - 36)');disp(' ');

disp(' ');disp('  Модельное точное решение z=1');disp(' ');
disp('--------------------------------------------------------------------------');
disp(' Нажмите любую клавишу для начала вычислений!');disp(' ');
pause

A=hilb(N);ca=cond(A);% A=1/(i+j-1) -- матрица Гильберта N-го порядка
B=toeplitz([1./(1+([0:N-1]))]);cb=cond(B);
%B=toeplitz([1./(1+abs([0:N-1]./N))]);cb=cond(B);
disp(['   Число обусловленности матрицы Гильберта= ' num2str(ca)]);disp(' ');
disp(['   Число обусловленности матрицы Тёплица= ' num2str(cb)]);disp(' ');


z=ones(size(A,1),1);
u=A*z;u1=B*z;
%zz=invhilb(N)*u;
rr=randn(size(u));RA=randn(size(A));
del=0.01;Del=[];ER=[];ERP=[];ERT=[];CA=[];ERt=[];ERPt=[];ERTi=[];
warning off

for kk=1:8;del=del*0.1;Del=[Del del];
   ud=(u+del*rr/norm(rr));% Возмущения правой части СЛАУ
   ud1=(u1+del*rr/norm(rr));% Возмущения правой части СЛАУ
   AA=A+0.00001*del*RA/norm(RA);% Малые возмущения самой матрицы Гильберта
   zz=invhilb(N)*ud;% Точное Обращение матрицы Гильберта
   zp=pinv(AA)*ud;% МНК
Er=norm(z-zz)/norm(z);ER=[ER Er];Erp=norm(z-zp)/norm(z);ERP=[ERP Erp];
   BB=B+del*RA/norm(RA);% Малые возмущения самой матрицы Тёплица
   zzt=inv(BB)*ud1;% Точное oбращение матрицы Тёплица
   zpt=pinv(BB)*ud1;% МНК
Ertt=norm(z-zzt)/norm(z);ERt=[ERt Ertt];Erpt=norm(z-zpt)/norm(z);ERPt=[ERPt Erpt];

disp('--------------------------------------------------------------------------');
disp(' ');disp(['     Матрицы с возмущением delta = ' num2str(del)]);disp(' ');
disp('         Нажмите любую клавишу для получения результата!')
pause;

Mzz=max(abs(zp));
figure(1);subplot(2,1,1);plot([1:N],z,'kx-',[1:N],zz,'b-',[1:N],zp,'ro-');
set(gca,'YLim',[-Mzz Mzz]);
set(gca,'FontName',FntNm,'XLim',[1 N]);
title('Решение системы с матрицей Гильберта. ');
legend('z=1','z_{\delta}=A^{-1}u_{\delta}',' z_{МНК}',2);
subplot(2,1,2);plot([1:N],z,'kx-',[1:N],zzt,'b.',[1:N],zpt,'ro-');
set(gca,'FontName',FntNm,'XLim',[1 N]);%'YLim',HL,
title('Решение системы с матрицей Тёплица. ');
legend('z=1','z_{\delta}=A^{-1}u_{\delta}',' z_{МНК}',2);
set(gcf,'Name',['Матрица Гильберта и Тёплица. delta=' num2str(del)],'NumberTitle','off')


end

warning on
disp(' ');disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ');
disp(' ');disp('  Анализ ошибок полученных решений');disp(' ');
disp(' Нажмите любую клавишу!');
pause

figure(2);subplot(1,2,2);%plot(log10(Del),log10(ERt),'o-',log10(Del),log10(ERPt),'k.-')%,...
loglog((Del),(ERt),'.-',(Del),(ERPt),'ko-')
set(gca,'FontName',FntNm);xlabel('\delta');
title('Матрица Тёплица');ylabel('Относительная ошибка решения');
legend('Ошибка z_{\delta}','Ошибка z_{МНК}',2)%...
subplot(1,2,1);%plot(log10(Del),log10(ER),'o-',log10(Del),log10(ERP),'k.-')%,...
loglog((Del),(ER),'.-',(Del),(ERP),'ko-')
set(gca,'FontName',FntNm);xlabel('\delta');
ylabel('Относительная ошибка решения');title('Матрица Гильберта');
set(gcf,'Name',' Ошибки в зависимости от delta','NumberTitle','off')


disp(' ');disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ');
disp(' ');disp('  Анализ типа некорректности');disp(' ');
disp(' Нажмите любую клавишу!');
pause
%
s1=svd(A);
s2=svd(B);
figure(3);plot(log10(s1),'r.-');hold on;plot(log10(s2),'.-');hold off
set(gca,'FontName',FntNm);
title('Сравнение сингулярных чисел s_i матриц Гильберта и Тёплица');
ylabel('lg s_i');xlabel(' Номер i сингулярного числа')
legend(['Матрица Гильберта порядка N=' num2str(N)],...
   'Матрица [1/(1+|i-j|/N)]_{i,j=1,...,N}' ,1);
set(gcf,'Name',' Анализ типа некорректности','NumberTitle','off')

disp(' ');disp('%%%%%%%%%%%% Конец %%%%%%%%%%%%%%%%%%%%%%%% ');
disp(' ');
%
