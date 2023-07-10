% groupBarDemo.m
figure('Position',[500,200,850,550])
% 自行构造的数据
YData=[0.7772    1.0363    0.7772    1.0363    2.7202;
       3.4974    5.3109    4.2746    4.0155   12.9534;
       3.4974    3.7565    3.1088    3.8860   14.8964;
       1.9430    2.3316    2.3316    2.7202    2.7202;
      17.2280   19.9482   17.0984   19.0415   22.6684;
       0.2591    0.3886    0.3886    0.3886    2.5907];
YData1=YData;YData2=YData;
% 原图片配色(matlab要求配色范围0-1因此要除以255)
CData=[111,173,72;92,154,215;255,192,1;69,103,42;36,94,144]./255;
% -------------------------------------------------------------------------
% 上子图
ax1=subplot(2,1,1);hold on
hBar1=bar(YData1);

% 下子图
ax2=subplot(2,1,2);hold on
hBar2=bar(YData2);
% -------------------------------------------------------------------------
% 分组柱状图修饰
for i=1:length(hBar1)
    hBar1(i).EdgeColor='none';      % 轮廓无色
    hBar1(i).FaceColor=CData(i,:);  % 设置颜色
    hBar2(i).EdgeColor='none';
    hBar2(i).FaceColor=CData(i,:);
end
% -------------------------------------------------------------------------
% 修改X轴标签文本
ax1.XTick=1:size(YData1,1);
ax2.XTick=1:size(YData2,1);
ax1.XTickLabel={'SO2','NO2','PM10','PM2.5','O3','CO'};
ax2.XTickLabel={'SO2','NO2','PM10','PM2.5','O3','CO'};
% 修改坐标区域字体
ax1.FontName='Cambria';
ax2.FontName='Cambria';
ax1.FontWeight='bold';
ax2.FontWeight='bold';
ax1.FontSize=12;
ax2.FontSize=12;
% 添加网格并修饰
ax1.XGrid='on';
ax2.XGrid='on';
ax1.GridAlpha=.2;
ax2.GridAlpha=.2;
% 框修饰
ax1.Box='on';
ax2.Box='on';
ax1.LineWidth=1.5;
ax2.LineWidth=1.5;
% 刻度长度设置为0
ax1.TickLength=[0,0];
ax2.TickLength=[0,0];
% -------------------------------------------------------------------------
% 绘制辅助线
XV=(1:size(YData1,1)-1)+.5;
for i=1:length(XV)
    xline(ax1,XV(i),'LineWidth',1.4,'LineStyle','--','Color',[0,0,0]);
    xline(ax2,XV(i),'LineWidth',1.4,'LineStyle','--','Color',[0,0,0]);
end
% -------------------------------------------------------------------------
% 添加图例
lgd1=legend(hBar1,'FNN','RF','XGBoost','SVR','WRF-CMAQ','FontSize',13);
lgd2=legend(hBar2,'FNN','RF','XGBoost','SVR','WRF-CMAQ','FontSize',13);
% 设置图例位置
lgd1.Location='southoutside';
lgd2.Location='southoutside';
% 设置图例横向排列
lgd1.NumColumns=length(hBar1);
lgd2.NumColumns=length(hBar2);
% 设置图例方形大小
lgd1.ItemTokenSize=[8,8];
lgd2.ItemTokenSize=[8,8];
% 关闭框
lgd1.Box='off';
lgd2.Box='off';
% -------------------------------------------------------------------------
% 调整子图位置和比例
set(ax1,'LooseInset',[.1,0,0.028,0.03],'OuterPosition',[0,1/2-1/30,1,1/2+1/30]);
set(ax2,'LooseInset',[.1,0,0.028,0.03],'OuterPosition',[0,0-1/30,1,1/2+1/30]);
% -------------------------------------------------------------------------
% 添加左上角标签
text(ax1,0.6,22.5,'MAE','FontSize',15,'FontWeight','bold','FontName','Cambria')
text(ax2,0.6,22.5,'RMSE','FontSize',15,'FontWeight','bold','FontName','Cambria')

