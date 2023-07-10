%  Reconstr_four
clear all;close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Реконструкция изображения с помощью Тихоновского алгоритма в пространствах
%  Соболева и Лебега. Реализация: преобразование Фурье + проектирование на конус 
%  неотрицательных функций. параметр регуляризации -- предвычислен.

disp(' ');disp(' Реконструкция изображения с помощью Тихоновского алгоритма');
disp(' в пространствах Соболева и Лебега с проектированием на R_{+}.');
disp('       Описание задач -- см. с.250 - 251');
disp(' ');

%disp(' ');
num_zad=input('     Введите номер задачи (1 -- 3):  ');disp(' ');
if isempty(num_zad)|abs((num_zad-2))>1;
    disp('     Номер неверный. Повторите ввод!');return;end

if num_zad==2;% Спутник
   load model1;
   n=min(size(M1));A=M1(1:n,1:n);alfa=1e-8;
   u=M1(n+1:2*n,1:n);
   figure(1);h1=subplot(2,2,1);imagesc(A);
   set(h1,'XTickLabel',[],'YTickLabel',[],'FontName',FntNm);
   axis square;title('Ядро')
   h2=subplot(2,2,2);imagesc(u);axis square;
   set(h2,'XTickLabel',[],'YTickLabel',[],'FontName',FntNm);
   title('Правая часть')
   title('Правая часть');set(gcf,'Name',' Данные задачи','NumberTitle','off')
elseif num_zad==1;% EL
   num_podzad=input('     delta=1.5% (1) или delta=8.5% (2)?:  ');disp(' ');
   if num_podzad==1;load model2;alfa=3e-8;else load datAuEL;alfa=5e-7;end;
   n=min(size(M1));A=M1(1:n,1:n);
   u=M1(n+1:2*n,1:n);
   figure(1);h1=subplot(2,2,1);imagesc(A);
   set(h1,'XTickLabel',[],'YTickLabel',[],'FontName',FntNm);
   axis square;title('Ядро')
   h2=subplot(2,2,2);imagesc(u);axis square;
   set(h2,'XTickLabel',[],'YTickLabel',[],'FontName',FntNm);
   title('Правая часть');set(gcf,'Name',' Данные задачи','NumberTitle','off')
else
   load datAu;%  Крест Эйнштейна
   n=min(size(M1));A=M1(1:n,1:n);alfa=0.05;
   u=M1(n+1:2*n,1:n);
   figure(1);h1=subplot(2,2,1);imagesc(A);
   set(h1,'XTickLabel',[],'YTickLabel',[],'FontName',FntNm);
   axis square;title('Ядро')
   h2=subplot(2,2,2);imagesc(u);axis square;
   set(h2,'XTickLabel',[],'YTickLabel',[],'FontName',FntNm);
   title('Правая часть')
   title('Правая часть');set(gcf,'Name',' Данные задачи','NumberTitle','off')
end        


%disp('    ');disp(' ');
disp('    Ошибки решений на различных классах функций:');disp(' ');
tikhpls(n,A,u,alfa,2);         
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%  Конец демонстрации  %%%%%%%%%%%%%%%%%%%%%%%%%%%');
%disp(' ');disp(' ');