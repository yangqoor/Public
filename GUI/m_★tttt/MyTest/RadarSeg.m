function varargout = RadarSeg(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RadarSeg_OpeningFcn, ...
                   'gui_OutputFcn',  @RadarSeg_OutputFcn, ...
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


% --- Executes just before RadarSeg is made visible.
function RadarSeg_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
%% 初始化



% --- Outputs from this function are returned to the command line.
function varargout = RadarSeg_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% --- 文件自然排序函数
function [cs,index] = sort_nat(c,mode)
% Set default value for mode if necessary.
if nargin < 2
    mode = 'ascend';
end

% Make sure mode is either 'ascend' or 'descend'.
modes = strcmpi(mode,{'ascend','descend'});
is_descend = modes(2);
if ~any(modes)
    error('sort_nat:sortDirection',...
        'sorting direction must be ''ascend'' or ''descend''.')
end

% Replace runs of digits with '0'.
c2 = regexprep(c,'\d+','0');

% Compute char version of c2 and locations of zeros.
s1 = char(c2);
z = s1 == '0';

% Extract the runs of digits and their start and end indices.
[digruns,first,last] = regexp(c,'\d+','match','start','end');

% Create matrix of numerical values of runs of digits and a matrix of the
% number of digits in each run.
num_str = length(c);
max_len = size(s1,2);
num_val = NaN(num_str,max_len);
num_dig = NaN(num_str,max_len);
for i = 1:num_str
    num_val(i,z(i,:)) = sscanf(sprintf('%s ',digruns{i}{:}),'%f');
    num_dig(i,z(i,:)) = last{i} - first{i} + 1;
end

% Find columns that have at least one non-NaN.  Make sure activecols is a
% 1-by-n vector even if n = 0.
activecols = reshape(find(~all(isnan(num_val))),1,[]);
n = length(activecols);

% Compute which columns in the composite matrix get the numbers.
numcols = activecols + (1:2:2*n);

% Compute which columns in the composite matrix get the number of digits.
ndigcols = numcols + 1;

% Compute which columns in the composite matrix get chars.
charcols = true(1,max_len + 2*n);
charcols(numcols) = false;
charcols(ndigcols) = false;

% Create and fill composite matrix, comp.
comp = zeros(num_str,max_len + 2*n);
comp(:,charcols) = double(s1);
comp(:,numcols) = num_val(:,activecols);
comp(:,ndigcols) = num_dig(:,activecols);

[unused,index] = sortrows(comp);
if is_descend
    index = index(end:-1:1);
end
index = reshape(index,size(c));
cs = c(index);

% --- 路径选择
function Btn_OpenFilePath_Callback(hObject, eventdata, handles)
global mydir;
% n = 0;
%读取数据文件
mydir='\';
mydir=uigetdir('c:\Users\LIUYANG\Desktop\',mydir);
get_DIRS(handles)

% --- 编辑路径
function Edit_FilePath_Callback(hObject, eventdata, handles)
global mydir;
mydir = get(handles.Edit_FilePath,'String');
get_DIRS(mydir,handles)
% --- Executes during object creation, after setting all properties.
function Edit_FilePath_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- 获取数据文件名
function get_DIRS(handles)
global n;      
global egn;
global DIRS;
global minute;
global second;
global minutes;
global seconds;
global ggroup;
global eg;
global egs;
global mydir;
seconds=[];
minutes=[];
ggroup={};
if mydir ~= 0
    if mydir(end)~='\'
        mydir=[mydir,'\'];
    end
    DIRS=dir([mydir,'*.dat']);
    DIRS_empty = isempty(DIRS);
    if DIRS_empty == 1
        h=msgbox('请选择正确的文件路径！','错误','error','modal');
        ha=get(h,'children');
        hu=findall(allchild(h),'style','pushbutton');
        set(hu,'string','确定');
        ht=findall(ha,'type','text');
        set(ht,'fontsize',10,'fontname','黑体');
    else
        % DIRS=dir(mydir);  %
        nameCell = cell(length(DIRS),1);
        for i =1:length(DIRS)
            nameCell{i} = DIRS(i).name;
        end
        DIRS=sort_nat(nameCell);  %文件名自然排序
        n=length(DIRS);%
        dataname={};
        for i=1:n
            id=strsplit(DIRS{i,1},'.');
            dataname{i}=id{1};
        end
        for i=1:n
            datname=strsplit(dataname{1,i},'-');
            minute{i}=datname{1};
            second{i}=datname{2};
        end
        all_groups(handles);
        eg=1;
        egn=ggroup{eg,2};
        egs=ggroup{eg,1};
        dealdata(egs,egn,handles);    
    end    
    set(handles.Edit_FilePath,'String',mydir);%显示文件路径
end

% --- Executes on button press in Btn_BACK.
function Btn_BACK_Callback(hObject, eventdata, handles)
global egn;
global ggroup;
global eg;
global egs;
eg=eg-1;
gg_empty = isempty (ggroup);%元胞为空值为1非空为0
% a_limit = size(ggroup);
if gg_empty == 1
    h=msgbox('请选择数据文件！','错误','error','modal');
    ha=get(h,'children');
    hu=findall(allchild(h),'style','pushbutton');
    set(hu,'string','确定');
    ht=findall(ha,'type','text');
    set(ht,'fontsize',10,'fontname','黑体');
else
    if eg<1
        h=msgbox('当前位置为文件首位，请点击NEXT！','警告','warn','modal');
        ha=get(h,'children');
        %     set (ha,'units','normalized');
        %     set (ha,'position',[1,1,9,9]);
        hu=findall(allchild(h),'style','pushbutton');
        set(hu,'string','确定');
        ht=findall(ha,'type','text');
        set(ht,'fontsize',10,'fontname','黑体');
        eg = eg+1;
    else
        egs=ggroup{eg,1};
        egn=ggroup{eg,2};
        dealdata(egs,egn,handles);
    end
end

% --- Executes on button press in Btn_NEXT.
function Btn_NEXT_Callback(hObject, eventdata, handles)
global egn;
global ggroup;
global eg;
global egs;
eg=eg+1;
gg_empty = isempty (ggroup);%元胞为空值为1非空为0
a_limit = size(ggroup);
if gg_empty == 1
    h=msgbox('请选择数据文件！','错误','error','modal');
    ha=get(h,'children');
    hu=findall(allchild(h),'style','pushbutton');
    set(hu,'string','确定');
    ht=findall(ha,'type','text');
    set(ht,'fontsize',10,'fontname','黑体');
else
    if eg > a_limit(1)
        h=msgbox('当前位置为文件末位，请点击BACK！','警告','warn','modal');
        ha=get(h,'children');
        hu=findall(allchild(h),'style','pushbutton');
        set(hu,'string','确定');
        ht=findall(ha,'type','text');
        set(ht,'fontsize',10,'fontname','黑体');
        eg = eg-1;
    else
        egs=ggroup{eg,1};
        egn=ggroup{eg,2};
        dealdata(egs,egn,handles);
    end
end

function all_groups(handles)
global ggroup;
global minute;
global minutes;
global n;
global second;
global seconds;

for i=1:n
    m=str2num(minute{i});
    minutes(i)=m;
    s=str2num(second{i});
    seconds(i)=s;
end
gnum=1;
ggnum=1;
name={[minute{1},'-',second{1},'-1.dat']};
ggroup{1,1}=1;
ggroup{1,2}=0;
for i=2:n
    diffm=minutes(i)-minutes(i-1);
    diffs=abs(seconds(i)-seconds(i-1));
    if diffm==1&&(seconds(i-1)==59&&seconds(i)==0)
        gnum=gnum+1;
    end
    if diffm==0 && diffs<=3
        gnum=gnum+1;
    end
    if diffm==0 && diffs>1
        ggroup{ggnum,2}=gnum;
        ggnum=ggnum+1;
        ggroup{ggnum,1}=i;
        gnum=1;
    end
    if diffm==1 &&(seconds(i-1)~=59||seconds(i)~=0)
        ggroup{ggnum,2}=gnum;
        ggnum=ggnum+1;
        ggroup{ggnum,1}=i;
        gnum=1;
    end
    if diffm>1
        ggroup{ggnum,2}=gnum;
        ggnum=ggnum+1;
        ggroup{ggnum,1}=i;
        gnum=1;
    end
    ggroup{ggnum,2}=1+n-ggroup{ggnum,1};
end

function dealdata(g,gn,handles)
% global A;       
global dist_far;
global dist_near;
global mydir;
global sector_flag;
global B;
global eg;
global angle_out;
global angle_in;
global dist_out;
global DIRS;
global zerodis;
%% 显示数据时间
FileInfo = dir(strcat(mydir,DIRS{g}));
old_date = char(datetime(FileInfo.datenum,'ConvertFrom','datenum','Format','yyyy-MM-dd'' ''HH:mm'));
set(handles.Text_History,'String',old_date);
%%
%global angle_in;        global dist_out;       
A=zeros(1024,gn); 
for i=g:g+gn-1
    fid = fopen(strcat(mydir,DIRS{i}));    
    A(:,i-g+1) = fread(fid,'int32');
    % A(:,i) = filter(b,1,A(:,i));
    fclose(fid);
end
B=zeros(512,gn);   
% DIS=zeros(1,gn);
for i=1:gn
    B1 = abs(fft(A(:,i),1024));
    B1(1) = 0;
    %     maxindex = find( B1 == max(B1));
    %     DIS(1,i)=0.0915*maxindex(1);
    B(:,i) = B1(1:512);
%     maxindex = find( B(:,i) == max(B(:,i)));
%     DIS(1,i)=0.0915*maxindex(1);
end
% [maxD,maxDindex]=max(B(1:120,:),[],1);
% Draw3d(B,dist_near,dist_far,handles);
% Draw2dSector(B,angle_out,angle_in,dist_out,dist_near,dist_far,handles);
set(handles.Text_CountNum,'String',eg);
show_image(handles);

function show_image(handles)
global B
size_num = size(B);
if size_num(2) == 1
    h=msgbox('本组文件数量太少，数据无效！','错误','error','modal');
    ha=get(h,'children');
    hu=findall(allchild(h),'style','pushbutton');
    set(hu,'string','确定');
    ht=findall(ha,'type','text');
    set(ht,'fontsize',10,'fontname','黑体');
end
n = length(B(1,:));
B = B(1:120,:);
cla(handles.axes1);
axes(handles.axes1);
% axes equal

set(handles.axes1,'units','pixels');
% pos_fig = get(handles.axes1,'pos');
% pos_img = [26+(274-2*n)/2 97+(451-240)/2 2*n 240];
pos=get(handles.axes1,'pos');
pos(3:4)=size(B);
set(handles.axes1,'pos',pos); 
imshow(B,[]);


% --- Executes on selection change in Pm_Prossing.
function Pm_Prossing_Callback(hObject, eventdata, handles)
global flag_segment;
flag_segment = get(handles.Pm_Prossing,'value');
Prepro(flag_segment,handles);

% --- Executes during object creation, after setting all properties.
function Pm_Prossing_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Prepro(flag,handles)


% --- Executes on selection change in Pm_Segment.
function Pm_Segment_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function Pm_Segment_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
