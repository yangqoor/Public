

% X=randn(20,8)+[(linspace(-1,2.5,20)').*[1,1,1,1,1],(linspace(.5,-.7,20)').*[1,1,1]];
load XData.mat


CMP=corrMatPlot(X,'Format','triu','Type','pie');
CMP=CMP.setColorMap(1);
CMP=CMP.draw();