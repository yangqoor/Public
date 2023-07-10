function varargout = GUIRestore(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUIRestore_OpeningFcn, ...
                   'gui_OutputFcn',  @GUIRestore_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GUIRestore is made visible.
function GUIRestore_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUIRestore (see VARARGIN)

% Choose default command line output for GUIRestore
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Hiding the axis
set(handles.axisdegradedimg, 'Visible', 'off');
set(handles.axisrestoredimg, 'Visible', 'off');
set(handles.FileSave, 'Enable', 'off');

%Setting the Filter->Restore menu item
set(handles.FilterRestore, 'Checked', 'on');

%Setting the Algorithm
settingAlgo(handles, evalin('base', 'algo'));

%Initialising global variable to 0 to signify that GUI is freshly opened
global comein; comein = 0;

%Setting the close function
set(gcf, 'CloseRequestFcn', 'my_closereq');

% UIWAIT makes GUIRestore wait for user response (see UIRESUME)
% uiwait(handles.GUIRestore);


% --- Outputs from this function are returned to the command line.
function varargout = GUIRestore_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% -------------------Start of GUIRestore ----------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ----------------------
function FileOpen_Callback(hObject, eventdata, handles)
% hObject    handle to FileOpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.lblstatus, 'Foregroundcolor', 'Red');
set(handles.lblstatus, 'String', 'Status: Busy');
set(gcf,'pointer','watch');
global comein;

[filename, pathname] = uigetfile('*.bmp;*.jpg;*.tif;', 'Open input image');

if filename ~= 0
    %Displaying the degraded image
    file = [pathname filename];
    degradedimg = imread(file);

    %Converting to double
    degradedimg = im2double(degradedimg);

    %Converting the image to grayshade
    if size(degradedimg, 3) == 3,
        degradedimg = rgb2gray(degradedimg);
    end

    %Setting axisdegradedimg as the current axis
    axes(handles.axisdegradedimg);
    imshow(real(degradedimg));
    
    %Storing the image in the base workspace
    assignin('base','degradedimg',degradedimg);
    
    %Setting start to 1 signifying that image is opened
    assignin('base', 'resimstatus', 1);

    %Initialising comein to 1 to signify that image is opened
    comein = 1;

    %Hiding the frame
    set(handles.frmdegradedimg, 'Visible', 'off');

    %Enabling the crop menu item
    %set(handles.EditCrop, 'Enable', 'on');

    pbestimatesnr_Callback(hObject, eventdata, handles);
end
set(gcf,'pointer','arrow');
set(handles.lblstatus, 'String', 'Status: Ready', 'Foregroundcolor', 'Black');


% ----------------------
function FileSave_Callback(hObject, eventdata, handles)
% hObject    handle to FileSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.lblstatus, 'Foregroundcolor', 'Red');
set(handles.lblstatus, 'String', 'Status: Busy');
set(gcf,'pointer','watch');

restoredimg = evalin('base', 'restoredimg');
[filename, pathname] = uiputfile('*.bmp', 'Save image');

if filename ~= 0
    file = [pathname, filename, '.bmp'];

    %Saving the degraded image
    imwrite(restoredimg, file, 'bmp');
end
set(gcf,'pointer','arrow');
set(handles.lblstatus, 'String', 'Status: Ready', 'Foregroundcolor', 'Black');


% ----------------------
function FileExit_Callback(hObject, eventdata, handles)
% hObject    handle to FileExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;

% ----------------------
function Filter_Callback(hObject, eventdata, handles)
% hObject    handle to Filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% ----------------------
function FilterDegrade_Callback(hObject, eventdata, handles)
% hObject    handle to FilterDegrade (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Closing the Restore GUI & Opening the Degrade GUI
delete(gcf);
GUIDegrade;


% ----------------------
function FilterRestore_Callback(hObject, eventdata, handles)
% hObject    handle to FilterRestore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% ----------------------
function RestoreInverse_Callback(hObject, eventdata, handles)
% hObject    handle to RestoreInverse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.lblstatus, 'Foregroundcolor', 'Red');
set(handles.lblstatus, 'String', 'Status: Busy');
set(gcf,'pointer','watch');
assignin('base', 'algo', 1);
settingAlgo(handles, 1);
set(gcf,'pointer','arrow');
set(handles.lblstatus, 'String', 'Status: Ready', 'Foregroundcolor', 'Black');


