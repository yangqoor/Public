% Gravy1
%
% Решение двумерной обратной задачи гравиметрии на классе корректности -
% множестве эллипсов с одним и тем же центром (с.17 - 18).
clear all
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
H=-3;a=3;b=1;fi0=pi/6;

disp(' ');
disp(' Решение двумерной обратной задачи гравиметрии на классе ')
disp(' корректности - множестве эллипсов с одним и тем же центром (с.17 - 18).');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Модельный потенциал
N=59;M=11;phi=linspace(0,2*pi,N);h=phi(2)-phi(1);
r=linspace(0,1,M);[R,PHI]=meshgrid(r,phi);
RR=1./sqrt(cos(PHI-fi0).^2/a^2+sin(PHI-fi0).^2/b^2);
%x1=RR.*cos(PHI);y1=H+RR.*sin(PHI);%[N x M]

rr=1./sqrt(cos(phi-fi0).^2/a^2+sin(phi-fi0).^2/b^2);
x1=rr.*cos(phi);y1=H+rr.*sin(phi);
NN=71;x=linspace(-10,10,NN);[X,PHI]=meshgrid(x,phi);

z0=[a;b;fi0];
U=potenz1(z0,H,X,PHI,phi);

delta=0.05;
RN=randn(size(U));U1=U+RN*delta*norm(U)/norm(RN);
disp(' ');disp(['   Относительная точность данных = ' num2str(delta)]);disp(' ');
l=a+0.5;lx=l*cos(fi0);ly=l*sin(fi0);
l1=b+0.5;lx1=l1*cos(fi0+pi/2);ly1=l1*sin(fi0+pi/2);
figure(2);plot(x,U,'m',x,U1,'.',x,0*U,'k');hold on;
plot(x1,y1,'r',0,H,'or',[-lx lx],[H-ly H+ly],'r-',...
  [lx1 -lx1],[H+ly1 H-ly1],'r-');
hold off;axis equal;set(gca,'FontName',FntNm);
title('Данные задачи (сверху) и решения (внизу)')
legend('Точные данные','Приближенные данные','Земная поверхность','Точное решение',1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


disp(' ');disp('    Для перехода к решению обратной задачи');
          disp('    нажмите любую клавишу!');pause
          
niter=10;
if exist('fminunc');          
options=optimset('Display','iter','MaxIter',niter,'GradObj','off',...
   'LineSearchType','quadcubic','TolFun',1e-10,'MaxFunEvals',250,...
   'TolX',1e-10);% 'iter'
warning off

aaa0=[0.1 0.1 0]';%  Начальное приближение
disp(' ');disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' ');disp(['     Начальный цикл оптимизации. ' num2str(niter) ' итераций.']);
tic 
[aaa,nev_min]=fminunc('Gravy_nev1',aaa0,options,H,X,PHI,phi,U1);
%  fminsearch: 'MaxIter' >120 - не рекомендуется!
toc
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' ');
disp(' Точное решение:');disp(' ');
disp(['    a_exact = ' num2str(a) '  b_exact = ' num2str(b) ' phi_exact = ' num2str(fi0)])
disp(' ');
disp(' Приближенное решение:');disp(' ');

a_approx = aaa(1);
b_approx = aaa(2);
phi_approx=aaa(3);
disp(['    a_approx = ' num2str(a_approx) '  b_approx = ' num2str(b_approx) ' phi_approx = ' num2str(phi_approx)])
disp(' ');
disp(' Невязка точного и вычисленного потенциала и ошибки приближенного решения:');
disp(' ');
disp(['    nev_min = ' num2str(nev_min) '; Err_a (%) = ' num2str(100*abs(a-aaa(1))/a) '; Err_b (%) = ' num2str(100*abs(b-aaa(2))/b) '; Err_phi (%) = ' num2str(100*abs(fi0-aaa(3))/fi0)]);
disp(' ');

rr=1./sqrt(cos(phi-phi_approx).^2/a_approx^2+sin(phi-phi_approx).^2/b_approx^2);
x1=rr.*cos(phi);y1=H+rr.*sin(phi);
figure(2);hold on;
plot(x1,y1,'k');
hold off

disp('   Для продолжения решения нажмите любую клавишую');
disp('   Для прекращения процедуры -- Ctrl+C');disp(' ');pause


for nuntr=1:10;
disp(' ');disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp(' ');
disp(['     Цикл оптимизации № ' num2str(nuntr)]);
[aaa,nev_min]=fminunc('Gravy_nev1',aaa,options,H,X,PHI,phi,U1);

%   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ');disp(' ');disp('  Промежуточные результаты:');disp(' ');
disp(' Точное решение:');disp(' ');
disp(['    a_exact = ' num2str(a) '  b_exact = ' num2str(b) ' phi_exact = ' num2str(fi0)])
disp(' ');disp(' Приближенное решение:');disp(' ');

a_approx = aaa(1);
b_approx = aaa(2);
phi_approx=aaa(3);
disp(['    a_approx = ' num2str(a_approx ) '  b_approx = ' num2str(b_approx ) ' phi_approx = ' num2str(phi_approx)])
disp(' ');
disp(' Невязка точного и вычисленного потенциала и ошибки приближенного решения:');
disp(' ');
disp(['    nev_min = ' num2str(nev_min) '; Err_a (%) = ' num2str(100*abs(a-aaa(1))/a) '; Err_b (%) = ' num2str(100*abs(b-aaa(2))/b) '; Err_phi (%) = ' num2str(100*abs(fi0-aaa(3))/fi0)]);
disp(' ');

rr=1./sqrt(cos(phi-phi_approx).^2/a_approx^2+sin(phi-phi_approx).^2/b_approx^2);
x1=rr.*cos(phi);y1=H+rr.*sin(phi);
figure(2);hold on;
plot(x1,y1,'.b');
hold off


disp('   Для продолжения решения нажмите любую клавишую');
disp('   Для прекращения процедуры -- Ctrl+C');disp(' ');pause
end
else disp('   Optimization toolbox для МАТЛАБа не установлен на данном компьютере. ');
     disp('   Демонстрация прерывается.');end