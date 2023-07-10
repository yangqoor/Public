function [] = GUI_16()
% Demonstrate display & change a slider's position & limits with edit boxes  
% This is an extension of GUI_13. Slide the slider and it's position will 
% be shown in the editbox.  Enter a valid number in the editbox and the 
% slider will be moved to that position.  If the number entered is outside 
% the range of the slider, the number will be reset.  The range of the 
% slider will be shown in two editboxes on either side of the slider.  The 
% user may change the range of the slider, as long as valid entries are 
% made.
%
% Suggested exercise:  Notice that any number (>min) is acceptable for the 
% max range number, and that when max is chosen such that max < value,
% value is set equal to max.  Modify the code to restrict max>=value.  Do
% similarly for the min.
%
%
% Author:  Matt Fig
% Date:  7/15/2009

S.fh = figure('units','pixels',...
              'position',[300 300 390 100],...
              'menubar','none',...
              'name','GUI_16',...
              'numbertitle','off',...
              'resize','off');
S.sl = uicontrol('style','slide',...
                 'unit','pix',...
                 'position',[60 10 270 30],...
                 'min',1,'max',100,'val',50); 
S.ed(1) = uicontrol('style','edit',...
                    'unit','pix',...
                    'position',[10 10 40 30],...
                    'fontsize',12,...
                    'string','1');   % Displays the min.          
S.ed(2) = uicontrol('style','edit',...
                    'unit','pix',...
                    'position',[60 50 270 30],...
                    'fontsize',16,...
                    'string','50');  % Displays the value.
S.ed(3) = uicontrol('style','edit',...
                    'unit','pix',...
                    'position',[340 10 40 30],...
                    'fontsize',12,...
                    'string','100');    % Displays the max.    
set([S.ed(:);S.sl],'call',{@sl_call,S});  % Shared Callback.



function [] = sl_call(varargin)
% Callback for the edit box and slider.
[h,S] = varargin{[1,3]};  % Get calling handle and structure.
SL = get(S.sl,{'min','value','max'});  % Get the slider's info.
E = str2double(get(h,'string'));  % Numerical edit string.

switch h  % Who called?
    case S.ed(1)
        if E <= SL{2}
            set(S.sl,'min',E)  % E is less than current value.
        elseif E < SL{3}
            set(S.sl,'val',E,'min',E) % E is less than max value.
            set(S.ed(2),'string',E) % Set the current display.
        else
            set(h,'string',SL{1}) % Reset the value.
        end
    case S.ed(2)
        if E >= SL{1} && E <= SL{3}
            set(S.sl,'value',E)  % E falls within range of slider.
        else
            set(h,'string',SL{2}) % User tried to set slider out of range. 
        end
    case S.ed(3)
        if E >= SL{2}
            set(S.sl,'max',E)  % E is less than current value.
        elseif E > SL{1}
            set(S.sl,'val',E,'max',E) % E is less than max value.
            set(S.ed(2),'string',E) % Set the current display.
        else
            set(h,'string',SL{3}) % Reset the value.
        end      
    case S.sl
        set(S.ed(2),'string',SL{2}) % Set edit to current slider.
    otherwise
        % Do nothing
end




