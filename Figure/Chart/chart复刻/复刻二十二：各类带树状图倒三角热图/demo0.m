clc; clear

% 随机生成数据
X = randn(20,20)+[(linspace(-1,2.5,20)').*ones(1,8),(linspace(.5,-.7,20)').*ones(1,5),(linspace(.9,-.2,20)').*ones(1,7)];
Data = corr(X);
% 变量名列表
NameList = compose('Sl-%d',1:20);

fig = figure('Units', 'normalized', 'Position', [.05,.1,.6,.8], 'Color', 'w');
%% ========================================================================
% 创建热图对象 -- create heatmap object
SM = SMatrix(Data);
SM.ColName = NameList;
% 设置文本和字体 -- Set Text and Font
SM.LeftLabel = 'off';
SM.BottomLabel = 'off';
SM.TopLabel = 'on';
SM.TopLabelFont = {'FontSize', 15, 'FontName', 'Times New Roman', 'Rotation', 45};
% 设置位置 -- set position
SM.XLim = [0,1];
SM.YLim = [0,1];
SM.TLim = [-pi/4,-pi/4];
SM.draw()
%% ========================================================================
% 修饰句柄 -- decorate handles
% 清除热图下半部分 -- Clear the bottom half of the heatmap
tData = triu(ones(size(Data)),1);
tInd = find(tData(:) == 1);
for i = 1:length(tInd)
    set(SM.heatmapHdl{tInd(i)}, 'Visible', 'off')
end
% 修饰坐标区域 -- decorate axes
set(gca, 'XColor', 'none', 'YColor', 'none',...
    'DataAspectRatio', [1,1,1],'XLim', [0,1.45]);
CB = colorbar();
set(CB,'Location','southoutside','FontName','Times New Roman','FontSize',14);