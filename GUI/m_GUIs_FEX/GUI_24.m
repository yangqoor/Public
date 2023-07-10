function [] = GUI_24()
% Demonstrate how to get data from one GUI to another (data passing).  
% Creates a GUI with an editbox and a pushbutton.  When the user presses 
% the pushbutton, another GUI pops up with an editbox.  Whatever is in the 
% editbox of the second GUI when the user hits return will be put into the 
% edit box of the first GUI.
%
% Suggested exercise:  Alter the code to have the new GUI display whatever 
% text is in the editbox from the first GUI when the new GUI is created.
% Even more advanced:  Alter the code so that two new GUIs cannot be
% launched simultaneously by pressing the pushbutton repeatedly.  
%
%
% Author:  Matt Fig
% Date:  7/15/2009

S.fh = figure('units','pixels',...
              'position',[500 500 200 130],...
              'menubar','none',...
              'numbertitle','off',...
              'name','GUI_24',...
              'resize','off');
S.ed = uicontrol('style','edit',...
                 'units','pix',...
                'position',[10 60 180 60],...
                'string','Data');
S.pb = uicontrol('style','pushbutton',...
                 'units','pix',...
                'position',[10 20 180 30],...
                'string','Push to Get Data',...
                'callback',{@pb_call,S});
            
            
function [] = pb_call(varargin)
% Callback for GUI_24 pushbutton.
S = varargin{3};  % Get the structure.
f = figure('units','pixels',...
       'menubar','none',...
       'position',[750 510 200 100]); % Create a new GUI.
E = uicontrol('style','edit',...
              'units','pixels',...
              'position',[10 20 180 60],...
              'string','Type something, press return.',...
              'callback',{@E_call,varargin{3}});
uicontrol(E);  % Allow user to simply hit return without typing anything.
% If user closes GUI_24, close new one as well because it will error when 
% it tries to execute the callback otherwise.      
set(S.fh,'deletefcn',{@fig_delet,f})    



function [] = E_call(varargin)
% Callback for secondary GUI editbox.
S = varargin{3};  % Get the structure.
set(S.ed,'string',get(gcbo,'string'))  % Set GUI_24 editbox string.
close(gcbf)  % Close secondary GUI.


function [] = fig_delet(varargin)
% Executes when user closes GUI_24.
try
    delete(varargin{3})
catch
    % Do nothing.
end