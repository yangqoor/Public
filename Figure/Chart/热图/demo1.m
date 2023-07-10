% demo1

% sq    : 方形(默认)
% pie   : 饼图
% circ  : 圆形
% oval  : 椭圆形
% hex   : 六边形
% asq   : 自带调整大小的方形
% acirc : 自带调整大小的圆形

% 绘制无负数的热图
figure()
Data=rand(25,30);
SHM=SHeatmap(Data,'Format','sq');
SHM=SHM.draw();


% 绘制有负数热图
figure()
Data=rand(12,12)-.5;
Data([4,5,13])=nan;

SHM=SHeatmap(Data,'Format','circ');
SHM=SHM.draw();

SHM.setText();
% clim([-1,1])
