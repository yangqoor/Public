function [] = GUI_18()
% Demonstrate the use of the buttondownfcn for an axes.  
% Clicking on the axes creates a random line.  Note that clicking on the 
% line does the same thing.  This must be accounted for in the coding 
% below, or clicking on the line would do nothing.  Right click to delete 
% the line.
%
% An exercise would be to alter the code so that right clicking recreates
% the plot in another figure window.  This could be done at least two
% different ways.
%
%
% Author:  Matt Fig
% Date:  7/15/2009

S.fh = figure('units','pixels',...
              'position',[200 200 200 200],...
              'menubar','none',...
              'numbertitle','off',...
              'name','GUI_18',...
              'resize','off');
S.ax = axes('units','pixels',...
            'position',[30 30 160 160],...
            'fontsize',8,...
            'buttondownfcn',{@ax_bdfcn,S},...
            'nextplot','replacechildren');


function [] = ax_bdfcn(varargin)
% buttondownfcn for axes.
[h,S] = varargin{[1,3]};  % Extract the calling handle and structure.

% We need to account for when the user clicks the line instead of the axes.
if ~strcmpi(get(h,'type'),'axes')
   h = findobj('children',h);  % 
end

seltype = get(S.fh,'selectiontype'); % Right-or-left click?

switch seltype
    case 'alt'
        cla  % Delete the line.
    case 'normal'
        ln = plot(h,sort(rand(1,10)));  % Plot a new line.
        set(ln,'buttondownfcn',{@ax_bdfcn,S})
    otherwise
        % Do something else for double-clicks, etc.
end