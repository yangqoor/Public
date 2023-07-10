% froot=get(0);
% fsize=froot.ScreenSize;
% fig=figure();
% fig.Position=[fsize(3)/7,fsize(4)/7,fsize(3)*4/7,fsize(4)*2.5/7];

y=[6 3 4 2 1;12 6 3 2 1;9 5 2 2 2;7 3 1 1 0;5 2 2 1 1;2 1 1 0 1;];
ax1=subplot(1,2,1);
bar(y)
legend('class1','class2','class3','class4','class5')

ax2=subplot(1,2,2);
bar(y,'stacked')
legend('class1','class2','class3','class4','class5')
% exportgraphics(fig,'_demo_1.png')

pause(0.5)
ggThemeBar(ax1,'dust');
ggThemeBar(ax2,'dust');
% exportgraphics(fig,'_demo_1_1.png')