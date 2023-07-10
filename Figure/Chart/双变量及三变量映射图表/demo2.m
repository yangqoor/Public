% demo2 surf绘图三变量展示

multiData=load('multi2_3.mat');
X1=multiData.X1;
X2=multiData.X2;
A=multiData.A;
B=multiData.B;
C=multiData.C;

% 先绘制一个没有赋予颜色的图形
surfHdl=surf(X1,X2,zeros(size(X1)),'EdgeColor','none');
hold on;view(2);axis tight

% 调用工具函数生成图例和映射表
[CMapData,CMapHdl]=multiVarMap3(A,B,C,'colorList',1,'pieceNum',8);
set(surfHdl,'CData',CMapData);
% CMapHdl.XColor=[1,1,1];
% CMapHdl.YColor=[1,1,1];
% CMapHdl.ZColor=[1,1,1];
% CMapHdl.Title.Color=[1,1,1];