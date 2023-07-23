function sol3(nfig)
% 
%  du/dn|_{outer}=А(du/dn)|_{inner} при В(u|_{outer})=0 ~ u|_{outer}=0
global a gg u_ext  

[p,e,t]=initmesh('reactg');
[p,e,t]=refinemesh('reactg',p,e,t);[p,e,t]=refinemesh('reactg',p,e,t);
%[p,e,t]=refinemesh('reactg',p,e,t);
u=assempde('reacb',p,e,t,'1',0,0);% Стационарный случай
 
k0=16.5;eta0=0.0115;T0=400;c=1;
T_calc=T0+(sqrt(u)-1)*k0/eta0;
figure(nfig);pdeplot(p,e,t,'xydata',T_calc);axis equal
set(gca,'FontName','Arial Cyr');
title('Распределение температуры для найденного решения, K^o');pause(1)
[dx,dy]=pdecgrad(p,t,c,u);
G=sqrt(dx.^2+dy.^2);GG=0.5*k0^2*G/eta0;
figure(nfig+1);pdeplot(p,e,t,'xydata',GG);axis equal
set(gca,'FontName','Arial Cyr');
title('Тепловые потоки в области для найденного решения, Вт/м^2');
