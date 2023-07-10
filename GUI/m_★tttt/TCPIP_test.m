function varargout = TCPIP_test(varargin)
% Last Modified by GUIDE v2.5 26-Aug-2019 09:45:12
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TCPIP_test_OpeningFcn, ...
                   'gui_OutputFcn',  @TCPIP_test_OutputFcn, ...
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

function TCPIP_test_OpeningFcn(hObject, eventdata, handles, varargin)
global t2
%%
% t2 = tcpip('192.168.0.105', 60000,'NetworkRole','client','Timeout', 1);
t2 = tcpclient('192.168.0.105', 60000)
% fopen(t2);
%%
handles.output = hObject;
guidata(hObject, handles);


function varargout = TCPIP_test_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


function pushbutton1_Callback(hObject, eventdata, handles)
global t2
% fwrite(t2,65:74)
% A = char(fread(t2))
A = char(read(t2));
set(handles.text2, 'string', A);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% global t2
% fclose(t2);
delete(hObject);
