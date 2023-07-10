t=0:0.1:3*pi;
plot(t,sin(t),'Color',[0.4 0.76 0.65])
hold on
grid on
plot(t,cos(t./2),'Color',[0.99 0.55 0.38])
plot(t,t,'Color',[0.55 0.63 0.8])

lgd=legend('y=sin(t)','y=cos(t/2)','y=t');
lgd.Location='northwest';
title(lgd,'Func','FontSize',12)

comicAxes([])
