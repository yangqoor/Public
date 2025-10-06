
% ----------------------------------------------------------------------
% 例子1 随便构造数据
% 随便构造的数据，可以换成自己的数据
clc; clear; rng(4)
Data = rand([7, 12]) + 1 + sin(linspace(0, 2*pi, 12) - pi/1.2) + (1:7).'./12;
Data = Data./max(max(Data));

% 绘制小提琴图的数据，应为列数与 Data 相同的矩阵或元胞数组
VData = mean(Data, 1) + randn([50, size(Data, 2)]).*.6;

% ----------------------------------------------------------------------
% % 例子2 已有各年份每一天数据，对其进行统计
% clc; clear
% testData = load('test.mat');
% t = testData.Data.t;
% v = testData.Data.v;
% y = 2024:-1:2018;
% % 构造一个矩阵，第 i 行第 j 列是第 i 年第 j 个月的数值平均值
% Data = zeros(length(y), 12);
% for i = 1:length(y)
%     for m = 1:12
%         idx = (year(t) == y(i)) & (month(t) == m);
%         Data(i, m) = mean(v(idx));
%     end
% end
% % 构造一个元胞数组，第 i 个元胞是 i 月全部数值合集
% VData{12} = [];
% for m = 1:12
%     idx = (month(t) == m);
%     VData{m} = v(idx)';
% end


