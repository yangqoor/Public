y=[2 2 3 2 5; 2 5 6 2 5; 9 8 9 2 5];

SH=shadowHist(y,'ShadowType',{'/','\','.','_','+'});
SH=SH.draw();
SH=SH.legend({'AAAAAAA','BBBBBBB','CCCCCCC','DDDDDDD','EEEEEEE'},'FontName','Arial','FontSize',11);
