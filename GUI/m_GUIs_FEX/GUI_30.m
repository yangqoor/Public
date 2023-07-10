function [] = GUI_30()
% Same as GUI_29, except uses callback strings.
% Uses callback strings.  Strings are evaluated in command window using
% eval, so we need to make the strings find the objects needed.  For this
% use findobj.  This is included simply as a reference to an older style.
% Callback strings are evaluated in the base workspace, so when using this
% style this MUST be taken into account. (Note that this style of callback
% is generally not recommended, for good reasons.)
%
%
% Author:  Matt Fig
% Date:  7/15/2009

% First create the figure and plot to manipulate with the slider.
x = 0:.1:100;  % Some simple data.
f = figure;  % This is the figure which has the axes to be controlled.
plot(x,sin(x));
xlim([0,pi]);  % Set the beginning x/y limits.
ylim([-1,1])
set(gca,'tag','axes1');  % This axes will be controlled.

% This string will serve as a callback string.
cbs = ['set(findobj(''tag'',''axes1''),''xlim'',',...
       '[0 get(gcbo,''val'')],''ylim'',[-1,1]);'];  % Callback string.
S.fh = figure('units','pixels',...
              'position',[400 400 220 40],...
              'menubar','none',...
              'name','GUI_30',...
              'numbertitle','off',...
              'resize','off');
S.sl = uicontrol('style','slide',...
                 'unit','pixel',...
                 'position',[10 10 200 20],...
                 'min',1,'value',pi,'max',100,...
                 'callback',cbs,...
                 'deletefcn',{@delete,f});
set(f,'deletef',{@delete,S.fh})  % Closing one closes the other.             

   
