clear;clc
tabStrings = {'Tab 1', 'Tab 2','Tab 3'};  %��ǩ��
tabdims={[140,140,140],20}; % ��ǩ�ĳ��͸�
figsize=[300,300]; % figure��С
[dialogFig,sheetPos,sheetPanels,buttonPanel]=tabdlg('create', tabStrings,tabdims,'',figsize);%ʹ��MATLAB�Դ�����tabdlg����


%% ��ҳ��1�з��ÿؼ�
a1=axes('Parent',sheetPanels(1));
ezplot('sin(x)')

%% ��ҳ��2�з��ÿؼ�
a2 = axes('Parent',sheetPanels(2));
ezplot('cos(x)')

%% ��ҳ��3�з��ÿؼ�
a2 = axes('Parent',sheetPanels(3));
ezplot('tan(x)')

set(dialogFig, 'Visible', 'on');

% web -browser http://www.ilovematlab.cn/thread-100442-1-3.html

% strings={'Tab 1','Tab 2','Tab 3'}; % ��ǩ��
% tabdims={[140 140 140],20}; % ��ǩ�ĳ��͸�
% mycallback=@changetabs; % ���ı��ǩҳʱִ�и�callback����
% sheetDims=[400,400]; % GUI��С
% offsets=[10 10 10 10]; % ��ǩҳ��Figure�ıߵľ���
% starting=1; % Starting on page 1, "Input data"
% 
% % Calling TABDLG to set up the GUI
% % It will still be invisible after this call
% [h, pos]=tabdlg('create',strings, tabdims, mycallback, sheetDims, offsets, starting);
% set(h,'visible','on')

