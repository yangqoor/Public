load SimulatedStock.mat 

T=TMW.Time;
V=TMW.High;
 
% 绘制三个热力图
ax1=axes(gcf,'Position',[.06,2/3+.01,1-.07,1/3-.03]);
heatmapDT(ax1,2013,T,V)
ax2=axes(gcf,'Position',[.06,1/3+.01,1-.07,1/3-.03]);
heatmapDT(ax2,2014,T,V)
ax3=axes(gcf,'Position',[.06,0+.01,1-.07,1/3-.03]);
heatmapDT(ax3,2015,T,V)

% 绘制标题并调整位置
TT=title(ax1,{'Simulated Stock heatmap'},'FontSize',18,'FontWeight','bold','FontName','Times New Roman');
TT.Position(2)=-.1;


set(gcf,'Position',[100,100,1200,620])

% 修改配色
colormap(turbo)

% 使用配色工具包
colormap(slanCM(141))