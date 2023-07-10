% demo3 地图绘制双变量展示

axm=usamap("conus");

states=shaperead("usastatelo.shp",'UseGeoCoords',true);
% 俩州离太远画不开，不要
for i=length(states):-1:1
    if states(i).Name=="Alaska"||states(i).Name=="Hawaii"
        states(i)=[];
    end
end

faceColors=makesymbolspec('Polygon',{'INDEX',[1 numel(states)],'FaceColor',...
  polcmap(numel(states))});
usaMap=geoshow(states, 'DisplayType','polygon','SymbolSpec', faceColors);

% 不想去收集数据了，随便生成点随机数
A=rand(numel(states),1);
B=rand(numel(states),1);

% 调用工具函数生成图例和映射表
[CMapData,CMapHdl]=multiVarMap2(A,B,'colorList',11,'pieceNum',8);
% 循环修改每个州颜色
for i=1:length(usaMap.Children)
    usaMap.Children(i).FaceColor=[CMapData(i,1,1),CMapData(i,1,2),CMapData(i,1,3)];
end

