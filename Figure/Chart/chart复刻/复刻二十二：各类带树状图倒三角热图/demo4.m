clc; clear

% 随机生成数据
X=randn(20,30)+[(linspace(-1,2.5,20)').*ones(1,8),(linspace(-3,1,20)').*ones(1,5),(linspace(.5,-.7,20)').*ones(1,10),(linspace(.9,-.2,20)').*ones(1,7)];
Data = corr(X);
% 变量名列表
NameList = compose('Sl-%d',1:30);
% 分类配色 -- Color schemes for each clust
CList = [0.1490    0.4039    0.4980
         0.3882    0.3608    0.4471
         0.5373    0.2157    0.3098
         0.7686    0.4353    0.2431];


% 创建聚类树状图对象 -- create tree(dendrogram) object
% 左侧聚类树状图 -- left Cluster Tree
Z1 = linkage(Data, 'average');
ST = STree(Z1, 'MaxClust', 4); % 聚类数量，如果大于4请给CList多设置几个颜色
ST.Orientation = 'top';
ST.XLim = [0,sqrt(2)];
ST.YLim = [0,.25];
ST.Label = 'off';
ST.BranchColor = 'on';
ST.BranchHighlight = 'on';
ST.RTick = [0,1,1.2,0];
ST.CData = CList;
ST.draw();
%% ========================================================================
% 创建热图对象 -- create heatmap object
SM = SMatrix(Data);
% 添加分组信息 -- Add grouping information
SM.RowName = NameList;
SM.ColName = NameList;
SM.RowOrder = ST.order;
SM.RowClass = ST.class;
SM.ColOrder = ST.order;
SM.ColClass = ST.class;
% 设置文本和字体 -- Set Text and Font
SM.LeftLabel = 'off';
SM.RightLabel = 'on';
SM.BottomLabelFont = {'FontSize', 15, 'FontName', 'Times New Roman', 'Rotation', 45};
SM.RightLabelFont = {'FontSize', 15, 'FontName', 'Times New Roman'};
% 设置位置 -- set position
SM.XLim = [0,1];
SM.YLim = [0,1];
SM.TLim = [-pi/4,-pi/4];
SM.draw()
%% ========================================================================
% 修饰句柄 -- decorate handles
% 清除热图上半部分 -- Clear the bottom half of the heatmap
tData = tril(ones(size(Data)),-1);
tInd = find(tData(:) == 1);
for i = 1:length(tInd)
    set(SM.heatmapHdl{tInd(i)}, 'Visible', 'off')
end
tData = eye(size(Data));
tInd = find(tData(:) == 1);
for i = 1:length(tInd)
    SM.heatmapHdl{tInd(i)}.XData(SM.heatmapHdl{tInd(i)}.YData > 0) = [];
    SM.heatmapHdl{tInd(i)}.YData(SM.heatmapHdl{tInd(i)}.YData > 0) = [];
end
% 修饰坐标区域 -- decorate axes
set(gca, 'XColor', 'none', 'YColor', 'none',...
    'DataAspectRatio', [1,1,1],'XLim', [-.15,1.5], 'YLim', [-1.45/2, .26]);
CB = colorbar();
set(CB,'FontName','Times New Roman','FontSize',14);
CB.Position(4) = CB.Position(4)/3;