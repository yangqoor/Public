Data=randi([20,35],[5,2]);
err=rand([5,2]).*5;

hold on
barHdl=bar(Data);
% 绘制误差棒
for i=1:size(err,2)
    errorbar(barHdl(i).XEndPoints,Data(:,i),err(:,i),...
        'LineStyle','none','Color','k','LineWidth',.8)
end