function C = GUI_34()
% Demonstrate how to make a simple printscreen GUI.  Note that this does
% not work for all setups, for example, on some vista machines the image is
% black (all values zero).
%
% C = GUI_34;  % Don't forget the semicolon!
% image(C)
%
%
% Author:  Matt Fig
% Date:  1/15/2010


C = [];
S.fh = figure('units','pixels',...
              'menubar','none',...
              'numbertitle','off',...
              'name','GUI_34',...
              'position',[400 400 120 50]);
S.SCR = get(0,'screensize');
S.pb = uicontrol('units','pixels',...
                 'string','PrintScreen',...
                 'position',[10 10 100 30],...
                 'callback',{@pb_call});
uiwait(S.fh)  % Stop other processes from beginning until closed.

    function [] = pb_call(varargin)
    % Callback for the pushbutton.
        set(S.fh,'position',[-150 -75 100 50])
        pause(1)
        f = getframe (S.fh, [150 75 S.SCR(3)+1 S.SCR(4)+1]) ;
        C = frame2im(f);
        close(S.fh)
    end
end