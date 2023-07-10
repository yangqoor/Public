clc;clear
hfig = figure('Name','example2','Menubar','none','Toolbar','none','resize','off');
htab=uitabpanel('Parent',hfig,'string',{'Tab 1','Tab 2','Tab 3'},'CreateFcn',@CreateTab);


% web -browser http://www.ilovematlab.cn/thread-100442-1-3.html