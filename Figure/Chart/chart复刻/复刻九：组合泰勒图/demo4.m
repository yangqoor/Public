STATS = [64.167 , 46.599 , 50.884;
              0      , 48.155 , 49.611;
              1      ,  0.664 ,  0.650];

% Create taylor axes(生成泰勒图坐标区域)
figure('Units','normalized','Position',[.2,.1,.52,.72]);
TD = STaylorDiag(STATS);

% Color list(颜色列表)
colorList = [0.3569    0.0784    0.0784
    0.6784    0.4471    0.1725
    0.1020    0.3882    0.5176
    0.1725    0.4196    0.4392
    0.2824    0.2275    0.2902];
MarkerType={'o','diamond','pentagram','^','v'};
% Plot(绘制散点图)
for i = 1:3
    TD.SPlot(STATS(1,i),STATS(2,i),STATS(3,i),'Marker',MarkerType{i},'MarkerSize',15,...
        'Color',colorList(i,:),'MarkerFaceColor',colorList(i,:));
end

% Legend
NameList = {'AAA','BBB','CCC'};
legend(NameList,'FontSize',13,'FontName','Times New Roman')

% Annotation
TD.SText(STATS(1,1),STATS(2,1),STATS(3,1),{'reference';' '},'FontWeight','bold',...
    'FontSize',20,'FontName','Times New Roman','Color',colorList(1,:),...
    'VerticalAlignment','bottom','HorizontalAlignment','center');

for i = 1:3
    TD.SText(STATS(1,i),STATS(2,i),STATS(3,i),"   "+string(NameList{i}),'FontWeight','bold',...
    'FontSize',14,'FontName','Times New Roman',...
    'VerticalAlignment','middle','HorizontalAlignment','left');
end