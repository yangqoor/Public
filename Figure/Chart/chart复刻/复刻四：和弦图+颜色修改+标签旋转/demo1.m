% demo 1
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

% CC.setChordColorByMap([0,0,.8;.8,0,0])


CC.setFont('FontSize',17,'FontName','Cambria')
CC.tickState('on')
