function [] = GUI_17()
% Demonstrate how to have a running clock in a GUI, and timer use.
% Creates a small little GUI which displays the correct time and is updated
% every minute according to the system clock.
%
% Author:  Matt Fig
% Date:  1/15/2010

S.fh = figure('units','pixels',...
              'position',[300 300 180 50],...
              'menubar','none',...
              'name','GUI_17',...
              'numbertitle','off',...
              'resize','off');
S.tx = uicontrol('style','text',...
                 'unit','pix',...
                 'position',[35 10 110 30],...
                 'string',datestr(now,16),...
                 'backgroundc',get(S.fh,'color'),...
                 'fontsize',18,...
                 'fontweight','bold',...
                 'foregroundcolor',[.9 .1 .1]);
STRT = 60 - str2double(datestr(now,'ss')); % So we can update every minute.             
tmr = timer('Name','Reminder',...
            'Period',60,...  % Update the time every 60 seconds.
            'StartDelay',STRT,... % In seconds.
            'TasksToExecute',inf,...  % number of times to update
            'ExecutionMode','fixedSpacing',...
            'TimerFcn',{@updater}); 
start(tmr);  % Start the timer object.
set(S.fh,'deletefcn',{@deleter})  % Kill timer if fig is closed.

    function [] = updater(varargin)
    % timerfcn for the timer.  If figure is deleted, so is timer.
         % I use a try-catch here because timers are finicky in my
         % experience.
         try
             set(S.tx,'string',datestr(now,16))
             if ~str2double(datestr(now,'MM'))
                 X = load('gong');  % At the hour, sound a gong.
                 sound(X.y,X.Fs*2.5)  
             end
             clear X
         catch
             delete(S.fh) % Close it all down.
         end
    end

    function [] = deleter(varargin)
    % If figure is deleted, so is timer.
         stop(tmr);
         delete(tmr);
    end
end

             
