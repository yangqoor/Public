% STree_demo6
% + Larger angle range [1]
% + Different x coordinate ranges


% 随机生成数据 -- random data
% rng(10)
Data = rand(75,3);

% 分类数 -- clust number
N = 5;

% 创建聚类树状图对象 -- create tree(dendrogram) object
Z = linkage(Data, 'average');
ST = STree(Z, 'MaxClust', N);

% 改变方向 -- change the orientation
ST.Orientation = 'left';

ST.ClustGap = 'on';        % 每个类之间加入间隙   -- insert gap between each clust
ST.BranchColor = 'on';     % 为不同类树枝添加颜色 -- set the branch's color of each clust
ST.BranchHighlight = 'on'; % 增添树枝高亮         -- add highlight for each clust's branches
ST.Label = 'on';           % 关闭样本标签         -- close sample label
ST.Layout = 'bezier';      % 改变树枝类型         -- change the layout
ST.ClassHighlight = 'on';  % 分类高亮            -- add class highlight
ST.ClassLabel = 'on';      % 分类文本信息         -- add class-label

ST.TLim = [0,2*pi];
close all
layoutSet = {'rectangular', 'rounded', 'slanted', 'ellipse', 'bezier'};


% 调整各个元素半径 -- adjust the radius of each elementa
% 样本文本 类弧形内侧 类弧形外侧 类文本
% Sample text, inner side of class arc, outer side of class arc, class text
ST.RTick = [1+1/40, 1.22, 1.27, 1.35];
ST.XLim = [0,3];
for i = 1:length(layoutSet)
    tempFig = figure('Units', 'normalized', 'Position', [.05,.1,.5,.7], 'Color', 'w'); 
    ST.ax = gca;
    ST.Layout = layoutSet{i};
    ST.draw()

    set(gca,'XColor','none','YColor','none')
    % exportgraphics(tempFig, ['.\gallery\demo6_left_full_fan_XLim_0_3_',layoutSet{i},'.png'])
end

%% ========================================================================
% 调整各个元素半径 -- adjust the radius of each elementa
% 样本文本 类弧形内侧 类弧形外侧 类文本
% Sample text, inner side of class arc, outer side of class arc, class text
ST.RTick = [1+1/40, 1.26, 1.31, 1.37];
ST.XLim = [1,3];
for i = 1:length(layoutSet)
    tempFig = figure('Units', 'normalized', 'Position', [.05,.1,.5,.7], 'Color', 'w'); 
    ST.ax = gca;
    ST.Layout = layoutSet{i};
    ST.draw()

    set(gca,'XColor','none','YColor','none')
    % exportgraphics(tempFig, ['.\gallery\demo6_left_full_fan_XLim_1_3_',layoutSet{i},'.png'])
end












