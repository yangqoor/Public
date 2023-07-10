
% 定义分段函数
syms x
%            变量 分段点     每段上的函数         端点处的函数
f=piecewiseSym(x,[-1,1],[-x-1,-x^2+1,(x-1)^3],[-x-1,(x-1)^3]);
% 求解
S=solve(f==.4,x)
% 绘图
xx=linspace(-2,2,500);
f=matlabFunction(f);
yy=f(xx);
plot(xx,yy,'LineWidth',2);

hold on
scatter(double(S),.4.*ones(length(S),1),50,'filled')


