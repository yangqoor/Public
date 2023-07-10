function [] = GUI_38()
% Demonstrate bringing the focus to the figure after callback using JAVA.
% This is an extension of GUI_5.  In this case we have both a keypressfcn
% and a buttonpressfcn for the figure.  Here the word Keypress is printed
% to the command window when a key is pressed while the figure has focus.
% Likewise the word ButtonDown is printed to the command window when the
% mouse is pressed in an area of the figure which is not over a uicontrol.
% When the GUI is first created, the figure has focus, so pressing a key
% triggers the keypressfcn of the figure. After pushing the pushbutton,
% however, the uicontrol takes focus.  In order to make it so the user does
% not have to click in the figure window to give focus back to the figure,
% we simulate a mouseclick in the figure at the end of the callback for the
% pushbutton.  In some versions of MATLAB we could do a similar thing
% without calling JAVA, but here we use JAVA for the sake of using JAVA.
% Note that we must write the buttondownfcn for the figure such that the
% JAVA mouseclick doesn't trigger it.  
%
% The JAVA code is taken from a newsgroup post by Jan Simon.  
% See Yair Altman's website for many more examples.
%
% Author: Matt Fig
% Date: 7/15/2009
 
S.TF = true;
S.ja = java.awt.Robot;   % Define the java AWT object.  
S.fh = figure('units','pixels',...
              'position',[300 300 300 100],...
              'menubar','none',...
              'name','GUI_38',...
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
set(S.pb,'callback',{@pb_call,S})
set(S.fh,'keypressfcn',{@fh_kpfcn},'buttondownfcn',{@fh_bdfcn,S})


function [] = pb_call(varargin)
% Callback for the pushbutton.
S = varargin{3};  % Get the structure.
T = get(S.tx,'string');  % Get the current string.

if isempty(T)
    set(S.pb,'backgroundcolor',[1 .5 .5],'string','Nothing to Delete!')
else
    set(S.tx,'str',T(1:end-1));  % Delete the last character in string.
end

pos = get(S.fh, 'Position');  % User might have moved figure.
pointpos = get(0,'pointerlocation');  % Current pointer location.
set(0, 'PointerLocation', [pos(1),pos(2)]);  % Put pointer at corner of figure.
% Now we simulate a mouseclick on the figure using the JAVA.
S.TF = false;  % This tells the fh_bdfcn that it was JAVA clicking.
set(S.fh,'buttondownfcn',{@fh_bdfcn,S})  % Update with the new S.TF
S.ja.mousePress(java.awt.event.InputEvent.BUTTON1_MASK);  % Click down
S.ja.mouseRelease(java.awt.event.InputEvent.BUTTON1_MASK); % Let up.
set(0,'pointerlocation',pointpos);  % Put the pointer back.
pause(.025)   % drawnow does NOT work here.
S.TF = true;  % So that the user's clicks in figure will work.
set(S.fh,'buttondownfcn',{@fh_bdfcn,S})  % Update the structure.



function [] = fh_kpfcn(varargin)
% Keypressfcn for figure.
disp('       Keypress')  % Just so we know that it is working.


function [] = fh_bdfcn(varargin)
% ButtonDownFcn for figure.
S = varargin{3};

if S.TF
    % We use the If Statement because we don't want the buttondownfcn to
    % execute when the button was pushed by JAVA.  All code for the
    % function should go into here except the structure extraction.
    disp('           ButtonDown')  % Just so we know that it is working.
end












