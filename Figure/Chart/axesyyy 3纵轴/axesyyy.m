% 随便生成一组数据
x=0:.05:3*pi;
noise=(rand([1,length(x)])-0.5);
y1=sin(x-2)-5+noise.*.1;
y2=6.*cos(0.5*x)+noise.*.1;
y3=1.5.*sin(x)+0.5.*cos(x)+noise.*.3;

% 创建布局
tdl=tiledlayout(1,10);
% 减小空白区域面积,可删去
tdl.TileSpacing='tight';
tdl.Padding='compact';

% 第一条曲线坐标区域 ==============================
ax1=axes(tdl);hold on
ax1.LineWidth=1.5;        % 轴粗细
ax1.YColor='k';           % 轴颜色(k:黑色)
ax1.XLabel.String='x';    % x轴标签:'x'
ax1.YLabel.String='var1'; % y轴标签:'var1'
ax1.Layout.TileSpan=[1 9];% 坐标区域占9/10宽度，第三个y轴占1/10宽度
% 在这进行第 1 组数据绘图- - - - - - - - - - - - -  
plot(ax1,x,y1,'k','LineWidth',2)

% 第二条曲线坐标区域 ==============================
% 其他属性与上一坐标区域相似
% 设置Color为'none'
% 可将坐标区域背景设置为透明
% 让之前的绘图不被遮挡
ax2=axes(tdl);hold on
ax2.LineWidth=1.5;
ax2.YAxisLocation='right';
ax2.Color='none';
ax2.YColor='r';
ax2.YLabel.String='var2';
ax2.Layout.TileSpan=[1 9];
% 在这进行第 2 组数据绘图- - - - - - - - - - - - - 
plot(ax2,x,y2,'r','LineWidth',2)

% 第三条曲线坐标区域 ==============================
ax3=axes(tdl);hold on
ax3.Color='none';
ax3.YColor='none';
ax3.Layout.TileSpan=[1 9];
% 在这进行第 3 组数据绘图- - - - - - - - - - - - - 
plot(ax3,x,y3,'b','LineWidth',2)

% 让坐标区域x轴关联
linkaxes(tdl.Children,'x')
% 绘制第三个y轴，占1/10宽度，颜色为b:蓝色
ax4=axes(tdl,'LineWidth',1.5,'YAxisLocation','right',...
    'Color','none','XColor','none');
ax4.YColor='b';
ax4.YLabel.String='var3';
ax4.Layout.Tile='east';
ax4.Layout.Tile=10;
linkaxes([ax3,ax4],'y')


