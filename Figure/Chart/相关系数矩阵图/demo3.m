load XData.mat


CMP=corrMatPlot(X,'Format','triu','Type','pie');
CMP=CMP.setColorMap(1);
CMP=CMP.draw(); 
CMP.setXLabel('Color',[.8,0,0],'FontName','Cambria','FontSize',15)
CMP.setYLabel('Color',[0,0,.8],'FontName','Cambria','FontSize',15)