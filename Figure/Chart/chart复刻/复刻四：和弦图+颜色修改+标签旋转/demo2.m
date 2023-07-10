% demo 2
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer

dataMat=[2 0 1 2 5 1 2;
         3 5 1 4 2 0 1;
         4 0 5 5 2 4 3];
colName={'G1','G2','G3','G4','G5','G6','G7'};
rowName={'S1','S2','S3'};

CC=chordChart(dataMat,'rowName',rowName,'colName',colName);
CC=CC.draw();

% 弦属性设置 ===============================================================
CC.setChordProp('EdgeColor',[.3,.3,.3],'LineStyle','--',...
    'LineWidth',.1)

% CC.setChordMN(2,4,'FaceColor',[1,0,0])

CC.setChordColorByMap(flipud(gray(100)))


% 方块属性设置 =============================================================
CC.setSquareT_Prop('FaceColor',[0,0,0])
CC.setSquareT_N(2,'FaceColor',[.8,0,0])
% CC.setSquareF_Prop('FaceColor',[0,0,0])
% CC.setSquareF_N(2,'FaceColor',[.8,0,0])

% 字体设置 =================================================================
CC.setFont('FontSize',17,'FontName','Cambria','Color',[0,0,.8])


% 刻度开关设置 =============================================================
CC.tickState('on')