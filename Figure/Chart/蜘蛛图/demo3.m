rng(1)
figure('Position',[600,200,600,600]);

X=randi([2,8],[4,7])+rand([4,7]);
RC=radarChart(X,'Type','Patch');
RC=RC.draw();
RC.legend();

colorList=[78 101 155;
          138 140 191;
          184 168 207;
          231 188 198;
          253 207 158;
          239 164 132;
          182 118 108]./255;
for n=1:RC.ClassNum
    RC.setPatchN(n,'FaceColor',colorList(n,:),'EdgeColor',colorList(n,:))
end