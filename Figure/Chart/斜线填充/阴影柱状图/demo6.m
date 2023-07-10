y=[2 2 3 2 5; 2 5 6 2 5; 9 8 9 2 5];

SH=shadowHist(y,'ShadowType',{'/','\','.','_','+'});
SH=SH.draw();
SH=SH.legend({'AAAAAAA','BBBBBBB','CCCCCCC','DDDDDDD','EEEEEEE'},'FontName','Cambria','FontSize',11);

% 修饰阴影变成红色并加粗
shadowHdl=findobj('Tag','barShadow');
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
boxHdl=findobj('Tag','barBox');
for i=1:length(boxHdl)
    boxHdl(i).EdgeColor=[.3,.3,.8];
    boxHdl(i).LineWidth=2;
end

% 图例框加粗并变成绿色
lgdBox=findobj('Tag','lgdBox');
lgdBox.LineWidth=1.3;
lgdBox.EdgeColor=[.1,.3,.1];
lgdBox.FaceColor=[173,189,163]./255;