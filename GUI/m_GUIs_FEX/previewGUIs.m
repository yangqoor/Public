function [] = previewGUIs()
% This is a helper GUI which lets the user quickly view all of the example
% GUIs in order to find one that they need for a particular purpose.
% If the stop button is pressed, the runthrough GUI will be deleted but the
% currently visible example GUI will remain onscreen.  If the continue
% button is pressed, the current example GUI will close and the next one
% will open.
% This will skip all GUIs which call uiwait on startup.  These are:
% GUI_11,34,36,37
%
% Author:  Matt Fig
% Date:  1/15/2010


S.fh = figure('units','pixels',...
              'position',[800 500 200 50],...
              'menubar','none',...
              'numbertitle','off',...
              'name','runthrough',...
              'resize','off');
S.pb(1) = uicontrol('style','push',...
                    'units','pixels',...
                    'position',[10 10 85 30],...
                    'fontsize',14,...
                    'string','Continue');
S.pb(2) = uicontrol('style','push',...
                    'units','pixels',...
                    'position',[105 10 85 30],...
                    'fonts',14,...
                    'str','Stop');
set(S.pb(:),'callback',{@pb_call,S})  % Set callbacks.
S.TF = false;  % Flag for stopping the loop.

for ii = 1:41
    if ii == 11 || ii == 34 || ii == 36 || ii==37
        continue
    else
        STR = ['GUI_',num2str(ii)];  % You just know what is coming next.
    end
    
    eval(STR)  % Invoke the GUI.  Note that no 'poofing' is taking place.
    H = findobj(0,'name',['GUI_',num2str(ii)]); % So we can close it.
    uiwait(S.fh) % Wait for continue or stop button.
    
    if S.TF
        close(S.fh)  % Found the one we are looking for.
        return
    end
    
    close(H);  % Keep looking.
end

close(S.fh)  % Nothing was found, so stop looking.



    function [] = pb_call(varargin)
    % Callback for the buttons.
       if varargin{1}==S.pb(2)
           S.TF = true;
       end
       
       uiresume  % On to next loop iteration.
    end

end

