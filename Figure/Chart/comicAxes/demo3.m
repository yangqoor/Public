t=1:10;
y1=rand([1,10])*15;

plot(t,y1)
hold on
grid on

tq=1:0.1:10;
y2=interp1(t,y1,tq,'spline');
plot(tq,y2)

y3=interp1(t,y1,tq,'makima');
plot(tq,y3)

lgd=legend('linear','spline','makima');
lgd.Location='northeast';
title(lgd,'method','FontSize',12)

exportgraphics(gca,'3_1.png')


comicAxes([])