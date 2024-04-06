% 构造一组比较连续但是有波动的数据
T=datetime(2022,1,1):datetime(2022,12,31);
t=linspace(1,length(T),10);
tV=rand(size(t));
V=interp1(t,tV,1:length(T))+rand(1,[length(T)])./3;

% 展示数据类型
% figure()
% plotDemo(T,V)
% figure()

% 绘制日历热图
heatmapDT(2022,T,V)

% 调整图窗和坐标区域大小
set(gcf,'Position',[100,500,1500,260])
set(gca,'Position',[.03,.03,1-.1,1-.1])

% 调整配色
% colormap(pink)

% 使用配色工具包
colormap(slanCM(141))
clim([-.5,1.5])

% CM=[1.0000    1.0000    0.8510
%     0.9487    0.9800    0.7369
%     0.8617    0.9458    0.6995
%     0.7291    0.8938    0.7109
%     0.5237    0.8139    0.7308
%     0.3433    0.7465    0.7558
%     0.2036    0.6610    0.7629
%     0.1155    0.5504    0.7444
%     0.1298    0.4050    0.6759
%     0.1398    0.2788    0.6160
%     0.1141    0.1793    0.5162
%     0.0314    0.1137    0.3451];
% CMX=linspace(0,1,size(CM,1));
% CMXX=linspace(0,1,256)';
% CM=[interp1(CMX,CM(:,1),CMXX,'pchip'), ...
%     interp1(CMX,CM(:,2),CMXX,'pchip'), ...
%     interp1(CMX,CM(:,3),CMXX,'pchip')];
% colormap(CM)