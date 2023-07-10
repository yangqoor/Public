tbl = readtable('TemperatureData.csv')
monthOrder = {'January','February','March','April','May','June','July', ...
    'August','September','October','November','December'};
tbl.Month = categorical(tbl.Month,monthOrder);

nSet={'flat','flat_dark','camouflage','chalk','copper','dust','earth','fresh',...
    'grape','grass','greyscale','light','lilac','pale','sea','sky','solarized'};
boxchart(tbl.Month,tbl.TemperatureF,'GroupByColor',tbl.Year)
ylabel('Temperature (F)')
legend('2015','2016')
ggThemeBox(gca,nSet{6});
%exportgraphics(gca,[nSet{6},'.png'])