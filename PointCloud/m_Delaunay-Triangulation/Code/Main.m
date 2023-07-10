function varargout = Main(varargin)
% MAIN M-file for Main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Main

% Last Modified by GUIDE v2.5 21-Dec-2010 11:48:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Main_OpeningFcn, ...
                   'gui_OutputFcn',  @Main_OutputFcn, ...
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


% --- Executes just before Main is made visible.
function Main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Main (see VARARGIN)

% Choose default command line output for Main
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Main wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Main_OutputFcn(hObject, eventdata, handles) 
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
global Points
Points=[];
inputfile=uigetfile('*.txt','Choose the specific file :');
Coordinates=load(inputfile);
set(handles.uitable2,'Data',Coordinates(:,2:4));
scatter(Coordinates(:,2),Coordinates(:,3),'.')
[row col]=size(Coordinates);
Points=[Coordinates];
text(Points(:,2),Points(:,3),int2str(Points(:,1)))
set(handles.pushbutton1,'Enable','off');
set(handles.pushbutton2,'Enable','off');
set(handles.pushbutton4,'Enable','on');
set(handles.pushbutton5,'Enable','on');
% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dat = []; 
set(handles.uitable1,'Data',dat);
set(handles.uitable2,'Data',dat);
set(handles.edit2,'string','');
set(handles.edit3,'string','');
cla(handles.axes1);
set(handles.pushbutton4,'Enable','off');
set(handles.pushbutton5,'Enable','off');
set(handles.pushbutton6,'Enable','off');
set(handles.pushbutton1,'Enable','on');
set(handles.pushbutton2,'Enable','on');
clear all;clc;

function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Points DataStructure X Y
hold off
dt=DelaunayTri(Points(:,2),Points(:,3));
Table(:,2:4)=dt.Triangulation;
[row col]=size(dt.Triangulation);
Table(:,1)=1:row;
triplot(dt,'r')
hold on
cc = incenters(dt);
text(cc(:,1),cc(:,2),int2str(Table(:,1)),'color','b','fontsize',8)
hold on
x=str2double(get(handles.edit2,'string'));
y=str2double(get(handles.edit3,'string'));
Triangle=Walking_Fnc(x,y,DataStructure,Points);
if Triangle==0
     msgbox('Please insert correct coordinates!','Wrong input value','error') 
else
edge= DataStructure(Triangle,2:4);
Tr=[Points(edge(1),2) Points(edge(1),3);Points(edge(2),2) Points(edge(2),3);Points(edge(3),2) Points(edge(3),3)];
fill(Tr(:,1),Tr(:,2),'r')
text(cc(Triangle,1),cc(Triangle,2),int2str(Triangle),'color','m','fontsize',20)
end
% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Points DataStructure 
dt=DelaunayTri(Points(:,2),Points(:,3));
hold on
triplot(dt,'r')
Table(:,2:4)=dt.Triangulation;
[row col]=size(dt.Triangulation);
Table(:,1)=1:row;
DataStructure=DataStructure_Fnc(Table);
set(handles.uitable1,'Data',DataStructure(:,2:7));
cc = incenters(dt);
text(cc(:,1),cc(:,2),int2str(Table(:,1)),'color','b','fontsize',8)
set(handles.pushbutton4,'Enable','off');
set(handles.pushbutton5,'Enable','off');
set(handles.pushbutton6,'Enable','on');


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Points
dt=DelaunayTri(Points(:,2),Points(:,3));
hold off
Table(:,2:4)=dt.Triangulation;
trisurf(Table(:,2:4),Points(:,2),Points(:,3),Points(:,4));
[row col]=size(dt.Triangulation);
Table(:,1)=1:row;
DataStructure=DataStructure_Fnc(Table);
set(handles.uitable1,'Data',DataStructure(:,2:7));
cc = incenters(dt);
text(cc(:,1),cc(:,2),int2str(Table(:,1)),'color','b','fontsize',8)
set(handles.pushbutton4,'Enable','off');
set(handles.pushbutton5,'Enable','off');


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Points
Points=[];
Number_of_Point=str2double(get(handles.edit4,'string'));
Coordinates=rand(Number_of_Point,3);
set(handles.uitable2,'Data',Coordinates);
scatter(Coordinates(:,1),Coordinates(:,2),'.')
[row col]=size(Coordinates);
Points=[(1:row)' Coordinates];
text(Points(:,2),Points(:,3),int2str(Points(:,1)))
set(handles.pushbutton1,'Enable','off');
set(handles.pushbutton2,'Enable','off');
set(handles.pushbutton4,'Enable','on');
set(handles.pushbutton5,'Enable','on');



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global X Y
[X,Y]=ginput(1);
set(handles.edit2,'string',X)
set(handles.edit3,'string',Y)