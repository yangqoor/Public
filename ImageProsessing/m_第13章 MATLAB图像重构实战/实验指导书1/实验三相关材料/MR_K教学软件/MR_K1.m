function varargout = MR_K1(varargin)
% MR_K1 M-file for MR_K1.fig
%      MR_K1, by itself, creates a new MR_K1 or raises the existing
%      singleton*.
%
%      H = MR_K1 returns the handle to a new MR_K1 or the handle to
%      the existing singleton*.
%
%      MR_K1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MR_K1.M with the given input arguments.
%
%      MR_K1('Property','Value',...) creates a new MR_K1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MR_K1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MR_K1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MR_K1

% Last Modified by GUIDE v2.5 15-May-2013 16:39:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MR_K1_OpeningFcn, ...
                   'gui_OutputFcn',  @MR_K1_OutputFcn, ...
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


% --- Executes just before MR_K1 is made visible.
function MR_K1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MR_K1 (see VARARGIN)

% Choose default command line output for MR_K1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

setappdata(handles.figure1,'Xdata',1);
setappdata(handles.figure1,'Ydata',1);
setappdata(handles.figure1,'img_src',0);

% UIWAIT makes MR_K1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%axes(handles.axes2);
%I=imread('hd06.gif');
%J=double(I);
%imshow(I);title('原图')



% --- Outputs from this function are returned to the command line.
function varargout = MR_K1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
axes(handles.axes4);

fig_user_data=get(gcf,'Userdata');
fig_user_data(1)=get(hObject,'value');
set(handles.figure1,'UserData',fig_user_data);
data_process(handles);


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUI DATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
axes(handles.axes4)
%clear all
fig_user_data=get(gcf,'Userdata');
fig_user_data(2)=get(hObject,'value');
set(handles.figure1,'UserData',fig_user_data);
data_process(handles);

function data_process(handles)

fig_user_data = get(handles.figure1,'Userdata');

I=getappdata(handles.figure1,'img_src');
I=double(I);
F=fft2(I);
F2=fftshift(F);

if fig_user_data(1)
    F2(1:2:512,:)=0;
end

if fig_user_data(2)
    F2(:,1:2:512)=0;
end

if fig_user_data(3)
   x = getappdata(handles.figure1,'Xdata');
   y = getappdata(handles.figure1,'Ydata');
   F2(x,y)=99999999;
end

if fig_user_data(4)
    F2(1:100,:)=0;
    F2(412:512,:)=0;
    F2(:,1:100)=0;
    F2(:,412:512)=0;
end

 g1=ifftshift(F2);
 %g1=real(ifft2(g1));
 g1=ifft2(g1);
 imshow(g1,[]);
 title('处理后的MR图像')
 axes(handles.axes3);
 F2_log=log(1+abs(F2));
imshow(F2_log,[]);title('处理后的K空间');

% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3
axes(handles.axes4);

fig_user_data=get(gcf,'Userdata');
fig_user_data(3)=get(hObject,'value');
set(handles.figure1,'UserData',fig_user_data);

data_process(handles);



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

Xdata=str2double(get(hObject,'String'));
setappdata(handles.figure1,'Xdata',Xdata);
%guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double
Ydata=str2double(get(hObject,'String'));
setappdata(handles.figure1,'Ydata',Ydata);
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


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4
axes(handles.axes4);
cla;

%popup_sel_index = get(handles.popupmenu1, 'Value');
%switch popup_sel_index
%    case 1
I=getappdata(handles.figure1,'img_src');
J=double(I);
D1=15;
n=2;
Fuv=fftshift(fft2(J));
[M,N]=size(Fuv);
x0=floor(M/2);
y0=floor(N/2);
for i=1:M
    for j=1:N
        D=sqrt((i-x0)^2+(j-y0)^2);
        h(i,j)=1/((1+D/D1)^(2*n));
    end
end
Guv=h.*Fuv;
g=ifftshift(Guv);
g=uint8(real(ifft2(g)));;
imshow(g);title('重建图像')

