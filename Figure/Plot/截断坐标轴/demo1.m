x=0:.05:60;
y1=4.*cos(x)./(x+2);
y2=2.*sin(x);
 
plot(x,y1,'LineWidth',2)
hold on
plot(x,y2,'LineWidth',2)
box on
grid on

set(gca,'Position',[0.06,0.06,.92,.92]);

truncAxis('Y',[0,0.5])

