X=[1 3 0.5 2.5 2];
explode=[0 1 0 5 0];

SP=shadowPie(X,explode,'ShadowType',{'/','.','|','+','x'});
SP=SP.draw();

SP.legend({'AAA','BBB','CCC','DDD','EEE'},'FontSize',13,'FontName','Cambria');

% 修饰文字
textHdl=findobj('Tag','pieText');
for i=1:length(textHdl)
    textHdl(i).FontName='Cambria';
    textHdl(i).FontSize=14;
    textHdl(i).Color=[0,0,.8];
end

% 修饰阴影变成红色并加粗
shadowHdl=findobj('Tag','pieShadow');
for i=1:length(shadowHdl)
    if isa(shadowHdl(i),'matlab.graphics.chart.primitive.Line')
        shadowHdl(i).Color=[.8,.6,.6];
        shadowHdl(i).LineWidth=1;
    else
        shadowHdl(i).MarkerFaceColor=[.8,.6,.6];
        shadowHdl(i).SizeData=5;
    end
end

% 修饰框变为蓝色并加粗
boxHdl=findobj('Tag','pieBox');
for i=1:length(boxHdl)
    boxHdl(i).EdgeColor=[.3,.3,.8];
    boxHdl(i).LineWidth=2;
end

% 图例框加粗并变成绿色
lgdBox=findobj('Tag','lgdBox');
lgdBox.LineWidth=1.3;
lgdBox.EdgeColor=[.1,.3,.1];
lgdBox.FaceColor=[173,189,163]./255;