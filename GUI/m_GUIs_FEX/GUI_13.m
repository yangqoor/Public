function [] = GUI_13()
% Demonstrate how to display & change a slider's position with an edit box.  
% Slide the slider and it's position will be shown in the editbox.  
% Enter a valid number in the editbox and the slider will be moved to that 
% position.  If the number entered is outside the range of the slider, 
% the number will be reset.
%
%
% Author:  Matt Fig
% Date:  7/15/2009

S.fh = figure('units','pixels',...
              'position',[300 300 300 100],...
              'menubar','none',...
              'name','GUI_13',...
              'numbertitle','off',...
              'resize','off');
S.sl = uicontrol('style','slide',...
                 'unit','pix',...
                 'position',[20 10 260 30],...
                 'min',1,'max',100,'val',50);             
S.ed = uicontrol('style','edit',...
                 'unit','pix',...
                 'position',[20 50 260 30],...
                 'fontsize',16,...
                 'string','50');
set([S.ed,S.sl],'call',{@ed_call,S});  % Shared Callback.



function [] = ed_call(varargin)
% Callback for the edit box and slider.
[h,S] = varargin{[1,3]};  % Get calling handle and structure.

switch h  % Who called?
    case S.ed
        L = get(S.sl,{'min','max','value'});  % Get the slider's info.
        E = str2double(get(h,'string'));  % Numerical edit string.
        if E >= L{1} && E <= L{2}
            set(S.sl,'value',E)  % E falls within range of slider.
        else
            set(h,'string',L{3}) % User tried to set slider out of range. 
        end
    case S.sl
        set(S.ed,'string',get(h,'value')) % Set edit to current slider.
    otherwise
        % Do nothing, or whatever.
end