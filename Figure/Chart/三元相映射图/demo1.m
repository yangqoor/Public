% 导入数据并绘制贴图版地图
load korea5c
worldmap(korea5c,korea5cR);
koreaHdl=geoshow(korea5c,korea5cR,'DisplayType','texturemap');

A=koreaHdl.XData;A=A(1:end-1,1:end-1);
B=koreaHdl.YData;B=B(1:end-1,1:end-1);
C=koreaHdl.CData;


% % 调用工具函数生成图例和映射表
[CMapData,CMapHdl]=multiVarMap3(A,B,C,'colorList',1,'pieceNum',50);
koreaHdl.CData=CMapData;
