% half violin plot 

Name = {'AAA', 'BBB', 'CCC'};
ClassName = {'Ambient','WarNing'};
Condition = {'ns','*','**'};

% 随机生成数据
rng(2)
offset = repmat(rand(1, 3), [100,1]).*2;
DataL = rand(100, 3) + offset;
DataR = rand(100, 3) + offset;


% 配色
CList = [153,153,253; 255,153,154]./255;
% CList = [0,64,115; 254,103,110]./255;
% 此参数用于调整小提琴图宽度
width = .36;

% 坐标区域修饰
ax = gca; 
ax.NextPlot = 'add';
ax.Box = 'on';
ax.XGrid = 'on';
ax.YGrid = 'on';
ax.XTick = 1:length(Name);
ax.XTickLabel = Name;
ax.FontName = 'Times New Roman';
ax.FontSize = 15;
ax.XTickLabelRotation = 30;
ax.XLim = [0, length(Name)] + .5;


for i = 1:length(Name)
    % 绘制核密度曲线
    [fL, yiL] = ksdensity(DataL(:, i));
    [fR, yiR] = ksdensity(DataR(:, i));
    fill(ax, (i - fL.*width), yiL, CList(1,:), 'EdgeColor','none', 'FaceAlpha',.5)
    fill(ax, (i + fR.*width), yiR, CList(2,:), 'EdgeColor','none', 'FaceAlpha',.5)
    % 绘制四分位数线
    qt25L = quantile(DataL(:, i), 0.25); qt75L = quantile(DataL(:, i), 0.75);
    plot(ax, [-1, 1, nan, -1, 1, nan, 0, 0].*.05 + i - .08, [qt75L, qt75L, nan, qt25L, qt25L, nan, qt75L, qt25L], 'LineWidth',1, 'Color','k')
    qt25R = quantile(DataR(:, i), 0.25); qt75R = quantile(DataR(:, i), 0.75);
    plot(ax, [-1, 1, nan, -1, 1, nan, 0, 0].*.05 + i + .08, [qt75R, qt75R, nan, qt25R, qt25R, nan, qt75R, qt25R], 'LineWidth',1, 'Color','k')
    % 绘制中位数点
    medL = median(DataL(:, i));
    scatter(i - .08, medL, 20, 'filled', 'CData',[0,0,0]);
    medR = median(DataR(:, i));
    scatter(i + .08, medR, 20, 'filled', 'CData',[0,0,0]);
    % 绘制显著性标签
    text(ax, i, max([yiL(:);yiR(:)]), Condition{i},...
        'FontSize',16, 'FontName','Times New Roman',...
        'HorizontalAlignment','center', 'VerticalAlignment','baseline')
end

% 绘制图例
fillHdl(1) = fill(ax, [-1,-2,-1], [0,0,1], CList(1,:), 'EdgeColor','none', 'FaceAlpha',.5);
fillHdl(2) = fill(ax, [-1,-2,-1], [0,0,1], CList(2,:), 'EdgeColor','none', 'FaceAlpha',.5);
lgdHdl = legend(fillHdl, ClassName, 'Location','best', 'Box','off');
lgdHdl.ItemTokenSize=[20,20];