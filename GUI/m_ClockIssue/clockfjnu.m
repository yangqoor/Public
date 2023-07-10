function varargout = clockfjnu(varargin)
% CLOCKFJNU M-file for clockfjnu.fig
%      CLOCKFJNU, by itself, creates a new CLOCKFJNU or raises the existing
%      singleton*.
% 
%      H = CLOCKFJNU returns the handle to a new CLOCKFJNU or the handle to
%      the existing singleton*.
% 
%      CLOCKFJNU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CLOCKFJNU.M with the given input arguments.
% 
%      CLOCKFJNU('Property','Value',...) creates a new CLOCKFJNU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before clockfjnu_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to clockfjnu_OpeningFcn via varargin.
% 
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
% 
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help clockfjnu

% Last Modified by GUIDE v2.5 23-Dec-2008 22:44:21

% Begin initialization code - DO NOT EDIT

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @clockfjnu_OpeningFcn, ...
    'gui_OutputFcn',  @clockfjnu_OutputFcn, ...
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

% --- Executes just before clockfjnu is made visible.
function clockfjnu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to clockfjnu (see VARARGIN)

% Choose default command line output for clockfjnu

handles.output = hObject;

global  Title;
Title='北京时间';

global VarTime;
VarTime=0;
TimeZoneString=get(handles.TimeZone,'String');
TimeZoneStingSize=size(TimeZoneString);

for i=1:TimeZoneStingSize(1) %时区选择中，默认选中(GMT+08:00)北京时间
    if  strcmp( TimeZoneString{i},'(GMT+08:00)北京时间')
        set(handles.TimeZone,'value',i); %北京
        break;
    end
end

handles.t=timer('ExecutionMode','fixedRate' ,'TimerFcn',{@TimeUpdate,handles},'Period',1);
start(handles.t);
set(gcf, 'DeleteFcn', {@DeleteFcn, handles.t}); %设置窗口销毁时的回调函数

global hh;
global hm;
global hs;

axes(handles.axes1);

set(hObject,'NumberTitle','off');
set(hObject,'MenuBar','none');
set(hObject,'visible','on');
A=linspace(0,6.3,1000); %0到6.3之间产生1000个点
x1=8*cos(A);
y1=8*sin(A);  %设置外圆所对应的x,y值

x2=7*cos(A);
y2=7*sin(A);  %设置内圆所对应的x,y值
plot(x1,y1,'b','linewidth',1)
hold on
plot(x2,y2,'b','linewidth',3.5,'color',[0 0 0])
fill(0.4*cos(A),0.4*sin(A),'r');%时钟中心小实心圆点
axis off;  %取消坐标轴显示

axis equal;%坐标轴x,y等比率

for k=1:12; %时钟面盘12等分，并写上相应的1，2...12数字
    xk=9*cos(-2*pi/12*k+pi/2);
    yk=9*sin(-2*pi/12*k+pi/2);
    plot([xk/9*8 xk/9*7],[yk/9*8 yk/9*7],'color',[1 0 0])
    h=text(xk,yk,num2str(k),'fontsize',16,'color',...
        [1 0 0],'HorizontalAlignment','center');
end

set(handles.TimeZoneStr,'string',Title);

% 计算时针位置
ti=clock;
th=-(ti(4)+ti(5)/60+ti(6)/3600)/12*2*pi+pi/2;
xh3=4.0*cos(th);
yh3=4.0*sin(th);
xh2=xh3/2+0.5*cos(th-pi/2);
yh2=yh3/2+0.5*sin(th-pi/2);
xh4=xh3/2-0.5*cos(th-pi/2);
yh4=yh3/2-0.5*sin(th-pi/2);
hh=fill([0 xh2 xh3 xh4 0],[0 yh2 yh3 yh4 0],[1 0 0]);

% 计算分针位置
tm=-(ti(5)+ti(6)/60)/60*2*pi+pi/2;
xm3=6.0*cos(tm);
ym3=6.0*sin(tm);
xm2=xm3/2+0.5*cos(tm-pi/2);
ym2=ym3/2+0.5*sin(tm-pi/2);
xm4=xm3/2-0.5*cos(tm-pi/2);
ym4=ym3/2-0.5*sin(tm-pi/2);
hm=fill([0 xm2 xm3 xm4 0],[0 ym2 ym3 ym4 0],[0 1 0]);

% 计算秒针位置
ts=-(ti(6))/60*2*pi+pi/2;
hs=plot([0 7*cos(ts)],[0 7*sin(ts)],...
    'color',[0 0 1],'linewidth',3);

set(gcf,'doublebuffer','on');

guidata(hObject, handles);

