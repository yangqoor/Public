function varargout = example1(varargin)
% EXAMPLE1 M-file for example1.fig
% Last Modified by GUIDE v2.5 17-Jul-2019 17:45:47
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

function example1_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
% web -browser http://www.ilovematlab.cn/thread-100442-1-3.html
% Update handles structure
tt = timer('Tag','t1','Name','timer1');
handles.tt = tt;
set(handles.tt,'TimerFcn',{@disptime,handles},'ExecutionMode','fixedspacing');
start(handles.tt);   %开启定时器


function disptime(hObject, eventdata, handles)
if ishandle(handles.figure1)
    str1 = char(datetime('now','Format','yyyy-MM-dd'));
    str2=datestr(now, 'HH:MM:ss');
    m_date = sprintf('%s %s',str1,str2);
    set(handles.text_date,'String',m_date);
else
    t = timerfind;
    stop(t);
    delete(t);
    clear all;
end

function varargout = example1_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


function pushbutton1_Callback(hObject, eventdata, handles)
setHvisible(handles,1,[2,3])


function pushbutton2_Callback(hObject, eventdata, handles)

setHvisible(handles,2,[1,3])


function pushbutton3_Callback(hObject, eventdata, handles)

setHvisible(handles,3,[1,2])


function pushbutton7_Callback(hObject, eventdata, handles)

close(gcf)



function pushbutton4_Callback(hObject, eventdata, handles)

axes(handles.axes1)
ezplot('sin(x)')


function pushbutton5_Callback(hObject, eventdata, handles)

axes(handles.axes2)
ezplot('cos(x)')


function pushbutton6_Callback(hObject, eventdata, handles)

axes(handles.axes3)
ezplot('tan(x)')

function setHvisible(handles,Iyes,Ino)
%% 设置对象的的visible属性
% 将Iyes序号对应的uipanel设置为显示 对应的pushbutton的enable设置成off
% 将Ino序号对应的uipanel设置为隐藏 对应的pushbutton的enable设置成on
for i=1:length(Iyes)
    eval( ['set(handles.uipanel',num2str(Iyes(i)),',','''visible'',''on'')'])   %设置为显示
%     eval( ['set(handles.pushbutton',num2str(Iyes(i)),',','''visible'',''off'')'])
    eval( ['set(handles.pushbutton',num2str(Iyes(i)),',',...
        '''BackgroundColor'',''w'',''ForegroundColor'',''black'',''FontWeight'',''bold'',''FontName'',''黑体'')'])%按钮变灰

end
for i=1:length(Ino)
    eval( ['set(handles.uipanel',num2str(Ino(i)),',','''visible'',''off'')'])   %设置为隐藏
%     eval( ['set(handles.pushbutton',num2str(Ino(i)),',','''visible'',''on'')'])
    eval( ['set(handles.pushbutton',num2str(Ino(i)),',',...
        '''BackgroundColor'',[0.1 0.35 0.65],''ForegroundColor'',''w'',''FontWeight'',''normal'',''FontName'',''宋体'')'])%按钮变灰
end


% --- Executes on button press in Twinkle.
function Twinkle_Callback(hObject, eventdata, handles)
% get(hObject, 'Value')
if get(hObject, 'Value')
    t = timer('ExecutionMode', 'fixedSpacing', 'Period', 1, 'TimerFcn', {@timerCallback, handles}); 
    start(t);
    set(handles.Twinkle,'BackgroundColor','w');
else
    set(handles.Twinkle,'BackgroundColor',[0.1 0.35 0.65]);
    t = timerfind;
    stop(t);
    delete(t);
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



function light_Callback(hObject, eventdata, handles)
