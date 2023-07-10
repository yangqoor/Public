% windrose demo 2

% 随机数据生成并拼成矩阵
h1=randi([8,18],[1,35])+rand([1,35]);
h2=randi([2,8],[1,35])+rand([1,35]);
h3=randi([0,3],[1,35])+rand([1,35]);
h=[h1;h2;h3];

% 生成极坐标区域，并更改背景颜色
ax=polaraxes(gcf);
ax.Color=[60,60,60]./255;
ax.GridColor=[212,217,217]./255;
ax.LineWidth=1.5;
ax.GridLineStyle='-.';
ax.FontName='Cambria';
ax.FontSize=13;

% 生成风玫瑰图
wr=windrose(ax,h);
wr=wr.draw();

% 属性修饰
wr.setStyle('LineWidth',1.2,'FaceAlpha',1,'EdgeColor',[.2,.2,.2])
wr.setLConf(4)

% 修改颜色
colorList=[194,196,191;
           212,217,217;
           110,135,117]./255;
wr.setColor(colorList,1:3)
