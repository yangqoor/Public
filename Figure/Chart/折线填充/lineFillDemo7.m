% 分段X轴区域填充


% 获取数据
[X,Y1,Y2,Y3]=demoData();

hold on
% 设置间断点和颜色
pwPnt=[10,20,30];
ColorList=[0.8275    0.7294    0.4078
    0.8353    0.4118    0.3647
    0.3647    0.5490    0.6588
    0.3961    0.6431    0.4745];
colormap(ColorList)
% 获取Y轴数据范围
YY=Y1;
YLim=[min(YY),max(YY)];
% 构造并绘制网格
[XMesh,YMesh]=meshgrid(X,linspace(YLim(1),YLim(2),1000));
YMeshA=repmat(YY,[1000,1]);
CMesh=nan.*XMesh;
pwPnt=[min(X),pwPnt,max(X)];
for i=1:length(pwPnt)-1
    CMesh(YMesh<=YMeshA&XMesh>=pwPnt(i)&XMesh<=pwPnt(i+1))=i;
end
surf(XMesh,YMesh,XMesh.*0,'EdgeColor','none','CData',CMesh,'FaceColor','flat','FaceAlpha',.7)
% 绘制分界线
for i=1:length(pwPnt)
    plot(pwPnt([i,i]),[min(YY),interp1(X,YY,pwPnt(i),'linear')],'Color',[0,0,0],'LineWidth',1);
end

% 绘制折线图
plot(X,Y1,'LineWidth',1,'Color',[0,0,0])

% 坐标区域修饰
defualtAxes()