% 矩阵每行名称
% rowName = {'2024','2023','2022','2021',2020','2019','2018'};
rowName = compose('%d',2024:-1:2018);

% 矩阵每列名称
colName = {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', ...
           'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};

%% 格式设置 ===============================================================
% 标签格式
fontProp = {'FontSize',16, 'FontName','Times New Roman'};

% 配色
CMap = 'summer';
% CMap = interp1([0,.5,1], [214,115,144;255,238,234;107,152,191]./255, 0:.01:1);


% 小提琴图宽度
width = 0.9;

% 数据范围，以及刻度位置
% VLim = [0, 1];
% VTick = 0:.2:1;
VLim = [];
VTick = [];


%% 数据预处理 ============================================================
% 如果不设置 VLim, VTick
% 则自动计算一个比较合理的刻度位置
linearTickCompactDegree = 5;
if isempty(VLim)
    if iscell(VData)
    VLim = [min(min(min(Data)), min(cellfun(@min, VData)))...
            max(max(max(Data)), max(cellfun(@max, VData)))];
    else
    VLim = [min(min(min(Data)), min(min(VData)))...
            max(max(max(Data)), max(max(VData)))];
    end
end
if isempty(VTick)
    tXS = diff(VLim) / linearTickCompactDegree;
    tXN = ceil(log(tXS) / log(10));
    tXS = round(round(tXS / 10^(tXN-2)) / 5) * 5 * 10^(tXN-2);
    tVTick1 = 0:-tXS:VLim(1);
    tVTick2 = 0:tXS:VLim(2);
    VTick = unique([tVTick1, tVTick2]);
    VTick(VTick < VLim(1)) = [];
    VTick(VTick > VLim(2)) = [];
end

%% 绘图部分代码 ============================================================
% 构造图窗及坐标区域
fig = figure('Units','normalized', 'Position',[.1,.1,.6,.8], 'Color','w');
ax = axes('Parent',fig, 'XLim',[-sqrt(3), sqrt(3)], 'YLim',[0, 2], ...
    'DataAspectRatio',[1,1,1], 'Position',[.05,.2,.9,.8], ...
    'NextPlot','add', 'XColor','none', 'YColor','none');
colormap(CMap)

% 绘制射线
w = 1*pi/3/size(Data, 2);
tt = linspace(5*pi/6 - w, pi/6 + w, size(Data, 2));
xx = cos(tt).*2; xx = [xx; xx.*0; xx.*nan(1)];
yy = sin(tt).*2; yy = [yy; yy.*0; yy.*nan(1)];
plot(ax, xx(:), yy(:), 'LineWidth',1, 'Color',[1,1,1].*.8, 'LineStyle','--')

% 绘制列标签
for i = 1:length(colName)
    text(ax, cos(tt(i)).*2.01, sin(tt(i)).*2.01, colName(i), ...
        'HorizontalAlignment','center', 'VerticalAlignment', 'bottom', ...
        'Rotation', tt(i)/pi*180 - 90, fontProp{:})
end

% 绘制行名称标签
for i = 1:length(rowName)
    r = 2/5 + (size(Data, 1) - i + .5)*4/size(Data, 1)/5;
    if mod(i, 2) == 1
        text(ax, cos(5*pi/6).*r - 1/100, sin(5*pi/6).*r - sqrt(3)/100, rowName{i}, ...
            'HorizontalAlignment','right', 'Rotation',60, fontProp{:})
    else
        text(ax, cos(pi/6).*r + 1/100, sin(pi/6).*r - sqrt(3)/100, rowName{i}, ...
            'HorizontalAlignment','left', 'Rotation',-60, fontProp{:})
    end
end

% 绘制刻度轴线
plot(ax, cos(5*pi/6).*[6/5 + 1/10, 10/5 - 1/10], ...
         sin(5*pi/6).*[6/5 + 1/10, 10/5 - 1/10], 'LineWidth',1, 'Color','k')
plot(ax, cos(pi/6).*[6/5 + 1/10, 10/5 - 1/10], ...
         sin(pi/6).*[6/5 + 1/10, 10/5 - 1/10], 'LineWidth',1, 'Color','k')

% 绘制刻度和刻度标签
for i = 1:length(VTick)
    r = (VTick(i) - VLim(1))./diff(VLim).*(3/5) + (6/5 + 1/10);
    x1 = [cos(5*pi/6).*r, cos(5*pi/6).*r + 1/100];
    y1 = [sin(5*pi/6).*r, sin(5*pi/6).*r + sqrt(3)/100];
    plot(ax, x1, y1, 'LineWidth',1, 'Color','k')
    x2 = [cos(pi/6).*r, cos(pi/6).*r - 1/100];
    y2 = [sin(pi/6).*r, sin(pi/6).*r + sqrt(3)/100];
    plot(ax, x2, y2, 'LineWidth',1, 'Color','k')
    if mod(length(VTick) - i, 2) == 0
        text(ax, cos(5*pi/6).*r - 1/100, sin(5*pi/6).*r - sqrt(3)/100, num2str(VTick(i)), ...
            'HorizontalAlignment','right', 'Rotation',60, fontProp{:})
    else
        text(ax, cos(pi/6).*r + 1/100, sin(pi/6).*r - sqrt(3)/100, num2str(VTick(i)), ...
            'HorizontalAlignment','left', 'Rotation',-60, fontProp{:})
    end
end

% 绘制小提琴图
maxf = 0;
for i = 1:size(Data, 2)
    if iscell(VData)
        tY = VData{i};
    else
        tY = VData(:,i);
    end
    tY(isnan(tY)) = [];
    [f, yi] = ksdensity(tY);
    maxf = max(maxf, max(f));
end
for i = 1:size(Data, 2)
    if iscell(VData)
        tY = VData{i};
    else
        tY = VData(:,i);
    end
    tY(isnan(tY)) = [];
    [f, yi] = ksdensity(tY);
    yyi = [min(tY), yi(yi<max(tY) & yi>min(tY)), max(tY)];
    ind1 = find(yi<max(tY) & yi>min(tY), 1, 'first');
    ind2 = find(yi<max(tY) & yi>min(tY), 1, 'last');
    f1 = interp1(yi((ind1 - 1):ind1), f((ind1 - 1):ind1), min(tY));
    f2 = interp1(yi(ind2:(ind2 + 1)), f(ind2:(ind2 + 1)), max(tY));
    ff = [f1, f(yi<max(tY) & yi>min(tY)), f2];
    xx = [ff, -ff(end:-1:1)]./maxf.*(4*pi/5/size(Data, 2)).*width./2;
    yy = ([yyi, yyi(end:-1:1)] - VLim(1))./diff(VLim).*3./5 + 6/5 + 1/10;
    xy = [cos(tt(i) - pi/2), - sin(tt(i) - pi/2);
          sin(tt(i) - pi/2), cos(tt(i) - pi/2)]*[xx; yy];
    % 绘制小提琴
    fill(ax, xy(1,:), xy(2,:), mean(tY), 'EdgeColor',[0,0,0], 'LineWidth',1)

    qt25 = quantile(tY, 0.25);
    qt75 = quantile(tY, 0.75);
    med = median(tY);
    ind3 = find(yi < qt25, 1, 'last');
    ind4 = find(yi < qt75, 1, 'last');
    ind5 = find(yi < med, 1, 'last');
    f3 = interp1(yi(ind3:(ind3 + 1)), f(ind3:(ind3 + 1)), qt25);
    f4 = interp1(yi(ind4:(ind4 + 1)), f(ind4:(ind4 + 1)), qt75);
    f5 = interp1(yi(ind5:(ind5 + 1)), f(ind5:(ind5 + 1)), med);
    xx = [f3, -f3, f4, -f4, f5, -f5]./maxf.*(4*pi/5/size(Data, 2)).*width./2;
    yy = ([qt25, qt25, qt75, qt75, med, med] - VLim(1))./diff(VLim).*3./5 + 6/5 + 1/10;
    xy = [cos(tt(i) - pi/2), - sin(tt(i) - pi/2);
          sin(tt(i) - pi/2), cos(tt(i) - pi/2)]*[xx; yy];
    % 绘制四分位线和中位线
    plot(ax, xy(1,1:2), xy(2,1:2), 'LineWidth',1, 'Color','k')
    plot(ax, xy(1,3:4), xy(2,3:4), 'LineWidth',1, 'Color','k')
    plot(ax, xy(1,5:6), xy(2,5:6), 'LineWidth',2, 'Color','k')
end

% 绘制热图
TT = linspace(5*pi/6, pi/6, size(Data, 2) + 1);
for i = 1:size(Data, 1)
    for j = 1:size(Data, 2)
        tt = linspace(TT(j), TT(j + 1), 30);
        r1 = 2/5 + (i - 1)*4/size(Data, 1)/5;
        r2 = 2/5 + i*4/size(Data, 1)/5;
        xx = [cos(tt).*r1, cos(tt(end:-1:1)).*r2];
        yy = [sin(tt).*r1, sin(tt(end:-1:1)).*r2];
        fill(ax, xx, yy, Data(i,j), 'EdgeColor','w', 'LineWidth',1)
    end
end

% 绘制最上方弧线
tt = linspace(5*pi/6, pi/6, 80);
xx = cos(tt).*2;
yy = sin(tt).*2;
plot(ax, xx(:), yy(:), 'LineWidth',1, 'Color','k')

colorbar(ax, 'Position',[.5-.01,.1,.02,.2], fontProp{:});