% ----------------------
function RestoreWiener_Callback(hObject, eventdata, handles)
% hObject    handle to RestoreWiener (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.lblstatus, 'Foregroundcolor', 'Red');
set(handles.lblstatus, 'String', 'Status: Busy');
set(gcf,'pointer','watch');
assignin('base', 'algo', 2);
settingAlgo(handles, 2);
set(gcf,'pointer','arrow');
set(handles.lblstatus, 'String', 'Status: Ready', 'Foregroundcolor', 'Black');


% ----------------------
function RestoreLucyRichardson_Callback(hObject, eventdata, handles)
% hObject    handle to RestoreLucyRichardson (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.lblstatus, 'Foregroundcolor', 'Red');
set(handles.lblstatus, 'String', 'Status: Busy');
set(gcf,'pointer','watch');
assignin('base', 'algo', 3);
settingAlgo(handles, 3);
set(gcf,'pointer','arrow');
set(handles.lblstatus, 'String', 'Status: Ready', 'Foregroundcolor', 'Black');


% ----------------------
function RestoreCompare_Callback(hObject, eventdata, handles)
% hObject    handle to RestoreCompare (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Closing the Restore GUI & Opening the Compare GUI
delete(gcf);
GUICompare;

function settingAlgo(handles, algo)
%This function sets the menu and the GUI for the respective algorithm

%Reset all the menu items
set(handles.RestoreInverse, 'Checked', 'off');
set(handles.RestoreWiener, 'Checked', 'off');
set(handles.RestoreLucyRichardson, 'Checked', 'off');

%Disabling the GUI Components
set(handles.slditerations, 'Enable', 'off');
set(handles.txtiterations, 'Enable', 'off');
set(handles.sldsnr, 'Enable', 'off');
set(handles.txtsnr, 'Enable', 'off');
set(handles.pbestimatesnr, 'Enable', 'off');

%Setting the menu item & gui properties
switch algo
    case 1
        set(handles.RestoreInverse, 'Checked', 'on');
        set(handles.lbltitle, 'String', 'Inverse Filter');
    case 2
        set(handles.RestoreWiener, 'Checked', 'on');
        set(handles.lbltitle, 'String', 'Wiener Filter');
        set(handles.sldsnr, 'Enable', 'on');
        set(handles.txtsnr, 'Enable', 'on');
        set(handles.pbestimatesnr, 'Enable', 'on');
    case 3
        set(handles.slditerations, 'Enable', 'on');
        set(handles.txtiterations, 'Enable', 'on');
        set(handles.RestoreLucyRichardson, 'Checked', 'on');
        set(handles.lbltitle, 'String', 'Lucy-Richardson');
end


% --- Executes during object creation, after setting all properties.
function sldlength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldlength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function sldlength_Callback(hObject, eventdata, handles)
% hObject    handle to sldlength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
str = sprintf('%.0f', get(handles.sldlength, 'Value'));
set(handles.txtlength, 'String', str);


% --- Executes during object creation, after setting all properties.
function sldtheta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldtheta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function sldtheta_Callback(hObject, eventdata, handles)
% hObject    handle to sldtheta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
str = sprintf('%.0f', get(handles.sldtheta, 'Value'));
set(handles.txttheta, 'String', str);


% --- Executes during object creation, after setting all properties.
function txtlength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtlength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function txtlength_Callback(hObject, eventdata, handles)
% hObject    handle to txtlength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtlength as text
%        str2double(get(hObject,'String')) returns contents of txtlength as a double
str = str2num(get(handles.txtlength,'String'));
if str<1 || str>100
    uiwait(errordlg('Please enter blur length in the range 1 to 100.', 'Invalid Length', 'modal'));
    
    %Resetting length
    str = sprintf('%.0f', get(handles.sldlength, 'Value'));
    set(handles.txtlength, 'String', str);
else
    set(handles.sldlength,'Value', str);
end


% --- Executes during object creation, after setting all properties.
function txttheta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txttheta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function txttheta_Callback(hObject, eventdata, handles)
% hObject    handle to txttheta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txttheta as text
%        str2double(get(hObject,'String')) returns contents of txttheta as a double
str = str2num(get(handles.txttheta,'String'));
if str<0 || str>180
    uiwait(errordlg('Please enter blur angle in the range 0 to 180.', 'Invalid Theta', 'modal'));
    
    %Resetting theta
    str = sprintf('%.0f', get(handles.sldtheta, 'Value'));
    set(handles.txttheta, 'String', str);
else
    set(handles.sldtheta,'Value', str);
end


% --- Executes on button press in angleexpert.
function angleexpert_Callback(hObject, eventdata, handles)
% hObject    handle to angleexpert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of angleexpert


% --- Executes on button press in lengthexpert.
function lengthexpert_Callback(hObject, eventdata, handles)
% hObject    handle to lengthexpert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of lengthexpert


function setAngle(hObject, eventdata, handles, THETA)
%This function sets the value of theta on GUI
global anglecount noofest;
if THETA<0 || THETA>180
    msg = ['The estimated blur angle value is invalid. '...
           'Please select a value manually.'];
    uiwait(errordlg(msg, 'Error', 'modal'));
    THETA = 0;
else
    set(handles.sldtheta, 'Value', THETA);
    set(handles.txttheta, 'String', THETA);
end
anglenexttip = [num2str(noofest-anglecount) ' estimates remaining...'];
set(handles.pbanglenext, 'Tooltipstring', anglenexttip);

%Disable the next angle estimate button once all the values are over
if noofest-anglecount <= 0
    set(handles.pbanglenext, 'Enable', 'off');
end


% --- Executes on button press in pbestimateangle.
function pbestimateangle_Callback(hObject, eventdata, handles)
% hObject    handle to pbestimateangle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.lblstatus, 'Foregroundcolor', 'Red');
set(handles.lblstatus, 'String', 'Status: Busy');
set(gcf,'pointer','watch');
global comein;
global anglecount THETAarr noofest;
noofest = size(THETAarr, 2);
anglecount = 0;

