clc; clear

% 随机生成数据
X=randn(20,20)+[(linspace(-1,2.5,20)').*ones(1,8),(linspace(.5,-.7,20)').*ones(1,5),(linspace(.9,-.2,20)').*ones(1,7)];
Data = corr(X);
% 变量名列表
NameList = compose('Sl-%d',1:20);
% 分类配色 -- Color schemes for each clust
CList = [0.1490    0.4039    0.4980
         0.3882    0.3608    0.4471
         0.5373    0.2157    0.3098
         0.7686    0.4353    0.2431];

fig = figure('Units', 'normalized', 'Position', [.05,.1,.6,.8], 'Color', 'w');
%% ========================================================================
% 创建聚类树状图对象 -- create tree(dendrogram) object
% 左侧聚类树状图 -- left Cluster Tree
Z1 = linkage(Data, 'average');
ST = STree(Z1, 'MaxClust', 3); % 聚类数量，如果大于4请给CList多设置几个颜色
ST.Orientation = 'left';
ST.XLim = [-.25,-.05];
ST.YLim = [0,1];
ST.TLim = [-pi/4,-pi/4];
ST.Label = 'off';
ST.BranchColor = 'on';
ST.BranchHighlight = 'on';
ST.ClassHighlight = 'on';
ST.RTick = [0,1,1.2,0];
ST.CData = CList;
% 每个类之间加入间隙 -- insert gap between each clust
ST.ClustGap = 'on';
ST.draw()
%% ========================================================================
% 创建热图对象 -- create heatmap object
SM = SMatrix(Data);
% 添加分组信息 -- Add grouping information
SM.ColName = NameList;
SM.RowOrder = ST.order;
SM.RowClass = ST.class;
SM.ColOrder = ST.order;
SM.ColClass = ST.class;
% 设置文本和字体 -- Set Text and Font
SM.LeftLabel = 'off';
SM.BottomLabel = 'off';
SM.TopLabel = 'on';
SM.TopLabelFont = {'FontSize', 15, 'FontName', 'Times New Roman', 'Rotation', 45};
% 每个类之间加入间隙 -- insert gap between each clust
SM.ClustGap = 'on';
% 设置位置 -- set position
SM.XLim = [0,1];
SM.YLim = [0,1];
SM.TLim = [-pi/4,-pi/4];
SM.draw()
%% ========================================================================
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
set(CB,'Location','southoutside','FontName','Times New Roman','FontSize',14);