axes(handles.axes3);
cla;
D1 = 15;
%popup_sel_index = get(handles.popupmenu1, 'Value');
%switch popup_sel_index
%    case 1
I=getappdata(handles.figure1,'img_src');
J=double(I);
Fuv=fftshift(fft2(J));
[M,N]=size(Fuv);
x0=floor(M/2);
y0=floor(N/2);
for i=1:M
     for j=1:N
        D=sqrt((i-x0)^2+(j-y0)^2);
        if(D>=D1)
            hl(i,j)=0;
        else
            hl(i,j)=1;
        end
     end
end
 Guv1=hl.*Fuv;
 imshow(log(1+abs(Guv1)),[]);title('低通滤波后的K空间')

% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5
axes(handles.axes4);
cla;

%popup_sel_index = get(handles.popupmenu1, 'Value');
%switch popup_sel_index
%    case 1
I=getappdata(handles.figure1,'img_src');
J=double(I);
D1=80;
n=2;
Fuv=fftshift(fft2(J));
[M,N]=size(Fuv);
x0=floor(M/2);
y0=floor(N/2);
for i=1:M
    for j=1:N
        D=sqrt((i-x0)^2+(j-y0)^2);
        h(i,j)=1/((1+D/D1)^(2*n));
    end
end
Guv=h.*Fuv;
g=ifftshift(Guv);
g=uint8(real(ifft2(g)));;
imshow(g);title('D1=80')

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

axes(handles.axes4);
cla;
D1 = get(handles.slider1,'Value');
popup_sel_index = get(handles.popupmenu1, 'Value');
switch popup_sel_index
    case 1
I=getappdata(handles.figure1,'img_src');
J=double(I);
n=2;
Fuv=fftshift(fft2(J));
[M,N]=size(Fuv);
x0=floor(M/2);
y0=floor(N/2);
for i=1:M
    for j=1:N
        D=sqrt((i-x0)^2+(j-y0)^2);
        h(i,j)=1/((1+D/D1)^(2*n));
    end
end
Guv=h.*Fuv;
g=ifftshift(Guv);
g=uint8(real(ifft2(g)));
imshow(g);title('低通重建图像')
    case 2
I=getappdata(handles.figure1,'img_src');
J=double(I);
n=2;
Fuv=fftshift(fft2(J));
[M,N]=size(Fuv);
x0=floor(M/2);
y0=floor(N/2);
for i=1:M
    for j=1:N
        D=sqrt((i-x0)^2+(j-y0)^2);
        if D==0
            h(i,j)=0;
        else
            h(i,j)=1/(1+(D1/D)^(2*n));
    end
    end
end
Guv=h.*Fuv;
g=ifftshift(Guv);
g=uint8(real(ifft2(g)));
imshow(g);title('高通重建图像');
end
axes(handles.axes3);
cla;
D1 = get(handles.slider1,'Value');
popup_sel_index = get(handles.popupmenu1, 'Value');
switch popup_sel_index
    case 1
I=getappdata(handles.figure1,'img_src');
J=double(I);
Fuv=fftshift(fft2(J));
[M,N]=size(Fuv);
x0=floor(M/2);
y0=floor(N/2);
for i=1:M
     for j=1:N
        D=sqrt((i-x0)^2+(j-y0)^2);
        if(D>=D1)
            hl(i,j)=0;
        else
            hl(i,j)=1;
        end
     end
end
 Guv1=hl.*Fuv;
 imshow(log(1+abs(Guv1)),[]);title('低通滤波后的K空间')
    case 2
        I=getappdata(handles.figure1,'img_src');
J=double(I);
n=2;
Fuv=fftshift(fft2(J));
[M,N]=size(Fuv);
x0=floor(M/2);
y0=floor(N/2);
for i=1:M
    for j=1:N
        D=sqrt((i-x0)^2+(j-y0)^2);
        if D==0
            h(i,j)=0;
        else
            h(i,j)=1/(1+(D1/D)^(2*n));
    end
    end
end
Guv=h.*Fuv;
imshow(log(1+abs(Guv)),[]);title('高通滤波后的K空间');
end



% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --------------------------------------------------------------------
function file_Callback(hObject, eventdata, handles)
% hObject    handle to file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mr_k_open_Callback(hObject, eventdata, handles)
% hObject    handle to mr_k_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fname,pname]=uigetfile('*.*','open');
if isequal(fname,0)||isequal(pname,fname)
    return;
else
       fullname=[pname fname];
       img_src=imread(fullname);
       setappdata(handles.figure1,'img_src',img_src);
       axes(handles.axes2);
       imshow(img_src);
       title(fullname);
       
%       setappdata(handles.figure_mr_k,'img_src',img_src);
%       
%       img_src=double(img_src);
%       img_fft2=fft2(img_src);
%       img_fft2_shift=fftshift(img_fft2);       
%       setappdata(handles.figure_mr_k,'img_fft2_shift',img_fft2_shift);
%       
%        img_fft2_shift_log=log(1+abs(img_fft2_shift));
        axes(handles.axes5);
        J=double(img_src);
        Fuv=fftshift(fft2(J));
        imshow(log(1+abs(Fuv)),[]);title('K空间')
       
end


% --------------------------------------------------------------------
function mr_k_exit_Callback(hObject, eventdata, handles)
% hObject    handle to mr_k_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1



% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes4);
cla;

popup_sel_index = get(handles.popupmenu1, 'Value');
switch popup_sel_index
    case 1
I=getappdata(handles.figure1,'img_src');
J=double(I);
D1=15;
n=2;
Fuv=fftshift(fft2(J));
[M,N]=size(Fuv);
x0=floor(M/2);
y0=floor(N/2);
for i=1:M
    for j=1:N
        D=sqrt((i-x0)^2+(j-y0)^2);
        h(i,j)=1/((1+D/D1)^(2*n));
    end
end
Guv=h.*Fuv;
g=ifftshift(Guv);
g=uint8(real(ifft2(g)));;
imshow(g);title('D1=15')

axes(handles.axes3);
I=getappdata(handles.figure1,'img_src');
J=double(I);
D1=15;
Fuv=fftshift(fft2(J));
[M,N]=size(Fuv);
x0=floor(M/2);
y0=floor(N/2);
for i=1:M
     for j=1:N
        D=sqrt((i-x0)^2+(j-y0)^2);
        if(D>=D1)
            hl(i,j)=0;
        else
            hl(i,j)=1;
        end
     end
end
 Guv1=hl.*Fuv;
 imshow(log(1+abs(Guv1)),[]);title('低通滤波后的K空间')
    case 2
        I=getappdata(handles.figure1,'img_src');
J=double(I);
D1=15;
n=2;
Fuv=fftshift(fft2(J));
[M,N]=size(Fuv);
x0=floor(M/2);
y0=floor(N/2);
for i=1:M
    for j=1:N
        D=sqrt((i-x0)^2+(j-y0)^2);
        if D==0
            h(i,j)=0;
        else
            h(i,j)=1/(1+(D1/D)^(2*n));
    end
    end
end
Guv=h.*Fuv;
g=ifftshift(Guv);
g=uint8(real(ifft2(g)));
imshow(g);title('D1=15');

axes(handles.axes3);
I=getappdata(handles.figure1,'img_src');
J=double(I);
D1=15;
n=2;
Fuv=fftshift(fft2(J));
[M,N]=size(Fuv);
x0=floor(M/2);
y0=floor(N/2);
for i=1:M
    for j=1:N
        D=sqrt((i-x0)^2+(j-y0)^2);
        if D==0
            h(i,j)=0;
        else
            h(i,j)=1/(1+(D1/D)^(2*n));
    end
    end
end
Guv=h.*Fuv;
imshow(log(1+abs(Guv)),[]);title('高通滤波后的K空间');
end


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6
axes(handles.axes4);

fig_user_data=get(gcf,'Userdata');
fig_user_data(4)=get(hObject,'value');
set(handles.figure1,'UserData',fig_user_data);
data_process(handles);

% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
