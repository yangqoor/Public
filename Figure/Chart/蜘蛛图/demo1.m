rng(5);
figure('Position',[600,200,600,600]);

X=randi([2,8],[4,7])+rand([4,7]);
RC=radarChart(X);
RC.RLim=[2,10];
RC.RTick=[2,8:1:10];
RC=RC.draw();
RC.legend();