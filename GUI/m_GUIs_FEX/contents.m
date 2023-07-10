%%       Syntax Considerations for reading the M-Code:
% 
% All of the handles to the various objects created in each GUI, as well as 
% data needed to run the GUI, are stored in a main structure called S.  
% The fieldnames for handles are in lowercase letters, and the fieldnames 
% for data are in uppercase letters.  Callback function names are  
% designated with the fieldname of the object to which they correspond,  
% followed by '_call.'  Other function names are similarly designated.  For  
% instance, a keypressfcn will end in '_kpfcn' and a buttondownfcn will end  
% in '_bdfcn.'  The code of each GUI is generously commented, and subtle 
% points may be examined in the comments (see for example the last comment 
% block in GUI_37).  If anything seems unclear, look first in the comments, 
% and if satisfaction is not found there feel free to email me.
%
% THE CODE IN THESE FILES IS MEANT TO BE READ, NOT JUST USED! 
%
% Therefore, if there is a need for more elaboration in the comments 
% somewhere, please let me know.
%   
% Simple summaries of the GUIs are given below.  See the help for
% each individual GUI for more details.  Also see the accompanying pdf file 
% for more general comments.
%
% Author:  Matt Fig
% Contact: popkenai@yahoo.com 
%
% 
%% GUI_1  Explore simple string manipulation.  
% Pushing the pushbutton deletes the string elements of a listbox one at a 
% time.
%
%% GUI_2  Explore simple string manipulation.  
% Pushing the pushbutton adds to the string elements of a listbox.  The 
% added string can be chosen by the user through an editbox.
%
%% GUI_3  Explore visibility properties.  
% A uicontrol element is set to be visible and invisible by a checkbox.
%
%% GUI_4  Explore simple string manipulation.  
% A multi-line editbox is created, and its string is added to a listbox by
% a pushbutton.
%
%% GUI_5  Explore simple string manipulation and user notification.  
% A pushbutton deletes the text in a textbox one character at a time.
% When the string is empty, the user is notified of this fact.
%
%% GUI_6  Explore selection determination.  
% Pushing the pushbutton reveals which, if any, of the radiobuttons is 
% currently selected.
%
%% GUI_7  Explore selection determination and counting.  
% Selecting an item from the popup causes the textbox to display the number
% of times the item has been selected.
%
%% GUI_8  Explore selection determination for a buttongroup.  
% Pushing the pushbutton updates an editbox to display which radiobutton in
% the uibuttongroup is selected.
%
%% GUI_9  Explore user notification.  
% Pushing the pushbutton causes the GUI to simulate a running process and 
% let the user know this process has not finished.
%
%% GUI_10  Explore making an image visible and invisible.  
% Just setting the axes visible/invisible is not enough!
%
%% GUI_11  Explore GUI use to stop a FOR loop.  
% Pushing the pushbutton causes the FOR loop to stop.  Two different uses
% of GUIs are explored through the use of two FOR loops which the user must
% activate.
%
%% GUI_12  Explore mouse pointer manipulation. 
% Pushing the pushbutton to close the GUI proves to be very difficult.
%
%% GUI_13  Explore slider and editbox interaction.  
% An editbox is used to display and manipulate the current position of a 
% slider.
%
%% GUI_14  Explore string color control.  
% A listbox with strings of different colors is presented.  Pushing the 
% pushbutton prints the user's choice to the command window.
%
%% GUI_15  Explore simple string manipulation.  
% An editbox is presented which has text that the user can copy, but not 
% change.
%
%% GUI_16  Explore slider and editbox interaction.  
% Three editboxes are used to display and manipulate the current position, 
% minimum and maximum of a slider.
%
%% GUI_17  Explore clock and timer use in a GUI.  
% A single textbox is used to display a running clock.
%
%% GUI_18  Explore the buttondownfcn for an axes.  
% Clicking in the axes creates a random line.  Right-clicking deletes that 
% line.
%
%% GUI_19  Explore counting and argument detection. 
% Pushing either of the pushbuttons causes the total number of pushes and 
% the number of arguments passed to one of their callbacks to display.
%
%% GUI_20  Explore popup selection determination.  
% Choosing an item from the popup causes the editbox to display the choice.
%
%% GUI_21  Explore popup selection determination and manipulation.  
% Similar to GUI_20, except that the editbox is allowed to select a value
% from the popup.
%
%% GUI_22  Explore popup selection determination and manipulation.  
% Similar to GUI_21, except that the editbox is allowed to select a value
% from the popup.  The editbox may also add an item to the popup.
%
%% GUI_23  Explore multiple-figure data-passing, and the stacking order.
% An editbox is made which will add a title to a selected figure/axes.
%
%% GUI_24  Explore multiple-figure data-passing.  
% Pushing the pushbutton creates another GUI with only a single editbox.  
% Any string entered into the new editbox is placed into the first GUI.
%
%% GUI_25  Explore file selection/manipulation.  
% A GUI is made which will list all of the .jpg files in the current 
% directory.  When a file is selected, the data is loaded into the base 
% workspace.
%
%% GUI_26  Explore listbox choice restriction.  
% Three listboxes are created with the same lists.  The user is not allowed 
% to have any two listboxes show the same choice.
%
%% GUI_27  Explore pointer location detection and display.  
% An axes is created and the current location of the mouse pointer in axes 
% coordinates is displayed as a title.
%
%% GUI_28  Explore contextmenues and buttondownfcn.   
% An axes is created and clicking in the axes plots a point.  Options are 
% available by right-clicking on the axes.
%
%% GUI_29  Explore multiple figure interaction.  
% A slider is created which controls the xlim of a plot.  Closing one 
% figure closes them both.
%
%% GUI_30  Explore callback strings.  
% Same as GUI_29, only the task of controlling the xlim is accomplished
% through callback strings.
%
%% GUI_31  Explore multiple interactions among uicontrols.  
% A simple calculator is created which features several interactions
% occurring among uicontrols.
%
%% GUI_32  Explore exporting data to the base workspace.  
% Same as GUI_31, except the GUI can be called with a string argument.
% This string argument will be the name of a variable created in the base
% workspace when the GUI is closed.
%
%% GUI_33  Explore exporting data to the base workspace.  
% Same as GUI_31, except a variable will be created in the base workspace
% through a contextmenu.
%
%% GUI_34  Explore image capturing with a printscreen GUI.  
% A GUI is created which captures an image of the users desktop.
%
%% GUI_35  Explore fake tabbed panels.  
% A GUI is created with togglebuttons that acts like the tabs on panels.
%
%% GUI_36  Explore a custom dialog box.  GUI returns data to caller.  
% A GUI is created which returns a string to whatever function called it,
% or the base workspace.
%
%% GUI_37  Explore string manipulation and nested functions.  
% An editbox is created which hides the users strings as asterisks. True
% or false values are returned depending on if the user enters the correct 
% password or not.
%
%% GUI_38  Explore the user of JAVA and focussing issues.  
% A simple GUI is created which has a pushbutton.  Normally the pushbutton
% would retain focus after it has been pushed.  This would the require the 
% user to click on the figure in order that the figure's keypressfcn should
% be accessable. The figure is given focus after the button press with the 
% help of JAVA.  
%
%% GUI_39  Explore a simple drawing program and image saving.  
% A blank palette is created which allows the user to draw whatever is 
% desired.  Right-clicking provides color options.  The ability to save the 
% drawing in an image format is provided.
%
%% GUI_40  Explore setting the background of pushbuttons to match an image.  
% A GUI is created which has an image as a background.  Several buttons
% which can be used to manipulate the image blend in with the image.
%
%% GUI_41  Explore saving the state of a GUI system.  
% Three figures make up a system for the user.  The state of the system may 
% be saved and loaded. 