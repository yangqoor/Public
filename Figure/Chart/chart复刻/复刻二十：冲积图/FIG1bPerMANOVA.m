clc; clear

%% 从xlsx内读取数据并预处理
% 处理结果等同于下方被注释掉的代码
Data = readcell('Fig.1b.xlsx');
rowName = Data(2:end, 1);
colName = Data(1, 2:end);
Data = cell2mat(Data(2:end, 2:end));
% rowName = {'BS';'RS';'RE';'VE';'SE';'LE';'P'};
% colName = {'Site','Fertilisation','Site×Fertilisation','Unknown'};
% Data = [62.49, 11.78, 17.66,  8.07;
%         60.53,  6.77, 15.84, 16.86;
%         53.61,  3.51, 11.71, 31.17;
%         11.23,  3.54, 13.65, 71.58;
%         25.88,  0.77, 19.59, 53.76;
%         29.78,  4.10, 24.69, 41.43;
%         36.33,  2.00, 17.60, 44.07];

%% 绘制堆叠柱状图
figure('Units','normalized', 'Position',[.2,.2,.5,.55])
barHdl = bar(Data, 'stacked', 'BarWidth',.65, 'EdgeColor','w', 'LineWidth',1);
barHdl(1).BaseLine.LineStyle = 'none'; % 隐藏柱状图基线


%% 柱状图修饰
% 修改柱状图配色
CList = [144,170,220; 169,209,143; 255,231,153; 219,219,219]./255;
for i = 1:size(Data, 2)
    barHdl(i).FaceColor = CList(i,:);
end
% 绘制图例
legend(colName, 'AutoUpdate','off', 'Box','off', ...
    'Location','eastoutside','IconColumnWidth',15);


%% 坐标区域修饰
ax = gca;
ax.NextPlot = 'add';
ax.Box = 'off';
ax.TickDir = 'out'; % 刻度线朝外
ax.LineWidth = 2;
% 修改刻度位置和标签
ax.XLim = .5 + [0, size(Data, 1)];
ax.YLim = [-1, 100];
ax.XTick = 1:size(Data, 1);
ax.YTick = 0:25:100;
ax.XTickLabel = rowName;
ax.FontSize = 18;
ax.YLabel.String = 'Explained variation(%)';
ax.YLabel.FontSize = 20;


%% 绘制冲积图链接部分
prop = {'FaceAlpha',.4, 'EdgeColor','none', 'EdgeColor','w', 'LineWidth',1};
numSegs = length(barHdl(1).YData);
yEndPoints = [zeros(1, numSegs); reshape([barHdl.YEndPoints]', numSegs, [])'];
barWidth = barHdl(1).BarWidth*.5;
for i = 1:length(barHdl)
    for j = 1:numSegs - 1
        fill(j + [barWidth, 1-barWidth, 1-barWidth, barWidth], ...
            yEndPoints(sub2ind(size(yEndPoints), [i,i,i+1,i+1], [j,j+1,j+1,j])), ...
            barHdl(i).FaceColor, prop{:});
    end
end


% numSegs = length(barHdl(1).YData);
% yEndPoints = [zeros(1, numSegs); ...
%     reshape([barHdl.YEndPoints]', numSegs, [])'];
% barWidth = barHdl(1).BarWidth*.5;
% for i = 1:length(barHdl)
%     for j = 1:numSegs - 1
%         [y1, y2] = bounds([yEndPoints(i, j), yEndPoints(i+1, j)]);
%         if y1*y2 < 0
%             ty = yEndPoints(find(yEndPoints(i+1, j) * ...
%                  yEndPoints(1:i, j) >= 0, 1, 'last'), j);
%             [y1, y2] = bounds([ty, yEndPoints(i+1, j)]);
%         end
%         [y3, y4] = bounds([yEndPoints(i, j+1), yEndPoints(i+1, j+1)]);
%         if y3*y4 < 0
%             ty = yEndPoints(find(yEndPoints(i+1, j + 1) * ...
%                  yEndPoints(1:i, j+1) >= 0, 1, 'last'), j+1);
%             [y3, y4] = bounds([ty, yEndPoints(i+1, j+1)]);
%         end
%         fill(j + [barWidth, 1-barWidth, 1-barWidth, barWidth], ...
%             [y1, y3, y4, y2], barHdl(i).FaceColor, prop{:});
%     end
% end
