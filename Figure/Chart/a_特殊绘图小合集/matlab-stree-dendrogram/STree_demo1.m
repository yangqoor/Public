% STree_demo1
% + basic usage
% + basic decorative elements

% 随机生成数据 -- random data
% rng(10)
Data = rand(75,3);

% 分类数 -- clust number
N = 5;

fig1 = figure('Units', 'normalized', 'Position', [.05,.3,.7,.4], 'Color', 'w');

% 创建聚类树状图对象 -- create tree(dendrogram) object
Z = linkage(Data, 'average');
ST = STree(Z, 'MaxClust', N);

ST.draw()
set(gca,'XColor','none','YColor','none')
% exportgraphics(fig1, '.\gallery\demo1_basic_usage.png')





%% ========================================================================
fig2 = figure('Units', 'normalized', 'Position', [.05,.3,.7,.4], 'Color', 'w');
ST.ax = gca;               % 更换坐标区域        -- change the axes
ST.ClustGap = 'on';        % 每个类之间加入间隙   -- insert gap between each clust
ST.BranchColor = 'on';     % 为不同类树枝添加颜色 -- set the branch's color of each clust
ST.BranchHighlight = 'on'; % 增添树枝高亮         -- add highlight for each clust's branches
ST.ClassHighlight = 'on';  % 分类高亮            -- add class highlight
ST.ClassLabel = 'on';      % 分类文本信息         -- add class-label

ST.SampleName = compose('slan%d', 1:size(Data,1));
ST.ClassName = compose('Class-%c', 64 + (1:N));

% 调整字体 -- adjust font
ST.SampleFont = {'FontSize', 10, 'FontName', 'Times New Roman'};
ST.ClassFont = {'FontSize', 14, 'FontName', 'Times New Roman', 'FontWeight', 'bold'};
ST.draw()
set(gca,'XColor','none','YColor','none')
% exportgraphics(fig2, '.\gallery\demo1_basic_decorative_elements.png')






%% ========================================================================
% change color
fig3 = figure('Units', 'normalized', 'Position', [.05,.3,.7,.4], 'Color', 'w');
ST.ax = gca;% 更换坐标区域  -- change the axes
ST.CData = [0.3569    0.0784    0.0784
    0.6784    0.4471    0.1725
    0.1020    0.3882    0.5176
    0.1725    0.4196    0.4392
    0.2824    0.2275    0.2902];
ST.draw()
set(gca,'XColor','none','YColor','none')
% exportgraphics(fig3, '.\gallery\demo1_change_color.png')
