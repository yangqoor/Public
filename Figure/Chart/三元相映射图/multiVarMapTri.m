function [CMapData,CMapHdl]=multiVarMapTri(A,B,C,varargin) 
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : hikari
help multiVarMapTri
% =========================================================================
% 基本属性提取
obj.arginList={'colorList','pieceNum','varName','title'};
obj.colorList=1;
obj.pieceNum=6;
obj.varName={'var1','var2','var3'};
obj.title='ColorMap';
for i=1:2:(length(varargin)-1)
    tid=ismember(obj.arginList,varargin{i});
    if any(tid)
        obj.(obj.arginList{tid})=varargin{i+1};
    end
end
% =========================================================================
% 基础配色表
baseAtla{1}=[1,0,0;0,1,0;0,0,1];
baseAtla{2}=[0,211,166;211,152,255;233,164,67]./255;
baseAtla{3}=[249,3,252;252,242,8;2,251,249]./255;
baseAtla{4}=[215,0,102;0,137,52;3,79,162]./255;
baseAtla{5}=[243,180,0;180,102,0;0,0,0]./255;
baseAtla{6}=[31,5,94;128,128,128;180,0,0]./255;
if numel(obj.colorList)==1,atla=baseAtla{obj.colorList};end
% =========================================================================
% 数据处理及图例色卡数据构建
CMapData=getCMap3(A,B,C,atla,obj.pieceNum);
    function CMap=getCMap3(A,B,C,atla,n)
        nA=(A(:)-min(A(:)))./(max(A(:))-min(A(:)));
        nB=(B(:)-min(B(:)))./(max(B(:))-min(B(:)));
        nC=(C(:)-min(C(:)))./(max(C(:))-min(C(:)));
        nA=(ceil(nA.*n.*3)-1)./(n.*3-1);
        nB=(ceil(nB.*n.*3)-1)./(n.*3-1);
        nC=(ceil(nC.*n.*3)-1)./(n.*3-1);
        nA(nA<0)=0;nB(nB<0)=0;nC(nC<0)=0;
        
        ABC=[nA,nB,nC];ABC=ABC./sum(ABC,2);ABC(isnan(ABC))=1/3;
        colorAB=atla(1,:).*ABC(:,1)+...
                atla(2,:).*ABC(:,2)+...
                atla(3,:).*ABC(:,3);

        CMap=zeros([size(A),3]);
        CMap(:,:,1)=reshape(colorAB(:,1),size(A));
        CMap(:,:,2)=reshape(colorAB(:,2),size(A));
        CMap(:,:,3)=reshape(colorAB(:,3),size(A));
    end

% =========================================================================
% 坐标区域初定位及修饰
ax1=gca;fig=ax1.Parent;
ax1Pos=ax1.Position;
ax2=axes('Parent',fig,'Position',[ax1Pos(1)+6/9*ax1Pos(3),...
    ax1Pos(2)+6/9*ax1Pos(4),ax1Pos(3)*2.5/9,ax1Pos(4)*2.5/9]);
ax1.UserData=1;
ax2.UserData=2;
ax2.XLim=[-.5,.5];
ax2.YLim=[-sqrt(3)/6,sqrt(3)/3.*1.3];
ax2.XTick=[];
ax2.YTick=[];
ax2.XColor='none';
ax2.YColor='none';
ax2.Color='none';
ax2.DataAspectRatio=[1,1,1];
ax2.FontName='Arial';
ax2.FontSize=9;
ax2.Title.String=obj.title;
ax2.Toolbar.Visible='off';
hold(ax2,'on');view(2);
% =========================================================================
% 图例中三元相图绘制
tt=[pi/2,pi/2+2*pi/3,pi/2+4*pi/3,pi/2];
tX=cos(tt)./sqrt(3);
tY=sin(tt)./sqrt(3);
plot(ax2,tX,tY,'Color',[0,0,0],'LineWidth',1.5)
YList=linspace(tY(1),tY(2),obj.pieceNum+1);
X0List=linspace(tX(1),tX(2),obj.pieceNum+1);
X1List=linspace(tX(1),tX(3),obj.pieceNum+1);
VList=zeros(round((obj.pieceNum+1)*(obj.pieceNum+2)/2),2);
for i=1:length(YList)
    tXList=linspace(X0List(i),X1List(i),i)';
    tYList=YList(i).*(ones(i,1));
    tN=round(i*(i-1)/2);
    VList((tN+1):(tN+i),:)=[tXList,tYList];
