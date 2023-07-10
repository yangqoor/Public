function [] = GUI_9()
% Demonstrate one way to let the user know a process is running. 
% Creates a pushbutton which, when pushed, simulates some process running 
% in the background and lets the user know this is happening by a text and 
% color change.  When the process is finished, the button returns to 
% normal.  CAREFULLY READ THE COMMENTS BELOW IF YOU PLAN ON USING THIS 
% METHOD IN ONE OF YOUR GUIs.
%
%
% Author:  Matt Fig
% Date:  7/15/2009

S.fh = figure('units','pixels',...
              'position',[300 300 200 100],...
              'menubar','none',...
              'name','GUI_9',...
              'numbertitle','off',...
              'resize','off');
S.pb = uicontrol('style','push',...
                 'unit','pix',...
                 'position',[20 20 160 60],...
                 'string','Push Me',...
                 'callback',{@pb_call},...
                 'backgroundc',[0.94 .94 .94],...
                 'busyaction','cancel',...% So multiple pushes don't stack.
                 'interrupt','off');
             
             
function [] = pb_call(varargin)
% Callback for pushbutton.
h = varargin{1}; % Get the caller's handle.
col = get(h,'backg');  % Get the background color of the figure.
set(h,'str','RUNNING...','backg',[1 .6 .6]) % Change color of button. 
% The pause (or drawnow) is necessary to make button changes appear.
% To see what this means, try doing this with the pause commented out.
pause(.01)  % FLUSH the event queue, drawnow would work too.
% Here is where you put whatever function calls or processes that the
% pushbutton is supposed to activate. 
% Next we simulate some running process.  Here just sort a vector.
A = rand(3000000,1);
A = sort(A); %#ok 
set(h,'str','Push Me','backg',col)  % Now reset the button features.
