y=[2 2 3 2 5 4 2 2 2 1;2 2 3 2 5 4 2 4 3 6];

SH=shadowHist(y,'ShadowType',{'/','\','x','.','_','|','+','w','k','g'});
SH=SH.draw();
SH=SH.legend({'A','B','C','D','E','F','G','H','I','J'});