%Enter only if image is opened first
if evalin('base', 'resimstatus') >= 1 & comein >= 1
    %Reading the degraded image from the base workspace
    degradedimg = evalin('base', 'degradedimg');
    expertstatus = get(handles.angleexpert, 'Value');

    %Enabling the Next Button for angle
    set(handles.pbanglenext, 'Enable', 'on');

    %Start the waitbar
    handle = waitbar(0,'Please wait...');

    %Estimating blur angle
    [THETAarr] = EstAngle(degradedimg, expertstatus, handle);

    %Close the waitbar
    close(handle);

    anglecount = anglecount + 1;
    setAngle(hObject, eventdata, handles, THETAarr(anglecount));
else
    uiwait(errordlg('Please open a file first.', 'Error', 'modal'));
end
set(handles.GUIRestore,'pointer','arrow');
set(handles.lblstatus, 'String', 'Status: Ready', 'Foregroundcolor', 'Black');


% --- Executes on button press in pbanglenext.
function pbanglenext_Callback(hObject, eventdata, handles)
% hObject    handle to pbanglenext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global anglecount THETAarr;
anglecount = anglecount + 1;
setAngle(hObject, eventdata, handles, THETAarr(anglecount));


% --- Executes on button press in pbestimatelen.
function pbestimatelen_Callback(hObject, eventdata, handles)
% hObject    handle to pbestimatelen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.lblstatus, 'Foregroundcolor', 'Red');
set(handles.lblstatus, 'String', 'Status: Busy');
set(gcf,'pointer','watch');
global comein;

%Enter only if image is opened first
if evalin('base', 'resimstatus') >= 1 & comein >= 1
    %Reading the degraded image from the base workspace
    degradedimg = evalin('base', 'degradedimg');
    THETA = str2num(get(handles.txttheta, 'String'));
    expertstatus = get(handles.lengthexpert, 'Value');

    %Start the waitbar
    handle = waitbar(0,'Please wait...');

    %Estimating blur length
    LEN = EstLen(degradedimg, THETA, expertstatus, handle);

    %Close the waitbar
    close(handle);

    if LEN<1 || LEN>100
        msg = ['The estimated blur length value is invalid. '...
                'Please select a value manually.'];
        uiwait(errordlg(msg, 'Error', 'modal'));
    else
        set(handles.sldlength, 'Value', LEN);
        set(handles.txtlength, 'String', LEN);
    end
else
    uiwait(errordlg('Please open a file first.', 'Error', 'modal'));
end
set(handles.GUIRestore,'pointer','arrow');
set(handles.lblstatus, 'String', 'Status: Ready', 'Foregroundcolor', 'Black');


% --- Executes during object creation, after setting all properties.
function slditerations_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slditerations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function slditerations_Callback(hObject, eventdata, handles)
% hObject    handle to slditerations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
str = sprintf('%.0f', get(handles.slditerations, 'Value'));
set(handles.txtiterations, 'String', str);


