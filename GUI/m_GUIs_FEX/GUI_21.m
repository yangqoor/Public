function [] = GUI_21()
% Demonstrate how to get selection from a popup to an edit box & vis versa. 
% This is an expansion of GUI_20.  Here we will enforce a specific list of 
% choices so that any text the user enters into the editbox which is not a 
% choice in the popup will be overwritten.
% 
%
% Author:  Matt Fig
% Date:  7/15/2009

S.fh = figure('units','pixels',...
              'position',[300 300 300 110],...
              'menubar','none',...
              'name','GUI_21',...
              'numbertitle','off',...
              'resize','off');
S.pop = uicontrol('style','pop',...
                  'units','pixels',...
                  'position',[20 10 260 40],...
                  'string',{'one','two','three','four'});
S.ed = uicontrol('style','edit',...
                 'units','pix',...
                 'position',[20 60 260 30],...
                 'fontsize',16,...
                 'string','one');

set([S.pop,S.ed],{'callback'},{{@pop_call,S};{@ed_call,S}}); % Set callback


function [] = pop_call(varargin)
% Callback for the popup.
S = varargin{3};  % Get the structure.
P = get(S.pop,{'string','val'});  % Get the users choice.
set(S.ed,'string',P{1}{P{2}});  % Assign the user's choice to the edit.


function [] = ed_call(varargin)
% Callback for the edit.
S = varargin{3};  % Get the structure.
E = get(S.ed,'string');  % Get the string from the edit.
P = get(S.pop,{'string','value'});  % Get the users choice.
% Check if edit string is found in pop-up list.
tmp = strmatch(E,P{1});

if ~isempty(tmp)
    set(S.pop,'value',tmp)  % Set the pop-up to match the edit.
else
    set(S.ed,'string',P{1}{P{2}}) % Set the edit to current pop-up.
end