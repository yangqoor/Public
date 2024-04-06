% Rotation 45-degree corr heatmap
% 随机生成数据
X=randn(20,20)+[(linspace(-1,2.5,20)').*ones(1,8),(linspace(.5,-.7,20)').*ones(1,5),(linspace(.9,-.2,20)').*ones(1,7)];
Data=corr(X);
% 变量名列表
NameList=compose('Sl-%d',1:20);

% 图窗及坐标区域
treeFig=figure('Position',[100,300,1000,600]);
ax=axes(treeFig);
ax.NextPlot='add';
ax.DataAspectRatio=[1,1,1];
ax.XColor='none';
ax.YColor='none';

% 热图绘制
sqX=[-1,0,1,0];
sqY=[0,1,0,-1];
for i=1:size(Data,1)
    for j=i:size(Data,1)
        fill(ax,sqX+(i-1)+(j-1),sqY-(i-1)+(j-1),Data(i,j),'EdgeColor','none')
    end
end
axis(ax,'tight')

% 设置颜色并绘制colorbar
clim(ax,[-1,1])
colormap(ax,'winter')
cbHdl=colorbar(ax);
cbHdl.Location='southoutside';
cbHdl.FontName='Times New Roman';
cbHdl.FontSize=12;

colormap(ax,slanCM(98))

% 下方注释
if true
for i=1:size(Data,1)
    text(ax,-1/2+2*(i-1),-1/2,NameList{i}+" ",'FontSize',13,...
        'FontName','Times New Roman','HorizontalAlignment','right','Rotation',45)
end
end

% 右上方注释
if true
for i=1:size(Data,1)
    text(ax,-1/2+(i-1)+size(Data,1),-1/2+size(Data,1)-(i-1)," "+NameList{i},'FontSize',13,...
        'FontName','Times New Roman','HorizontalAlignment','left','Rotation',45)
end
end
