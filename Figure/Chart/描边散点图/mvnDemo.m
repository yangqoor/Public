clc; clear; close all
rng(6)
% 生成随机点(Generate random points)
mu = [1 1; 12 10; 9 12];
S  = cat(3,[1 0; 0 2],[1 0; 0 2],[1 0; 0 1]);
r1 = abs(mvnrnd(mu(1,:),S(:,:,1),200));
r2 = abs(mvnrnd(mu(2,:),S(:,:,2),200));
r3 = abs(mvnrnd(mu(3,:),S(:,:,3),200));
% 绘制散点图(Draw scatter chart)
hold on
propCell = {'LineWidth',2,'MarkerEdgeColor',[.3,.3,.3],'SizeData',100};
strokeScatter(round(r1(:,1)),r1(:,2),'filled','CData',[0.40 0.76 0.60],propCell{:});
strokeScatter(round(r2(:,1)),r2(:,2),'filled','CData',[0.99 0.55 0.38],propCell{:});
strokeScatter(round(r3(:,1)),r3(:,2),'filled','CData',[0.55 0.63 0.80],propCell{:});
% 增添图例(Draw legend)
lgd = legend('class1','class2','class3');
lgd.Location = 'northwest';
lgd.FontSize = 14;
% 坐标区域基础修饰(Axes basic decoration)
ax=gca; grid on
ax.FontName   = 'Cambria';
ax.Color      = [0.9,0.9,0.9];
ax.Box        = 'off';
ax.TickDir    = 'out';
ax.GridColor  = [1 1 1];
ax.GridAlpha  = 1;
ax.LineWidth  = 1;
ax.XColor     = [0.2,0.2,0.2];
ax.YColor     = [0.2,0.2,0.2];
ax.TickLength = [0.015 0.025];
% 隐藏轴线(Hide XY-Ruler)
pause(1e-6)
ax.XRuler.Axle.LineStyle = 'none';
ax.YRuler.Axle.LineStyle = 'none';


function stHdl = strokeScatter(varargin)
    set(gca,'NextPlot','add');
    scHdl = scatter(varargin{:});
    stHdl = scatter(varargin{:},'MarkerEdgeColor','none');
    scHdl.Annotation.LegendInformation.IconDisplayStyle='off';
end