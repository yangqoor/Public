clear;clc
tabStrings = {'Tab 1', 'Tab 2','Tab 3'};  %标签名
tabdims={[140,140,140],20}; % 标签的长和高
figsize=[300,300]; % figure大小
[dialogFig,sheetPos,sheetPanels,buttonPanel]=tabdlg('create', tabStrings,tabdims,'',figsize);%使用MATLAB自带函数tabdlg创建


%% 在页面1中放置控件
a1=axes('Parent',sheetPanels(1));
ezplot('sin(x)')

%% 在页面2中放置控件
a2 = axes('Parent',sheetPanels(2));
ezplot('cos(x)')

%% 在页面3中放置控件
a2 = axes('Parent',sheetPanels(3));
ezplot('tan(x)')

set(dialogFig, 'Visible', 'on');

% web -browser http://www.ilovematlab.cn/thread-100442-1-3.html

% strings={'Tab 1','Tab 2','Tab 3'}; % 标签名
% tabdims={[140 140 140],20}; % 标签的长和高
% mycallback=@changetabs; % 当改变标签页时执行该callback函数
% sheetDims=[400,400]; % GUI大小
% offsets=[10 10 10 10]; % 标签页离Figure四边的距离
% starting=1; % Starting on page 1, "Input data"
% 
% % Calling TABDLG to set up the GUI
% % It will still be invisible after this call
% [h, pos]=tabdlg('create',strings, tabdims, mycallback, sheetDims, offsets, starting);
% set(h,'visible','on')

