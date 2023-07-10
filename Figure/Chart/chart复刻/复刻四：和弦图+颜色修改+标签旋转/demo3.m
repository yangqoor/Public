% demo 3
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer

dataMat=randi([0,1],[20,10]); 
% use Sep to decrease space (separation)
% 使用 sep 减小空隙
CC=chordChart(dataMat,'Sep',1/120);
CC=CC.draw();



CC.tickState('on')

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