% --- Executes during object creation, after setting all properties.
function txtiterations_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtiterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function txtiterations_Callback(hObject, eventdata, handles)
% hObject    handle to txtiterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtiterations as text
%        str2double(get(hObject,'String')) returns contents of txtiterations as a double
str = str2num(get(handles.txtiterations,'String'));
if str<1 || str>1000
    uiwait(errordlg('Please enter no. of iterations in the range 1 to 1000', 'Invalid Iterations', 'modal'));

    %Resetting iterations
    str = sprintf('%.0f', get(handles.slditerations, 'Value'));
    set(handles.txtiterations, 'String', str);
else
    set(handles.slditerations,'Value', str);
end


% --- Executes during object creation, after setting all properties.
function sldsnr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldsnr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function sldsnr_Callback(hObject, eventdata, handles)
% hObject    handle to sldsnr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
str = sprintf('%.4f', get(handles.sldsnr, 'Value'));
set(handles.txtsnr, 'String', str);


% --- Executes during object creation, after setting all properties.
function txtsnr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtsnr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function txtsnr_Callback(hObject, eventdata, handles)
% hObject    handle to txtsnr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtsnr as text
%        str2double(get(hObject,'String')) returns contents of txtsnr as a double
str = str2num(get(handles.txtsnr,'String'));
if str<0.0001 || str>1
    uiwait(errordlg('Please enter Signal to Noise Ratio (SNR) in the range 0.0001 to 1', 'Invalid SNR', 'modal'));

    %Resetting iterations
    str = sprintf('%.4f', get(handles.sldsnr, 'Value'));
    set(handles.txtsnr, 'String', str);
else
    set(handles.sldsnr,'Value', str);
end


% --- Executes on button press in pbestimatesnr.
function pbestimatesnr_Callback(hObject, eventdata, handles)
% hObject    handle to pbestimatesnr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.lblstatus, 'Foregroundcolor', 'Red');
set(handles.lblstatus, 'String', 'Status: Busy');
set(gcf,'pointer','watch');
global comein;

%Enter only if image is opened first
if evalin('base', 'resimstatus') >= 1 & comein >= 1
    degradedimg = evalin('base', 'degradedimg');
    R = str2num(sprintf('%.4f', 1/size(degradedimg, 2)));
    set(handles.txtsnr, 'String', R);
    set(handles.sldsnr, 'Value', R);
else
    uiwait(errordlg('Please open a file first.', 'Error', 'modal'));
end
set(gcf,'pointer','arrow');
set(handles.lblstatus, 'String', 'Status: Ready', 'Foregroundcolor', 'Black');


% --- Executes on button press in pbrestoreimg.
function pbrestoreimg_Callback(hObject, eventdata, handles)
% hObject    handle to pbrestoreimg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.lblstatus, 'Foregroundcolor', 'Red');
set(handles.lblstatus, 'String', 'Status: Busy');
set(gcf,'pointer','watch');
global comein zoompoint;

%Enter only if image is opened first
if evalin('base', 'resimstatus') >= 1 & comein >= 1
    %Reading the degraded image from the base workspace
    degradedimg = evalin('base', 'degradedimg');
    LEN         = str2num(get(handles.txtlength, 'String'));
    THETA       = str2num(get(handles.txttheta, 'String'));

    %Start the waitbar
    handle = waitbar(0,'Please wait...');
    switch evalin('base', 'algo')
        case 1 %Inverse filter
            restoredimg = Inverse(degradedimg, LEN, THETA, handle);
        case 2 %Wiener filter
            SNR = get(handles.sldsnr, 'Value');
            restoredimg = Wiener(degradedimg, LEN, THETA, SNR, handle);
        case 3 %Lucy-Richardson
            iterations = round(get(handles.slditerations, 'Value'));
            restoredimg = Lucy(degradedimg, LEN, THETA, iterations, handle);
    end

    %Close the waitbar
    close(handle);

    %Make the axisrestoredimg the current axes
    axes(handles.axisrestoredimg);
    imshow(real(restoredimg));

    %Storing the degraded image in the base workspace
    assignin('base','restoredimg',restoredimg);

    %Setting resimstatus to 2 signifying image can be saved now
    assignin('base', 'resimstatus', 2); comein = 2;

    %Hiding the frame
    set(handles.frmrestoredimg, 'Visible', 'off');

 
    %Enabling the File->LoadRestored & Save
    set(handles.FileSave, 'Enable', 'on');
    %set(handles.FileLoadRestored, 'Enable', 'on');
else
    uiwait(errordlg('Please open a file first.', 'Error', 'modal'));
end
set(gcf,'pointer','arrow');
set(handles.lblstatus, 'String', 'Status: Ready', 'Foregroundcolor', 'Black');
