function varargout = MainPanel(varargin)
% MAINPANEL M-file for MainPanel.fig
%      MAINPANEL, by itself, creates a new MAINPANEL or raises the existing
%      singleton*.
%
%      H = MAINPANEL returns the handle to a new MAINPANEL or the handle to
%      the existing singleton*.
%
%      MAINPANEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINPANEL.M with the given input arguments.
%
%      MAINPANEL('Property','Value',...) creates a new MAINPANEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MainPanel_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MainPanel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MainPanel


% Global variable
global Img_Data         %Source image data
global Img_Map          %Source image map
global Img_Hist
global Img_Threshold    %ͼ��ָ���ֵ
global Img_Segmented

% Last Modified by GUIDE v2.5 08-May-2005 10:07:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MainPanel_OpeningFcn, ...
                   'gui_OutputFcn',  @MainPanel_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
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


% --- Executes just before MainPanel is made visible.
function MainPanel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MainPanel (see VARARGIN)

% Choose default command line output for MainPanel
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MainPanel wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MainPanel_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


   

% --- Executes during object creation, after setting all properties.
function cboSegMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cboSegMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in cboSegMethod.
function cboSegMethod_Callback(hObject, eventdata, handles)
% hObject    handle to cboSegMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns cboSegMethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cboSegMethod

nSelected=get(hObject,'Value');
HideSegNum=[1,2,3,5,7];
if(~isempty(find(HideSegNum==nSelected)))
    set(handles.edtSegNum,'Visible','off');
    set(handles.txtSegNum,'Visible','off');
else
    set(handles.edtSegNum,'Visible','on');
    set(handles.txtSegNum,'Visible','on');
end


% --- Executes on button press in btnSegment.
function btnSegment_Callback(hObject, eventdata, handles)
% hObject    handle to btnSegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    sImgFile=get(handles.edtImageFile,'String');
    try
        [Img_Data,Img_Map]=imread(sImgFile);
    catch
        errordlg('ͼ���ļ�������','�ļ��򿪴���');
        return;
    end

    if(isempty(Img_Data)) 
        errordlg('�޷���ȡͼ������','��ȡͼ������ʧ��');
        return;
    end;
    
    N=str2num(get(handles.edtSegNum,'String'));
    
    if(N<2) return;end;
    
    tic;
        
    switch(get(handles.cboSegMethod,'Value'))
        case 1
            [Img_Threshold,Img_Segmented]=th_DA(Img_Data,Img_Map);
            sInfo='ֱ��ͼ�㷨';
        case 2
            [Img_Threshold,Img_Segmented]=thresh_md(Img_Data,Img_Map);
            sInfo='�����䷽�';
        case 3
            [Img_Threshold,Img_Segmented]=entropy_1D(Img_Data,Img_Map);
            sInfo='һάֱ��ͼ��';
        case 4
            [Img_Threshold,Img_Segmented]=entropy(Img_Data,N);
            sInfo='һάֱ��ͼ��(�ȸ���)';
        case 5
            [Img_Threshold,Img_Segmented]=entropy_2D(Img_Data);
            sInfo='��άֱ��ͼ��';
        case 6
            [Img_Threshold,Img_Segmented]=My2D_Entropy(Img_Data,N);
            sInfo='��άֱ��ͼ��(�ȸ���)';
        case 7
            dq=4;
            [Img_Threshold,Img_Segmented]=GetFuzzThread(Img_Data,dq);
            sInfo='ģ����ֵ��';
        case 8
            [Img_Threshold,Img_Segmented]=GetTemple(Img_Data,N);
            sInfo='K��ֵ���෨';
    end;
    
    t=toc;
    
    set(handles.txtTimeEllips,'String',t);
    set(handles.txtThreshold,'String',Img_Threshold');
    
    clrMap=[0,0,0;0,0,1;0,1,0;1,0,0;1,1,1];
    h=figure;
    set(h,'Name',sInfo);
    colormap(clrMap);
    imShow(Img_Segmented,clrMap);
    
% --- Executes during object creation, after setting all properties.
function edtSegNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtSegNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edtSegNum_Callback(hObject, eventdata, handles)
% hObject    handle to edtSegNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtSegNum as text
%        str2double(get(hObject,'String')) returns contents of edtSegNum as a double


% --- Executes during object creation, after setting all properties.
function edtImageFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtImageFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edtImageFile_Callback(hObject, eventdata, handles)
% hObject    handle to edtImageFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtImageFile as text
%        str2double(get(hObject,'String')) returns contents of edtImageFile as a double


% --- Executes on button press in btnDisp.
function btnDisp_Callback(hObject, eventdata, handles)
% hObject    handle to btnDisp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    sImgFile=get(handles.edtImageFile,'String');
    ShowImage(sImgFile);
    

% --- Executes on button press in btnSearch.
function btnSearch_Callback(hObject, eventdata, handles)
% hObject    handle to btnSearch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [filename,pathname,filterindex]=uigetfile({'*.bmp;*.jpg;*.tif','ͼ���ļ�(*.bmp,*.jpg,*.tif)'},'����ͼ���ļ�');
    if filterindex==0
        return;
    else
        filename=strcat(pathname,filename);
    end;
    
    set(handles.edtImageFile,'String',filename);
    ShowImage(sImgFile);
    
% --- �Զ��庯�� ---
% ��ָ����ͼ���ļ�����ʾ�ڴ�����
% sImageFile - ͼ��Դ�ļ�
function ShowImage(sImageFile)
    try
        [Img_Data,Img_Map]=imread(sImageFile);
    catch
        errordlg('ͼ���ļ�������','�ļ��򿪴���');
        return;
    end
    
    h=figure(1);
    set(h,'Name','Դͼ��/ֱ��ͼ');
    subplot(2,1,1),imshow(Img_Data,Img_Map),title('Դͼ��');
    subplot(2,1,2),imhist(Img_Data,Img_Map),title('ֱ��ͼ');
