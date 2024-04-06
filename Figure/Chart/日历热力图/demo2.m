% 构造一组比较连续但是有波动的数据
T=datetime(2022,1,1):datetime(2022,6,30);
t=linspace(1,length(T),10);
tV=rand(size(t));
V=interp1(t,tV,1:length(T))+rand(1,[length(T)])./3;

% 绘制日历热图
heatmapDT(2022,T,V)

% 调整图窗和坐标区域大小
set(gcf,'Position',[100,500,1500,260])
set(gca,'Position',[.03,.03,1-.1,1-.1])

% 调整配色
% colormap(pink)