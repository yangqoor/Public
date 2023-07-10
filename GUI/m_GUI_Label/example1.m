function varargout = example1(varargin)
% EXAMPLE1 M-file for example1.fig
%      EXAMPLE1, by itself, creates a new EXAMPLE1 or raises the existing
%      singleton*.
%
%      H = EXAMPLE1 returns the handle to a new EXAMPLE1 or the handle to
%      the existing singleton*.
%
%      EXAMPLE1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXAMPLE1.M with the given input arguments.
%
%      EXAMPLE1('Property','Value',...) creates a new EXAMPLE1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before example1_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to example1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help example1

% Last Modified by GUIDE v2.5 30-Aug-2010 01:15:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @example1_OpeningFcn, ...
                   'gui_OutputFcn',  @example1_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before example1 is made visible.
function example1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to example1 (see VARARGIN)

% Choose default command line output for example1
handles.output = hObject;
% web -browser http://www.ilovematlab.cn/thread-100442-1-3.html
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes example1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = example1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setHvisible(handles,1,[2,3])


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setHvisible(handles,2,[1,3])


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setHvisible(handles,3,[1,2])

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcf)



% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1)
ezplot('sin(x)')


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes2)
ezplot('cos(x)')



% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes3)
ezplot('tan(x)')

function setHvisible(handles,Iyes,Ino)
%% 设置对象的的visible属性
% 将Iyes序号对应的uipanel设置为显示 对应的pushbutton的enable设置成off
% 将Ino序号对应的uipanel设置为隐藏 对应的pushbutton的enable设置成on
for i=1:length(Iyes)
    eval( ['set(handles.uipanel',num2str(Iyes(i)),',','''visible'',''on'')'])   %设置为显示
    eval( ['set(handles.pushbutton',num2str(Iyes(i)),',','''enable'',''off'')'])%按钮变灰
end
for i=1:length(Ino)
    eval( ['set(handles.uipanel',num2str(Ino(i)),',','''visible'',''off'')'])   %设置为隐藏
    eval( ['set(handles.pushbutton',num2str(Ino(i)),',','''enable'',''on'')'])  %激活按钮
end

