% 绘制所有风格图片并存储到demo文件夹
% 此函数R2020a后版本才能使用,因为R2020a版本推出exportgraphics

X1=[1:2:7,13];
Y1=randn(100,5)+sin(X1);
X2=2:2:10;
Y2=randn(100,5)+cos(X2);

nSet={'flat','flat_dark','camouflage','chalk','copper','dust','earth','fresh',...
    'grape','grass','greyscale','light','lilac','pale','sea','sky','solarized'};

for i=1:length(nSet)
    figure(i)
    Hdl1=violinChart(gca,X1,Y1,[0     0.447 0.741],0.5);
    Hdl2=violinChart(gca,X2,Y2,[0.850 0.325 0.098],0.5);
    legend([Hdl1.F_legend,Hdl2.F_legend],{'randn+sin(x)','randn+cos(x)'});
    ggThemeViolin(gca,[Hdl1,Hdl2],nSet{i});
    exportgraphics(gca,['demo\',nSet{i},'.png'])
end
close all
pause(0.5)

for i=1:length(nSet)
    figure(i)
    Hdl1=violinChart(gca,X1,Y1,[0     0.447 0.741],0.5);
    Hdl2=violinChart(gca,X2,Y2,[0.850 0.325 0.098],0.5);
    legend([Hdl1.F_legend,Hdl2.F_legend],{'randn+sin(x)','randn+cos(x)'});
    ggThemeViolin(gca,[Hdl1,Hdl2],nSet{i},'LP');
    exportgraphics(gca,['demo\_LP_',nSet{i},'.png'])
end
close all