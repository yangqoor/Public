clc; clear

% 随机生成数据
X = randn(20,10)+[(linspace(-1,2.5,20)').*ones(1,6),(linspace(.5,-.7,20)').*ones(1,4)];
Data = corr(X);
% 变量名列表
NameList = compose('Sl-%d',1:10);

% 通过树状图工具进行分类和数值计算(毕竟这个热图工具是树状图工具的附属)
Z1 = linkage(Data, 'average');
ST = STree(Z1, 'MaxClust', 2); 
ST.draw(); close all

fig = figure('Units', 'normalized', 'Position', [.05,.1,.6,.8], 'Color', 'w');
%% ========================================================================
% 创建热图对象 -- create heatmap object
SM = SMatrix(Data);
% 添加分组信息 -- Add grouping information
SM.RowOrder = ST.order;
SM.RowClass = ST.class;
SM.RowName = NameList;
SM.ColOrder = ST.order;
SM.ColClass = ST.class;
SM.ColName = NameList;
% 设置文本和字体 -- Set Text and Font
SM.LeftLabel = 'off';
SM.BottomLabelFont = {'FontSize', 15, 'FontName', 'Times New Roman', ...
    'Rotation',45, 'HorizontalAlignment','right', 'VerticalAlignment','baseline'};
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
% 移动标签位置
txtHdl = findobj(gca,'Type','text');
for i = 1:length(txtHdl)
    txtHdl(i).Position(2) = txtHdl(1).Position(2);
    txtHdl(i).Position(1) = txtHdl(i).Position(1).*sqrt(2).*sqrt(2);
end
% 修饰坐标区域 -- decorate axes
set(gca, 'XColor', 'none', 'YColor', 'none',...
    'DataAspectRatio', [1,1,1],'XLim', [-.02,sqrt(2) + .02]);
CB = colorbar();
set(CB,'Location','southoutside','FontName','Times New Roman','FontSize',14);
%% 绘制分组黑线 ============================================================
numN = length(ST.class);
numA = sum(ST.class == ST.class(1));
numB = sum(ST.class == ST.class(end));
plot([0,sqrt(2)/2,sqrt(2)].*numA./numN, [0,sqrt(2)/2,0].*numA./numN, 'Color','k', 'LineWidth',4)
plot(sqrt(2) - [0,sqrt(2)/2,sqrt(2)].*numB./numN, [0,sqrt(2)/2,0].*numB./numN, 'Color','k', 'LineWidth',4)
xx = linspace(0,sqrt(2), 2*numN + 1);
yy = -sqrt(2)/numN./2.*mod(0:2*numN, 2);
plot(xx,yy, 'Color','k', 'LineWidth',4)
plot([0,sqrt(2)/2].*numA./numN - .15/numN, [0,sqrt(2)/2].*numA./numN + .15/numN, 'Color',[.8,0,0], 'LineWidth',6)
plot(sqrt(2) - [0,sqrt(2)/2].*numB./numN + .15/numN, [0,sqrt(2)/2].*numB./numN + .15/numN, 'Color',[0,0,.8], 'LineWidth',6)

% 在这里改分类名称
text(sqrt(2)/4.*numA./numN - .5/numN, sqrt(2)/4.*numA./numN + .5/numN, 'A',...
    'FontSize',36, 'FontName','Times New Roman','HorizontalAlignment','right')
text(sqrt(2) - sqrt(2)/4.*numB./numN + .5/numN, sqrt(2)/4.*numB./numN + .5/numN, 'B',...
    'FontSize',36, 'FontName','Times New Roman')