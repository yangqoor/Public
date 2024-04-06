clc;clear;close all;rng(32)
% sankeyBubble
fig=figure('Name','sankey bubble','Units','normalized','Position',[.05,.05,.44,.85],'Color','w');

ax1=axes('Parent',fig,'Position',[1/20,1/15,2.8/5-1/20,1-1.6/15]);
ax1.NextPlot='add';

LSet='ABCDEFGH';
links={'','',''};
for i=1:length(LSet)
    tLinks=[compose([char(LSet(i)+32),'%d'],(1:5)'),...
            num2cell(char(LSet(i).*ones(5,1))),num2cell(rand(5,1).*10)];   
    links=[links;tLinks];
end
for i=1:6
    links=[links;
        [char('A'+32+randi([0,7],[1,1])),...
        num2str(randi([1,5],[1,1]))],...
        char('A'+randi([0,7],[1,1])),...
        num2cell(rand(1,1).*10)];
end
links(1,:)=[];

% 创建桑基图对象(Create a Sankey diagram object)
SK=SSankey(links(:,1),links(:,2),links(:,3));

% 修改对齐方式(Set alignment)
% 'up'/'down'/'center'(default)
SK.Align='down';

SK.Sep=.12;

% 设置颜色(Set color)
SK.ColorList=[slanCM(134,40);slanCM(134,8)];

% 修改链接颜色渲染方式(Set link color rendering method)
% 'left'/'right'/'interp'(default)/'map'/'simple'
SK.RenderingMethod='simple'; 

% 开始绘图(Start drawing)
SK.draw();

for i=1:48
    SK.setLabel(i,'FontSize',12)
end

PatchSet=findobj(ax1,'Type','Patch');
Patch2Y=ones(0,4);
for i=length(PatchSet):-1:1
    if PatchSet(i).XData(1)==2
        Patch2Y=[Patch2Y;PatchSet(i).YData(:)'];
    end
end

%% ========================================================================
% 构建右侧坐标区域并基础修饰
Patch2Lim=max(max(Patch2Y))-min(min(Patch2Y));
ax2=axes('Parent',fig,'Position',[2.8/5+1/80,1/15,1.5/5-1/20,Patch2Lim./diff(ax1.YLim).*(1-1.6/15)]);
ax2.YLim=[min(min(Patch2Y)),max(max(Patch2Y))];
ax2.NextPlot='add';
ax2.Box='on';
ax2.YTick=[];
ax2.TickDir='out';
ax2.LineWidth=1;
ax2.FontName='Times New Roman';
ax2.FontSize=11;
ax2.YDir='reverse';
ax2.XLim=[-0.6,2.4];
ax2.XTick=-0.5:0.5:2;
ax2.XLabel.String='-Log(Pvalue)';
ax2.XLabel.FontSize=14;
ax2.XLabel.FontWeight='bold';

tMap=slanCM(20,64);
colormap(tMap(33:end,:))

% 随便编了点数据
NLogPvalue=linspace(2,-0.3,8);
PatchMeanY=(Patch2Y(:,2)+Patch2Y(:,3)).'./2;
Count=randi([1,8],[1,8]);
HitRatio=0.1+0.4.*rand([1,8]);

bubblechart(NLogPvalue,PatchMeanY,Count,HitRatio)
bubblesize([15,30])

% 绘制颜色条
CMPHdl=colorbar;
CMPHdl.Position=[4.3/5,1/15+Patch2Lim./diff(ax1.YLim).*(1-1.6/15)./2,1/40,Patch2Lim./diff(ax1.YLim).*(1-1.6/15).*0.4];
text(ax2,ax2.XLim(2)+diff(ax2.XLim).*0.12,ax2.YLim(1)+diff(ax2.YLim).*0.05,'Hit Ratio',...
    'FontSize',14,'FontName','Times New Roman','FontWeight','bold')

% 绘制图例
LGDHdl=bubblelegend;
LGDHdl.Position=[4.2/5,1/15,1/40,Patch2Lim./diff(ax1.YLim).*(1-1.6/15).*0.4];
LGDHdl.Box='off';
text(ax2,ax2.XLim(2)+diff(ax2.XLim).*0.12,ax2.YLim(1)+diff(ax2.YLim).*0.65,'Count',...
    'FontSize',14,'FontName','Times New Roman','FontWeight','bold')

