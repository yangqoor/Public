% demo3
% sq    : 方形(默认)
% pie   : 饼图
% circ  : 圆形
% oval  : 椭圆形
% hex   : 六边形
% asq   : 自带调整大小的方形
% acirc : 自带调整大小的圆形
figure() 
Data=rand(12,12);
SHM=SHeatmap(Data,'Format','oval');
SHM=SHM.draw(); 

figure() 
Data=rand(12,12)-.5;
SHM=SHeatmap(Data,'Format','pie');
SHM=SHM.draw(); 