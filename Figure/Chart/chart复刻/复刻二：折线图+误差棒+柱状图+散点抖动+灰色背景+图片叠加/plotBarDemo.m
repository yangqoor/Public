% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : 已由hikari更名slandarer
Data=readtable('2022.1.15.CSV','VariableNamingRule','preserve');
treatName=unique(Data.treat,'stable');

save Data.mat Data

% 配色数据
colorList=[84,148,206;255,130,131;13,137,138;249,204,82]./255;
% -------------------------------------------------------------------------
% 创建图窗获取坐标区域
figure('Position',[500,200,600,580],'Name','slandarer')
ax=gca;hold on
for i=1:length(treatName)
    tempData=Data(strcmp(Data.treat,treatName{i}),:);
    % 将日期数据和value由table转换为array数组
    day=table2array(tempData(:,2));
    value=table2array(tempData(:,3:5));

    % 绘制含误差条的折线图、及粗折线图、及圆点图
    errorbar(day,mean(value,2),std(value,1,2)/sqrt(size(value,2)),...
        'Color',[0,0,0],'LineWidth',1.8,'Marker','o','CapSize',8);
    plot(day,mean(value,2),'Color',colorList(i,:),'LineWidth',6)
    plot(day,mean(value,2),'o','LineWidth',1,'MarkerEdgeColor',[0,0,0],...
        'MarkerFaceColor',colorList(i,:),'MarkerSize',9);
    % 循环生成patch对象用来当作图例的图标
    patchHdl(i)=fill([0,0,0,0],[0,0,0,0],colorList(i,:),'LineWidth',1.2);
end
legend(patchHdl,{'Non\_SMK   ','SMK','Non\_SMK+abx','SMK+abx'},'AutoUpdate','off',...
    'Location','northoutside','NumColumns',4,'Box','off','FontSize',12)

% -------------------------------------------------------------------------
% 坐标区域修饰
% 调整边缘空间
ax.LooseInset=[0,0,0,0];
% 控制轴范围
ax.YLim=[0,60];
ax.XLim=[0,40];
ax.XTick=0:10:40;
ax.YTick=0:20:60;
% 修改xy轴标签和字体
ax.XLabel.String='Day';
ax.YLabel.String='Weight change(%)';
ax.XLabel.FontSize=14;
ax.YLabel.FontSize=14;
ax.XLabel.FontWeight='bold';
ax.YLabel.FontWeight='bold';
% 设置轴线粗细和刻度朝外
ax.LineWidth=1.5;
ax.TickDir='out';

% -------------------------------------------------------------------------
% 灰色区域和常量线
% 绘制区域分隔虚线,这里没用xline是因为推出较晚(R2018b)，且层级关系不好捋顺
xLineHdl=plot([21,21],[0,60],'LineWidth',1.8,'LineStyle','--','Color',[0,0,0]);
uistack(xLineHdl,'bottom')

% 绘制灰色区域并移动到最下方
grayAreaHdl=fill([21,21,40,40],[0+.2,60,60,0+.2],[229,229,229]./255,'EdgeColor','none');
uistack(grayAreaHdl,'bottom')

% -------------------------------------------------------------------------
% 添加显著性标志
plot([36.2,36.2],[18,26],'Color',[0,0,0],'LineWidth',2.5)
plot([38,38],[18,40],'Color',[0,0,0],'LineWidth',2.5)
text(37.3,22,'***','Rotation',90,'FontSize',17,'HorizontalAlignment','center','FontWeight','bold')
text(39.3,29,'****','Rotation',90,'FontSize',17,'HorizontalAlignment','center','FontWeight','bold')

