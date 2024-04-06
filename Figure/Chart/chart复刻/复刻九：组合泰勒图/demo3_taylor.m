clc; clear
Data = load('testData.mat');
Data = Data.Data;
% % 不想下数据的可以用随便捏造的数据试试
% % 随便捏造了点数据(Made up some data casually)
% Data = randn(100,6).*.2+[(linspace(-1,.5,100)').*ones(1,2),...
%                          (linspace(-.5,.7,100)').*ones(1,2),...
%                          (linspace(-.9,.2,100)').*ones(1,2)];

% Calculate STD RMSD and COR(计算标准差、中心均方根误差、相关系数)
STATS = zeros(4,size(Data,2));
for i = 1:size(Data,2)
    STATS(:,i) = SStats(Data(:,1),Data(:,i));
end
STATS(1,:) = [];

%% Create figure and axes(生成基础布局)
fig=figure('Units','normalized','Position',[.2,.1,.54,.74]);
bkgAx=axes(fig,'Position',[.13,.11,.67,.88],'XTick',[],'YTick',[],'Box','on',...
    'Color',[253,228,203]./255,'XLim',[0,100],'YLim',[0,88],'NextPlot','add');
plot(bkgAx,[50,50],[0,88],'Color','k','LineWidth',.8)
text(bkgAx,25,42,'Autumn','FontSize',16,'FontName','Times New Roman','HorizontalAlignment','center')
text(bkgAx,75,42,'Winter','FontSize',16,'FontName','Times New Roman','HorizontalAlignment','center')
text(bkgAx,25,86,'Spring','FontSize',16,'FontName','Times New Roman','HorizontalAlignment','center')
text(bkgAx,75,86,'Summer','FontSize',16,'FontName','Times New Roman','HorizontalAlignment','center')
bkgAx.XLabel.String='Standard Deviation(mm month^{-1})';
bkgAx.XLabel.FontSize=18;
bkgAx.XLabel.FontName='Times New Roman';
bkgAx.XLabel.Position=[50,-3,-1];
bkgAx.YLabel.String='Standard Deviation(mm month^{-1})';
bkgAx.YLabel.FontSize=18;
bkgAx.YLabel.FontName='Times New Roman';
bkgAx.YLabel.Position=[-7,44,-1];
% -------------------------------------------------------------------------
ax1 = axes(fig,'Position',[.13,.11,.335,.4],'Box','on');
ax2 = axes(fig,'Position',[.465,.11,.335,.4],'Box','on');
ax3 = axes(fig,'Position',[.13,.55,.335,.4],'Box','on');
ax4 = axes(fig,'Position',[.465,.55,.335,.4],'Box','on');

%% Create taylor axes(生成泰勒图坐标区域)
TD1 = STaylorDiag(ax1,STATS);
set(ax1,'Box','on','XTick',[],'YTick',[],'XColor','k','YColor','k',...
    'XLim',TD1.SLim.*1.13,'YLim',TD1.SLim.*1.15);
TD1.set('SLabel','Color','none');
TD1.set('RGrid','Color',[.77,.6,.18],'LineWidth',1.2)
TD1.set('RTickLabel','Color',[.77,.6,.18],'FontWeight','bold')
TD1.set('CLabel','FontSize',16)

TD2 = STaylorDiag(ax2,STATS);
set(ax2,'Box','on','XTick',[],'YTick',[],'XColor','k','YColor','k',...
    'XLim',TD2.SLim.*1.13,'YLim',TD2.SLim.*1.15);
TD2.set('SLabel','Color','none');
TD2.set('STickLabelY','Color','none');
TD2.set('RGrid','Color',[.77,.6,.18],'LineWidth',1.2)
TD2.set('RTickLabel','Color',[.77,.6,.18],'FontWeight','bold')
TD2.set('CLabel','FontSize',16)

TD3 = STaylorDiag(ax3,STATS);
set(ax3,'Box','on','XTick',[],'YTick',[],'XColor','k','YColor','k',...
    'XLim',TD2.SLim.*1.13,'YLim',TD2.SLim.*1.15);
TD3.set('SLabel','Color','none');
TD3.set('STickLabelX','Color','none');
TD3.set('RGrid','Color',[.77,.6,.18],'LineWidth',1.2)
TD3.set('RTickLabel','Color',[.77,.6,.18],'FontWeight','bold')
TD3.set('CLabel','FontSize',16)

TD4 = STaylorDiag(ax4,STATS);
set(ax4,'Box','on','XTick',[],'YTick',[],'XColor','k','YColor','k',...
    'XLim',TD2.SLim.*1.13,'YLim',TD2.SLim.*1.15);
TD4.set('SLabel','Color','none');
TD4.set('STickLabelX','Color','none');
TD4.set('STickLabelY','Color','none');
TD4.set('RGrid','Color',[.77,.6,.18],'LineWidth',1.2)
TD4.set('RTickLabel','Color',[.77,.6,.18],'FontWeight','bold')
TD4.set('CLabel','FontSize',16)

%% 绘制散点
% Color list(颜色列表)
colorList = [145,81,155;217,34,30;68,127,183;76,181,75;145,81,155;248,130,7]./255;
% Plot(绘制散点图)
for i = 1:size(Data,2)
    TD1.SPlot(STATS(1,i),STATS(2,i),STATS(3,i),'Marker','o','MarkerSize',10,...
        'Color',colorList(i,:),'MarkerFaceColor',colorList(i,:));
    TD2.SPlot(STATS(1,i),STATS(2,i),STATS(3,i),'Marker','o','MarkerSize',10,...
        'Color',colorList(i,:),'MarkerFaceColor',colorList(i,:));
    TD3.SPlot(STATS(1,i),STATS(2,i),STATS(3,i),'Marker','o','MarkerSize',10,...
        'Color',colorList(i,:),'MarkerFaceColor',colorList(i,:));
    lgdPltHdl(i)=TD4.SPlot(STATS(1,i),STATS(2,i),STATS(3,i),'Marker','o','MarkerSize',10,...
        'Color',colorList(i,:),'MarkerFaceColor',colorList(i,:));
end
% legend
lgdHdl = legend(ax4,lgdPltHdl(2:end),{'# 1 1/x','# 2 e\^-x(x/0.1\^2)','# 3 e\^-x(x/0.5\^2)','# 4 e\^-x(x/0.2\^2)','# 5 e\^-x(x/0.25\^2)'},...
    'Position',[.825,.47,0.15,0.2]);
lgdHdl.Title.String='Weighting Scheme';
lgdHdl.Title.FontSize=14;
lgdHdl.Title.FontName='Times New Roman';
lgdHdl.FontSize=12;
lgdHdl.FontName='Times New Roman';
lgdHdl.Box='off';
% Annotation
TD1.SText(STATS(1,1),STATS(2,1),STATS(3,1),{'observed';''},'FontWeight','bold',...
    'FontSize',13,'FontName','Times New Roman','Color',colorList(1,:),...
    'VerticalAlignment','bottom','HorizontalAlignment','center');
TD2.SText(STATS(1,1),STATS(2,1),STATS(3,1),{'observed';''},'FontWeight','bold',...
    'FontSize',13,'FontName','Times New Roman','Color',colorList(1,:),...
    'VerticalAlignment','bottom','HorizontalAlignment','center');
TD3.SText(STATS(1,1),STATS(2,1),STATS(3,1),{'observed';''},'FontWeight','bold',...
    'FontSize',13,'FontName','Times New Roman','Color',colorList(1,:),...
    'VerticalAlignment','bottom','HorizontalAlignment','center');
TD4.SText(STATS(1,1),STATS(2,1),STATS(3,1),{'observed';''},'FontWeight','bold',...
    'FontSize',13,'FontName','Times New Roman','Color',colorList(1,:),...
    'VerticalAlignment','bottom','HorizontalAlignment','center');
text(ax1,TD1.SLim(2),TD1.SLim(2),'RMS error','Color',[.77,.6,.18],...
    'VerticalAlignment','bottom','HorizontalAlignment','right',...
    'FontSize',15,'FontName','Times New Roman','FontWeight','bold')
text(ax2,TD1.SLim(2),TD1.SLim(2),'RMS error','Color',[.77,.6,.18],...
    'VerticalAlignment','bottom','HorizontalAlignment','right',...
    'FontSize',15,'FontName','Times New Roman','FontWeight','bold')
text(ax3,TD1.SLim(2),TD1.SLim(2),'RMS error','Color',[.77,.6,.18],...
    'VerticalAlignment','bottom','HorizontalAlignment','right',...
    'FontSize',15,'FontName','Times New Roman','FontWeight','bold')
text(ax4,TD1.SLim(2),TD1.SLim(2),'RMS error','Color',[.77,.6,.18],...
    'VerticalAlignment','bottom','HorizontalAlignment','right',...
    'FontSize',15,'FontName','Times New Roman','FontWeight','bold')





