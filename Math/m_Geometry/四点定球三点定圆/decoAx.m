function decoAx
ax=gca;
hold(ax,'on');
grid(ax,'on');
ax.FontName='cambria';
ax.XColor=[1,1,1].*.3;
ax.YColor=[1,1,1].*.3;
ax.ZColor=[1,1,1].*.3;
ax.LineWidth=1.5;
ax.GridLineStyle='--';
ax.DataAspectRatio=[1,1,1];
end