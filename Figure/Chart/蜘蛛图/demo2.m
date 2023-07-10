rng(1);
figure('Position',[600,200,600,600]);

X=randi([2,8],[4,7])+rand([4,7]);
RC=radarChart(X);
RC.PropName={'建模','实验','编程','总结','撰写','创新','摸鱼'};
RC.ClassName={'同门A','同门B','同门C','同门D'};
RC=RC.draw();
RC.legend();