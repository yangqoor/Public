clc; clear

% 随机生成数据
X = randn(20,20)+[(linspace(-1,2.5,20)').*ones(1,8),(linspace(.5,-.7,20)').*ones(1,5),(linspace(.9,-.2,20)').*ones(1,7)];
Data = corr(X);
% 变量名列表
NameList = compose('Sl-%d',1:20);

fig = figure('Units', 'normalized', 'Position', [.05,.1,.6,.8], 'Color', 'w');
%% ========================================================================
% 创建聚类树状图对象 -- create tree(dendrogram) object
% 左侧聚类树状图 -- left Cluster Tree
Z1 = linkage(Data, 'average');
ST = STree(Z1, 'MaxClust', 3); % 聚类数量，如果大于4请给CList多设置几个颜色
ST.Orientation = 'left';
ST.XLim = [-.25,0];
ST.YLim = [0,sqrt(2)];
ST.TLim = [-pi/4,-pi/4];
ST.Label = 'off';
ST.draw()
%% ========================================================================
% 创建热图对象 -- create heatmap object
SM = SMatrix(Data);
% 添加分组信息 -- Add grouping information
SM.RowOrder = ST.order;
SM.ColOrder = ST.order;
SM.ColName = NameList; SM.ColName{ST.order(1)} = '';
SM.RowName = NameList; SM.RowName{ST.order(end)} = '';
% 设置文本和字体 -- Set Text and Font
SM.RightLabel = 'on';
SM.LeftLabel = 'off';
SM.RightLabelFont = {'FontSize', 15, 'FontName', 'Times New Roman'};
SM.BottomLabelFont = {'FontSize', 15, 'FontName', 'Times New Roman'};
% 设置位置 -- set position
SM.XLim = [0,1];
SM.YLim = [0,1];
SM.TLim = [0,0];
SM.draw()
%% ========================================================================
% 修饰句柄 -- decorate handles
% 清除热图左上部分 -- Clear the bottom half of the heatlmap
tData = tril(ones(size(Data)), 0);
tInd = find(tData(:) == 1);
for i = 1:length(tInd)
    set(SM.heatmapHdl{tInd(i)}, 'Visible', 'off')
end
% 修饰坐标区域 -- decorate axes
set(gca, 'XColor', 'none', 'YColor', 'none',...
    'DataAspectRatio', [1,1,1], 'YLim',get(gca,'YLim')-[.05,0]);
CB = colorbar();
set(CB,'Location','southoutside','FontName','Times New Roman','FontSize',14);