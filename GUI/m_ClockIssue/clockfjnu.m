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
Title='����ʱ��';

global VarTime;
VarTime=0;
TimeZoneString=get(handles.TimeZone,'String');
TimeZoneStingSize=size(TimeZoneString);

for i=1:TimeZoneStingSize(1) %ʱ��ѡ���У�Ĭ��ѡ��(GMT+08:00)����ʱ��
    if  strcmp( TimeZoneString{i},'(GMT+08:00)����ʱ��')
        set(handles.TimeZone,'value',i); %����
        break;
    end
end

handles.t=timer('ExecutionMode','fixedRate' ,'TimerFcn',{@TimeUpdate,handles},'Period',1);
start(handles.t);
set(gcf, 'DeleteFcn', {@DeleteFcn, handles.t}); %���ô�������ʱ�Ļص�����

global hh;
global hm;
global hs;

axes(handles.axes1);

set(hObject,'NumberTitle','off');
set(hObject,'MenuBar','none');
set(hObject,'visible','on');
A=linspace(0,6.3,1000); %0��6.3֮�����1000����
x1=8*cos(A);
y1=8*sin(A);  %������Բ����Ӧ��x,yֵ

x2=7*cos(A);
y2=7*sin(A);  %������Բ����Ӧ��x,yֵ
plot(x1,y1,'b','linewidth',1)
hold on
plot(x2,y2,'b','linewidth',3.5,'color',[0 0 0])
fill(0.4*cos(A),0.4*sin(A),'r');%ʱ������Сʵ��Բ��
axis off;  %ȡ����������ʾ

axis equal;%������x,y�ȱ���

for k=1:12; %ʱ������12�ȷ֣���д����Ӧ��1��2...12����
    xk=9*cos(-2*pi/12*k+pi/2);
    yk=9*sin(-2*pi/12*k+pi/2);
    plot([xk/9*8 xk/9*7],[yk/9*8 yk/9*7],'color',[1 0 0])
    h=text(xk,yk,num2str(k),'fontsize',16,'color',...
        [1 0 0],'HorizontalAlignment','center');
end

set(handles.TimeZoneStr,'string',Title);

% ����ʱ��λ��
ti=clock;
th=-(ti(4)+ti(5)/60+ti(6)/3600)/12*2*pi+pi/2;
xh3=4.0*cos(th);
yh3=4.0*sin(th);
xh2=xh3/2+0.5*cos(th-pi/2);
yh2=yh3/2+0.5*sin(th-pi/2);
xh4=xh3/2-0.5*cos(th-pi/2);
yh4=yh3/2-0.5*sin(th-pi/2);
hh=fill([0 xh2 xh3 xh4 0],[0 yh2 yh3 yh4 0],[1 0 0]);

% �������λ��
tm=-(ti(5)+ti(6)/60)/60*2*pi+pi/2;
xm3=6.0*cos(tm);
ym3=6.0*sin(tm);
xm2=xm3/2+0.5*cos(tm-pi/2);
ym2=ym3/2+0.5*sin(tm-pi/2);
xm4=xm3/2-0.5*cos(tm-pi/2);
ym4=ym3/2-0.5*sin(tm-pi/2);
hm=fill([0 xm2 xm3 xm4 0],[0 ym2 ym3 ym4 0],[0 1 0]);

% ��������λ��
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

function TimeUpdate(obj,eventdata,handles) %��ʱ���ص�����
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
StrTime= sprintf('%d��%d��%d��%dʱ%d��%d��',NowTime);
set(handles.date,'String',StrTime);
%
global hh;
global hm;
global hs;

axes(handles.axes1);
ti=NowTime;
%ti=clock;
% ����ʱ��λ��
th=-(ti(4)+ti(5)/60+ti(6)/3600)/12*2*pi+pi/2;
xh3=4.0*cos(th);
yh3=4.0*sin(th);
xh2=xh3/2+0.5*cos(th-pi/2);
yh2=yh3/2+0.5*sin(th-pi/2);

xh4=xh3/2-0.5*cos(th-pi/2);
yh4=yh3/2-0.5*sin(th-pi/2);
set(hh,'XData',[0 xh2 xh3 xh4 0],'YData',[0 yh2 yh3 yh4 0])

% �������λ��
tm=-(ti(5)+ti(6)/60)/60*2*pi+pi/2;
xm3=6.0*cos(tm);
ym3=6.0*sin(tm);
xm2=xm3/2+0.5*cos(tm-pi/2);
ym2=ym3/2+0.5*sin(tm-pi/2);
xm4=xm3/2-0.5*cos(tm-pi/2);
ym4=ym3/2-0.5*sin(tm-pi/2);
set(hm,'XData',[0 xm2 xm3 xm4 0],'YData',[0 ym2 ym3 ym4 0])

% ��������λ��
ts=-(ti(6))/60*2*pi+pi/2;
set(hs,'XData',[0 7*cos(ts)],'YData',[0 7*sin(ts)])

drawnow;

function DeleteFcn(hObject, eventdata, t)          % ���ڹرյ���Ӧ������ֹͣ��ʱ��
stop(t);
delete(t); %���ٶ�ʱ��
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

switch TimeZoneString{SelZone}   %�Ա���ʱ��Ϊ����VarTime=0; �Ժ�Ҫ��������ʱ����ֻҪ�����¸�ʽ����case��֧��������popupmenu ΪTimeZone��������Ӧ���ַ��������籱��ʱ��Ϊ(GMT+08:00)����ʱ��
    case  '(GMT-12:00)�ս�����'
        
        Title='�ս�����ʱ��';
        set(handles.TimeZoneStr,'string',Title);
        VarTime=-20;
    case  '(GMT-10:00)������ʱ��'
        
        Title='������ʱ��';
        set(handles.TimeZoneStr,'string',Title);
        VarTime=-18;
    case  '(GMT-06:00)�в�ʱ�䣨������'
        
        Title='�в�ʱ�䣨������';
        set(handles.TimeZoneStr,'string',Title);
        VarTime=-14;
    case  '(GMT-04:00)���ô�ʱ��'
        
        Title='���ô�ʱ��';
        set(handles.TimeZoneStr,'string',Title);
        VarTime=-12;
    case  '(GMT)�������α�׼ʱ��'
        
        Title='�������α�׼ʱ��'
        set(handles.TimeZoneStr,'string',Title);
        VarTime=-8;
    case   '(GMT+02:00)�ŵ�ʱ��'
        
        Title='�ŵ�ʱ��';
        set(handles.TimeZoneStr,'string',Title);
        VarTime=-6;
        
    case   '(GMT+03:00)Ī˹��ʱ��'
        
        Title='Ī˹��ʱ��';
        set(handles.TimeZoneStr,'string',Title);
        VarTime=-5;
        
    case   '(GMT+08:00)����ʱ��'
        
        Title='����ʱ��';
        set(handles.TimeZoneStr,'string',Title);
        VarTime=0;
    case   '(GMT+09:00)����ʱ��'
        
        Title='����ʱ��';
        set(handles.TimeZoneStr,'string',Title);
        VarTime=1;
    case   '(GMT+10:00)������ʱ��'
        
        Title='������ʱ��';
        set(handles.TimeZoneStr,'string',Title);
        VarTime=2;

end


