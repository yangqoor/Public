% chord demo
rng(2)

dataMat=randi([1,7],[11,5]);
colName={'Fly','Beetle','Leaf','Soil','Waxberry'};
rowName={'Bartomella','Bradyrhizobium','Dysgomonas','Enterococcus',...
         'Lactococcus','norank','others','Pseudomonas','uncultured',...
         'Vibrionimonas','Wolbachia'};

CC=chordChart(dataMat,'rowName',rowName,'colName',colName,'Sep',1/80);
CC=CC.draw();

% 开启刻度
CC.tickState('on')

% 修改上方方块颜色
CListT=[0.7765 0.8118 0.5216;0.4431 0.4706 0.3843;0.5804 0.2275 0.4549;
        0.4471 0.4039 0.6745;0.0157 0      0     ];
for i=1:5
    CC.setSquareT_N(i,'FaceColor',CListT(i,:))
end

% 修改下方方块颜色
CListF=[0.5843 0.6863 0.7843;0.1098 0.1647 0.3255;0.0902 0.1608 0.5373;
        0.6314 0.7961 0.2118;0.0392 0.2078 0.1059;0.0157 0      0     ;
        0.8549 0.9294 0.8745;0.3882 0.3255 0.4078;0.5020 0.7216 0.3843;
        0.0902 0.1843 0.1804;0.8196 0.2314 0.0706];
for i=1:11
    CC.setSquareF_N(i,'FaceColor',CListF(i,:))
end

% 修改弦颜色
for i=1:5
    for j=1:11
        CC.setChordMN(j,i,'FaceColor',CListT(i,:),'FaceAlpha',.5)
    end
end


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

CC.setFont('FontSize',17,'FontName','Cambria')

