X1=[1:2:7,13];
Y1=randn(100,5)+sin(X1);
X2=2:2:10;
Y2=randn(100,5)+cos(X2);

figure
Hdl1=violinChart(gca,X1,Y1,[0     0.447 0.741]);
Hdl2=violinChart(gca,X2,Y2,[0.850 0.325 0.098]);
legend([Hdl1.F_legend,Hdl2.F_legend],{'randn+sin(x)','randn+cos(x)'});
ggThemeViolin(gca,[Hdl1,Hdl2],'dust');


figure
Hdl1=violinChart(gca,X1,Y1,[0     0.447 0.741]);
Hdl2=violinChart(gca,X2,Y2,[0.850 0.325 0.098]);
legend([Hdl1.F_legend,Hdl2.F_legend],{'randn+sin(x)','randn+cos(x)'});
ggThemeViolin(gca,[Hdl1,Hdl2],'dust','LP');