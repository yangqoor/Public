x=1:0.1:10;
y1=sin(x).*exp(-x/3) + 3;
y2=3*exp(-(x-7).^2/2) + 1;

ax=gca;
ax.XLim=[1,10];
ax.YLim=[-1,5];
hold(ax,'on')
grid on
box on
plot(x,y1,'b');
plot(x,y2,'r');


title('I am title')
xlabel('I am xlabel')
ylabel('I am ylabel')
lgd=legend({'line1','line2'},'location','southeast');
title(lgd,'a sub title')

% annotation一定要被添加至UserData才能被检测到
ax.UserData{1}=annotation(ax.Parent,'textarrow',[0.4 0.56],[0.74 0.67],'String',{'text','here'},'HorizontalAlignment','left');

comicAxes(ax)