% demo1 surf绘图双变量展示

multiData=load('multi2_3.mat');
X1=multiData.X1;
X2=multiData.X2;
A=multiData.A;
B=multiData.B;

% 先绘制一个没有赋予颜色的图形
surfHdl=surf(X1,X2,zeros(size(X1)),'EdgeColor','none');
hold on;view(2);axis tight

% 调用工具函数生成图例和映射表
[CMapData,CMapHdl]=multiVarMap2(A,B,'colorList',10,'pieceNum',8);
set(surfHdl,'CData',CMapData);