function [] = GUI_11()
% Demonstrate how to use a GUI to stop a FOR loop. 
% Note that this file has both the GUI creation lines and the FOR loop, but
% that is not necessary.  When the loop is stopped, the number of
% iterations completed will be displayed in the command window.
%
% Suggested exercise:  Modify this program so that a FOR loop running in
% another M-File could call it and allow the loop to be stopped.
%
%
% Author:  Matt Fig, with major idea from Jos(10584) on the FEX.
% Date:  1/15/2010

S.fh = figure('units','pix',...
              'pos',[400 400 120 50],...
              'menubar','none',...              
              'name','GUI_11',...
              'numbertitle','off',...
              'resize','off');
S.pb = uicontrol('string','Stop Loop!',...
                 'callback',{@pb_call},...
                 'units','pixels',...
                 'fontsize',11,...
                 'fontweight','bold',...
                 'position',[10 10 100 30]);

n = 1;
drawnow; % Draw the GUI before we enter the loop!

% Below are two versions of the FOR loop which we wish to stop.  The first
% version is simpler and close to the version which would be written if we
% didn't want a GUI to be able to stop its execution.  The second version
% allows for more iterations because it does not execute the ISHANDLE
% function  or use DRAWNOW every iteration, instead it executes the MOD 
% function every iteration.  To see the difference, run each loop for ten 
% seconds before stopping with the GUI.  The number of loop iterations will
% be displayed in the command window.  What are some potential drawbacks of
% using the second method?

for ii = 1:inf  % First loop, run EITHER this loop OR the next one.
    if ~ishandle(S.fh)  % Check if the figure exists.
        break;
    end
    drawnow;  % Try it without this line to see what happens (Ctrl+R)!
    n = n + 1; % Here is where all of the loop commands would go.
end

% for ii = 1:inf  % Second loop, run EITHER this loop OR the previous one.
%     if ~mod(ii,100)
%         if ~ishandle(S.fh)  % Check if the figure exists.
%             break;
%         end
%         drawnow;  % Try it without this line to see what happens (Ctrl+R)!
%     end
%     n = n + 1; % Here is where all of the loop commands would go.
% end

% Display how many iterations the loop was able to complete.
fprintf('\n\t%s%i\n\n','The number of iterations completed is: ',n )

    function [] = pb_call(varargin)
    % Callback for pushbutton
    delete(S.fh)  % Delete the figure.
    end
end 