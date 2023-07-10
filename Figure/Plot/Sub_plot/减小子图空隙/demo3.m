tsubplot(1,1,1,'tight');

t=0.01:0.2:3*pi;
hold on;grid on
plot(t,cos(t)./(1+t),'LineWidth',2)
plot(t,sin(t)./(1+t),'LineWidth',2)
plot(t,cos(t+pi/2)./(1+t+pi/2),'LineWidth',2)
plot(t,cos(t+pi)./(1+t+pi),'LineWidth',2)
legend