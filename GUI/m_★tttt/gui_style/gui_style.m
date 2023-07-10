function varargout = gui_style(varargin)
% Last Modified by GUIDE v2.5 09-Aug-2019 20:09:17
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_style_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_style_OutputFcn, ...
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


function gui_style_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
% 
javaFrame = get(hObject,'JavaFrame');
set(javaFrame,'Maximized',1);
set(gcf, 'units','pixels', ...
    'position',get(0,'ScreenSize'));
% set(handles.figure1, 'units','pixels', ...
%     'position',[0 0 1920 1080]);
get(hObject,'position')
%% 



function varargout = gui_style_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
