numc=[8,6];denc=conv([1,0,0],conv([1,15],[1,6,10]));
[numc,denc]=cloop(numc,denc,-1);GC=tf(numc,denc)
%计算传递函数
numc=[8,6];denc=conv([1,0,0],conv([1,15],[1,6,10]));
figure(1);
step(numc,denc);
grid on
%绘制阶跃响应曲线
figure(2);
bode(numc,denc);
grid on
%绘制伯德图
[Gm,Pm]=margin(GC)%求稳定裕量，相位裕量。