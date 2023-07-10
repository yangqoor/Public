function varargout = test(varargin)
% See also: GUIDE, GUIDATA, GUIHANDLES
% Edit the above text to modify the response to help test
% Last Modified by GUIDE v2.5 18-Jul-2019 09:15:28
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @test_OpeningFcn, ...
                   'gui_OutputFcn',  @test_OutputFcn, ...
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


% --- Executes just before test is made visible.
function test_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
% UIWAIT makes test wait for user response (see UIRESUME)
tt = timer('Tag','t1','Name','timer1');
handles.tt = tt;
set(handles.tt,'TimerFcn',{@disptime,handles},'ExecutionMode','fixedspacing');
start(handles.tt);   %¿ªÆô¶¨Ê±Æ÷


function disptime(hObject, eventdata, handles)
if ishandle(handles.figure1)
    str1 = char(datetime('now','Format','yyyy-MM-dd'));
    str2=datestr(now, 'HH:MM:ss');
    m_date = sprintf('%s %s',str1,str2);
    set(handles.text_date,'String',m_date);
    
%     fid=fopen('D:\DATA\runflag.txt','w');
%     a = 1
%     fprintf(fid,'%d',2);
%     fclose(fid);
else
    t = timerfind;
    stop(t);
    delete(t);
end
% --- Outputs from this function are returned to the command line.
function varargout = test_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


function pushbutton1_Callback(hObject, eventdata, handles)
get(hObject, 'Value')
if get(hObject, 'Value')
    t = timer('ExecutionMode', 'fixedSpacing', 'Period', 1, 'TimerFcn', {@timerCallback, handles}); 
    start(t);
else
    t = timerfind;
    stop(t(2));
    delete(t(2));
end

function timerCallback(obj, event, handles)
if ishandle(handles.figure1)
    val = get(handles.light, 'Value');
    if val == 1
        set(handles.light, 'BackgroundColor', 'b');
    else
        set(handles.light, 'BackgroundColor', 'w');
    end
    set(handles.light, 'Value', ~val);
else
    stop(obj);
    delete(obj);
end


% --- Executes on button press in light.
function light_Callback(hObject, eventdata, handles)
% hObject    handle to light (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
