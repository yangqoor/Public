function varargout = array2d(varargin)
% ARRAY2D M-file for array2d.fig
%      ARRAY2D, by itself, creates a new ARRAY2D or raises the existing
%      singleton*.
%
%      H = ARRAY2D returns the handle to a new ARRAY2D or the handle to
%      the existing singleton*.
%
%      ARRAY2D('Property','Value',...) creates a new ARRAY2D using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to array2d_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      ARRAY2D('CALLBACK') and ARRAY2D('CALLBACK',hObject,...) call the
%      local function named CALLBACK in ARRAY2D.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help array2d

% Last Modified by GUIDE v2.5 01-Sep-2004 19:00:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @array2d_OpeningFcn, ...
                   'gui_OutputFcn',  @array2d_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before array2d is made visible.
function array2d_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for array2d
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes array2d wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = array2d_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
