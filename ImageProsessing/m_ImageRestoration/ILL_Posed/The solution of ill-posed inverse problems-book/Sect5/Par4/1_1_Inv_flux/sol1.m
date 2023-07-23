function [Bg]=sol1
%  В(u|_{outer}) - поток на внешней поверхности при (du/dn)|_{inner}=0;
%   Вычисление столбца В(u|_{outer}) при a=(du/dn)|_{inner}=0
global a gg u_ext  

[p,e,t]=initmesh('reactg');
[p,e,t]=refinemesh('reactg',p,e,t);[p,e,t]=refinemesh('reactg',p,e,t);
%[p,e,t]=refinemesh('reactg',p,e,t);
u=assempde('reacb',p,e,t,'1',0,0);% Стационарный случай
%                   p,e,t,c,a,f
%u1=parabolic(1,0:0.15:0.3,'reacb1',p,e,t,'x',0,0,1);u=u1(:,end);
s=[0:0.025:1];% Это определяет размер сетки потока на внешней границе
% Вычисление du/dn
[du1,du6]=calcflux(s,p,t,u,gg*u_ext);

Bg=[du6(1:end-1) du1];
%figure(11);pdeplot(p,e,t,'xydata',u);axis equal
