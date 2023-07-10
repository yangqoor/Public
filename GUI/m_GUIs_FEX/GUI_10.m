function [] = GUI_10()
% Demonstrate how to make an image visible or invisible by pushbutton.
% Pushing the pushbutton makes the image appear and disappear to the user.
% Many people have trouble with this because just setting the axes property
% does not do the job.
%
%
% Author:  Matt Fig
% Date:  1/15/2010

S.fh = figure('units','pixels',...
              'position',[200 200 200 200],...
              'menubar','none',...
              'numbertitle','off',...
              'name','GUI_10',...
              'resize','off');
S.ax = axes('units','pixels',...
            'position',[30 50 160 140]);
S.im = load('clown');  % This is a built-in ML example.
S.R = image(S.im.X);  % Display the image on S.ax.
colormap(S.im.map);  % Set the figure's colormap.
set(S.ax,'xtick',[],'ytick',[])  % Get rid of ticks.
S.pb = uicontrol('style','push',...
                 'units','pixels',...
                 'position',[10 10 180 30],...
                 'fontsize',14,...
                 'string','INVISIBLE/VISIBLE',...
                 'callback',{@pb_call,S});

function [] = pb_call(varargin)
% Callback for the pushbutton.
S = varargin{3};  % Get the structure.
switch get(S.R,'visible')
    case 'on'
        st = 'off';
    case 'off'
        st = 'on';
    otherwise
        close(S.fh)  % It would be very strange to end up here.
        error('An unknown error occured in the callback')
end
set([S.R,S.ax],'visible',st)  % Set BOTH the image and axis visibility.
