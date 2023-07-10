froot=get(0);
fsize=froot.ScreenSize;
fig=figure();
fig.Position=[fsize(3)/7,fsize(4)/7,fsize(3)*4/7,fsize(4)*4.5/7];
%--------------------------------------------------------------------------
ax1=axes(fig);
ax1.Position=[0.025,0.525,0.45,0.45];
hold(ax1,'on');
t=0:0.6:3*pi;
plot(t,sin(t).*1.2,'LineWidth',2,'Marker','o')
plot(t,cos(t./2),'LineWidth',2,'Marker','s')
plot(t,t,'LineWidth',2,'Marker','^')
lgd=legend(' y=1.2sin(t)',' y=cos(t/2)',' y=t');
lgd.Location='best';
title(lgd,'Func')
%--------------------------------------------------------------------------
ax2=axes(fig);
ax2.Position=[0.525,0.525,0.45,0.45];
hold(ax2,'on');
y=[6 3 4 2 1;12 6 3 2 1;9 5 2 2 2;7 3 1 1 0;5 2 2 1 1;2 1 1 0 1;];
bar(y)
legend('class1','class2','class3','class4','class5')

%--------------------------------------------------------------------------
ax3=axes(fig);
ax3.Position=[0.025,0.025,0.45,0.45];
hold(ax3,'on');
tbl = readtable('TemperatureData.csv');
monthOrder = {'January','February','March','April','May','June','July', ...
    'August','September','October','November','December'};
tbl.Month = categorical(tbl.Month,monthOrder);
boxchart(tbl.Month,tbl.TemperatureF,'GroupByColor',tbl.Year)
ylabel('Temperature (F)')
legend('2015','2016')
%--------------------------------------------------------------------------
ax4=axes(fig);
ax4.Position=[0.525,0.025,0.45,0.45];
hold(ax4,'on');
x=linspace(-8,12,100);
y1=normpdf(x,4,6);
y2=normpdf(x,0,1).*0.5+normpdf(x,4,2).*0.5;
y3=normpdf(x,-3,2);
plot(x,y1);
plot(x,y2);
plot(x,y3);
ax=gca;
ax.XLim=[-8,12];
legend('density1','density2','density3')
%--------------------------------------------------------------------------
pause(0.5)
nSet={'flat','flat_dark','camouflage','chalk','copper','dust','earth','fresh',...
    'grape','grass','greyscale','light','lilac','pale','sea','sky','solarized'};
ggThemePlot(ax1,nSet{6});
ggThemeBar(ax2,nSet{4});
ggThemeBox(ax3,nSet{9});
ggThemeDensity(ax4,nSet{12});

exportgraphics(fig,'_demo.png')



