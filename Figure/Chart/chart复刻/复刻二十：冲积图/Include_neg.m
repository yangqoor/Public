% 含负数的例子
Data = randi([-2, 5], [6,4]);
barHdl = bar(Data, 'stacked', 'BarWidth',.4, 'EdgeColor','w');
prop = {'FaceAlpha',.4, 'EdgeColor','none', 'EdgeColor','w'};

%% 坐标区域修饰
ax = gca;
ax.NextPlot = 'add';
ax.Box = 'off';
ax.TickDir = 'out'; % 刻度线朝外
ax.LineWidth = 1.5;

% 修改刻度位置和标签
ax.XLim = .5 + [0, size(Data, 1)];
ax.XTick = 1:size(Data, 1);
ax.YTick = 0:25:100;

%% 绘制冲积图链接部分
numSegs = length(barHdl(1).YData);
yEndPoints = [zeros(1, numSegs); ...
    reshape([barHdl.YEndPoints]', numSegs, [])'];
barWidth = barHdl(1).BarWidth*.5;
for i = 1:length(barHdl)
    for j = 1:numSegs - 1
        [y1, y2] = bounds([yEndPoints(i, j), yEndPoints(i+1, j)]);
        if y1 * y2 < 0
            ty = yEndPoints(find(yEndPoints(i+1, j) * ...
                 yEndPoints(1:i, j) >= 0, 1, 'last'), j);
            [y1, y2] = bounds([ty, yEndPoints(i+1, j)]);
        end
        [y3, y4] = bounds([yEndPoints(i, j+1), yEndPoints(i+1, j+1)]);
        if y3 * y4 < 0
            ty = yEndPoints(find(yEndPoints(i+1, j+1) * ...
                 yEndPoints(1:i, j+1) >= 0, 1, 'last'), j+1);
            [y3, y4] = bounds([ty, yEndPoints(i+1, j+1)]);
        end
        fill(j + [barWidth, 1-barWidth, 1-barWidth, barWidth], ...
            [y1, y3, y4, y2], barHdl(i).FaceColor, prop{:});
    end
end
