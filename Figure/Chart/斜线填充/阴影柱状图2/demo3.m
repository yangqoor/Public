y=[2 2 -3 -2 -5; -2 -5 6 2 5; 9 8 9 2 5; -3 -5 6 2 5; 4 8 5 2 5];

SH=shadowHist(y,'ShadowType',{'/','\','.','x','|'},'stacked','Horizontal','on');
SH=SH.draw();