load SimulatedStock.mat;
CHdl=candle(TMW(end-20:end,:),'b');

rColor=[208,48,53]./255; % 红色
gColor=[55,173,55]./255; % 绿色

% 获取竖直线数据
LineHdl=CHdl(1);
LineDataX=reshape(LineHdl.XData,3,[]);
LineDataY=reshape(LineHdl.YData,3,[]);

hold on
% 若原本颜色是白色则改为红色，蓝色则改为绿色
for i=2:length(CHdl)
    if CHdl(i).FaceColor(1)==1
        plot(LineDataX(:,i-1),LineDataY(:,i-1),'Color',rColor)
        CHdl(i).FaceColor=rColor;
        CHdl(i).EdgeColor=rColor;
    else
        plot(LineDataX(:,i-1),LineDataY(:,i-1),'Color',gColor)
        CHdl(i).FaceColor=gColor;
        CHdl(i).EdgeColor=gColor;
    end
end 
% 删除原本的竖直线
delete(LineHdl);