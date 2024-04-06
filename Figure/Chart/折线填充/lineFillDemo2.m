% 双关系填充

% 获取数据
[X,Y1,Y2,Y3]=demoData();

hold on
% 获取Y轴数据范围
YY=[Y1,Y3];
YLim=[min(YY),max(YY)];

% 构造并绘制网格
[XMesh,YMesh]=meshgrid(X,linspace(YLim(1),YLim(2),1000));
YMeshA=repmat(Y1,[1000,1]);
YMeshB=repmat(Y3,[1000,1]);
CMesh=nan.*XMesh;
CMesh(YMesh>=YMeshB&YMesh<=YMeshA)=1;
CMesh(YMesh>=YMeshA&YMesh<=YMeshB)=2;
surf(XMesh,YMesh,XMesh.*0,'EdgeColor','none','CData',CMesh,'FaceColor','flat','FaceAlpha',.8)

% 设置配色
ColorList=[255,153,154;153,153,253]./255;
colormap(ColorList)

% 绘制折线图
plot(X,Y1,'LineWidth',1,'Color',[0,0,0])
plot(X,Y3,'LineWidth',1,'Color',[0,0,0])

% 坐标区域修饰
defualtAxes()