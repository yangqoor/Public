% Grouped heatmap

% 随便生成一些随机数据
rng(5)
Data = rand(50,10).*((1:10) + rand(1,10)) + randi([1,8],[50,1]);
Data = Data(:); Data = Data([end,1:end-1]); Data = reshape(Data, 50, []);

% 可以直接将上面部分删掉，然后
% Data = []% 自己的数据

K = 8; % kmeans 分组数
CName = compose('Class-%d', 1:K);

% 将相同组数据放在一起，并计算相关矩阵
[Class, Ind] = sort(kmeans(Data, K));
HMat = corr(Data(Ind,:).');

%% 绘图部分
%  坐标区域修饰
figure('Units','normalized', 'Position',[.1,.1,.6,.8])
ax = gca;
ax.NextPlot = 'add';
ax.Box = 'on';
ax.PlotBoxAspectRatio = [1,1,1];
ax.FontName = 'Times New Roman';
ax.FontSize = 14;
ax.YDir = 'reverse';
TickPos = find(diff([0;Class;K+1]) == 1);
ax.XTick = (TickPos(1:end-1) + TickPos(2:end) - 1)./2 - .5;
ax.YTick = ax.XTick;
ax.XTickLabel = CName;
ax.YTickLabel = CName;
ax.XTickLabelRotation = 30;
% 修改标题
ax.Title.String = 'XXXXXX K-means Centroid';
ax.Title.FontSize = 24;
ax.Title.VerticalAlignment = 'bottom';

% 绘制热图
N = size(Data, 1);
X = 0:N;
HMat(end+1, :) = nan;
HMat(:, end+1) = nan;
PHdl = pcolor(X, X, HMat);
PHdl.EdgeColor = [.3,.3,.3]; 
% PHdl.EdgeColor = 'none'; 

% 绘制分组线
for i = 2:K
    plot(ax, TickPos([i,i]) - 1, [0,N], 'Color','k', 'LineWidth',2)
    plot(ax, [0,N], TickPos([i,i]) - 1, 'Color','k', 'LineWidth',2)
end

% 绘制colorbar并调整颜色图
colorbar()
colormap(flipud(turbo))
clim([-1,1])


% colormap(slanCM(134))
set(gcf, 'Theme', 'dark')