PntSet1=mvnrnd([2 3],[1 0;0 2],800);
PntSet2=mvnrnd([6 7],[1 0;0 2],800);
PntSet3=mvnrnd([8 9],[1 0;0 1],800);

PntSet=[PntSet1;PntSet2;PntSet3];

colorList=[0.9400    0.9700    0.9600
    0.8900    0.9300    0.9200
    0.8200    0.9100    0.8800
    0.6900    0.8500    0.7700
    0.5900    0.7800    0.6900
    0.5500    0.7500    0.6500
    0.4500    0.6500    0.5600
    0.4000    0.5800    0.4900
    0.3500    0.5100    0.4200
    0.2500    0.3600    0.3100
    0.1300    0.1700    0.1400];
CData=density2C(PntSet(:,1),PntSet(:,2),-2:0.1:15,-2:0.1:15,colorList);

set(gcf,'Color',[1 1 1]);

% 主分布图
ax1=axes('Parent',gcf);hold(ax1,'on')
scatter(ax1,PntSet(:,1),PntSet(:,2),'filled','CData',CData);
ax1.Position=[0.1,0.1,0.6,0.6];

% X轴直方图
ax2=axes('Parent',gcf);hold(ax2,'on')
histogram(ax2,PntSet(:,1),'FaceColor',[0.78 0.88 0.82],...
    'EdgeColor','none','FaceAlpha',0.7)
ax2.Position=[0.1,0.75,0.6,0.15];
ax2.YColor='none';
ax2.XTickLabel='';
ax2.TickDir='out';
ax2.XLim=ax1.XLim;


% Y轴直方图
ax3=axes('Parent',gcf);hold(ax3,'on')
histogram(ax3,PntSet(:,2),'FaceColor',[0.78 0.88 0.82],...
    'EdgeColor','none','FaceAlpha',0.7,'Orientation','horizontal')
ax3.Position=[0.75,0.1,0.15,0.6];
ax3.XColor='none';
ax3.YTickLabel='';
ax3.TickDir='out';
ax3.YLim=ax1.YLim;


