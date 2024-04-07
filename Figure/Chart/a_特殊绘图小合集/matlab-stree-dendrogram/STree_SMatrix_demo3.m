% STree_SMatrix_demo3

% 随机生成数据
X=randn(20,20)+[(linspace(-1,2.5,20)').*ones(1,8),(linspace(.5,-.7,20)').*ones(1,5),(linspace(.9,-.2,20)').*ones(1,7)];
Data=corr(X);
% 变量名列表
NameList=compose('Sl-%d',1:20);
% 分类配色 -- Color schemes for each clust
CList = [0.1490    0.4039    0.4980
    0.3882    0.3608    0.4471
    0.5373    0.2157    0.3098
    0.7686    0.4353    0.2431];


fig1 = figure('Units', 'normalized', 'Position', [.05,.1,.6,.8], 'Color', 'w');

% 创建聚类树状图对象 -- create tree(dendrogram) object
% 左侧聚类树状图 -- left Cluster Tree
Z1 = linkage(Data, 'average');
ST1 = STree(Z1, 'MaxClust', 3);
ST1.Orientation = 'left';
ST1.XLim = [-.25,-.05];
ST1.YLim = [0,1];
ST1.TLim = [-pi/4,-pi/4];
ST1.Label = 'off';
ST1.BranchColor = 'on';
ST1.BranchHighlight = 'on';
ST1.ClassHighlight = 'on';
ST1.RTick = [0,1,1.2,0];
ST1.CData = CList;
ST1.draw()

% 创建热图对象 -- create heatmap object
SM = SMatrix(Data);

% 添加分组信息 -- Add grouping information
SM.ColName = NameList;
SM.RowOrder = ST1.order;
SM.RowClass = ST1.class;
SM.ColOrder = ST1.order;
SM.ColClass = ST1.class;

% 设置文本和字体 -- Set Text and Font
SM.LeftLabel = 'off';
SM.BottomLabel = 'off';
SM.TopLabel = 'on';
SM.TopLabelFont = {'FontSize', 12, 'FontName', 'Times New Roman', 'Rotation', 45};

% 设置位置 -- set position
SM.XLim = [0,1];
SM.YLim = [0,1];
SM.TLim = [-pi/4,-pi/4];
SM.draw()

% 修饰句柄 -- decorate handles
% 清除热图下半部分 -- Clear the bottom half of the heatmap
tData = triu(ones(size(Data)),1);
tInd = find(tData(:) == 1);
for i = 1:length(tInd)
    set(SM.heatmapHdl{tInd(i)}, 'Visible', 'off')
end

% 修饰坐标区域 -- decorate axes
set(gca, 'XColor', 'none', 'YColor', 'none',...
    'DataAspectRatio', [1,1,1],'XLim', [-.15,1.45]);
CB = colorbar();
CB.Location = 'southoutside';

exportgraphics(fig1, '.\gallery\STree_SMatrix_demo3_1.png')





%% ========================================================================
fig2 = figure('Units', 'normalized', 'Position', [.05,.1,.6,.8], 'Color', 'w');
ST1.ax = gca;
SM.ax = gca;

% SM.Colormap = slanCM(141, 64);

% 每个类之间加入间隙 -- insert gap between each clust
ST1.ClustGap = 'on';
SM.ClustGap = 'on';

% see slanCMdisplay
% and Zhaoxu Liu / slandarer (2024). 200 colormap, MATLAB Central File Exchange.
% https://www.mathworks.com/matlabcentral/fileexchange/120088-200-colormap
SM.Colormap = slanCM(141, 64);

ST1.draw() 
SM.draw()

% 修饰句柄 -- decorate handles
% 清除热图下半部分 -- Clear the bottom half of the heatmap
tData = triu(ones(size(Data)),1);
tInd = find(tData(:) == 1);
for i = 1:length(tInd)
    set(SM.heatmapHdl{tInd(i)}, 'Visible', 'off')
end


% 修饰坐标区域 -- decorate axes
set(gca, 'XColor', 'none', 'YColor', 'none',...
    'DataAspectRatio', [1,1,1],'XLim', [-.15,1.45]);
CB = colorbar();
CB.Location = 'southoutside';

exportgraphics(fig2, '.\gallery\STree_SMatrix_demo3_2.png')







