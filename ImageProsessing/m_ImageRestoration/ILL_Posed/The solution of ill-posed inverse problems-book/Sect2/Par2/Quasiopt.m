%  Quasiopt

%  Решение СЛАУ Az=u с возмущенной матрицей методом регуляризации 0-го порядка 
%  (нахождение нормального псевдорешения).
%  Выбор параметра регуляризации по теоретически обоснованным методам: 
%  обобщенному принципу невязки, обобщенному принципу сглаживающего функционала.
%  Сравнение с теоретически ошибочным выбором параметра по L-кривой.
%  Сравнение теоретически обоснованного обобщенного квазиоптимального выбора параметра
%  и обычного квазиоптимального выбора, применимого не всегда (с.55).
%  

clear all;close all
warning off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Пример, когда метод L-кривой дает плохой результат. 
%  При этом обобщенный принцип невязки (и функция pinv МАТЛАБа) работает хорошо.


BB=[];CC=[];DD=[];mu=0.4;AA=diag(ones(1,20))+diag(ones(1,19),1);
u1=ones(20,1);
hx=1;ht=1;[n,m]=size(AA);t=[1:n];x=[1:m];
z=pinv(AA)*u1;nr=norm(z);
%

disp(' ');disp(' Сравнение теоретически ошибочного метода L-кривой и теоретически');
disp('    обоснованных способов выбора параметра регуляризации');
disp('    при решении СЛАУ методом регуляризации А.Н.Тихонова (с.55)');disp(' ');
disp('      Нажмите любую клавишу для показа структуры матрицы системы. ');
disp(' ');pause
figure(21);A0=zeros(size(AA));A0(20,1)=1;spy(AA);
hold on;spy(A0,'r');hold off;title('');
set(gcf,'Name',' Структура точной и приближенной матрицы','Number','off');


disp(['      cond(A) = ' num2str(cond(AA))]);
disp('      Отличные от нуля элементы точной матрицы -- синие точки. ');
disp('      Возмущение, внесенное в точную матрицу -- красная точка. ');

delta=0.001;hdelta=0.001;C=1.1;
RN1=randn(m,1);%RN1=2*(rand(n,1)-0.5);
u=u1+delta*norm(u1)*RN1/norm(RN1);
RK1=(randn(size(AA)));%RN1=2*(rand(size(K1))-0.5);
A=AA+hdelta*norm(AA)*RK1/norm(RK1);
disp(' ');disp(['  Относ. ошибки данных: delta = ' num2str(delta) '  h = ' num2str(hdelta)]);
disp(' ');
disp(' ');
disp('      Нажмите любую клавишу для выбора параметра alpha. ');disp(' ');pause

% Вычисление основных функций, по которым выбирается параметр:
q=0.4;NN=25;
%     Задание регуляризатора
reg=0;% регуляризатор 0-го порядка
[Alf,Opt,Dis,Nz,VV,Tf,Dz,Ur]=func_calc(A,u,hx,ht,hdelta,delta,C,q,NN,z,reg);

Del=delta*norm(u)+hdelta*norm(A)*Nz;

% Выбор параметра по различным критериям:
[xxa,yya]=kriv(log10(Dis),log10(Nz));xxa=xxa+1;
ix=min(find(Dis<=Del));iix=min(find(Tf<=C*Del.^2));
[vm,iv]=min(VV);
[um,iu]=min(Ur);
[zm,iz]=min(Opt);


% Графическое отображение правил выбора параметра:
figure(22);
subplot (2,2,1);plot(log10(Alf),Dis, 'r.-',log10(Alf),Del,'k-',... %[-18 log10(max(Alf))],[Del Del], 'k-',...
   log10(Alf(ix)),Dis(ix),'bo');
xlabel('log_{10}(\alpha)');
set(gca,'FontName',FntNm,'XLim',[-18 log10(max(Alf))],'YLim',[0 0.2]);
title('ОПН');text(-1,delta,'\delta')
h6=legend ('||Az^{\alpha}-u||','\Delta (\delta,h,z^{\alpha})',['\alpha=' num2str(Alf(ix))],2 );
set(h6,'FontSize',8);

subplot (2,2,2);plot(log10(Alf),Opt/max(Opt), 'r.-',log10(Alf),VV/max(VV),'-b',...
   log10(Alf),Ur/max(Ur),'.-k',...
  log10(Alf(iz)),Opt(iz),'r*',log10(Alf(iu)),Ur(iu)/max(Ur),'ok',...
  log10(Alf(iv)),VV(iv)/max(VV),'bo');%
