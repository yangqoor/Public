function [] = GUI_40()
% Demonstrate how to use an image as a background of a GUI.
% A GUI is created which has the clown as its background.  Also
% demonstrated are several buttons which appear to be part of the image.
%
%
% Author:  Matt Fig
% Date:  1/15/2010

S.fh = figure('units','pixels',...
              'position',[400 400 480 300],...
              'menubar','none',...
              'name','GUI_40',...              
              'resize','off',...
              'numbertitle','off'); 
S.ax = axes('units','pixels',...
            'position',[0 0 480 300],...
            'xtick',[],'ytick',[]);
X = load('clown');  % This is a built-in ML example.
S.IMG = ind2rgb(X.X,X.map);  % We want to convert it to RGB.
S.IH = image(S.IMG);  % Display the image.
S.BTP = {[10 10 60 48];[10 68 60 48];...
         [10 126 60 48];[10 184 60 48];...
         [10 242 60 48]};  % Cell array of button positions.
S.BST = {'Restore';'Gray';'Red';'Green';'Blue'};  % And labels.   
% Now what we want to do is to get a picture of the axes under the button
% and use that picture as the cdata of each button.
for ii = 1:5
    F = getframe(S.ax,S.BTP{ii});   
    S.pb(ii) = uicontrol('style','push',...
                         'units','pix',...
                         'position',S.BTP{ii},...
                         'string',S.BST{ii},...
                         'fontsize',10,...
                         'fontweight','bold');
    set(S.pb(ii),'cdata',F.cdata,...
        'foregroundc',[1 1 1])
end

set(S.pb(1),'callback',{@pb1_call}) % Set the callbacks.
set(S.pb(2),'callback',{@pb2_call})
set(S.pb(3:5),'callback',{@pb345_call})

    function [] = pb1_call(varargin)
    % Callback for the Restore button.
        set(S.IH,'cdata',S.IMG)  % This restores the original image.
        colorbal
    end

    function [] = pb2_call(varargin)
    % Callback for the Gray button.  
    % Use an average accross the pages to create a gray image.  
        set(S.IH,'cdata',repmat(mean(S.IMG,3),[1,1,3]))
        colorbal
    end

    function [] = pb345_call(varargin)
    % Callback for the Green, Red, Blue buttons.
         switch get(gcbo,'string')  % Which button called?
             case 'Red'
                 ind = 1;
             case 'Green'
                 ind = 2;
             case 'Blue'
                 ind = 3;
             otherwise
                 lasterr
                 error('An unknown error occured in the callback.')  
         end
         
         tmp = get(S.IH,'cdata'); % We don't want to go over 1.
         tmp(:,:,ind) = min(1,tmp(:,:,ind)*1.05); % Increase a little.
         set(S.IH,'cdata',tmp)
         colorbal
    end

    function [] = colorbal()
    % Makes each button's cdata equal to the image underneath.            
        for jj = 1:5
            set(S.pb(jj),'visible','off')
            F = getframe(S.ax,S.BTP{jj});
            set(S.pb(jj),'cdata',F.cdata,'visible','on')
        end
    end
end




