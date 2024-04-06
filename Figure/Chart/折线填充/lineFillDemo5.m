% 单变量横向渐变填充

% 获取数据
[X,Y1,Y2,Y3]=demoData();

hold on
% 获取Y轴数据范围
YY=Y1;
YLim=[min(YY),max(YY)];

% 构造并绘制网格
[XMesh,YMesh]=meshgrid(X,linspace(YLim(1),YLim(2),1000));
YMeshA=repmat(YY,[1000,1]);
CMesh=nan.*XMesh;
CMesh(YMesh>=YLim(1)&YMesh<=YMeshA)=YMesh(YMesh>=YLim(1)&YMesh<=YMeshA);
surf(XMesh,YMesh,XMesh.*0,'EdgeColor','none','CData',CMesh,'FaceColor','flat','FaceAlpha',.8)

% 设置配色
colormap(turbo(32))
colormap(slanCM(141,32))
colorbar

% 绘制折线图
plot(X,YY,'LineWidth',1,'Color',[0,0,0])

% 坐标区域修饰
defualtAxes()