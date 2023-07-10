function [] = GUI_23()
% Demonstrate finding which figure was current before callback execution.  
% Usage:
%
%     Call GUI_23, then create several plots, for example:
%
%     GUI_23
%     x = 0:.1:10;
%     figure;plot(x,x);figure;plot(x,x.^2);figure;plot(x,x.^3)
%
%     Now click on whichever of the figures needs a title.
%     Enter the title in the GUI_23 editbox, then push the button.
%     Clicking on a different figure will make it receive the next title.
%     GUI_23 can also be called AFTER the figures have been created.
%
% If no figure exists, one will be created with the title found in the edit
% box.
%
% Suggested exercise:  Alter the code so that an xlabel and ylabel
% also are added.  This could be done by making 2 more edits, and having
% the pushbutton use the information from all 3 edits to do the job.
%
%
% Author:  Matt Fig
% Date:  7/15/2009

S.fh = figure('units','pixels',...
              'position',[500 500 350 50],...
              'menubar','none',...
              'numbertitle','off',...
              'name','GUI_23',...
              'resize','off');
S.ed = uicontrol('style','edit',...
                 'units','pixels',...
                 'position',[10 10 220 30],...
                 'fontsize',14,...
                 'string','Enter Title');
S.pb = uicontrol('style','push',...
                 'units','pixels',...
                 'position',[240 10 100 30],...
                 'fonts',14,...
                 'str','Insert Title',...
                 'callback',{@pb_call,S});
           
function [] = pb_call(varargin)
% Callback for the button labeled PUSH_1.
S = varargin{3}; % Get the structure.
AX = findobj('type','axes');  % Look for existing axes objects.

if isempty(AX)
   % The GUI could popup a message box saying, "No axes to title!" or 
   % something similar, then return from here.
   figure
   AX = axes;
end

title(AX(1),get(S.ed,'string')) % The first one in the list was current!


    








