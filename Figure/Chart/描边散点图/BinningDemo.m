% BinningDemo
Date  = readtable('binningData.txt','Delimiter',',');
% Group = flipud(unique(Date.group))
Group = {'other bins'; 'bin 19'; 'bin 13'; 'bin 11'; 'bin 3'; 'bin 5'};
CList = [177,177,176; 63,168,106; 24,222,154;
         96,0,123; 189,83,110; 170,219,87]./255;

figure('Units','normalized','Position',[.2,.3,.4,.6]);
% 循环绘制散点
for i = 1:length(Group)
    ind  = strcmp(Date.group,Group(i));
    binX = Date.X(ind);
    binY = Date.Y(ind);
    if i == 1
        strokeScatter(binX,binY,170,'filled','CData',CList(i,:),...
            'MarkerEdgeColor','none');
    else
        strokeScatter(binX,binY,170,'filled','CData',CList(i,:),...
            'MarkerEdgeColor','k','LineWidth',2);
    end
end

% 坐标区域修饰
ax = gca;
ax.PlotBoxAspectRatio = [1,1,1];
ax.Box = 'on';
ax.LineWidth = 2;
ax.FontName = 'Times New Roman';
ax.XGrid = 'on';
ax.YGrid = 'on';
ax.TickDir = 'out';
ax.XLim = [0.2,0.85];
ax.YTick = 0:50:150;
ax.XTick = 0.4:0.2:0.8;
ax.FontSize = 14;
ax.XColor = [.2,.2,.2];
ax.YColor = [.2,.2,.2];
% X轴副标签
ax.XRuler.SecondaryLabel.String = 'GC content';
ax.XRuler.SecondaryLabel.Position(1) = ax.XLim(1);
ax.XRuler.SecondaryLabel.HorizontalAlignment = 'left';
ax.XRuler.SecondaryLabel.FontSize = 16;
ax.XRuler.SecondaryLabel.VerticalAlignment = 'bottom';
ax.XRuler.SecondaryLabel.FontWeight = 'bold';
% Y轴标签
ax.YLabel.String = 'Contig abundance';
ax.YLabel.FontSize = 24;
ax.YLabel.FontWeight = 'bold';
% 绘制图例
lgdHdl = legend(Group);
lgdHdl.NumColumns = length(Group);
lgdHdl.Location = 'southoutside';
lgdHdl.Box = 'off';
lgdHdl.FontSize = 14;


