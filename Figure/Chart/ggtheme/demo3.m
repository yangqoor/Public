tbl = readtable('TemperatureData.csv');
monthOrder = {'January','February','March','April','May','June','July', ...
    'August','September','October','November','December'};
tbl.Month = categorical(tbl.Month,monthOrder);
boxchart(tbl.Month,tbl.TemperatureF,'GroupByColor',tbl.Year)
ylabel('Temperature (F)')
legend

pause(0.5)
ggThemeBox(gca,'camouflage');
