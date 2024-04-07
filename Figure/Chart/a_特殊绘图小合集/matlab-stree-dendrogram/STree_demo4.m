% STree_demo4
% + position
% + rotation

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

ST.XLim = [1,3];           % 改变X坐标范围 -- change X-limit
ST.YLim = [1,2];           % 改变Y坐标范围 -- change Y-limit
ST.TLim = [pi/6,pi/6];     % 围绕0点旋转pi/6(当TLim 两个数值相等时，围绕(0,0)点做不形变的旋转)
                           % Rotate pi/6 around point 0 (when TLim has two equal values, rotate around point (0,0) without deformation)

close all

fig1 = figure('Units', 'normalized', 'Position', [.05,.1,.5,.7], 'Color', 'w');       
ST.ax = gca;
ST.Orientation = 'left';
ST.draw()
% exportgraphics(fig1, '.\gallery\demo4_position_rotation_left.png')

%% 
fig2 = figure('Units', 'normalized', 'Position', [.05,.1,.5,.7], 'Color', 'w');       
ST.ax = gca;
ST.Orientation = 'top';
ST.draw()
% exportgraphics(fig2, '.\gallery\demo4_position_rotation_top.png')





