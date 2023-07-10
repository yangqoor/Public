x=0:.05:60;

y1=cos(x)./(x+2)+5;
y2=sin(x);

plot(x,y1);
hold on
plot(x,y2);
box on
ax=gca;
ax.LineWidth=1.5;

truncAxis(gca,'Y',[1,4])


axset=get(gcf,'Children');
axset(2).XLabel.String='XXXXX';
axset(1).YLabel.String='YYYYY';
axset(1).YLabel.Position(2)=axset(1).YLim(1);
