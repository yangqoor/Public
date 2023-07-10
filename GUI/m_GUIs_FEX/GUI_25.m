function [] = GUI_25()
% Demonstrate how to make an image loader.
% Creates a GUI which looks for files with the extention .jpg in the
% current directory.  A listbox is populated with the names of all such
% files, and is empty if none exist in the current directory.  When the 
% pushbutton is activated, the current selection in the listbox is read 
% into a variable in the base workspace.  The name of the variable will 
% have a timestamp so as to minimize the chances of overwriting another 
% variable.  For example, say the selected image file is called Mypic.jpg  
% The base workspace variable will be Mypic_10_05_21 if the pushbutton was 
% pushed as 10:05:21 according to the system clock.
%
% Suggested exercise:  Modify the code so that the user could pass in
% the extention of the image file-type which they wished to load.  In the
% callback section, there should be some kind of check for indexed
% images, and appropriate action taken.  Further:  modify this file so that
% the user can pass in a directory name within which to search, or add a
% browse button to the GUI.
%
%
%
% Author:  Matt Fig
% Date:  7/15/2009

D = dir('*.jpg');  % or jpeg or whatever.
S.NAM = {D(:).name};  % Store the name of all items returned in D.
S.fh = figure('units','pixels',...
              'position',[450 450 400 200],...
              'menubar','none',...
              'name','Verify Password.',...
              'resize','off',...
              'numbertitle','off',...
              'name','GUI_25');

S.ls = uicontrol('style','list',...
                 'units','pix',...
                 'position',[10 60 380 120],...
                 'backgroundcolor','w',...
                 'string',S.NAM,...
                 'HorizontalAlign','left');
S.pb = uicontrol('style','push',...
                 'units','pix',...
                 'position',[10 10 380 40],...
                 'backgroundcolor','w',...
                 'HorizontalAlign','left',...
                 'string','Load Image',...
                 'fontsize',14,'fontweight','bold',...
                 'callback',{@pb_call,S});

           


function [] = pb_call(varargin)
% Callback for pushbutton.
S = varargin{3};
L = get(S.ls,{'string';'value'});  % Get the editbox string
try
    L = L{1}{L{2}};  % Give it a name for the base workspace.
    X = imread(L); % Read the image.
    % Next we will append a timestamp to the variable name so that we 
    % minimize the chances of overwriting a variable in the base 
    % workspace.  There are many other ways to handle this, so feel free to
    % experiment with alternatives.  
    str = [L(1:end-4),'_',strrep(datestr(now,'HH:MM:SS'),':','_')];
    assignin('base',str,X)  % Create the variable in the base workspace.
catch
    % Also more could be done here as far as returning what kind of error,
    % or offereing other suggestions to the user, etc.
    fprintf('\t\t%s\n','No file selected, or read error.')
end
