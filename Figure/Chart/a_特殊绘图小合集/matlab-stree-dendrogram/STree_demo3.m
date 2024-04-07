% STree_demo3 
% + Orientation : 'left' / 'right' / 'top' / 'bottom'

% 随机生成数据 -- random data
% rng(10)
Data = rand(75,3);

% 分类数 -- clust number
N = 5;

fig = figure('Units', 'normalized', 'Position', [.05,.1,.9,.8], 'Color', 'w');

% 创建聚类树状图对象 -- create tree(dendrogram) object
Z = linkage(Data, 'average');
ST = STree(Z, 'MaxClust', N);

% 每个类之间加入间隙 -- insert gap between each clust
ST.ClustGap = 'on';
delete(gca);

% 创建坐标区域并修改绘图坐标区域 -- create subplots and change the parent of the tree object
axR = axes('Parent', fig, 'Position', [1/20, 1/30, 1/4-1/20, 1-1/15], 'XColor', 'none', 'YColor', 'none');
ST.ax = axR;

% 改变树枝类型 -- change the layout
ST.Layout = 'bezier';
% 改变方向 -- change the orientation
ST.Orientation = 'right';
ST.draw()




%% =========================================================================
axL = axes('Parent', fig, 'Position', [3/4, 1/30, 1/4-1/20, 1-1/15], 'XColor', 'none', 'YColor', 'none');
ST.ax = axL;
ST.Orientation = 'left';
ST.draw()

axT = axes('Parent', fig, 'Position', [1/4, 1/10, 2/4, 1/2-1/10-1/40], 'XColor', 'none', 'YColor', 'none');
ST.ax = axT;
ST.Orientation = 'top';
ST.draw()

axB = axes('Parent', fig, 'Position', [1/4, 1/2+1/40, 2/4, 1/2-1/10-1/40], 'XColor', 'none', 'YColor', 'none');
ST.ax = axB;
ST.Orientation = 'bottom';
ST.draw()

% exportgraphics(fig, '.\gallery\demo3_orientation_all.png')
