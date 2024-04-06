% 3D高度渐变填充折线

% 获取数据
[X,Y]=demoDataN();

YLim=[min(min(Y)),max(max(Y))];
% 构造并绘制网格
[XMesh,YMesh]=meshgrid(X,linspace(YLim(1),YLim(2),1000));
hold on
for i=1:size(Y,1)
    YMeshA=repmat(Y(i,:),[1000,1]);
    CMesh=nan.*XMesh;
    YMeshD=YMeshA-YLim(1);
    CMesh(YMesh>=YLim(1)&YMesh<=YMeshA)=YMeshD(YMesh>=YLim(1)&YMesh<=YMeshA);
    surf(XMesh,XMesh.*0+i,YMesh,'EdgeColor','none','CData',CMesh,'FaceColor','flat','FaceAlpha',.8)
end

% 绘制折线图
for i=1:size(Y,1)
    plot3(X,X.*0+i,Y(i,:),'LineWidth',1,'Color',[0,0,0,.8])
end

% 设置配色
colorList=turbo(64);
% colorList=slanCM(110,64);
colormap(colorList)
colorbar

% 坐标区域修饰
defualtAxes();
set(gca,'Projection','perspective','GridAlpha',.05)
view(16,36)