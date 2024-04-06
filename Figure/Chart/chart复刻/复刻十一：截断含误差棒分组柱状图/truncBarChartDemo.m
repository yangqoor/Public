% code for pnas.2200057120fig03
% by slandarer
% bar chart with trunc-axis

figure('Units','normalized','Position',[.2,.3,.36,.45],'Color','w');

rng(24)
% 随机生成了两组数据
DataA = rand(7,1)*ones(1,5).*2+rand(7,5)./3.5;
DataB = rand(7,1)*ones(1,5)./2+rand(7,5)./3.5;
meanData = [mean(DataA,2), mean(DataB,2)];

% 文章图片中的颜色数据
CList = [188,188,240; 160,161,166; 237,187,128;
         177,202,233; 245,185,192]./255;
CList = CList([1,2],:);
% CList = CList([4,5],:);

% 横坐标标签文本
NameList = {'Cortex';
            'Hippocampus';
            'Cerebellum';
            'Brainstem';
            'Cervical spinal cord';
            'Thoracic spinal cord';
            'Lumbar spinal cord'};

hold on
% 绘制柱状图 ---------------------------------------------------------------
barHdl = bar(meanData,'EdgeColor','none','FaceAlpha',.5,'BarWidth',.7);
% 修改配色
barHdl(1).FaceColor = CList(1,:);
barHdl(2).FaceColor = CList(2,:);
% 绘制散点图 ---------------------------------------------------------------
XA = barHdl(1).XEndPoints.'*ones(1,size(DataA,2));
scatter(XA(:),DataA(:),55,'filled','o','MarkerEdgeColor','k','LineWidth',.8,...
                      'CData',CList(1,:),'XJitter','rand','XJitterWidth',0.15)
XB = barHdl(2).XEndPoints.'*ones(1,size(DataB,2));
scatter(XB(:),DataB(:),55,'filled','o','MarkerEdgeColor','k','LineWidth',.8,...
                      'CData',CList(2,:),'XJitter','rand','XJitterWidth',0.15)
% 绘制误差棒 ---------------------------------------------------------------
errorbar(barHdl(1).XEndPoints,meanData(:,1),std(DataA,0,2),'vertical',...
    'LineStyle','none','LineWidth',1,'Color','k')
errorbar(barHdl(2).XEndPoints,meanData(:,2),std(DataB,0,2),'vertical',...
    'LineStyle','none','LineWidth',1,'Color','k')

% 坐标区域简单修饰
ax = gca;
ax.XTick = 1:length(barHdl(1).XEndPoints);
ax.XTickLabel = NameList(:);
ax.FontName = 'Arial';
ax.FontWeight = 'bold';
ax.FontSize = 11;
ax.XTickLabelRotation = 35;

% 截断坐标轴
truncAxis('y',[1,1.4]);
fig = gcf;
ax1 = fig.Children(1);
ax2 = fig.Children(2);

% 隐藏基线
ax1.XColor = 'none';
ax1.Children(end).BaseLine.Color = 'none';

% 坐标轴修饰
ax1.LineWidth = 1.5; 
ax2.LineWidth = 1.5;
ax1.TickDir = 'out';
ax2.TickDir = 'out';

% 增添Y轴标签
ax1.YLabel.String = 'ug of Ab/ g wet weight of tissue';
ax1.YLabel.Position = [0 1.4 -1];
ax1.YLabel.FontSize = 15;

% -------------------------------------------------------------------------
% 随便加点显著性标志

N = 2; % 第二个柱
S = '***';
% 要修改右侧柱请改成barHdl(2)及DataB(N,:)
X = barHdl(1).XEndPoints(N);
Y = max(DataA(N,:))+.1;
errorbar(X,Y,.2,'horizontal','LineStyle','none','LineWidth',1,'Color','k')
text(X,Y,S,'FontSize',15,'FontWeight','bold','FontName','Arial',...
    'HorizontalAlignment','center','VerticalAlignment','baseline')

N = 3; % 第三个柱
S = '****';
% 要修改右侧柱请改成barHdl(2)及DataB(N,:)
X = barHdl(1).XEndPoints(N);
Y = max(DataA(N,:))+.1;
errorbar(X,Y,.2,'horizontal','LineStyle','none','LineWidth',1,'Color','k')
text(X,Y,S,'FontSize',15,'FontWeight','bold','FontName','Arial',...
    'HorizontalAlignment','center','VerticalAlignment','baseline')


N = 6; % 第六个柱
S = '****';
% 要修改右侧柱请改成barHdl(2)及DataB(N,:)
X = barHdl(1).XEndPoints(N);
Y = max(DataA(N,:))+.1;
errorbar(X,Y,.2,'horizontal','LineStyle','none','LineWidth',1,'Color','k')
text(X,Y,S,'FontSize',15,'FontWeight','bold','FontName','Arial',...
    'HorizontalAlignment','center','VerticalAlignment','baseline')












