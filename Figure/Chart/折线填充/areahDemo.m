% areahDemo
% 生成数据
x=linspace(-8,12,100);
y1=normpdf(x,4,6);
y2=normpdf(x,0,1).*0.5+normpdf(x,4,2).*0.5;
y3=normpdf(x,-3,2);
y4=normpdf(x,-2,2)+normpdf(x,-3,2);
y5=normpdf(x,4,6)+normpdf(x,-3,2);

% 简单修饰坐标区域1
ax1=axes(gcf,'Position',[0.1,0.54,0.44,0.44]);hold on
ax1.XLim=[-8,12];
ax1.YLim=[-.1,.5];
ax1.YTick=0:.1:.4;
ax1.XTickLabel='';
ax1.Box='on';
ax1.LineWidth=.8;
ax1.FontName='Cambria';
ax1.YLabel.String='YYYYY1';
% 绘制渐变面积图
areah(x,y2,'Color',[150,60,59]./255,'LineWidth',1);
areah(x,y4,'Color',[74,156,167]./255,'LineWidth',1);
text(-7,.45,'(a)','FontSize',12,'FontName','Cambria')
text(0,.4,{'made by MATLAB';'follow slandarer'},'FontSize',12,'FontName','Cambria')

% 简单修饰坐标区域2
ax2=axes(gcf,'Position',[0.54,0.54,0.44,0.44]);hold on
ax2.XLim=[-8,12];
ax2.YLim=[-.1,.5];
ax2.XTickLabel='';
ax2.YTickLabel='';
ax2.Box='on';
ax2.LineWidth=.8;
ax2.FontName='Cambria';
% 绘制渐变面积图
areah(x,y2,'Color',[132,158,119]./255,'LineWidth',1);
areah(x,y4,'Color',[150,60,59]./255,'LineWidth',1);
areah(x,y5,'Color',[242,199,60]./255,'LineWidth',1);
text(-7,.45,'(b)','FontSize',12,'FontName','Cambria')

% 简单修饰坐标区域3
ax3=axes(gcf,'Position',[0.1,0.1,0.44,0.44]);hold on
ax3.XLim=[-8,12];
ax3.YLim=[-.05,.3];
ax3.Box='on';
ax3.LineWidth=.8;
ax3.FontName='Cambria';
ax3.XLabel.String='XXXXX1';
ax3.YLabel.String='YYYYY2';
% 绘制渐变面积图
areah(x,y1,'Color',[150,60,59]./255,'LineWidth',1);
areah(x,y2,'Color',[74,156,167]./255,'LineWidth',1);
areah(x,y3,'Color',[132,158,119]./255,'LineWidth',1);
text(-7,.25,'(c)','FontSize',12,'FontName','Cambria')
annotation('textarrow',[.35,.3],[.4,.35],'String','noting to write','FontSize',12,'FontName','Cambria')

% 简单修饰坐标区域4
ax4=axes(gcf,'Position',[0.54,0.1,0.44,0.44]);hold on
ax4.XLim=[-8,12];
ax4.YLim=[-.05,.3];
ax4.YTickLabel='';
ax4.Box='on';
ax4.LineWidth=.8;
ax4.FontName='Cambria';
ax4.XLabel.String='XXXXX2';
% 绘制渐变面积图
areah(x,y2,'Color',[132,158,119]./255,'LineWidth',1);
areah(x,y5,'Color',[242,199,60]./255,'LineWidth',1);
text(-7,.25,'(d)','FontSize',12,'FontName','Cambria')