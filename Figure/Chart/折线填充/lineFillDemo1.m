% 悬挂填充折线图

% 获取数据
[X,Y1,Y2,Y3]=demoData();

hold on
% Uy：上面的辅助线y值，Ly：下面的辅助线y值
Uy=40;Ly=20;
yline(Uy,'LineWidth',.8,'LineStyle','--')
yline(Ly,'LineWidth',.8,'LineStyle','--')

% 填充颜色
UY=Y1;UY(UY<Uy)=Uy;
fill([X(1),X,X(end)],[Uy,UY,Uy],[255,153,154]./255,'EdgeColor','none','FaceAlpha',.9)
LY=Y1;LY(LY>Ly)=Ly;
fill([X(1),X,X(end)],[Ly,LY,Ly],[153,153,253]./255,'EdgeColor','none','FaceAlpha',.9)

% 绘制折线图
plot(X,Y1,'LineWidth',1,'Color',[0,0,0])

% 坐标区域修饰
defualtAxes()