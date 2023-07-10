function [CMapData,CMapHdl]=multiVarMap2(A,B,varargin) 
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : hikari
help multiVarMap2
% colorList应为4x3大小RGB数组
% [R1,G1,B1;R2,G2,B2;R3,B3,G3;R4,G4,B4]
% 分别对应图例左下，右下，左上，右上的颜色
% 或数值编号1-12

% =========================================================================
% 基本属性提取
obj.arginList={'colorList','pieceNum','varName','title'};
obj.colorList=1;
obj.pieceNum=4;
obj.varName={'var1','var2'};
obj.title='ColorMap';
for i=1:2:(length(varargin)-1)
    tid=ismember(obj.arginList,varargin{i});
    if any(tid)
        obj.(obj.arginList{tid})=varargin{i+1};
    end
end
% =========================================================================
% 基础配色表
baseAtla{1}=[233,233,233;201, 90, 90;100,173,191; 86, 64, 71]./255;
baseAtla{2}=[249,244,248;139,182,224;235,130,144;122,123,171]./255;
baseAtla{3}=[243,243,243;140,227,176;231,164,209;124,143,176]./255;
baseAtla{4}=[233,233,233;201,180, 90;154,115,176;129, 76, 51]./255;
baseAtla{5}=[222,222,222;  0,110,175;205,  0, 31; 74, 33, 76]./255;
baseAtla{6}=[233,233,233;108,132,182;116,175,129; 37, 90, 91]./255;
baseAtla{7}=[233,233,233; 89,201,201;191,100,173; 56, 71,149]./255;
baseAtla{8}=[243,243,243; 79,158,195;243,180,  0; 40, 40, 40]./255;
baseAtla{9}=[233,231,242; 78,174,209;223, 78,167; 37,19,139]./255;
baseAtla{10}=[227,228,223;127,135,124; 57,120,164; 20, 72, 83]./255;
baseAtla{11}=[243,232,156;248,161,127;207,102,148; 92, 82,166]./255;
baseAtla{12}=[248,225,152;181,167,124;108,119,149; 65, 92,170]./255;

if numel(obj.colorList)==1,atla=baseAtla{obj.colorList};end
% =========================================================================
% 数据处理及图例色卡数据构建
% nX1=X1(:);nX2=X2(:);
CMapData=getCMap(A,B,atla,obj.pieceNum);
    function CMap=getCMap(A,B,atla,n)
        nA=(A(:)-min(A(:)))./(max(A(:))-min(A(:)));
        nB=(B(:)-min(B(:)))./(max(B(:))-min(B(:)));
        nA=(ceil(nA.*n)-1)./(n-1);nB=(ceil(nB.*n)-1)./(n-1);
        nA(nA<0)=0;nB(nB<0)=0;

        colorAB=nA.*nB.*atla(4,:)+...
                nA.*(1-nB).*atla(2,:)+...
                (1-nA).*nB.*atla(3,:)+...
                (1-nA).*(1-nB).*atla(1,:);

        CMap=zeros([size(A),3]);
        CMap(:,:,1)=reshape(colorAB(:,1),size(A));
        CMap(:,:,2)=reshape(colorAB(:,2),size(A));
        CMap(:,:,3)=reshape(colorAB(:,3),size(A));
    end
% =========================================================================
% 坐标区域初定位及修饰
ax1=gca;fig=ax1.Parent;
ax1Pos=ax1.Position;
ax2=axes('Parent',fig,'Position',[ax1Pos(1)+3/4*ax1Pos(3),...
    ax1Pos(2)+6/9*ax1Pos(4),ax1Pos(3)/4,ax1Pos(4)*2.5/9]);
ax1.UserData=1;
ax2.UserData=2;
ax2.XLim=[min(A(:)),max(A(:))];
ax2.YLim=[min(B(:)),max(B(:))];
ax2.TickDir='out';ax2.TickLength=[0.02,0.025];
ax2.PlotBoxAspectRatio=[1,1,1];
ax2.Layer='top';
ax2.LineWidth=1;
ax2.FontName='Arial';
ax2.FontSize=9;
ax2.Title.String=obj.title;
ax2.Title.FontSize=12;
ax2.XLabel.String=obj.varName{1};
ax2.XLabel.FontSize=11;
ax2.YLabel.String=obj.varName{2};
ax2.YLabel.FontSize=11;
ax2.Toolbar.Visible='off';
hold(ax2,'on');view(2);
% =========================================================================
% 绘制右上角图例
[AA,BB]=meshgrid(linspace(0,1,obj.pieceNum),...
                 linspace(0,1,obj.pieceNum));
tCMap=getCMap(AA,BB,atla,obj.pieceNum);
legendCMap=zeros([size(AA)+1,3]);
legendCMap(1:end-1,1:end-1,1)=tCMap(:,:,1);
legendCMap(1:end-1,1:end-1,2)=tCMap(:,:,2);
legendCMap(1:end-1,1:end-1,3)=tCMap(:,:,3);
[XX,YY]=meshgrid(linspace(ax2.XLim(1),ax2.XLim(2),obj.pieceNum+1),...
                 linspace(ax2.YLim(1),ax2.YLim(2),obj.pieceNum+1));
surf(ax2,XX,YY,zeros(size(XX)),'CData',legendCMap,'EdgeColor','none','FaceColor','flat');
% =========================================================================
% 图例拖动回调
set(fig,'WindowButtonDownFcn',@BtnDownFunc, ...
        'WindowButtonUpFcn',@BtnUpFunc, ...
        'WindowButtonMotionFcn',@BtnMotionFunc)
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