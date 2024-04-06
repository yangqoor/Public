% 带分组热图(Grouping heat map)

% 随便捏造了点数据(Made up some data casually)
ClassCol=[1,1,1,1,2,1,2,2,2,2,3,3,3,3,3,4,4,4,4,4,5,5,5,5,5];
ClassRow=[1,1,1,1,1,2,2,2,2,2,3,3,3,3,3,4,4,4,4,4];
Data=rand(20,25);

% 图窗创建(create figure)
fig=figure('Position',[100,100,800,800]);

% 调整主坐标区域位置并将Y轴置于右侧
% Adjust the position of the main coordinate area 
% and place the Y axis to the right
axMain=axes('Parent',fig);
axMain.Position=[.1,.05,.85,.85];
P=axMain.Position;
axMain.YAxisLocation='right';

% 绘制左侧分组方块(Draw the left Block)
axBlockL=axes('Parent',fig);
axBlockL.Position=[P(1)-P(3)/20-P(3)*.01,P(2),P(3)/20,P(4)];
SClusterBlock(ClassRow,'Orientation','left','Parent',axBlockL);

% 绘制上侧分组方块(Draw the top Block)
axBlockT=axes('Parent',fig);
axBlockT.Position=[P(1),P(2)+P(4)*1.01,P(3),P(4)/20];
SClusterBlock(ClassCol,'Orientation','top','Parent',axBlockT);

% 绘制热图(Draw Heatmap)
SHM_b1=SHeatmap(Data,'Format','sq','Parent',axMain);
SHM_b1=SHM_b1.draw();
axMain.DataAspectRatioMode='auto';
colorbar(axMain,'off');
clim(axMain,[-.2,1])
exportgraphics(gcf,'gallery\Group.png')


