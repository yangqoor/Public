% STree_SMatrix_demo1

% 随便捏造了点数据 -- made up some data casually
X1 = randn(20,20) + [(linspace(-1,2.5,20)').*ones(1,8),(linspace(.5,-.7,20)').*ones(1,5),(linspace(.9,-.2,20)').*ones(1,7)];
X2 = randn(20,25) + [(linspace(-1,2.5,20)').*ones(1,10),(linspace(.5,-.7,20)').*ones(1,8),(linspace(.9,-.2,20)').*ones(1,7)];
% 求相关系数矩阵 -- get the correlation matrix
Data = corr(X1,X2);
% rowName and colName
rowName = {'FREM2','ALDH9A1','RBL1','AP2A2','HNRNPK','ATP1A1','ARPC3','SMG5','RPS27A',...
          'RAB8A','SPARC','DDX3X','EEF1D','EEF1B2','RPS11','RPL13','RPL34','GCN1','FGG','CCT3'};
colName = compose('slan%d', 1:25);

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
ST1.YLim = [0,1.2];
ST1.Label = 'off';
ST1.BranchColor = 'on';
ST1.BranchHighlight = 'on';
ST1.ClassHighlight = 'on';
ST1.RTick = [0,1,1.2,0];
ST1.CData = CList;
ST1.draw()
% 右侧聚类树状图 -- right Cluster Tree
Z2 = linkage(Data.', 'average');
ST2 = STree(Z2, 'MaxClust', 3);
ST2.Orientation = 'top';
ST2.XLim = [0,1];
ST2.YLim = [1.25,1.45];
ST2.Label = 'off';
ST2.BranchColor = 'on';
ST2.BranchHighlight = 'on';
ST2.ClassHighlight = 'on';
ST2.RTick = [0,1,1.2,0];
ST2.CData = CList;
ST2.draw() 

% -------------------------------------------------------------------------
% 创建热图对象 -- create heatmap object
SM = SMatrix(Data);

% 添加分组信息 -- Add grouping information
SM.RowName = rowName;
SM.ColName = colName;
SM.RowOrder = ST1.order;
SM.RowClass = ST1.class;
SM.ColOrder = ST2.order;
SM.ColClass = ST2.class;

% 设置文本和字体 -- Set Text and Font
SM.LeftLabel = 'off';
SM.RightLabel = 'on';
SM.BottomLabelFont = {'FontSize', 12, 'FontName', 'Times New Roman'};
SM.RightLabelFont = {'FontSize', 12, 'FontName', 'Times New Roman'};

% 设置位置 -- set position
SM.XLim = [0,1];
SM.YLim = [0,1.2];
SM.draw()

% 修饰坐标区域 -- Decorate axes
set(gca, 'XColor', 'none', 'YColor', 'none',...
    'DataAspectRatio', [1,1,1], 'XLim', [-.5,1.3]);
CB = colorbar;
CB.Position(4) = CB.Position(4).*0.75;
CB.Position(4) = CB.Position(4).*0.75;
% exportgraphics(fig1, '.\gallery\STree_SMatrix_demo1_1.png')



%% ========================================================================
fig2 = figure('Units', 'normalized', 'Position', [.05,.1,.6,.8], 'Color', 'w');
ST1.ax = gca;
ST2.ax = gca;
SM.ax = gca;

% SM.Colormap = slanCM(141, 64);

% 每个类之间加入间隙 -- insert gap between each clust
ST1.ClustGap = 'on';
ST2.ClustGap = 'on';
SM.ClustGap = 'on';

ST1.draw() 
ST2.draw() 
SM.draw()


% 修饰坐标区域 -- Decorate axes
set(gca, 'XColor', 'none', 'YColor', 'none',...
    'DataAspectRatio', [1,1,1], 'XLim', [-.5,1.3]);
CB = colorbar;
CB.Position(4) = CB.Position(4).*0.75;
CB.Position(4) = CB.Position(4).*0.75;
% exportgraphics(fig2, '.\gallery\STree_SMatrix_demo1_2.png')









