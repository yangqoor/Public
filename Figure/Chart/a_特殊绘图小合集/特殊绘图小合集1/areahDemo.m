% areahDemo
% 生成数据
x=linspace(-8,12,100);
y1=normpdf(x,4,6);
y2=normpdf(x,0,1).*0.5+normpdf(x,4,2).*0.5;
y3=normpdf(x,-3,2);

% 绘制渐变面积图
hold on
areah(gca,x,y1,'Color',[144,69,70]./255,'LineWidth',1.5);
areah(x,y2,'Color',[74,156,167]./255,'LineWidth',1.5);
areah(x,y3,'Color',[102,140,123]./255,'LineWidth',1.5);

% 简单修饰坐标区域
ax=gca;
ax.XLim=[-8,12];
ax.Box='on';
