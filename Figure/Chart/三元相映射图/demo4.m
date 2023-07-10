x=1:20;
y=rand(1,20);
sz=rand(1,20);
BC=bubblechart(x,y,sz); 

% 不想去收集数据了，随便生成点随机数
A=rand(1,20);
B=rand(1,20);
C=rand(1,20);

% 调用工具函数生成图例和映射表
[CMapData,CMapHdl]=multiVarMapTri(A,B,C,'colorList',2,'pieceNum',8);
BC.CData=[CMapData(:,:,1)',CMapData(:,:,2)',CMapData(:,:,3)']; 