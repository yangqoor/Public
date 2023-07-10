% demo7

multiData=load('multi2_3.mat');
X1=multiData.X1;
X2=multiData.X2;
A=multiData.A;
B=multiData.B;

% 先绘制一个没有赋予颜色的图形
surfHdl=surf(X1,X2,max(A,B),'EdgeColor','none');
hold on;view(3);axis tight

% 调用工具函数生成图例和映射表
[CMapData,CMapHdl]=multiVarMap2(A,B,'colorList',10,'pieceNum',8);
set(surfHdl,'CData',CMapData);