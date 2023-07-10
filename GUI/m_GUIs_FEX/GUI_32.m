function [] = GUI_32(str)
% Demonstrate how to get data from a GUI into the base workspace without
% "poofing" unawares.  This is based on GUI_31.  When called with a string
% argument, all of the operations performed by the user will be recorded 
% and returned to the base workspace in a variable of the name given by the
% string.  This happens when the GUI is closed.  If no string argument is
% used, the data is not created in the base workspace.
% 
%  Example:
%          
%           GUI_32('Myops') % Call this then perform a few operations.
%           % After closing the GUI, call:
%           Myops  % at the command line displays a record of operations.
%
% Suggested exercise:  Alter the code so that the variable in the base
% workspace is created upon GUI initialization.  Then update the data after
% every new operation.
%
%
% Author:  Matt Fig
% Date:  7/15/2009

if nargin==0
    str = [];  % User called the GUI without and output name.  
elseif ~ischar(str)
    error('Only a string argument is valid.  See help.')
elseif ~isvarname(str) % User passed something like:  0.?6#
    error('String must be a valid variable name.  See help.')
end

S.STR = str;  % The name of the variable the user wishes to have in base.
S.CNT = 0;  % The number of times user pressed the pushbutton.
S.CHC = [];  % Holds the strings which represent the operations performed.
S.fh = figure('units','pixels',...
              'position',[400 400 300 130],...
              'menubar','none',...
              'name','GUI_32',...
              'numbertitle','off',...
              'resize','off',...
              'deletefcn',{@fig_del,S});
COL = get(S.fh,'color');          
S.pp = uicontrol('style','pop',...
                  'unit','pix',...
                  'position',[10 20 120 30],...
                  'string',{'Add';'Multiply';'Subtract';'Divide';'Power'});
S.ed(1) = uicontrol('style','edit',...
                    'unit','pix',...
                    'position',[10 90 70 30],...
                    'string','3');
S.tx(1) = uicontrol('style','text',...
                    'unit','pix',...
                    'position',[85 90 20 30],...
                    'string','+',...
                    'fontsize',16,...
                    'backgroundcolor',COL);                  
S.ed(2) = uicontrol('style','edit',...
                    'unit','pix',...
                    'position',[110 90 70 30],...
                    'string','2');  
S.tx(2) = uicontrol('style','text',...
                    'unit','pix',...
                    'position',[185 90 20 30],...
                    'string','=',...
                    'fontsize',16,...
                    'backgroundcolor',COL);                 
S.ed(3) = uicontrol('style','edit',...
                    'unit','pix',...
                    'position',[220 90 70 30],...
                    'string','answer');
S.pb = uicontrol('style','push',...
                  'unit','pix',...
                  'position',[160 20 120 30],...
                  'string','Calculate');
set([S.pp,S.pb],'callback',{@pb_call,S});               


function [] = pb_call(varargin)
% Callback for pushbutton
S = varargin{3};  % Get the structure.
N = str2double(get(S.ed(1:2),'string'));  % Numbers from edits to op. on.
VL = get(S.pp,{'str','value'});  % User's choice from popup.

% Now get the string updates and perform operations.
switch VL{1}{VL{2}}  % User's string choice.
    case 'Add'
        A = sum(N);
        str = '+';
    case 'Multiply'
        A = prod(N);
        str = 'x';
    case 'Subtract'
        A = -diff(N);
        str = '-';
    case 'Divide'
        A = N(1)/N(2);
        str = '/';
    case 'Power'
        A = N(1).^N(2);
        str = '^';
    otherwise
end

set(S.tx(1),'string',str)  % Set the operation display.

if varargin{1}==S.pb  % This stuff we only need to do if button is pushed.
    S.CNT = S.CNT + 1;
    set(S.ed(3),'str',A)
    S.CHC{S.CNT,1} = sprintf('%2.2f %s %2.2f %s %2.2f',N(1),str,N(2),'=',A);
    set(S.pb,'callback',{@pb_call,S})
    set(S.fh,'deletefcn',{@fig_del,S})
end


function [] = fig_del(varargin)
S = varargin{3};
if ~isempty(S.STR)
    assignin('base',S.STR,S.CHC) % Assign the data to the base workspace.
end



