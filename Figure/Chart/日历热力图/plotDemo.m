function plotDemo(x,y)
plot(x,y,'LineWidth',1)
ax=gca;hold on;box on
ax.XGrid='on';
ax.YGrid='on';
ax.XMinorTick='on';
ax.YMinorTick='on';
ax.LineWidth=.8;
ax.GridLineStyle='-.';
ax.FontName='宋体';
ax.FontSize=12;
end