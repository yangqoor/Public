rng(1)
figure('Position',[600,200,600,600]);

X=randi([2,8],[4,7])+rand([4,7]);

RC=radarChart(X,'Type','Patch');
RC.RTickLabelFormat = @(X) sprintf('%.3f cm',X);
RC.CList = [78 101 155;
          138 140 191;
          184 168 207;
          231 188 198;
          253 207 158;
          239 164 132;
          182 118 108]./255;

RC=RC.draw();
RC.legend();
