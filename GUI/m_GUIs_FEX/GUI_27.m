function [] = GUI_27()
% Demonstrate how to display the current location of the mouse in an axes.
% Run the GUI then move the cursor over the axes.  The current location of 
% the pointer in the axes will be displayed at the top of the plot, in axes
% units. 
%
% Suggested exercise: Make this function to take an axes handle as an
% input argument, automatically detect the xlim and ylim, and show the
% pointer location in the title.  Even more advanced:  Detect when
% the axes already has a title.  In that case don't overwrite the title, 
% but launch another small GUI which displays the pointer location.
%
%
% Author:  Matt Fig
% Date:  7/15/2009

S.fh = figure('units','pixels',...
              'position',[560 528 560 420],...
              'menubar','none',...
              'name','GUI_27',...
              'numbertitle','off',...
              'resize','off');
% Now make a simple plot.
x = 0:.1:2*pi;
plot(x,sin(x))
S.ax = gca;
set(S.ax,'unit','pix','position',[40 40 480 340]);
axis([0 7 -1 1])
% Fill the structure with data.
S.XLM = get(S.ax,'xlim');
S.YLM = get(S.ax,'ylim');
S.AXP = get(S.ax,'pos');
S.DFX = diff(S.XLM);
S.DFY = diff(S.YLM);
S.tx(1) = uicontrol('style','tex',...
                    'unit','pix',...
                    'posit',[50 390 250 20],...
                    'backg',get(S.fh,'color'),...
                    'fontsize',14,'fontweight','bold',... 
                    'string','Current Pointer Location:');
% This textbox will display the current position of the mouse.
S.tx(2) = uicontrol('style','tex',...
                    'unit','pix',...
                    'position',[310 390 120 20],...
                    'backg',get(S.fh,'color'),...
                    'fontsize',14,'fontweight','bold' );
            
set(S.fh,'windowbuttonmotionfcn',{@fh_wbmfcn,S}) % Set the motion detector.

function [] = fh_wbmfcn(varargin)
% WindowButtonMotionFcn for the figure.
S = varargin{3};  % Get the structure.
F = get(S.fh,'currentpoint');  % The current point w.r.t the figure.
% Figure out of the current point is over the axes or not -> logicals.
tf1 = S.AXP(1) <= F(1) && F(1) <= S.AXP(1) + S.AXP(3);
tf2 = S.AXP(2) <= F(2) && F(2) <= S.AXP(2) + S.AXP(4);

if tf1 && tf2
    % Calculate the current point w.r.t. the axes.
    Cx =  S.XLM(1) + (F(1)-S.AXP(1)).*(S.DFX/S.AXP(3));
    Cy =  S.YLM(1) + (F(2)-S.AXP(2)).*(S.DFY/S.AXP(4));
    set(S.tx(2),'str',num2str([Cx,Cy],2))
end