% =========================================================================
% 子图绘制
% 左上角坐标区域
ax2=axes(gcf,'Position',[.11,.69,.4,.17]);
hold on
ax2.XLim=[-50,600];
ax2.Color='none';
ax2.LineWidth=1.5;
ax2.TickDir='out';
ax2.FontSize=12;
ax2.XTick=0:200:600;
ax2.YTick=[];
ax2.Title.String='iAUC: Exposure';
ax2.Title.FontWeight='bold';
ax2.Title.FontSize=15;
ax2.YDir='reverse';
ax2.YLim=[.4,4.6];
% -------------------------------------------------------------------------
% 获取第一组柱状图数据并删除缺失值
barData1=[Data.Non_SMK,Data.SMK,Data.("Non_SMK+abx"),Data.("SMK+abx")];
barData1(isnan(barData1(:,1)),:)=[];
barHdl=barh(ax2,mean(barData1),'FaceColor',[1,1,1],'LineWidth',1.2,'EdgeColor',[0,0,0]);
% 设置0基线属性
barBaseLineHdl=barHdl.BaseLine;
barBaseLineHdl.LineWidth=1.2;
% 绘制误差条
errorbar(ax2,mean(barData1),1:4,std(barData1,1)./sqrt(size(barData1,1)),...
    'horizontal','LineStyle','none','LineWidth',1.2,'Color',[0,0,0])
% 绘制抖动散点图
for i=1:4
    scatter(ax2,barData1(:,i),i.*ones(1,size(barData1,1)),20,...
        'filled','YJitter','density','CData',colorList(i,:))
end
% % 老版本方案
% % 绘制抖动散点图
% for i=1:4
%     scatter(ax2,barData1(:,i),i+rand(1,size(barData1,1)).*.8-.4,20,...
%         'filled','CData',colorList(i,:))
% end

% 添加显著性标志
plot(ax2,[370,370],[1,2],'Color',[0,0,0],'LineWidth',2.5)
plot(ax2,[530,530],[3,4],'Color',[0,0,0],'LineWidth',2.5)
text(ax2,410,1.5,'****','Rotation',90,'FontSize',17,'HorizontalAlignment','center','FontWeight','bold')
text(ax2,570,3.5,'****','Rotation',90,'FontSize',17,'HorizontalAlignment','center','FontWeight','bold')
% -------------------------------------------------------------------------
% 右上角坐标区域
ax3=axes(gcf,'Position',[.595,.69,.365,.17]);
hold on
ax3.XLim=[0,500];
ax3.Color='none';
ax3.LineWidth=1.5;
ax3.TickDir='out';
ax3.FontSize=12;
ax3.XTick=0:100:500;
ax3.YTick=[];
ax3.Title.String='iAUC: Cessation';
ax3.Title.FontWeight='bold';
ax3.Title.FontSize=15;
ax3.YDir='reverse';
ax3.YDir='reverse';
ax3.YLim=[.4,4.6];
% -------------------------------------------------------------------------
% 获取第一组柱状图数据并删除缺失值
barData2=[Data.Non_SMK_1,Data.SMK_1,Data.("Non_SMK+abx_1"),Data.("SMK+abx_1")];
barData2(isnan(barData2(:,1)),:)=[];
barHdl=barh(ax3,mean(barData2),'FaceColor',[1,1,1],'LineWidth',1.2,'EdgeColor',[0,0,0]);
% 设置0基线属性
barBaseLineHdl=barHdl.BaseLine;
barBaseLineHdl.LineWidth=1.2;
% 绘制误差条
errorbar(ax3,mean(barData2),1:4,std(barData2,1)./sqrt(size(barData2,1)),...
    'horizontal','LineStyle','none','LineWidth',1.2,'Color',[0,0,0])
% 绘制抖动散点图
for i=1:4
    scatter(ax3,barData2(:,i),i.*ones(1,size(barData2,1)),20,...
        'filled','YJitter','density','CData',colorList(i,:))
end
% % 老版本方案
% % 绘制抖动散点图
% for i=1:4
%     scatter(ax3,barData1(:,i),i+rand(1,size(barData2,1)).*.8-.4,20,...
%         'filled','CData',colorList(i,:))
% end

% 添加显著性标志
plot(ax3,[430,430],[1,2],'Color',[0,0,0],'LineWidth',2.5)
plot(ax3,[420,420],[3,4],'Color',[0,0,0],'LineWidth',2.5)
text(ax3,465,1.5,'****','Rotation',90,'FontSize',17,'HorizontalAlignment','center','FontWeight','bold')
text(ax3,455,3.5,'****','Rotation',90,'FontSize',17,'HorizontalAlignment','center','FontWeight','bold')
