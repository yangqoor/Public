X=linspace(0,2*pi,100);
Y=exp(0.3*X).*sin(3*X);
scatter(X,Y,'LineWidth',1);

box off
grid off

set(gca,'Position',[0.06,0.06,.92,.92]);

truncAxis('X',[3,4],'Y',[0,1])

legend