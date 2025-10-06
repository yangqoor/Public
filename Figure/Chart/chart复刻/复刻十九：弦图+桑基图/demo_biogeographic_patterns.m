% 原图出处
% Ji, M., Zhou, J., Li, Y. et al. 
% Biodiversity of mudflat intertidal viromes along the Chinese coasts. 
% Nat Commun 15, 8611 (2024). https://doi.org/10.1038/s41467-024-52996-x
% Fig.4 : Biogeographic patterns of intertidal viromes 
% and their linkages with other habitats.

% 数据预处理部分 ====================================
CList = [  1,201,117; 197,169,255; 247,191,142; 
         252,235, 79;  78,149,241; 190,190,190]./255;
Data = readtable('Fig.4d.csv');
% 提取变量名和数值
nameList = Data.Region;
Data = Data(:, 2:end); 
dataMat = Data.Variables;


% 弦图绘图部分 ==========================================
figure('Units','normalized','Position',[.02,.05,.7,.85])
ax1 = axes('Parent', gcf, 'Position',[0, .11, .7, .8], 'NextPlot','add');
BCC=biChordChart(dataMat, 'Label',nameList, 'Arrow','on', 'CData',CList, ...
    'TickMode','Linear', 'LRadius',1.3);
% 刻度的设置要在draw()之前
% 刻度的紧密程度，数值越高刻度线数量越多
BCC.linearTickCompactDegree = 3.2;
% 是否开启次刻度线
BCC.linearMinorTick = 'on';
BCC=BCC.draw(); 
BCC.tickState('on')
BCC.tickLabelState('on')
% 设置字体、刻度线粗细
set(findobj('type', 'line'), 'LineWidth',1.5)
BCC.setFont('FontSize', 18)


% 桑基图绘图部分 =========================================
ax2 = axes('Parent', gcf, 'Position', [.7, .11, .23, .8], 'NextPlot','add');
links(1:5, 1) = nameList(1);
links(1:5, 2) = nameList(2:end);
links(1:5, 3) = num2cell(dataMat(2:end,1));
disp(links)
% 创建桑基图对象
SK=SSankey(links(:,1), links(:,2), links(:,3));
% 设置配色
SK.ColorList = CList;
% 修改链接颜色渲染方式
% 'left'/'right'/'interp'(default)/'map'/'simple'
SK.RenderingMethod='interp'; 
% 设置方块横向宽度和竖向间隔
SK.Sep=.02;
SK.BlockScale = .1;
SK.draw()

% 修饰一下
for i=1:6
    % 设置块线条粗细，设置字体
    SK.setBlock(i,'EdgeColor',[0,0,0], 'LineWidth',1)
    SK.setLabel(i,'FontSize',18, 'FontName','default')
end
% 设置最左侧方块的文字旋转90度
SK.setLabel(1,'Rotation',90, 'HorizontalAlignment','center', ...
    'VerticalAlignment','bottom')
annotation(gcf, 'line', [.59 .68], [.544 0.575], 'LineWidth',1.5, 'LineStyle','--');