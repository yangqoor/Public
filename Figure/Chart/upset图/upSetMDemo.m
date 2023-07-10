% upSetMDemo
% @author : slandarer
% Zhaoxu Liu / slandarer (2023). upset plot 
% (https://www.mathworks.com/matlabcentral/fileexchange/123695-upset-plot), 
% MATLAB Central File Exchange. 检索来源 2023/1/22.

rng(5)
clc;clear;
setName={'RB1','PIK3R1','EGFR','TP53','PTEN'};
Data=rand([200,5])>.85;
% setName={'A','B','C','D','E','F','G'};
% Data=rand([200,7])>.9;

% 设置两个柱状图及关系连线的颜色
% bar1Color=[61,58,61]./255;
% bar2Color=[61,58,61]./255;
% lineColor=[61,58,61]./255;

bar1Color=[66,182,195]./255;
bar2Color=[253,255,228;
          164,218,183;
          68,181,197;
          44,126,185;
          35,51,154]./255;
lineColor=[61,58,61]./255;

% bar1Color=[0,0,245;245,0,0]./255;
% bar2Color=cool;
% lineColor=[61,58,61]./255;

%% =========================================================================
% 进行组合统计(一顿花里胡哨的操作)
pBool=abs(dec2bin((1:(2^size(Data,2)-1))'))-48;
[pPos,~]=find(((pBool*(1-Data'))|((1-pBool)*Data'))==0);
sPPos=sort(pPos);dPPos=find([diff(sPPos);1]);
pType=sPPos(dPPos);pCount=diff([0;dPPos]);
[pCount,pInd]=sort(pCount,'descend');
pType=pType(pInd);
sCount=sum(Data,1);
[sCount,sInd]=sort(sCount,'descend');
sType=1:size(Data,2);
sType=sType(sInd);
%% ========================================================================
% 构造figure及axes
fig=figure('Units','normalized','Position',[.3,.2,.5,.63],'Color',[1,1,1]);
axI=axes('Parent',fig);hold on;
set(axI,'Position',[.33,.35,.655,.61],'LineWidth',1.2,'Box','off','TickDir','out',...
    'FontName','Times New Roman','FontSize',12,'XTick',[],'XLim',[0,length(pType)+1])
axI.YLabel.String='Intersection Size';
axI.YLabel.FontSize=16;
%
axS=axes('Parent',fig);hold on;
set(axS,'Position',[.01,.08,.245,.26],'LineWidth',1.2,'Box','off','TickDir','out',...
    'FontName','Times New Roman','FontSize',12,'YColor','none','YLim',[.5,size(Data,2)+.5],...
    'YAxisLocation','right','XDir','reverse','YTick',[])
axS.XLabel.String='Set Size';
axS.XLabel.FontSize=16;
%
axL=axes('Parent',fig);hold on;
set(axL,'Position',[.33,.08,.655,.26],'YColor','none','YLim',[.5,size(Data,2)+.5],'XColor','none','XLim',axI.XLim)
%% ========================================================================
% 相交关系统计图 -----------------------------------------------------------
barHdlI=bar(axI,pCount);
barHdlI.EdgeColor='none';
if size(bar1Color,1)==1
    bar1Color=[bar1Color;bar1Color];
end
tx=linspace(0,1,size(bar1Color,1))';
ty1=bar1Color(:,1);ty2=bar1Color(:,2);ty3=bar1Color(:,3);
tX=linspace(0,1,length(pType))';
bar1Color=[interp1(tx,ty1,tX,'pchip'),interp1(tx,ty2,tX,'pchip'),interp1(tx,ty3,tX,'pchip')];
barHdlI.FaceColor='flat';
for i=1:length(pType)
    barHdlI.CData(i,:)=bar1Color(i,:);
end
text(axI,1:length(pType),pCount,string(pCount),'HorizontalAlignment','center',...
    'VerticalAlignment','bottom','FontName','Times New Roman','FontSize',12,'Color',[61,58,61]./255)
% 集合统计图 ---------------------------------------------------------------
barHdlS=barh(axS,sCount,'BarWidth',.6);
barHdlS.EdgeColor='none';
barHdlS.BaseLine.Color='none';
for i=1:size(Data,2)
    annotation('textbox',[(axS.Position(1)+axS.Position(3)+axI.Position(1))/2-.02,...
        axS.Position(2)+axS.Position(4)./size(Data,2).*(i-.5)-.02,.04,.04],...
        'String',setName{sInd(i)},'HorizontalAlignment','center','VerticalAlignment','middle',...
        'FitBoxToText','on','LineStyle','none','FontName','Times New Roman','FontSize',13)
end
if size(bar2Color,1)==1
    bar2Color=[bar2Color;bar2Color];
end
tx=linspace(0,1,size(bar2Color,1))';
ty1=bar2Color(:,1);ty2=bar2Color(:,2);ty3=bar2Color(:,3);
tX=linspace(0,1,size(Data,2))';
bar2Color=[interp1(tx,ty1,tX,'pchip'),interp1(tx,ty2,tX,'pchip'),interp1(tx,ty3,tX,'pchip')];
barHdlS.FaceColor='flat';
sstr{size(Data,2)}='';
for i=1:size(Data,2)
    barHdlS.CData(i,:)=bar2Color(i,:);
    sstr{i}=[num2str(sCount(i)),' '];
end
text(axS,sCount,1:size(Data,2),sstr,'HorizontalAlignment','right',...
    'VerticalAlignment','middle','FontName','Times New Roman','FontSize',12,'Color',[61,58,61]./255)
% 绘制关系连线 ---------------------------------------------------------------
patchColor=[248,246,249;255,254,255]./255;
for i=1:size(Data,2)
    fill(axL,axI.XLim([1,2,2,1]),[-.5,-.5,.5,.5]+i,patchColor(mod(i+1,2)+1,:),'EdgeColor','none')
end
[tX,tY]=meshgrid(1:length(pType),1:size(Data,2));
plot(axL,tX(:),tY(:),'o','Color',[233,233,233]./255,...
    'MarkerFaceColor',[233,233,233]./255,'MarkerSize',10);
for i=1:length(pType)
    tY=find(pBool(pType(i),:));
    oY=zeros(size(tY));
    for j=1:length(tY)
        oY(j)=find(sType==tY(j));
    end
    tX=i.*ones(size(tY));
    plot(axL,tX(:),oY(:),'-o','Color',lineColor(1,:),'MarkerEdgeColor','none',...
        'MarkerFaceColor',lineColor(1,:),'MarkerSize',10,'LineWidth',2);
end
% Zhaoxu Liu / slandarer (2023). upset plot 
% (https://www.mathworks.com/matlabcentral/fileexchange/123695-upset-plot), 
% MATLAB Central File Exchange. 检索来源 2023/1/22.





