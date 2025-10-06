% demo8
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer
rng(3)
dataMat = randi([1, 15], [7, 22]);
dataMat(dataMat < 11) = 0;
dataMat(1, sum(dataMat,1) == 0) = 15;
colName = {'A2M', 'FGA', 'FGB', 'FGG', 'F11', 'KLKB1', 'SERPINE1', 'VWF',...
           'THBD', 'TFPI', 'PLAT', 'SERPINA5', 'SERPIND1', 'F2', 'PLG', 'F12',...
           'SERPINC1', 'SERPINA1', 'PROS1', 'SERPINF2', 'F13A1', 'PROC'};
rowName = {'Lung', 'Spleen', 'Liver', 'Heart',...
           'Renal cortex', 'Renal medulla', 'Thyroid'};

figure('Units','normalized', 'Position',[.02, .05, .6, .85])
CC = chordChart(dataMat, 'rowName',rowName, 'colName',colName, 'Sep',1/80, 'LRadius',1.21);
CC = CC.draw();
CC.labelRotate('on')

% 单独设置每一个弦末端方块(Set individual end blocks for each chord)
% Use obj.setEachSquareF_Prop 
% or  obj.setEachSquareT_Prop
% F means from (blocks below)
% T means to   (blocks above)
CListT = [173,70,65; 79,135,136]./255;
% Upregulated:1 | Downregulated:2
Regulated = rand([7, 22]);
Regulated = (Regulated < .8) + 1;
for i = 1:size(Regulated, 1)
    for j = 1:size(Regulated, 2)
        CC.setEachSquareT_Prop(i, j, 'FaceColor', CListT(Regulated(i,j),:))
    end
end
% 绘制图例(Draw legend)
H1 = fill([0,1,0]+100, [1,0,1]+100, CListT(1,:), 'EdgeColor','none');
H2 = fill([0,1,0]+100, [1,0,1]+100, CListT(2,:), 'EdgeColor','none');
lgdHdl = legend([H1,H2], {'Upregulated','Downregulated'}, 'AutoUpdate','off', 'Location','best');
lgdHdl.ItemTokenSize = [12,12];
lgdHdl.Box = 'off';
lgdHdl.FontSize = 13;

% 修改下方方块颜色(Modify the color of the blocks below)
CListF=[128,108,171; 222,208,161; 180,196,229; 209,150,146; 175,201,166;
        134,156,118; 175,175,173]./255;
for i=1:7
    CC.setSquareF_N(i, 'FaceColor',CListF(i,:))
end
% 修改弦颜色(Modify chord color)
for i=1:7
    for j=1:22
        CC.setChordMN(i,j, 'FaceColor',CListF(i,:), 'FaceAlpha',.45)
    end
end