% UIWAIT makes clockfjnu wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = clockfjnu_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function date_Callback(hObject, eventdata, handles)
% hObject    handle to date (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of date as text
%        str2double(get(hObject,'String')) returns contents of date as a double

% --- Executes during object creation, after setting all properties.
function date_CreateFcn(hObject, eventdata, handles)
% hObject    handle to date (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function TimeUpdate(obj,eventdata,handles) %定时器回调函数
global VarTime;
global Title;

%VarTime
NowTime=fix(clock);
if NowTime(4)+VarTime<0
    NowTime(3)=NowTime(3)-1;
    NowTime(4)=NowTime(4)+VarTime+24;
elseif NowTime(4)+VarTime>=24
    NowTime(3)=NowTime(3)+1;
    NowTime(4)=NowTime(4)+VarTime-24;
else
    NowTime(4)=NowTime(4)+VarTime;
end
StrTime= sprintf('%d年%d月%d日%d时%d分%d秒',NowTime);
set(handles.date,'String',StrTime);
%
global hh;
global hm;
global hs;

axes(handles.axes1);
ti=NowTime;
%ti=clock;
% 计算时针位置
th=-(ti(4)+ti(5)/60+ti(6)/3600)/12*2*pi+pi/2;
xh3=4.0*cos(th);
yh3=4.0*sin(th);
xh2=xh3/2+0.5*cos(th-pi/2);
yh2=yh3/2+0.5*sin(th-pi/2);

xh4=xh3/2-0.5*cos(th-pi/2);
yh4=yh3/2-0.5*sin(th-pi/2);
set(hh,'XData',[0 xh2 xh3 xh4 0],'YData',[0 yh2 yh3 yh4 0])

% 计算分针位置
tm=-(ti(5)+ti(6)/60)/60*2*pi+pi/2;
xm3=6.0*cos(tm);
ym3=6.0*sin(tm);
xm2=xm3/2+0.5*cos(tm-pi/2);
ym2=ym3/2+0.5*sin(tm-pi/2);
xm4=xm3/2-0.5*cos(tm-pi/2);
ym4=ym3/2-0.5*sin(tm-pi/2);
set(hm,'XData',[0 xm2 xm3 xm4 0],'YData',[0 ym2 ym3 ym4 0])

% 计算秒针位置
ts=-(ti(6))/60*2*pi+pi/2;
set(hs,'XData',[0 7*cos(ts)],'YData',[0 7*sin(ts)])

drawnow;

function DeleteFcn(hObject, eventdata, t)          % 窗口关闭的响应函数－停止计时器
stop(t);
delete(t); %销毁定时器
clear all;

% --- Executes during object creation, after setting all properties.
function TimeZone_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeZone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in TimeZone.
function TimeZone_Callback(hObject, eventdata, handles)
% hObject    handle to TimeZone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns TimeZone contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TimeZone
global VarTime;
global Title;
SelZone=get(handles.TimeZone,'value');

TimeZoneString=get(handles.TimeZone,'String');

switch TimeZoneString{SelZone}   %以北京时间为例，VarTime=0; 以后要加其它的时区，只要按如下格式输入case分支，并且在popupmenu 为TimeZone中输入相应的字符串，例如北京时间为(GMT+08:00)北京时间
    case  '(GMT-12:00)日界线西'
        
        Title='日界线西时间';
        set(handles.TimeZoneStr,'string',Title);
        VarTime=-20;
    case  '(GMT-10:00)夏威夷时间'
        
        Title='夏威夷时间';
        set(handles.TimeZoneStr,'string',Title);
        VarTime=-18;
    case  '(GMT-06:00)中部时间（美国）'
        
        Title='中部时间（美国）';
        set(handles.TimeZoneStr,'string',Title);
        VarTime=-14;
    case  '(GMT-04:00)加拿大时间'
        
        Title='加拿大时间';
        set(handles.TimeZoneStr,'string',Title);
        VarTime=-12;
    case  '(GMT)格林威治标准时间'
        
        Title='格林威治标准时间'
        set(handles.TimeZoneStr,'string',Title);
        VarTime=-8;
    case   '(GMT+02:00)雅典时间'
        
        Title='雅典时间';
        set(handles.TimeZoneStr,'string',Title);
        VarTime=-6;
        
    case   '(GMT+03:00)莫斯科时间'
        
        Title='莫斯科时间';
        set(handles.TimeZoneStr,'string',Title);
        VarTime=-5;
        
    case   '(GMT+08:00)北京时间'
        
        Title='北京时间';
        set(handles.TimeZoneStr,'string',Title);
        VarTime=0;
    case   '(GMT+09:00)东京时间'
        
        Title='东京时间';
        set(handles.TimeZoneStr,'string',Title);
        VarTime=1;
    case   '(GMT+10:00)堪培拉时间'
        
        Title='堪培拉时间';
        set(handles.TimeZoneStr,'string',Title);
        VarTime=2;

end


