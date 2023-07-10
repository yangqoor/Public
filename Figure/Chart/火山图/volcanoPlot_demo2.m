% @author:slandarer
% volcano plot demo 2

% 读取数据
data=readmatrix('volcano.txt');
logFC=data(:,2);
padj=data(:,3);

DB_not=(padj>0.5)|(logFC<0.5&logFC>-0.5);
DB_up=padj<=0.05&logFC>=0.5;
DB_down=padj<=0.05&logFC<=-0.5;

ax=gca;
hold(ax,'on');
grid(ax,'on');

% 需要适度调整的属性：坐标区域范围及刻度===================================
ax.XLim=[-8,8];
ax.YLim=[-10,200];
ax.XTick=-5:2.5:5;
ax.YTick=0:50:300;
% ==========================================================================
DB_down_out=(-log(padj)./log(10)>ax.YLim(2)&logFC<=-0.5)|logFC<ax.XLim(1);
DB_down_out_Set=[logFC(DB_down_out),-log(padj(DB_down_out))./log(10)];
DB_down_out_Set(DB_down_out_Set(:,1)<ax.XLim(1),1)=ax.XLim(1);
DB_down_out_Set(DB_down_out_Set(:,2)>ax.YLim(2),2)=ax.YLim(2);

DB_up_out=(-log(padj)./log(10)>ax.YLim(2)&logFC>=0.5)|logFC>ax.XLim(2);
DB_up_out_Set=[logFC(DB_up_out),-log(padj(DB_up_out))./log(10)];
DB_up_out_Set(DB_up_out_Set(:,1)>ax.XLim(2),1)=ax.XLim(2);
DB_up_out_Set(DB_up_out_Set(:,2)>ax.YLim(2),2)=ax.YLim(2);

% =========================================================================
ax.XLabel.String='log_2(FoldChange)';
ax.XLabel.FontSize=14;
ax.XLabel.FontName='Cambria';
ax.XLabel.FontWeight='bold';
ax.YLabel.String='-log_{10}(padj)';
ax.YLabel.FontSize=14;
ax.YLabel.FontName='Cambria';
ax.YLabel.FontWeight='bold';

ax.Color=[235,235,235]./255;
ax.GridColor=[1 1 1];
ax.LineWidth=1.4;
ax.GridAlpha=0.5;
ax.XColor=[44,62,80]./255;
ax.YColor=[44,62,80]./255;
Hdl_not=scatter(logFC(DB_not),-log(padj(DB_not))./log(10),30,'filled',...
    'MarkerFaceColor',[190,190,190]./255,'MarkerEdgeColor',[190,190,190]./255,...
    'MarkerFaceAlpha',0.6);
Hdl_up=scatter(logFC(DB_up),-log(padj(DB_up))./log(10),30,'filled',...
    'MarkerFaceColor',[196,88,62]./255,'MarkerEdgeColor',[196,88,62]./255,...
    'MarkerFaceAlpha',0.6);
Hdl_down=scatter(logFC(DB_down),-log(padj(DB_down))./log(10),30,'filled',...
    'MarkerFaceColor',[1,114,182]./255,'MarkerEdgeColor',[1,114,182]./255,...
    'MarkerFaceAlpha',0.6);

% -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
scatter(DB_up_out_Set(:,1),DB_up_out_Set(:,2),30,'filled','Marker','+',...
    'MarkerFaceColor',[196,88,62]./255,'MarkerEdgeColor',[196,88,62]./255,...
    'MarkerFaceAlpha',0.6,'LineWidth',1);

scatter(DB_down_out_Set(:,1),DB_down_out_Set(:,2),30,'filled','Marker','+',...
    'MarkerFaceColor',[1,114,182]./255,'MarkerEdgeColor',[1,114,182]./255,...
    'MarkerFaceAlpha',0.6,'LineWidth',1);
% -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -

plot([ax.XLim(1),ax.XLim(2)],[-log(0.05)/log(10),-log(0.05)/log(10)],...
    'LineWidth',1.2,'Color',[.2,.2,.2],'LineStyle','-.')
plot([-0.5,-0.5],[ax.YLim(1),ax.YLim(2)],...
    'LineWidth',1.2,'Color',[.2,.2,.2],'LineStyle','-.')
plot([0.5,0.5],[ax.YLim(1),ax.YLim(2)],...
    'LineWidth',1.2,'Color',[.2,.2,.2],'LineStyle','-.')

lgd=legend(ax,[Hdl_up,Hdl_not,Hdl_down],{'up','not','down'});
lgd.Title.String='threshold';
lgd.FontSize=12;
lgd.Title.FontSize=13;
lgd.EdgeColor=[44,62,80]./255;
lgd.TextColor=[44,62,80]./230;
lgd.FontName='Cambria';
lgd.Location='best';