end
RList=zeros(obj.pieceNum*obj.pieceNum,3);
FList=zeros(obj.pieceNum*obj.pieceNum,3);n=1;
for i=2:length(YList)
    NLList=(round((i-1)*(i-2)/2)+1):(round((i-1)*(i-2)/2)+i-1);
    NList=(round(i*(i-1)/2)+1):(round(i*(i-1)/2)+i);
    for j=1:(i-1)
        FList(n,:)=[NList(j),NList(j+1),NLList(j)];
        RList(n,:)=[j-1,i-1-j,obj.pieceNum+1-i];
        n=n+1;
    end
end
for i=2:(length(YList)-1) 
    NList=(round(i*(i-1)/2)+1):(round(i*(i-1)/2)+i);
    NNList=(round((i+1)*(i)/2)+1):(round((i+1)*(i)/2)+i+1);
    for j=1:(i-1)
        FList(n,:)=[NList(j),NList(j+1),NNList(j+1)];
        RList(n,:)=[j-1+1/3,i-1-j+1/3,obj.pieceNum+1-i-2/3];
        n=n+1;
    end
end
legendCMap=getCMap3(RList(:,1),RList(:,2),RList(:,3),atla,obj.pieceNum);
patch(ax2,'Faces',FList,'Vertices',VList,'CData',legendCMap,...
    'FaceColor','flat','EdgeColor','none')
text(ax2,cos(pi/2+2*pi/3).*0.65,sin(pi/2+2*pi/3).*0.8,obj.varName{1},'FontSize',11,'FontName','Arial','HorizontalAlignment','center')
text(ax2,cos(pi/2).*0.69,sin(pi/2).*0.69,obj.varName{2},'FontSize',11,'FontName','Arial','HorizontalAlignment','center')
text(ax2,cos(pi/2-2*pi/3).*0.68,sin(pi/2-2*pi/3).*0.8,obj.varName{3},'FontSize',11,'FontName','Arial','HorizontalAlignment','center')


text(ax2,cos(-pi/2).*0.4,sin(-pi/2).*0.4,'→','FontSize',15,'FontName','Arial','HorizontalAlignment','center')
text(ax2,cos(-pi/2+2*pi/3).*0.4,sin(-pi/2+2*pi/3).*0.4,'→','FontSize',15,'FontName','Arial','HorizontalAlignment','center','Rotation',120)
text(ax2,cos(-pi/2-2*pi/3).*0.4,sin(-pi/2-2*pi/3).*0.4,'→','FontSize',15,'FontName','Arial','HorizontalAlignment','center','Rotation',-120)

% 图例拖动回调
set(fig,'WindowButtonDownFcn',@BtnDownFunc, ...
        'WindowButtonUpFcn',@BtnUpFunc, ...
        'WindowButtonMotionFcn',@BtnMotionFunc, ...
        'KeyPressFcn',@keyFunc)
selectedAx=false;
    % 选择图例时的回调
    function BtnDownFunc(~,~)
        taxes=get(fig,'currentAxes');
        if taxes.UserData==2
            selectedAx=true;
        end
    end
    % 松开图例时的回调
    function BtnUpFunc(~,~)
        selectedAx=false;
        set(fig,'currentAxes',ax1)
    end
    % 选择图例并拖动时的回调
    function BtnMotionFunc(~,~)
        if selectedAx
            tpos=get(fig,'CurrentPoint');
            figPos=fig.Position;
            normPos=tpos./figPos(3:4);
            ax2.Position(1:2)=-ax2.Position(3:4)./2+normPos;
        end
    end
set(fig,'currentAxes',ax1)
CMapHdl=ax2;
end