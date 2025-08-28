defualtAxes()
Data=randi([20,35],[5,1]);
err=rand([5,1]).*5;

hold on
barHdl=bar(Data,'BarWidth',.4);
% 绘制误差棒
errorbar(barHdl.XEndPoints,barHdl.YEndPoints,err,...
    'LineStyle','none','Color','k','LineWidth',.8)