function seqLogo(varargin)
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer
% Zhaoxu Liu / slandarer (2023). sequence logos (序列logo图) 
% (https://www.mathworks.com/matlabcentral/fileexchange/123060-sequence-logos-logo), 
% MATLAB Central File Exchange. 检索来源 2023/1/10.
% =========================================================================
% Color  | 配色              | {'A',[]./255,'C',[]./255,... ...}
% Method | 比例计算方法       | Bits/Prob
% Type   | 种类(核酸/蛋白质)  | NA/PR
coe.arginList={'Color','Method','Type'};
% 数据预定义
logoData=load('logoData.mat');
coe.Color={'CDEFH',[37,92,153]./255,'AIKLM',[16,150,72]./255,'TUNPQR',[214,40,57]./255,'GSVWY',[247,179,43]./255};
coe.Method='Bits';
coe.Type='NA';
% 坐标区域获取
if isa(varargin{1},'matlab.graphics.axis.Axes')
    coe.ax=varargin{1};varargin(1)=[];
else
    coe.ax=gca;
end
% 获取其他数据
coe.Data=varargin{1};varargin(1)=[];
for i=1:2:(length(varargin)-1)
    tid=ismember(coe.arginList,varargin{i});
    if any(tid)
        coe.(coe.arginList{tid})=varargin{i+1};
    end
end
% 获取版本信息
tver=version('-release');
verMatlab=str2double(tver(1:4))+(abs(tver(5))-abs('a'))/2;
if verMatlab<2017
    hold on
else
    hold(coe.ax,'on')
end
% 颜色计算
coe.CData=zeros(length(logoData.logoName),3);
for i=1:2:length(coe.Color)
    tLogo=coe.Color{i};
    for j=1:length(tLogo)
        tPos=find(logoData.logoName==tLogo(j));
        coe.CData(tPos,:)=coe.Color{i+1};
    end
end
% 统计基因出现次数
coe.Count=zeros(length(logoData.logoName),size(coe.Data,2));
for i=1:length(logoData.logoName)
    coe.Count(i,:)=sum(coe.Data==logoData.logoName(i),1);
end
% 开始绘图
if strcmpi(coe.Method,'Prob')
    coe.ax.YLim=[0,1];
    coe.ax.DataAspectRatio=[1 .2 1];
    coe.ax.YLabel.String='Probability';
else
    coe.ax.YLabel.String='Bits';
    if strcmpi(coe.Type,'NA')
        coe.ax.DataAspectRatio=[1 .4 1];
        coe.ax.YLim=[0,log(4)/log(2)];
    else
        coe.ax.DataAspectRatio=[1 .8 1];
        coe.ax.YLim=[0,log(20)/log(2)];
    end
end
coe.ax.XLim=[.5,size(coe.Data,2)+.5];
coe.ax.XTick=1:size(coe.Data,2);
coe.ax.LineWidth=1.2;
coe.ax.TickDir='out';
coe.ax.TickLength=[0.0020 0.0250];
coe.ax.FontSize=14;
coe.ax.YLabel.FontSize=16;
%coe.ax.LooseInset=[0,0,0,0];
fig=gcf;
fig.Units='normalized';
fig.Position=[0,0,1,1];
for i=1:size(coe.Count,2)
    tPos=find(coe.Count(:,i)>0);
    tCount=coe.Count(tPos,i)';
    tRatio=tCount./sum(tCount);
    if strcmpi(coe.Method,'Prob')
        maxH=1;
    else
        if strcmpi(coe.Type,'NA')
            maxH=log(4)/log(2);
        else
            maxH=log(20)/log(2);
        end
        maxH=maxH+sum(log(tRatio)./log(2).*tRatio);
    end
    tLen=tRatio.*maxH;
    [sortRatio,ind]=sort(tLen);
    cumsumSortRatio=[0,cumsum(sortRatio)];
    for j=1:length(sortRatio)
        tPic=logoData.logoPic.(logoData.logoName(tPos(ind(j))));
        tAlpha=double(255-tPic(:,:,1)./3-tPic(:,:,2)./3-tPic(:,:,3)./3)./255;
        tPic(:,:,1)=(255-tPic(:,:,1)).*coe.CData(tPos(ind(j)),1);
        tPic(:,:,2)=(255-tPic(:,:,2)).*coe.CData(tPos(ind(j)),2);
        tPic(:,:,3)=(255-tPic(:,:,3)).*coe.CData(tPos(ind(j)),3);
        image([i-.5,i+.5],[cumsumSortRatio(j),cumsumSortRatio(j+1)],tPic,'AlphaData',tAlpha,'AlphaDataMapping','scaled')
    end
end
% Zhaoxu Liu / slandarer (2023). sequence logos (序列logo图) 
% (https://www.mathworks.com/matlabcentral/fileexchange/123060-sequence-logos-logo), 
% MATLAB Central File Exchange. 检索来源 2023/1/10.
end