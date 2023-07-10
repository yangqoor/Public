function [] = GUI_19()
% Demonstrate how to keep track of the number of times an action is taken 
% and the number of arguments passed.  Here pressing both buttons
% calls the same function (pb2_call), but pushing button one calls pb2_call
% from it's own callback.  Thus the number of arguments received in
% pb2_call is different depending on how it is called.  Pushing either
% button prints to the command window both the total number of button
% pushes and the number of input arguments used in the latest call.
%
%
% Author:  Matt Fig
% Date:  7/15/2009

S.CNT = 0;  % This keeps track of how many times the buttons are pushed.
S.fh = figure('units','pixels',...
              'position',[500 500 200 50],...
              'menubar','none',...
              'numbertitle','off',...
              'name','GUI_19',...
              'resize','off');
S.pb(1) = uicontrol('style','push',...
                    'units','pixels',...
                    'position',[10 10 85 30],...
                    'fontsize',14,...
                    'string','PUSH_1');
S.pb(2) = uicontrol('style','push',...
                    'units','pixels',...
                    'position',[105 10 85 30],...
                    'fonts',14,...
                    'str','PUSH_2');
set(S.pb(:),{'callback'},{{@pb1_call,S};{@pb2_call,S}})  % Set callbacks.

           
function [] = pb1_call(varargin)
% Callback for the button labeled PUSH_1.
[h,S] = varargin{[1,3]}; % Extract the calling handle and structure.
pb2_call(h,S) % call the other button's callback.


function [] = pb2_call(varargin)
% Callback for PUSH_2, and the function that pb1_call calls.
N = numel(varargin);
Ns = num2str(N-1);  % String representation used with fprintf
S = varargin{N};  % Extract the structure.
S.CNT = S.CNT + 1;  % The call counter.
fprintf('\t\t%s%i\n','Call number: ',S.CNT)
fprintf('\t\t%s%i%s\n',['PUSH_',Ns,' called me with : '],N,' arguments.')
% Now we need to make sure that the new value of CNT is available.
set(S.pb(:),{'callback'},{{@pb1_call,S};{@pb2_call,S}}) 