% 原图出处：
% Kong, L., Feng, Y., Zheng, R. et al. Interspecies hydrogen transfer 
% between cyanobacteria and symbiotic bacteria drives nitrogen loss. 
% Nat Commun 16, 5078 (2025). https://doi.org/10.1038/s41467-025-60327-x
% Fig.1 : Morphology and nitrogen removal performance of engineered photogranules.

% 数据预处理部分 ====================================
Data = readtable('41467_2025_60327_MOESM6_ESM.xlsx');
% 提取变量名和数值
rowName = Data.Taxon_name;
Data = Data(:, 2:end); 
colName = Data.Properties.VariableNames;
Data = Data.Variables;


% 绘图部分 ==========================================
figure('Units','normalized', 'Position',[.02,.05,.8,.85])
CC = chordChart(Data, 'colName',colName, 'rowName', rowName, ...
    'TickMode','linear' ,'Sep',1/80, 'LRadius', 1.32, 'OSqRatio',75/100);
% 刻度的设置要在draw()之前
% 刻度的紧密程度，数值越高刻度线数量越多
CC.linearTickCompactDegree = 1.7;
% 是否开启次刻度线
CC.linearMinorTick = 'on';
CC = CC.draw();
% 显示刻度和数值
CC.tickState('on')
CC.tickLabelState('on')
% 设置字体、刻度线粗细并把 1 号和 5:10 号标签隐藏
set(findobj('type', 'line'), 'LineWidth',1.5)
CC.setFont('FontSize', 18)
set(CC.nameFHdl([1, 5:10]), 'Color', 'none')
set(CC.nameFHdl(7), 'Color', 'k', 'String', 'Others')

% 修改配色 ==========================================
colCList = [204,103, 99; 232,183,183; 252,168,133; 
            206, 96, 16;  61,114,176;   1,  7,172]./255;
rowCList = [ 32,180,  2;  95,167,255;  85, 77,150;
            253,224,169; 215,234,209; 177,229,253;
            255,239,206; 163,184,209; 207,225,226;
            219,210,234]./255;
% 修改上方块颜色
for i = 1:length(colName)
    CC.setSquareT_N(i, 'FaceColor', colCList(i,:))
end
% 修改下方块颜色和弦配色
for i = 1:length(rowName)
    CC.setSquareF_N(i, 'FaceColor', rowCList(i,:))
    for j = 1:length(colName)
        CC.setChordMN(i,j, 'FaceColor',rowCList(i,:), 'FaceAlpha',.4)
    end
end

% 绘制图例 ==========================================
patchHdl = [];
for i = [10:-1:5, 1]
    patchHdl(end + 1) = fill([10,11,12],[10,13,13], ...
        rowCList(i,:), 'EdgeColor', 'none');
end
lgdHdl = legend(patchHdl, rowName([10:-1:5, 1]), 'FontSize',14, 'Box','off');
lgdHdl.Position = [.76,.11,.167,.27];
lgdHdl.ItemTokenSize = [18,8];