% Ill_posed_type
%
% —равнение некоректных задач типа операторного уравнени€ 1 рода
% по скорости убывани€ сингул€рных чисел

clear all
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ');
disp('  Cравнение р€да некоректных задач -- дискретизированных операторных ');
disp('  уравнений 1 рода -- по скорости убывани€ сингул€рных чисел их матриц (с.37).');
disp(' ');
               
t=linspace(-1,1,125);x=t;n=length(t);h=t(2)-t(1);[XX,TT]=meshgrid(x,t);

K1=h*tril(ones(n));% —лабо некорректна€ задача (задача дифференцировани€)
K2=h*tril((XX-TT).^2.*exp(-(XX-TT)));% ”меренно некорректна€ задача с cond=infty
K3=h./(1+(XX-TT).^2);% —ильно некорректна€ задача
K4=h*exp(-XX.*TT);% —ильно некорректна€ задача

disp(' ');disp(' „исла обусловленности 4-х матриц (см. с.37):');disp(' ');
SK1=svd(K1);sk1=SK1/max(SK1);cond1=cond(K1);
SK2=svd(K2);sk2=SK2/max(SK2);cond2=cond(K2);
SK3=svd(K3);sk3=SK3/max(SK3);cond3=cond(K3);
SK4=svd(K4);sk4=SK4/max(SK4);cond4=cond(K4);
disp([' cond_1 = ' num2str(cond1) '; cond_2 = ' num2str(cond2) '; cond_3 = ' num2str(cond3) '; cond_4 = ' num2str(cond4)]);
disp(' ');

figure(11);semilogy(1:length(SK1),sk1,'.-');hold on;semilogy(1:length(SK2),sk2,'.-r');
semilogy(1:length(SK3),sk3,'.-g');semilogy(1:length(SK4),sk4,'.-k');
plot([1 125],[1e-16 1e-16],'--');hold off
set(gca,'FontName',FntNm);
title('Ћогарифм сингул€рных чисел матриц дл€ задач \int_{a}^{b}K(x,t)z(t)dt=u(x)')
legend ('K(x,t)=\{1,t<x; 0,t>x\}','K(x,t)=\{(x-t)^2*exp(-(x-t)),t<x; 0,t>x\}',...
    'K(x,t)=1/(1+(x-t)^2)','K(x,t)=exp(-xt)',1) ;
set(gcf,'Name','—равнение сингул€рных чисел задач','NumberTitle','off')



