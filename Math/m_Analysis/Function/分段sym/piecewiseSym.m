function pwFunc=piecewiseSym(x,waypoint,func,pfunc)
% @author : slandarer
%{
https://mp.weixin.qq.com/s?__biz=Mzg4MTcwODk5Ng==&mid=2247490262&idx=1&sn=
a355fec0c5f228e1433276ed9a1da68a&chksm=cf60807df817096be11424528015ca2b634
f0298a73fb360bbf53a7fe9b432d66df7086458fe&scene=178&cur_album_id=273608363
6160020481#rd
%}
% =======================================
% demo:MATLAB | solve函数求解析解时不支持分段函数的解决方案
% ---------------------------------------
% % 定义分段函数
% syms x
% f=piecewiseSym(x,[-1,1],[-x-1,-x^2+1,(x-1)^3],[-x-1,(x-1)^3]);
% % 求解
% S=solve(f==.4,x);
% % 绘图
% xx=linspace(-2,2,500);
% f=matlabFunction(f);
% yy=f(xx);
% 
% plot(xx,yy,'LineWidth',2);
% hold on
% scatter(double(S),.4.*ones(length(S),1),50,'filled') 

gSign=[1,heaviside(x-waypoint)*2-1];
lSign=[heaviside(waypoint-x)*2-1,1];


inSign=floor((gSign+lSign)/2);
onSign=1-abs(gSign(2:end));

inFunc=inSign.*func;
onFunc=onSign.*pfunc;

pwFunc=simplify(sum(inFunc)+sum(onFunc));
end