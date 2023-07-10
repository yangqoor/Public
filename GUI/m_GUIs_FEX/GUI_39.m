function [] = GUI_39()
% Demonstrate use of nested functions for callbacks and other functions.
% Notice here that there is no need to extract S from varargin in each
% function because all callback functions are nested in the main function
% and therefore have access to the structure S.  
% User can draw whatever is desired, and change colors by right-clicking in
% the axes window.  When the drawing is complete, click the Save-As menu to
% save the file in one of three image formats.
%
%
% Suggested exercise:  Add ability to interactively delete data points.
%
%
% Author:  Matt Fig
% Date:  7/30/2009

S.COL = [0 0 1];  % Start with blue.
S.LST = {[],[0 0 1],[1 0 0],[0 .9 0],[.9 .9 0],[0 0 0]}; % List of colors.
S.FMT = {[],'jpg','png','bmp'};  % List of file formats.
S.fh = figure('units','pixels',...
              'position',[300 300 400 400],...
              'menubar','none',...
              'name','GUI_39',...
              'numbertitle','off',...
              'resize','off');
S.ax = axes('units','pixels',...
            'position',[20 20 360 350],...
            'Xlim',[0 1],...
            'YLim',[0 1],...
            'drawmode','fast');
S.cm = uicontextmenu;
% Define the different color menus.  We could define as many as we like.
% Each color has it's corresponding RGB values in S.LST.  Note that the
% first cell in S.LST should be kept empty.  (See um_call)
S.um(1) = uimenu(S.cm,'label','Color');  % First menu seen on right-click
S.um(2) = uimenu(S.um(1),'label','Blue'); % The rest are seen as submenus.
S.um(3) = uimenu(S.um(1),'label','Red');
S.um(4) = uimenu(S.um(1),'label','Green'); 
S.um(5) = uimenu(S.um(1),'label','Yellow');
S.um(6) = uimenu(S.um(1),'label','Black');
set(S.um(2:6),'callback',@um_call)  % The callback for 5 uimenus.
% This next one will select from a wider palette.
S.um(7) = uimenu(S.um(1),'label','Other','callback',{@um7_call});
% Now we create a menu for the figure itself.
S.fm = uimenu(S.fh,'label','Save As');
S.fm(2) = uimenu(S.fm(1),'label','jpg');
S.fm(3) = uimenu(S.fm(1),'label','png');
S.fm(4) = uimenu(S.fm(1),'label','bmp');
set(S.fm(2:4),'callback',{@fm_call})  % To save the drawing.   
axis([0,1,0,1]) % This locks the axes limits to avoid auto-rescaling.
set(S.ax,'xticklabel',[],'yticklabel',[],'xtick',[],'ytick',[])  % Neaten.
% Set the uicontextmenu to point to the axes.
set(S.ax, 'buttondownfcn',@ax_bdfcn,'uicontextmenu',S.cm) 
hold on, box on  % So that we don't overwrite with each new point drawn.
set(S.fh,'windowbuttonupfcn', @fh_wbufcn);

    function [] = ax_bdfcn(varargin)
    % ButtonDownFcn for the axes.
        % We only want to do something if left clicking.
        if strcmp(get(S.fh,'selectiontype'),'normal')
            % We want to plot dots as long as user holds down mouse button.
            set(S.fh, 'windowbuttonmotionfcn', @fh_wbmfcn)
        end

    end

    function [] = fh_wbmfcn(varargin)
    % The windowbuttonmotionfcn for figure, while button is held only.
        pt = get(S.ax, 'currentpoint');
        plot(pt(1),pt(3),'.','buttondownfcn',@ax_bdfcn,'color',S.COL);
    end

    function [] = fh_wbufcn(varargin)
    % WindowButtonUpFcn for the figure.
        % We want to stop drawing dots when user lets mouse button up.
        set(S.fh, 'windowbuttonmotionfcn', '');
    end

    function [] = um_call(varargin)
    % Callback for the uicontextmenu 2:6.
        S.COL = S.LST{varargin{1}==S.um};  % Set the current color.
    end

    function [] = um7_call(varargin)
    % Callback for the uicontextmenu number 7.
        c = uisetcolor();  % Call the MATLAB color-getter.
        S.COL = c;  % Set the current color.
    end

    function [] = fm_call(varargin)
    % Callback for the figure menu.
        N = inputdlg('Enter a file name.','FileName'); % Get a name.
        F = getframe(S.fh,get(S.ax,'position')+[1 1 -2 -2]);  % Only want to get axes.
        FMT = S.FMT{varargin{1}==S.fm};  % User's format choice.
        imwrite(F.cdata,[N{1},'.',FMT],FMT)  % Write the image.
    end
end



