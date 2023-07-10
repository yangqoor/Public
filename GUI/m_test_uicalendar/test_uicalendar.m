function varargout = test_uicalendar(varargin)
% Last Modified by GUIDE v2.5 15-Aug-2019 18:35:15
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @test_uicalendar_OpeningFcn, ...
                   'gui_OutputFcn',  @test_uicalendar_OutputFcn, ...
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

function test_uicalendar_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
% t_now = timer('ExecutionMode', 'fixedSpacing', 'Period', 1, 'TimerFcn', {@disptime, handles});
% start(t_now);


function varargout = test_uicalendar_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


%% 
function Btn_TimeSelect_Callback(hObject, eventdata, handles)
my_uicalendar('Weekend', [1 0 0 0 0 0 1], ...
    'SelectionType', 1, ...
    'OutputDateStyle', 0,...
    'DestinationUI', {handles.Edit_Date,'String'},...
    'WindowStyle','Normal' ); 

%% 
function Edit_Date_Callback(hObject, eventdata, handles)
user_entry = get(handles.Edit_Date,'string');
% control = regexp(user_entry,'[0-3]\d (Jan|Feb|Mar|...|Dec) \d\d\d\d (0\d|1[0-2]):[0-5]\d:[0-5]\d.\d\d\d');
control = regexp(user_entry,'20\d\d-(0[1-9]|1[0-2])-(0[1-9]|[1-2]\d|3[0-1])');
if (numel(control)==0)
    errordlg({'无效的日期格式';'示例：2019-01-01'},'Error Message','modal')
    uicontrol(hObject)
end
function Edit_Date_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% 


%% 
%%%另存uicalendar，修改validateparams函数中的defaultPVals对应的paramValStruct.outDateFmt，得到目标日期格式

% his_data = get(handles.Edit_Data,'String');
% isdatetime(his_data)


% 
% function disptime(hObject, eventdata, handles)
% 
% his_data = get(handles.Edit_Data,'String');
% if ~isempty(his_data)
%     %     a = datenum(his_data,'dd-mmm-yy')
%     %     datetime(his_data,'InputFormat','dd-mmm-yyy','Locale','en_US')
%     his_data = datestr(his_data,29);
%     set(handles.Edit_Data,'String',his_data);
% end


%% 
function Ppm_date_Callback(hObject, eventdata, handles)

function Ppm_date_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white')
end

%% 
function Btn_Hour_Callback(hObject, eventdata, handles)
A = {'12';'12';'13';'14';'14';'15'};
B = union(A,[]);
str = '';
for i = 1:length(B)-1
    str = [str,B{i},':00|'];
end
str = [str,B{end},':00'];
set(handles.Ppm_date, 'string',str);
% a = get(handles.Ppm_date, 'string')
% b = get(handles.Ppm_date, 'value')
h1 = '14';
[~,Locb] = ismember({h1},B);
set(handles.Ppm_date, 'value',Locb);
