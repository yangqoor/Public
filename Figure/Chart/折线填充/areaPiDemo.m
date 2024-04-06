% 获取pi前500位小数
Pi=getPi(500); 
% 计算比例变化
Ratio=cumsum(Pi==(0:9)',2);
Ratio=Ratio./sum(Ratio);
% 配色列表
CM=[231,98,84;239,138,71;247,170,88;255,208,111;255,230,183;
    170,220,224;114,188,213;82,143,173;55,103,149;30,70,110]./255;
% 绘制堆叠面积图
hold on
areaHdl=area(Ratio');
for i=1:10
    areaHdl(i).FaceColor=CM(i,:);
    areaHdl(i).FaceAlpha=.9;
end
% 图窗和坐标区域修饰
set(gcf,'Position',[200,100,720,420]);
ax=gca;
ax.YLim=[0,1];
ax.XMinorTick='on';
ax.YMinorTick='on';
ax.LineWidth=.8;
ax.FontName='Cambria';
ax.FontSize=11;
ax.TickDir='out';
ax.XLabel.String='Decimals';
ax.YLabel.String='Proportion';
ax.XLabel.FontSize=13;
ax.YLabel.FontSize=13;
ax.Title.String='Area Chart of Proportion — 500 digits';
ax.Title.FontSize=14;
% 绘制图例并修饰
lgdHdl=legend(num2cell('0123456789'));
lgdHdl.NumColumns=5;
lgdHdl.FontSize=11;
lgdHdl.Location='southeast';

function Pi=getPi(n)
if nargin<1,n=3;end
Pi=char(vpa(sym(pi),n+10));
Pi=abs(Pi)-48;
Pi=Pi(3:n+2);
end 