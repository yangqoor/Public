t=0:0.6:3*pi;
plot(t,sin(t).*1.2,'LineWidth',2,'Marker','o')
hold on
plot(t,cos(t./2),'LineWidth',2,'Marker','s')
plot(t,t,'LineWidth',2,'Marker','^')

lgd=legend(' y=1.2sin(t)',' y=cos(t/2)',' y=t');
lgd.Location='best';
title(lgd,'Func')

pause(0.5)
ggThemePlot(gca,'flat_dark');