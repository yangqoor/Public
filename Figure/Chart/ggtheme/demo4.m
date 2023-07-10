x=linspace(-8,12,100);
y1=normpdf(x,4,6);
y2=normpdf(x,0,1).*0.5+normpdf(x,4,2).*0.5;
y3=normpdf(x,-3,2);
plot(x,y1);
hold on
plot(x,y2);
plot(x,y3);
ax=gca;
ax.XLim=[-8,12];
legend('density1','density2','density3')

pause(0.5)
ggThemeDensity(gca,'grape');