% STree_demo5
% + Fan-shaped rotation


% 随机生成数据 -- random data
% rng(10)
Data = rand(75,3);

% 分类数 -- clust number
N = 5;

% 创建聚类树状图对象 -- create tree(dendrogram) object
Z = linkage(Data, 'average');
ST = STree(Z, 'MaxClust', N);

ST.ClustGap = 'on';        % 每个类之间加入间隙   -- insert gap between each clust
ST.BranchColor = 'on';     % 为不同类树枝添加颜色 -- set the branch's color of each clust
ST.BranchHighlight = 'on'; % 增添树枝高亮         -- add highlight for each clust's branches
ST.Label = 'off';          % 关闭样本标签         -- close sample label
ST.Layout = 'bezier';      % 改变树枝类型         -- change the layout

ST.XLim = [1,3];           % 改变X坐标范围 -- change X-limit
ST.TLim = [pi/6,pi/2];     % 绘制pi/6到pi/2范围的扇形树状图 -- Draw a dendrogram of the range from pi/6 to pi/2
close all

OrientationSet = {'left', 'right', 'top', 'bottom'};
for i = 1:4
    tempFig = figure('Units', 'normalized', 'Position', [.05,.1,.5,.7], 'Color', 'w'); 
    ST.ax = gca;
    ST.Orientation = OrientationSet{i};
    ST.draw()

    set(gca,'XColor','none','YColor','none')
    % exportgraphics(tempFig, ['.\gallery\demo5_Fan_shaped_rotation_',OrientationSet{i},'.png'])
end