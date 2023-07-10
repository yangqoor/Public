% demo4

t=-.1:.01:pi/2;
y1=sin(t).*2;
y2=t.^2;

hold on
plot(t,y1,'LineWidth',2);
plot(t,y2,'LineWidth',2);

diffy=y1-y2;
tpos=find(diffy>=0);
T=[t(tpos(1):tpos(end)),t(tpos(end):-1:tpos(1))];
Y=[y1(tpos(1):tpos(end)),y2(tpos(end):-1:tpos(1))];


shadowFill(T,Y,pi/5,70,'LineStyle',':','Color',[.2,.2,.9]); 

% ax=gca;
% ax.FontName='Cambria';
% ax.LineWidth=1.1;
% ax.XColor=[1,1,1].*.3;
% ax.YColor=[1,1,1].*.3;
% ax.XMinorTick='on';
% ax.YMinorTick='on';
% ax.XGrid='on';
% ax.YGrid='on';
% ax.Box='on';
% ax.GridLineStyle='-.';
% ax.GridAlpha=.1;