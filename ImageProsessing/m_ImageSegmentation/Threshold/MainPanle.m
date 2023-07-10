function varargout = MainPanle(varargin)
% MAINPANLE M-file for MainPanle.fig
%      MAINPANLE, by itself, creates a new MAINPANLE or raises the existing
%      singleton*.
%
%      H = MAINPANLE returns the handle to a new MAINPANLE or the handle to
%      the existing singleton*.
%
%      MAINPANLE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINPANLE.M with the given input arguments.
%
%      MAINPANLE('Property','Value',...) creates a new MAINPANLE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MainPanle_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MainPanle_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MainPanle


% Global variable
global Img_Data         %Source image data
global Img_Map          %Source image map
global Img_Hist
global Img_Threshold    %ͼ��ָ���ֵ

% Last Modified by GUIDE v2.5 26-Apr-2005 08:29:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MainPanle_OpeningFcn, ...
                   'gui_OutputFcn',  @MainPanle_OutputFcn, ...
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


% --- Executes just before MainPanle is made visible.
function MainPanle_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MainPanle (see VARARGIN)

% Choose default command line output for MainPanle
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MainPanle wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MainPanle_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function cboSrcImage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cboSrcImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in cboSrcImage.
function cboSrcImage_Callback(hObject, eventdata, handles)
% hObject    handle to cboSrcImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns cboSrcImage contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cboSrcImage
	handles=guihandles;
    switch(get(hObject,'Value'))
        case 1
            [Img_Data,Img_Map]=imread('woman.bmp');
        case 2
            [Img_Data,Img_Map]=imread('tire.bmp');
        case 3
            [Img_Data,Img_Map]=imread('��.bmp');
        case 4
            [Img_Data,Img_Map]=imread('.\images\woman.bmp');
	end
    
    Img_Hist=imhist(Img_Data,Img_Map);
    
    img=image(Img_Data);
    colormap(handles.axes_Image,Img_Map);
    set(img,'Parent',handles.axes_Image);
    set(Img_Hist,'Parent',handles.axes_Hist);
    %imhist(Img_Data,Img_Map);

% --- Executes during object creation, after setting all properties.
function cboSegMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cboSegMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in cboSegMethod.
function cboSegMethod_Callback(hObject, eventdata, handles)
% hObject    handle to cboSegMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns cboSegMethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cboSegMethod
handles=guihandles;
switch(get(hObject,'Value'))
    case 1,2,3,5
        set(handles.edtSegNum,'String','2');
end

% --- Executes during object creation, after setting all properties.
function cboSegNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cboSegNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in cboSegNum.
function cboSegNum_Callback(hObject, eventdata, handles)
% hObject    handle to cboSegNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns cboSegNum contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cboSegNum


% --- Executes on button press in btnSegment.
function btnSegment_Callback(hObject, eventdata, handles)
% hObject    handle to btnSegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function edtSegNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtSegNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edtSegNum_Callback(hObject, eventdata, handles)
% hObject    handle to edtSegNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtSegNum as text
%        str2double(get(hObject,'String')) returns contents of edtSegNum as a double


