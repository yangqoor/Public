% 区域填充

% 获取数据
[X,Y1,Y2,Y3]=demoData();

hold on
% 设置填充区域范围
UXLim=[20,30];
xline(UXLim(1),'LineWidth',.8,'LineStyle','--')
xline(UXLim(2),'LineWidth',.8,'LineStyle','--')

% 填充颜色
YY=Y1;
UY=YY(X<=UXLim(2)&X>=UXLim(1));
UX=X(X<=UXLim(2)&X>=UXLim(1));
fill([UXLim(1),UX,UXLim(end)],[min(YY),UY,min(YY)],[255,153,154]./255,'EdgeColor','none','FaceAlpha',.9)

% 绘制折线图
plot(X,Y1,'LineWidth',1,'Color',[0,0,0])

% 坐标区域修饰
defualtAxes()