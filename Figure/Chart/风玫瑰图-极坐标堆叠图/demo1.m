% windrose demo 1

% 随机数据生成并拼成矩阵
h1=randi([8,18],[1,35])+rand([1,35]);
h2=randi([2,8],[1,35])+rand([1,35]);
h3=randi([0,3],[1,35])+rand([1,35]);
h=[h1;h2;h3];

wr=windrose(h);
wr=wr.draw();

% 图像属性设置
wr.setStyle('LineWidth',1.2,'FaceAlpha',.8,'EdgeColor',[.2,.2,.2])

% 添加下界限
wr.setLConf(4)

% 将第二层变成绿
% wr.setColor([.1,.8,.1],2)
% 将第一第二层变成黑色
% wr.setColor([0,.2,0;0 0 .2],[1,3])

% 添加图例
lgd=legend(wr.Children,'CLASS 1','CLASS 2','CLASS 3');
lgd.Location='best';

% 坐标区域修饰
ax=gca;
ax.LineWidth=1.5;
ax.GridLineStyle='-.';
ax.FontName='Cambria';
ax.FontSize=13;