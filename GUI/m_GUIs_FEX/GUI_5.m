function [] = GUI_5()
% Demonstrate how to use a pushbutton to delete bits of string and how to 
% let the user know that their actions are futile.  After the string is 
% deleted completely, the user is informed that there is nothing left to 
% delete if the delete button is pressed again.  A color change accompanies
% this announcement.
%
% Suggested exercise:  Add a counter to S that starts incrementing when the  
% warning is given.  If the user clicks again, close the GUI.
%
%
% Author:  Matt Fig
% Date:  7/15/2009

S.fh = figure('units','pixels',...
              'position',[300 300 300 100],...
              'menubar','none',...
              'name','GUI_5',...
              'numbertitle','off',...
              'resize','off');
S.pb = uicontrol('style','push',...
                 'unit','pix',...
                 'position',[20 10 260 30],...
                 'string','Deleter');
S.tx = uicontrol('style','text',...
                 'unit','pix',...
                 'position',[20 50 260 30],...
                 'fontsize',16,...
                 'string','DeleteMe');
set(S.pb,'callback',{@pb_call,S})  % Set the callback for pushbutton.


function [] = pb_call(varargin)
% Callback for the pushbutton.
S = varargin{3};  % Get the structure.
T = get(S.tx,'string');  % Get the current string.

if isempty(T)
    set(S.pb,'backgroundcolor',[1 .5 .5],'string','Nothing to Delete!')
else
    set(S.tx,'str',T(1:end-1));  % Delete the last character in string.
end