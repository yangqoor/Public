% STree_demo2 
% + layout : 'rectangular'(default) / 'rounded' / 'slanted' / 'ellipse' / 'bezier'

% 随机生成数据 -- random data
% rng(10)
Data = rand(75,3);

% 分类数 -- clust number
N = 5;

fig = figure('Units', 'normalized', 'Position', [.05,.1,.7,.8], 'Color', 'w');

% 创建聚类树状图对象 -- create tree(dendrogram) object
Z = linkage(Data, 'average');
ST = STree(Z, 'MaxClust', N);

% 每个类之间加入间隙 -- insert gap between each clust
ST.ClustGap = 'on';
delete(gca);

% 所有类型树枝展示 -- all kinds of branch(layout)
layoutSet = {'rectangular', 'rounded', 'slanted', 'ellipse', 'bezier'};
for i = 1:length(layoutSet)
    % 创建坐标区域并修改绘图坐标区域 -- create subplots and change the parent of the tree object
    ax = axes('Parent', fig, 'Position', [1/40, (5-i)/5+1/20, 1-1/20, 1/5-1/15], 'XColor', 'none', 'YColor', 'none');
    ST.ax = ax; 

    % 改变树枝类型 -- change the layout
    ST.Layout = layoutSet{i};

    % 修改绘图范围以便方便添加text信息
    % -- change the X-limit and the Y-limit to add the following text
    ST.XLim = [0,1];
    ST.YLim = [0,1];
    ST.draw();

    text(0, 1, layoutSet{i}, 'FontName', 'Times New Roman',...
        'FontSize', 16, 'FontWeight', 'bold','Color', [1,1,1].*.2);
end

% exportgraphics(fig, '.\gallery\demo2_layout_all.png')