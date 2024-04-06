% 构造一组比较连续但是有波动的数据
T=datetime(2022,1,1):datetime(2022,12,31);
t=linspace(1,length(T),10);
tV=rand(size(t));
V=interp1(t,tV,1:length(T))+rand(1,[length(T)])./3;

% 绘制日历热图
heatmapDT(2022,T,V,[2,3])

% 调整图窗和坐标区域大小
set(gcf,'Position',[100,100,800,600])
set(gca,'Position',[.15,.15,1-.3,1-.3])
