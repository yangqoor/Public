function [] = GUI_26()
% Demonstrate how to make the choices in several popups mutually exclusive.
% Here we want three popups, with which the user can make three different
% choices from the same set of choices.  We want the users choices to be
% made in any order.  Once a certain value has been chosen through a popup,
% that value should disappear from the lists for the other popups.  The
% user is allowed to change past choices, and popup lists will reflect
% this.
%
%
% Author:  Matt Fig
% Date:  7/15/2009

S.fh = figure('unit','pix',...
              'position',[400 400 300 120],...
              'menub','no',...
              'name','GUI_26',...
              'numbertitle','off',...
              'resize','off');
S.STR = {'alfa ';'beta';'gamma';'delta';'omega'};  % String for popups.
S.pp(1) = uicontrol('style','pop',...
                    'unit','pix',...
                    'position',[20 70 70 30],...
                    'string',S.STR);
S.pp(2) = uicontrol('style','pop',...
                    'unit','pix',...
                    'position',[110 70 70 30],...
                    'string',S.STR,...
                    'value',2);
S.pp(3) = uicontrol('style','pop',...
                    'unit','pix',...
                    'position',[210 70 70 30],...
                   'string',S.STR,...
                   'value',3);
S.pb = uicontrol('style','push',...
                 'unit','pix',...
                 'posit',[20 20 260 30],...
                 'string','Print Choices',...
                 'callback',{@pb_call,S});
S.CHC = [0 0 0]; % To keep track of when a choice has been made.            
set(S.pp(:),'call',{@pp_call,S});  % All popups have the same callback.




function [] = pb_call(varargin)
% Callback for pushbutton, prints out the users choices.
S = varargin{3};  % Get the structure.
CHC = get(S.pp(:),{'string','value'});
fprintf('\n\t%s','Your choices are: ');

for ii = 1:3
    fprintf(' %s,',deblank(CHC{ii,1}{CHC{ii,2}}))
end

fprintf('\b\n\n')



function [] = pp_call(varargin)
% Callback for popups.
[h,S] = varargin{[1,3]}; % Handle to cbo and structure.
N = ~ismember(S.pp,h); % The other 2 popup menus.
tmp = 1:3;  % Instead of calling find twice, or setdiff, see next 2 lines.
idx = tmp(~N); % The index to the current popup menu.
idxo = tmp(N);  % The indices into the other pops
S.CHC(idx) = 1;  % Let the subsequent calls know this choice has been made.
CHC = get(h,{'string','value'});  % String and value of h.
CHC = CHC{1}{CHC{2}};
ho = S.pp(N);  % Handles to the other two popups.
I = [1,2];  % Used in loop below.

for ii = I
    s = get(ho(ii),{'string','value'}); % Get the iith other pop str,val.
    s = s{1}{s{2}};  % The current string for the iith pop.
    tmp = I(I~=ii);  % Used to see if the other pop has made its choice.
    Str = S.STR;  % Get the master string.
    Str(strmatch(CHC,Str)) = [];  % Set this choice to null in master string.
    nm = get(ho(tmp),{'string','value'}); % Get the other pop's info.
    
    if S.CHC(idxo(tmp)) % The other-other pop has made a choice.
        Str(strmatch(nm{1}{nm{2}},Str)) = [];  % Set this choice to null.
    end
    
    if strcmp(s,CHC)  % The iith pop had same as new h, move it.
        for jj = 1:length(Str)
            if ~strcmp(Str{jj},CHC)&&~strcmp(Str{jj},nm{1}{nm{2}})
                nm = strmatch(Str{jj},Str);
                break  
            end
        end
    else
        nm = strmatch(s,Str); % Get the value for the iith pop.
    end
    
    set(ho(ii),'string',Str,'value',nm,'callb',{@pp_call,S}) % Assignments.
end
