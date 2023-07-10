function [] = GUI_28()
% Demonstrate uicontextmenu for an axes click.
% Clicking on the axes plots a single point.  After plotting as many points
% as desired, the user may click in the axes to access two options
% concerning the plotted points.
%
% Suggested exercise:  Add another menu to the context menu which
% exports the current plot into another figure then clears the GUI axes for
% more playtime.
%
%
% Author:  Matt Fig
% Date:  7/15/2009

S.ln = [];  % This holds the handles to the points.
S.fh = figure('units','pixels',...
              'position',[200 200 500 500],...
              'menubar','none',...
              'name','GUI_28',...
              'numbertitle','off',...
              'resize','off');
S.ax = axes('xlim',[0 1],'ylim',[0 1]);
title('Click to add points.  Right click for options.','fontw','bold')
S.cm = uicontextmenu;
S.um(1) = uimenu(S.cm,...
                 'label','Delete Points',...
                 'Callback', {@um1_call,S});
S.um(2) = uimenu(S.cm,...
                 'label','Rand Colors',...
                 'Callback', {@um2_call,S});
set(S.ax,'buttondownfcn',{@ax_bdfcn,S},'uicontextmenu',S.cm)

function [] = ax_bdfcn(varargin)
% Serves as the buttondownfcn for the axes.
S = varargin{3};  % Get the structure.
seltype = get(S.fh,'selectiontype'); % Right-or-left click?
L = length(S.ln);

if strmatch(seltype,'normal')
    p = get(S.ax, 'currentpoint'); % Get the position of the mouse.
    S.ln(L+1) = line(p(1),p(3),'Marker','+');  % Make our plot.
    set(S.ln(L+1),'uicontextmenu',S.cm)  % So user can click a point too.
end
% Update structure.
set(S.ax,'ButtonDownFcn',{@ax_bdfcn,S}) 
set(S.um(:),{'callback'},{{@um1_call,S};{@um2_call,S}})


function [] = um1_call(varargin)
% Callback for uimenu to delete the points.
S = varargin{3};  % Get the structure.
delete(S.ln(:));  % Delete all the lines.
S.ln = [];  % And reset the structure.
set(S.ax,'ButtonDownFcn',{@ax_bdfcn,S})


function [] = um2_call(varargin)
% Callback for uimenu to change the colors of the points.
S = varargin{3};  % Get the structure.
L = length(S.ln);  % The number of points.
set(S.ln(:),{'color'},mat2cell(0+.75*rand(L,3),ones(1,L),3 ))  % Color mat.

