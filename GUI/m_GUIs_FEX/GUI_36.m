function [R] = GUI_36()
% Demonstrate how to make a custom dialog box which returns information.
%
% Example: 
%          T = GUI_36;  % T will be a string.
%
% Suggested exercise:  How would you modify this code so that the default
% answer 'Enter Some Data' CANNOT be returned?
%
%
% Author:  Matt Fig
% Date:  1/15/2010

R = [];  % In case the user closes the GUI.
S.fh = figure('units','pixels',...
              'position',[500 500 200 100],...
              'menubar','none',...
              'name','GUI_36',...              
              'numbertitle','off',...
              'resize','off');
S.ed = uicontrol('style','edit',...
                 'units','pix',...
                'position',[10 60 180 30],...
                'string','Enter Some Data');
S.pb = uicontrol('style','pushbutton',...
                 'units','pix',...
                'position',[10 20 180 30],...
                'string','Push to Return Data',...
                'callback',{@pb_call});
uicontrol(S.ed)  % Make the editbox active.
uiwait(S.fh)  % Prevent all other processes from starting until closed.

    function [] = pb_call(varargin)
    % Callback for the pushbutton.
        R = get(S.ed,'string');
        close(S.fh);  % Closes the GUI, allows the new R to be returned.
    end
end






% Below is the exact same program, without the use of nested functions.

% function [R] = GUI_36()
% % Get information from a GUI to the command line.
% % How to make a GUI that returns information to caller?
% % How to initialize the string as active in an editbox
% % Suggested exercise:  How would you modify this code so that the default
% % answer 'Enter Some Data' cannot be returned?
% R = [];
% S.fh = figure('units','pixels',...
%               'position',[500 500 200 130],...
%               'menubar','none',...
%               'name','GUI_36',...  
%               'numbertitle','off',...
%               'resize','off');
% S.ed = uicontrol('style','edit',...
%                  'units','pix',...
%                 'position',[10 60 180 60],...
%                 'string','Data');
% S.pb = uicontrol('style','pushbutton',...
%                  'units','pix',...
%                 'position',[10 20 180 30],...
%                 'string','Push to Return Data');
% set(S.pb,'callback',{@pb_call,S})            
% waitfor(S.ed)
% 
% if ishandle(S.fh)
%     F = get(S.pb,'callback');
%     R = F{2}.R;
%     close(S.fh)
% end
% 
% 
% function [] = pb_call(varargin)
% S = varargin{3};
% S.R = get(S.ed,'string');
% set(S.pb,'callback',{@pb_call,S});
% delete(S.ed);
       