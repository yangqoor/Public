% STree_SMatrix_demo2

% 随便捏造了点数据 -- made up some data casually
rng(5)
X = randn(100,80) + [(linspace(-1,2.5,100)').*ones(1,15),(linspace(.5,-.7,100)').*ones(1,15),...
                  (linspace(.1,-.7,100)').*ones(1,15),(linspace(.9,-.2,100)').*ones(1,15),...
                  (linspace(-.1,.7,100)').*ones(1,10),(linspace(-.9,-.2,100)').*ones(1,10)];
Y = randn(100,8) + [(linspace(-1,2.5,100)').*ones(1,2),(linspace(.5,-.7,100)').*ones(1,3),(linspace(-1,-2.5,100)').*ones(1,3)];
% 求相关系数矩阵 -- get the correlation matrix
Data = corr(X,Y);
% rowName and colName
rowName = compose('slan%d', 1:80);
colName = compose('var%d', 1:8);
% 分类配色 -- Color schemes for each clust
CList = [0.1490    0.4039    0.4980
    0.3882    0.3608    0.4471
    0.5373    0.2157    0.3098
    0.7686    0.4353    0.2431];

fig1 = figure('Units', 'normalized', 'Position', [.05,.1,.6,.8], 'Color', 'w');

% 创建聚类树状图对象 -- create tree(dendrogram) object
% 内侧聚类树状图 -- inner Cluster Tree
Z1 = linkage(Data, 'average');
ST1 = STree(Z1, 'MaxClust', 4);
ST1.Orientation = 'left';
ST1.XLim = [0,1];
ST1.TLim = [pi/2,2*pi+pi/4];
ST1.Label = 'off';
ST1.BranchColor = 'on';
ST1.CData = CList;
ST1.draw()
% 径向聚类树状图 -- radial Cluster Tree
Z2 = linkage(Data.', 'average');
ST2 = STree(Z2, 'MaxClust', 2);
ST2.Orientation = 'top';
ST2.XLim = [1,2];
ST2.TLim = [pi/4,pi/4];
ST2.YLim = [0,0.3];
ST2.Label = 'off';
ST2.BranchColor = 'on';
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
SM.XLim = [1,2];
SM.TLim = [pi/2,2*pi+pi/4];
SM.draw()

% 修饰坐标区域 -- Decorate axes
set(gca, 'XColor', 'none', 'YColor', 'none',...
    'DataAspectRatio', [1,1,1], 'XLim', [-2.2,2.3]);

exportgraphics(fig1, '.\gallery\STree_SMatrix_demo2_1.png')





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

% see slanCMdisplay
% and Zhaoxu Liu / slandarer (2024). 200 colormap, MATLAB Central File Exchange.
% https://www.mathworks.com/matlabcentral/fileexchange/120088-200-colormap
SM.Colormap = slanCM(136, 64);

ST1.draw() 
ST2.draw() 
SM.draw()


% 修饰坐标区域 -- Decorate axes
set(gca, 'XColor', 'none', 'YColor', 'none',...
    'DataAspectRatio', [1,1,1], 'XLim', [-2.2,2.3]);

exportgraphics(fig2, '.\gallery\STree_SMatrix_demo2_2.png')