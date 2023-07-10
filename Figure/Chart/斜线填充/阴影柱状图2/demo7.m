y=[2 2 3 2 5; 2 5 6 2 5; 9 8 9 2 5];

SH=shadowHist(y,'ShadowType',{'/','\','.','_','+'},'Horizontal','on');
SH=SH.draw();
SH=SH.legend({'AAAAAAA','BBBBBBB','CCCCCCC','DDDDDDD','EEEEEEE'},'FontName','Cambria','FontSize',11);
% 坐标区域修饰
ax=gca;
ax.FontName='Cambria';
ax.LineWidth=1.1;
ax.XColor=[1,1,1].*.3;
ax.YColor=[1,1,1].*.3;
ax.XMinorTick='on';
ax.YMinorTick='on';
ax.XGrid='on';
ax.YGrid='on';
ax.Box='on';
ax.GridLineStyle='-.';
ax.GridAlpha=.1;
% 图例框修饰
lgdBox=findobj('Tag','lgdBox');
lgdBox.LineWidth=1.3;