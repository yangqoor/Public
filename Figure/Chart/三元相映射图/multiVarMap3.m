function [CMapData,CMapHdl]=multiVarMap3(A,B,C,varargin) 
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : hikari
help multiVarMap3
% colorList应为8x3大小RGB数组
% [R1,G1,B1;R2,G2,B2;R3,B3,G3;R4,G4,B4,...]

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
% [0;X;Y;Z;XY;YZ;XZ;XYZ]
baseAtla{1}=[222,222,222;201,90,90;116,175,129;108,132,182;
             243,180,0;37,90,91;74,33,76;40 40 40]./255; 
baseAtla{2}=[0 0 0;1 0 0;0 1 0;0 0 1;1 1 0;0 1 1;1 0 1;1 1 1]; 

if numel(obj.colorList)==1,atla=baseAtla{obj.colorList};end
% =========================================================================
% 数据处理及图例色卡数据构建
CMapData=getCMap3(A,B,C,atla,obj.pieceNum);
    function CMap=getCMap2(A,B,atla,n)
        nA=(A(:)-min(A(:)))./(max(A(:))-min(A(:)));
        nB=(B(:)-min(B(:)))./(max(B(:))-min(B(:)));
        nA=(ceil(nA.*n)-1)./(n-1);
        nB=(ceil(nB.*n)-1)./(n-1);
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
    function CMap=getCMap3(A,B,C,atla,n)
        nA=(A(:)-min(A(:)))./(max(A(:))-min(A(:)));
        nB=(B(:)-min(B(:)))./(max(B(:))-min(B(:)));
        nC=(C(:)-min(C(:)))./(max(C(:))-min(C(:)));
        nA=(ceil(nA.*n)-1)./(n-1);
        nB=(ceil(nB.*n)-1)./(n-1);
        nC=(ceil(nC.*n)-1)./(n-1);
        nA(nA<0)=0;nB(nB<0)=0;nC(nC<0)=0;

        colorAB=atla(1,:).*(1-nA).*(1-nB).*(1-nC)+...
                atla(2,:).*(nA).*(1-nB).*(1-nC)+...
                atla(3,:).*(1-nA).*(nB).*(1-nC)+...
                atla(4,:).*(1-nA).*(1-nB).*(nC)+...
                atla(5,:).*(nA).*(nB).*(1-nC)+...
                atla(6,:).*(1-nA).*(nB).*(nC)+...
                atla(7,:).*(nA).*(1-nB).*(nC)+...
                atla(7,:).*(nA).*(nB).*(nC);

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
ax2.XLim=[min(A(:)),max(A(:))];
ax2.YLim=[min(B(:)),max(B(:))];
ax2.ZLim=[min(C(:)),max(C(:))];
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
ax2.ZLabel.String=obj.varName{3};
ax2.ZLabel.FontSize=11;
ax2.Toolbar.Visible='off';
hold(ax2,'on');view(3);
% =========================================================================
% 绘制右上角图例
[AA,BB]=meshgrid(linspace(0,1,obj.pieceNum),...
                 linspace(0,1,obj.pieceNum));

    function newMap=expMap(oriMap)
        newMap=zeros([size(oriMap,1)+1,size(oriMap,2)+1,3]);
        newMap(1:end-1,1:end-1,1)=oriMap(:,:,1);
        newMap(1:end-1,1:end-1,2)=oriMap(:,:,2);
        newMap(1:end-1,1:end-1,3)=oriMap(:,:,3);
    end

[XX,YY]=meshgrid(linspace(ax2.XLim(1),ax2.XLim(2),obj.pieceNum+1),linspace(ax2.YLim(1),ax2.YLim(2),obj.pieceNum+1));
tCMap=getCMap2(AA,BB,atla([1,2,3,5],:),obj.pieceNum);tCMap=expMap(tCMap);
surf(ax2,XX,YY,ones(size(XX)).*ax2.ZLim(1),'CData',tCMap,'EdgeColor','none','FaceColor','flat');
tCMap=getCMap2(AA,BB,atla([4,7,6,8],:),obj.pieceNum);tCMap=expMap(tCMap);
surf(ax2,XX,YY,ones(size(XX)).*ax2.ZLim(2),'CData',tCMap,'EdgeColor','none','FaceColor','flat');
% -------------------------------------------------------------------------
[XX,ZZ]=meshgrid(linspace(ax2.XLim(1),ax2.XLim(2),obj.pieceNum+1),linspace(ax2.ZLim(1),ax2.ZLim(2),obj.pieceNum+1));
tCMap=getCMap2(AA,BB,atla([1,2,4,7],:),obj.pieceNum);tCMap=expMap(tCMap);
surf(ax2,XX,ones(size(XX)).*ax2.YLim(1),ZZ,'CData',tCMap,'EdgeColor','none','FaceColor','flat');
tCMap=getCMap2(AA,BB,atla([3,5,6,8],:),obj.pieceNum);tCMap=expMap(tCMap);
surf(ax2,XX,ones(size(XX)).*ax2.YLim(2),ZZ,'CData',tCMap,'EdgeColor','none','FaceColor','flat');
% -------------------------------------------------------------------------
[YY,ZZ]=meshgrid(linspace(ax2.YLim(1),ax2.YLim(2),obj.pieceNum+1),linspace(ax2.ZLim(1),ax2.ZLim(2),obj.pieceNum+1));
tCMap=getCMap2(AA,BB,atla([1,3,4,6],:),obj.pieceNum);tCMap=expMap(tCMap);
surf(ax2,ones(size(YY)).*ax2.XLim(1),YY,ZZ,'CData',tCMap,'EdgeColor','none','FaceColor','flat');
tCMap=getCMap2(AA,BB,atla([2,5,7,8],:),obj.pieceNum);tCMap=expMap(tCMap);
surf(ax2,ones(size(YY)).*ax2.XLim(2),YY,ZZ,'CData',tCMap,'EdgeColor','none','FaceColor','flat');

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