xlabel('log_{10}(\alpha)');
set(gca,'FontName',FntNm,'FontSize',8,'XLim',[-18 log10(max(Alf))],'YLim',[0 1]);
title('Oптим. (квазиоп.) выбор ');
h6=legend ('~||z^{\alpha}-z_{exact}||' ,'~||\alpha dz^{\alpha}/d\alpha||',...
   '~Модиф. квазиопт.',...
   ['\alpha_{opt}=' num2str(Alf(iz))] , ['\alpha_{m.q.opt}=' num2str(Alf(iu))] ,2 );
set(h6,'FontSize',8);

subplot (2,2,3);plot(log10(Dis),log10(Nz),'.-',log10(Dis(xxa)),log10(Nz(xxa)),'ro',...
   log10(Dis(xxa)),log10(Nz(xxa)),'r.');axis equal;
set(gca,'FontName',FntNm);h6=legend('L-кривая',['\alpha=' num2str(Alf(xxa))],3);
set(h6,'FontSize',8);
xlabel('log_{10}(||Az^{\alpha}-u||)');
ylabel('log_{10}(||z^{\alpha}||)');

subplot (2,2,4);plot(log10(Alf),Tf, 'r.-',log10(Alf),C*Del.^2,'k-',... %[-18 log10(max(Alf))],[C*Del^2 C*Del^2], 'k-',...
   log10(Alf(iix)),Tf(iix),'bo');
xlabel('log_{10}(\alpha)');
set(gca,'FontName',FntNm,'XLim',[-18 log10(max(Alf))],'YLim',[0 0.02]);
title('OПСФ');
text(-1,delta^2,'C\delta^2');
h6=legend ('\alpha||z^{\alpha}||^2+||Az^{\alpha}-u||^2',...
   'C\Delta^2 (\delta,h,z^{\alpha})',['\alpha=' num2str(Alf(iix))],2 );
set(h6,'FontSize',8);
set(gcf,'Name','Выбор параметра','NumberTitle','off')

disp('      Нажмите любую клавишу для показа решений СЛАУ. ');disp(' ');pause


% Вычисление соответствующих приближений:
% Сравнение качества решений
[zrd,dis1]=tikh_alf11(A,u,ht,delta,Alf(ix),reg);
[zrk,dis1]=tikh_alf11(A,u,ht,delta,Alf(iu),reg);%iv
[zrl,dis1]=tikh_alf11(A,u,ht,delta,Alf(xxa),reg);
[zrs,dis1]=tikh_alf11(A,u,ht,delta,Alf(iix),reg);

erd=norm(zrd-z)/norm(z);erk=norm(zrk-z)/norm(z);
erl=norm(zrl-z)/norm(z);ers=norm(zrs-z)/norm(z);ero=[];
[nmm,ind]=min([erd erk erl ers ero]);

%if ~isequal(show_comp,0);
figure(23);plot(t,z,'k.-',t,zrd,'bo',t,zrk,'g^',t,zrl,'r.',t,zrs,'rx');
set(gca,'FontName',FntNm,'YLim',[-0.5 1.1*max(z)]);
xlabel('t');ylabel('z(t), z^{\alpha}(t)');
h7=legend('точное реш.','об. невязка','модиф. кв.опт. выбор','L-кривая','сглаж. ф-л',1);
set(h7,'Position', [0.543095 0.119936 0.35 0.201095],'FontSize',8);
hh=text(1,-0.15,'Отн. ошибки');set(hh,'FontName',FntNm,'FontSize',8);
hh=text(1,-0.25,['об.невязка: ' num2str(erd)]);set(hh,'FontName',FntNm,'FontSize',8);
hh=text(1,-0.32, ['мод.кв.опт:  ' num2str(erk)]);set(hh,'FontName',FntNm,'FontSize',8);
hh=text(1,-0.39,['L-кривая:    ' num2str(erl)]);set(hh,'FontName',FntNm,'FontSize',8);
hh=text(1,-0.46, ['об.сгл.ф-л:  ' num2str(ers)]);set(hh,'FontName',FntNm,'FontSize',8);
set(gcf,'Name','Сравнение решений','NumberTitle','off')
% end
disp(' ');disp(' Конец');

