function varargout = GUIDegrade(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUIDegrade_OpeningFcn, ...
                   'gui_OutputFcn',  @GUIDegrade_OutputFcn, ...
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


% --- Executes just before GUIDegrade is made visible.
function GUIDegrade_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUIDegrade (see VARARGIN)

% Choose default command line output for GUIDegrade
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Hiding the axis
set(handles.axisoriginalimg, 'Visible', 'off');
set(handles.axisdegradedimg, 'Visible', 'off');

%Initialising global variable to 0 to signify that GUI is freshly opened
global comein; comein = 0;

%Setting the close function
set(gcf, 'CloseRequestFcn', 'my_closereq');

% UIWAIT makes GUIDegrade wait for user response (see UIRESUME)
% uiwait(handles.GUIDegrade);


% --- Outputs from this function are returned to the command line.
function varargout = GUIDegrade_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% -------------------Start of GUIDegrade ----------------------
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
    %Displaying the original image
    file = [pathname filename];
    originalimg = imread(file);
    
    %Converting to double
    originalimg = im2double(originalimg);

    %Converting the image to grayshade
    if size(originalimg, 3) == 3,
        originalimg = rgb2gray(originalimg);
    end

    %Setting axisoriginalimg as the current axis
    axes(handles.axisoriginalimg);
    imshow(real(originalimg));
    
    %Storing the image in the base workspace
    assignin('base','originalimg',originalimg);
    
    %Setting start to 1 signifying that image is opened
    assignin('base', 'degimstatus', 1);

    %Initialising comein to 1 to signify that image is opened
    comein = 1;

    %Hiding the frame
    set(handles.frmoriginalimg, 'Visible', 'off');
    
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

degradedimg = evalin('base', 'degradedimg');
[filename, pathname] = uiputfile('*.bmp', 'Save image');

if filename ~= 0
    file = [pathname, filename, '.bmp'];

    %Saving the degraded image
    imwrite(degradedimg, file, 'bmp');
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

%Closing the Degrade GUI & Opening the Restore GUI
assignin('base', 'algo', 1);
delete(gcf);
GUIRestore;


% ----------------------
function RestoreWiener_Callback(hObject, eventdata, handles)
% hObject    handle to RestoreWiener (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Closing the Degrade GUI & Opening the Restore GUI
assignin('base', 'algo', 2);
delete(gcf);
GUIRestore;


% ----------------------
function RestoreLucyRichardson_Callback(hObject, eventdata, handles)
% hObject    handle to RestoreLucyRichardson (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Closing the Degrade GUI & Opening the Restore GUI
assignin('base', 'algo', 3);
delete(gcf);
GUIRestore;


% ----------------------
function RestoreCompare_Callback(hObject, eventdata, handles)
% hObject    handle to RestoreCompare (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Closing the Degrade GUI & Opening the Compare GUI
delete(gcf);
GUICompare;

% ----------------------- End of GUIDegrade --------------------------

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


% --- Executes on button press in chknoise.
function chknoise_Callback(hObject, eventdata, handles)
% hObject    handle to chknoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chknoise

if get(handles.chknoise, 'Value')
    %Enabling the popup menu for noise type
    set(handles.popnoisetype, 'Enable', 'on');
    popnoisetype_Callback(hObject, eventdata, handles);
else
    %Disabling popup menu for noise type
    set(handles.popnoisetype, 'Enable', 'off');
    
    %Disabling all the sliders
    set(handles.sldnoisedensity, 'Enable', 'off');
    set(handles.sldmean, 'Enable', 'off');
    set(handles.sldvariance, 'Enable', 'off');

    %Resetting all the labels
    set(handles.lblnoisedensityval, 'String', 0);
    set(handles.lblmeanval, 'String', 0);
    set(handles.lblvarianceval, 'String', 0);
end


% --- Executes during object creation, after setting all properties.
function popnoisetype_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popnoisetype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in popnoisetype.
function popnoisetype_Callback(hObject, eventdata, handles)
% hObject    handle to popnoisetype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popnoisetype contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popnoisetype

%Disabling all the sliders
set(handles.sldnoisedensity, 'Enable', 'off');
set(handles.sldmean, 'Enable', 'off');
set(handles.sldvariance, 'Enable', 'off');

%Resetting all the labels
set(handles.lblnoisedensityval, 'String', 0);
set(handles.lblmeanval, 'String', 0);
set(handles.lblvarianceval, 'String', 0);

% 1: salt & pepper
% 2: gaussian
switch get(handles.popnoisetype, 'Value')
    case 1,
        set(handles.sldnoisedensity, 'Enable', 'on', 'Value', 0.05);
        set(handles.lblnoisedensityval, 'String', 0.05);
    case 2,
        set(handles.sldmean, 'Enable', 'on', 'Value', 0);
        set(handles.lblmeanval, 'String', 0);
        set(handles.sldvariance, 'Enable', 'on', 'Value', 0.01);
        set(handles.lblvarianceval, 'String', 0.01);
end


% --- Executes during object creation, after setting all properties.
function sldmean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldmean (see GCBO)
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
function sldmean_Callback(hObject, eventdata, handles)
% hObject    handle to sldmean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
value = sprintf('%.2f', get(handles.sldmean, 'Value'));
set(handles.lblmeanval, 'String', value);


% --- Executes during object creation, after setting all properties.
function sldvariance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldvariance (see GCBO)
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
function sldvariance_Callback(hObject, eventdata, handles)
% hObject    handle to sldvariance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
value = sprintf('%.2f', get(handles.sldvariance, 'Value'));
set(handles.lblvarianceval, 'String', value);


% --- Executes during object creation, after setting all properties.
function sldnoisedensity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldnoisedensity (see GCBO)
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
function sldnoisedensity_Callback(hObject, eventdata, handles)
% hObject    handle to sldnoisedensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
value = sprintf('%.2f', get(handles.sldnoisedensity, 'Value'));
set(handles.lblnoisedensityval, 'String', value);


% --- Executes on button press in pbdegradeimg.
function pbdegradeimg_Callback(hObject, eventdata, handles)
% hObject    handle to pbdegradeimg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.lblstatus, 'Foregroundcolor', 'Red');
set(handles.lblstatus, 'String', 'Status: Busy');
set(gcf,'pointer','watch');
global comein;

%Enter only if image is opened first
if evalin('base', 'degimstatus') >= 1 & comein >= 1
    %Reading original image from base workspace
    originalimg = evalin('base', 'originalimg');
    LEN         = str2num(get(handles.txtlength, 'String'));
    THETA       = str2num(get(handles.txttheta, 'String'));

    %If noise is checked
    if get(handles.chknoise, 'Value')
        switch get(handles.popnoisetype, 'Value')
            case 1 %salt & pepper
                d = str2num(get(handles.lblnoisedensityval, 'String'));
                degradedimg = degrade(originalimg, LEN, THETA, 'salt & pepper', d);
            case 2 %gaussian
                m = str2num(get(handles.lblmeanval, 'String'));
                v = str2num(get(handles.lblvarianceval, 'String'));
                degradedimg = degrade(originalimg, LEN, THETA, 'gaussian', m, v);
        end
    else %noise is not checked
        degradedimg = degrade(originalimg, LEN, THETA);
    end

    %Make the axisdegradedimg the current axes
    axes(handles.axisdegradedimg);
    imshow(real(degradedimg));

    %Storing the degraded image in the base workspace
    assignin('base','degradedimg',degradedimg);

    %Setting degimstatus to 2 signifying image can be saved now
    assignin('base', 'degimstatus', 2); comein = 2;

    %Hiding the frame
    set(handles.frmdegradedimg, 'Visible', 'off');

    %Enabling the File->LoadDegraded & Save
    set(handles.FileSave, 'Enable', 'on');

else
    uiwait(errordlg('Please open a file first.', 'Error', 'modal'));
end
set(gcf,'pointer','arrow');
set(handles.lblstatus, 'String', 'Status: Ready', 'Foregroundcolor', 'Black');
