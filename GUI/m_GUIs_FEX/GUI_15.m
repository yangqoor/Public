function [] = GUI_15()
% Demonstrate an edit text which has copyable but unchangeable text.
% Also creates a pushbutton which will print the contents of the
% editbox to the command line.
%
% Suggested exercise:  Notice that the text can be cut (as well as copied).
% Alter the keypressfcn to eliminate this.
%
% Author:  Matt Fig
% Date:  7/15/2009

S.fh = figure('units','pixels',...
              'position',[300 300 400 120],...
              'menubar','none',...
              'name','GUI_15',...
              'numbertitle','off',...
              'resize','off');
S.ed = uicontrol('style','edit',...
                 'unit','pix',...
                 'position',[30 70 340 30],...
                 'string','This text can be copied but not changed');
S.pb = uicontrol('style','push',...
                 'unit','pix',...
                 'position',[30 30 340 30],...
                 'string','Print to screen');           
set([S.ed,S.pb],{'callback'},{{@ed_call,S};{@pb_call,S}}) % Set callbacks.       
set(S.ed,'keypressfcn',{@ed_kpfcn,S})  % set keypressfcn.

function [] = pb_call(varargin)
% callback for pushbutton
S = varargin{3};  % Get the structure.
disp(get(S.ed,'string'))  % Print to the command line.


function [] = ed_call(varargin)
% Callback for edit
S = varargin{3};  % Get the structure.
set (S.ed,'string','This text can be copied but not changed');


function [] = ed_kpfcn(varargin)
% Keypressfcn for edit
[K,S] = varargin{[2 3]};

if isempty(K.Modifier)
        uicontrol(S.pb)
        set (S.ed,'string','This text can be copied but not changed');  
elseif ~strcmp(K.Key,'c') && ~strcmp(K.Modifier{1},'control')
        uicontrol(S.pb)
        set (S.ed,'string','This text can be copied but not changed');
end

