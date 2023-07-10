% demo 3
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer

dataMat=randi([0,8],[6,6]);

% 添加标签名称
NameList={'CHORD','CHART','MADE','BY','SLANDARER','MATLAB'};
BCC=biChordChart(dataMat,'Label',NameList,'Arrow','on');
BCC=BCC.draw(); 

% 添加刻度
BCC.tickState('on')

% 修改字体，字号及颜色
BCC.setFont('FontName','Cambria','FontSize',17,'Color',[.2,.2,.2])

% 以下代码用来旋转标签
% The following code is used to rotate the label
textHdl=findobj(gca,'Type','Text');
for i=1:length(textHdl)
    if textHdl(i).Rotation<-90
        textHdl(i).Rotation=textHdl(i).Rotation+180;
    end
    switch true
        case textHdl(i).Rotation<0&&textHdl(i).Position(2)>0
            textHdl(i).Rotation=textHdl(i).Rotation+90;
            textHdl(i).HorizontalAlignment='left';
        case textHdl(i).Rotation>0&&textHdl(i).Position(2)>0
            textHdl(i).Rotation=textHdl(i).Rotation-90;
            textHdl(i).HorizontalAlignment='right';
        case textHdl(i).Rotation<0&&textHdl(i).Position(2)<0
            textHdl(i).Rotation=textHdl(i).Rotation+90;
            textHdl(i).HorizontalAlignment='right';
        case textHdl(i).Rotation>0&&textHdl(i).Position(2)<0
            textHdl(i).Rotation=textHdl(i).Rotation-90;
            textHdl(i).HorizontalAlignment='left';
    end
end