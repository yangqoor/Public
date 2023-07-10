t=0.01:0.01:3*pi;
plot(t,cos(t)./(1+t))
hold on
plot(t,sin(t)./(1+t))
plot(t,cos(t+pi/2)./(1+t+pi/2))
plot(t,cos(t+pi)./(1+t+pi))
legend