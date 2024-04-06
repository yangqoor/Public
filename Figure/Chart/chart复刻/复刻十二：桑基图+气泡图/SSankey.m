classdef SSankey < handle
% Copyright (c) 2023, Zhaoxu Liu / slandarer
% =========================================================================
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer
% -------------------------------------------------------------------------
% Zhaoxu Liu / slandarer (2023). sankey plot 
% (https://www.mathworks.com/matlabcentral/fileexchange/128679-sankey-plot), 
% MATLAB Central File Exchange. 检索来源 2023/4/28.
    properties
        Source;Target;Value;
        SourceInd;TargetInd;
        Layer;LayerPos;
        AdjMat;BoolMat;
        RenderingMethod='interp'  % 'left'/'right'/'interp'/'map'/'simple'
        LabelLocation='left'      % 'left'/'right'/'top'/'center'/'bottom'
        Align='center'            % 'up'/'down'/'center'
        BlockScale=0.05;          %  BlockScale>0 ! !
        Sep=0.05;                 %  Sep>=0 ! !
        NodeList={};
        ColorList=[[65,140,240;252,180,65;224,64,10;5,100,146;191,191,191;26,59,105;255,227,130;18,156,221;
                    202,107,75;0,92,219;243,210,136;80,99,129;241,185,168;224,131,10;120,147,190]./255;
                   [127,91,93;187,128,110;197,173,143;59,71,111;104,95,126;76,103,86;112,112,124;
                    72,39,24;197,119,106;160,126,88;238,208,146]./255];
        BlockHdl;LinkHdl;LabelHdl;ax;Parent;
        BN;LN;VN;TotalLen;SepLen;
        arginList={'RenderingMethod','LabelLocation','BlockScale',...
                   'Sep','Align','ColorList','Parent','NameList'}
    end
% 构造函数 =================================================================
    methods
        function obj=SSankey(varargin)
            % 获取基本数据 -------------------------------------------------
            if isa(varargin{1},'matlab.graphics.axis.Axes')
                obj.ax=varargin{1};varargin(1)=[];
            else  
            end
            obj.Source=varargin{1};
            obj.Target=varargin{2};
            obj.Value=varargin{3};
            varargin(1:3)=[];
            % 获取其他信息 -------------------------------------------------
            for i=1:2:(length(varargin)-1)
                tid=ismember(obj.arginList,varargin{i});
                if any(tid)
                obj.(obj.arginList{tid})=varargin{i+1};
                end
            end
            if isempty(obj.ax)&&(~isempty(obj.Parent)),obj.ax=obj.Parent;end
            if isempty(obj.ax),obj.ax=gca;end
            obj.ax.NextPlot='add';
            % 基本数据预处理 -----------------------------------------------
            if isempty(obj.NodeList)
                obj.NodeList=[obj.Source;obj.Target];
                obj.NodeList=unique(obj.NodeList,'stable');
            end
            obj.BN=length(obj.NodeList);
            if length(obj.NodeList)>size(obj.ColorList,1)
                obj.ColorList=[obj.ColorList;rand(length(obj.NodeList),3).*.7];
            end
            obj.VN=length(obj.Value);
            % 坐标区域基础设置 ---------------------------------------------
            obj.ax.YDir='reverse';
            obj.ax.XColor='none';
            obj.ax.YColor='none';
        end
% Copyright (c) 2023, Zhaoxu Liu / slandarer
% =========================================================================
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer
% -------------------------------------------------------------------------
% Zhaoxu Liu / slandarer (2023). sankey plot 
% (https://www.mathworks.com/matlabcentral/fileexchange/128679-sankey-plot), 
% MATLAB Central File Exchange. 检索来源 2023/4/28.
% 绘图函数 =================================================================
        function draw(obj)
            % 生成整体邻接矩阵 ---------------------------------------------
            obj.AdjMat=zeros(obj.BN,obj.BN);
            for i=1:length(obj.Source)
                obj.SourceInd(i)=find(strcmp(obj.Source{i},obj.NodeList));
                obj.TargetInd(i)=find(strcmp(obj.Target{i},obj.NodeList));
                obj.AdjMat(obj.SourceInd(i),obj.TargetInd(i))=obj.Value{i};
            end
            obj.BoolMat=abs(obj.AdjMat)>0;
            % 计算每个对象位于的层、每层方块长度、每个方块位置 ----------------
            obj.Layer=zeros(obj.BN,1);
            obj.Layer(sum(obj.BoolMat,1)==0)=1;
            startMat=diag(obj.Layer);
            for i=1:(obj.BN-1)
                tLayer=(sum(startMat*obj.BoolMat^i,1)>0).*(i+1);
                obj.Layer=max([obj.Layer,tLayer'],[],2);
            end
            obj.LN=max(obj.Layer);
            obj.TotalLen=max([sum(obj.AdjMat,1).',sum(obj.AdjMat,2)],[],2);
            obj.SepLen=max(obj.TotalLen).*obj.Sep;
            obj.LayerPos=zeros(obj.BN,4);
            for i=1:obj.LN
                tBlockInd=find(obj.Layer==i);
                tBlockLen=[0;cumsum(obj.TotalLen(tBlockInd))];
                tY1=tBlockLen(1:end-1)+(0:length(tBlockInd)-1).'.*obj.SepLen;
                tY2=tBlockLen(2:end)+(0:length(tBlockInd)-1).'.*obj.SepLen;
                obj.LayerPos(tBlockInd,3)=tY1;
                obj.LayerPos(tBlockInd,4)=tY2;
                % for j=1:length(tY2)
                %     plot([i,i],[tY1(j),tY2(j)],'LineWidth',2)
                % end
            end
            obj.LayerPos(:,1)=obj.Layer;
            obj.LayerPos(:,2)=obj.Layer+obj.BlockScale;
            % 根据对齐方式调整Y坐标 -----------------------------------------
            tMinY=min(obj.LayerPos(:,3));
            tMaxY=max(obj.LayerPos(:,4));
            for i=1:obj.LN
                tBlockInd=find(obj.Layer==i);
                tBlockPos3=obj.LayerPos(tBlockInd,3);
                tBlockPos4=obj.LayerPos(tBlockInd,4);
                switch obj.Align
                    case 'up'
                    case 'down'
                        obj.LayerPos(tBlockInd,3)=obj.LayerPos(tBlockInd,3)+tMaxY-max(tBlockPos4);
                        obj.LayerPos(tBlockInd,4)=obj.LayerPos(tBlockInd,4)+tMaxY-max(tBlockPos4);
                    case 'center'
                        obj.LayerPos(tBlockInd,3)=obj.LayerPos(tBlockInd,3)+...
                            min(tBlockPos3)/2-max(tBlockPos4)/2+tMinY/2-tMaxY/2;
                        obj.LayerPos(tBlockInd,4)=obj.LayerPos(tBlockInd,4)+...
                            min(tBlockPos3)/2-max(tBlockPos4)/2+tMinY/2-tMaxY/2;
                end
            end
            % 绘制连接 -----------------------------------------------------
            for i=1:obj.VN
                tSource=obj.SourceInd(i);
                tTarget=obj.TargetInd(i);
                tS1=sum(obj.AdjMat(tSource,1:(tTarget-1)))+obj.LayerPos(tSource,3);
                tS2=sum(obj.AdjMat(tSource,1:tTarget))+obj.LayerPos(tSource,3);
                tT1=sum(obj.AdjMat(1:(tSource-1),tTarget))+obj.LayerPos(tTarget,3);
                tT2=sum(obj.AdjMat(1:tSource,tTarget))+obj.LayerPos(tTarget,3);
                if isempty(tS1),tS1=0;end
                if isempty(tT1),tT1=0;end
                tX=[obj.LayerPos(tSource,1),obj.LayerPos(tSource,2),obj.LayerPos(tTarget,1),obj.LayerPos(tTarget,2)];
                qX=linspace(obj.LayerPos(tSource,1),obj.LayerPos(tTarget,2),200);qT=linspace(0,1,50);
                qY1=interp1(tX,[tS1,tS1,tT1,tT1],qX,'pchip');
                qY2=interp1(tX,[tS2,tS2,tT2,tT2],qX,'pchip');
                XX=repmat(qX,[50,1]);YY=qY1.*(qT'.*0+1)+(qY2-qY1).*(qT');
                MeshC=ones(50,200,3);
                switch obj.RenderingMethod
                    case 'left'
                        MeshC(:,:,1)=MeshC(:,:,1).*obj.ColorList(tSource,1);
                        MeshC(:,:,2)=MeshC(:,:,2).*obj.ColorList(tSource,2);
                        MeshC(:,:,3)=MeshC(:,:,3).*obj.ColorList(tSource,3);
                    case 'right'
                        MeshC(:,:,1)=MeshC(:,:,1).*obj.ColorList(tTarget,1);
                        MeshC(:,:,2)=MeshC(:,:,2).*obj.ColorList(tTarget,2);
                        MeshC(:,:,3)=MeshC(:,:,3).*obj.ColorList(tTarget,3);
                    case 'interp'
                        MeshC(:,:,1)=repmat(linspace(obj.ColorList(tSource,1),obj.ColorList(tTarget,1),200),[50,1]);
                        MeshC(:,:,2)=repmat(linspace(obj.ColorList(tSource,2),obj.ColorList(tTarget,2),200),[50,1]);
                        MeshC(:,:,3)=repmat(linspace(obj.ColorList(tSource,3),obj.ColorList(tTarget,3),200),[50,1]);
                    case 'map'
                        MeshC=MeshC(:,:,1).*obj.Value{i};
                    case 'simple'
                        MeshC(:,:,1)=MeshC(:,:,1).*.6;
                        MeshC(:,:,2)=MeshC(:,:,2).*.6;
                        MeshC(:,:,3)=MeshC(:,:,3).*.6;
                end
                obj.LinkHdl(i)=surf(obj.ax,XX,YY,XX.*0,'EdgeColor','none','FaceAlpha',.3,'CData',MeshC);
            end
            % 绘制方块 -----------------------------------------------------
            for i=1:obj.BN
                obj.BlockHdl(i)=fill(obj.ax,obj.LayerPos(i,[1,2,2,1]),...
                    obj.LayerPos(i,[3,3,4,4]),obj.ColorList(i,:),'EdgeColor','none');
            end
            % 绘制文本 -----------------------------------------------------
            for i=1:obj.BN
                switch obj.LabelLocation
                    case 'right'
                        obj.LabelHdl(i)=text(obj.ax,obj.LayerPos(i,2),mean(obj.LayerPos(i,[3,4])),...
                            [' ',obj.NodeList{i}],'FontSize',15,'FontName','Times New Roman','HorizontalAlignment','left');
                    case 'left'
                        obj.LabelHdl(i)=text(obj.ax,obj.LayerPos(i,1),mean(obj.LayerPos(i,[3,4])),...
                            [obj.NodeList{i},' '],'FontSize',15,'FontName','Times New Roman','HorizontalAlignment','right');
                    case 'top'
                        obj.LabelHdl(i)=text(obj.ax,mean(obj.LayerPos(i,[1,2])),obj.LayerPos(i,3),...
                            obj.NodeList{i},'FontSize',15,'FontName','Times New Roman','HorizontalAlignment','center','VerticalAlignment','bottom');
                    case 'center'
                        obj.LabelHdl(i)=text(obj.ax,mean(obj.LayerPos(i,[1,2])),mean(obj.LayerPos(i,[3,4])),...
                            obj.NodeList{i},'FontSize',15,'FontName','Times New Roman','HorizontalAlignment','center');
                    case 'bottom'
                        obj.LabelHdl(i)=text(obj.ax,mean(obj.LayerPos(i,[1,2])),obj.LayerPos(i,4),...
                            obj.NodeList{i},'FontSize',15,'FontName','Times New Roman','HorizontalAlignment','center','VerticalAlignment','top');
                end
            end
            % -------------------------------------------------------------
            axis tight;help SSankey
        end
% Copyright (c) 2023, Zhaoxu Liu / slandarer
% =========================================================================
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer
% -------------------------------------------------------------------------
% Zhaoxu Liu / slandarer (2023). sankey plot 
% (https://www.mathworks.com/matlabcentral/fileexchange/128679-sankey-plot), 
% MATLAB Central File Exchange. 检索来源 2023/4/28.
% =========================================================================
        function setBlock(obj,n,varargin)
            set(obj.BlockHdl(n),varargin{:})
        end
        function setLink(obj,n,varargin)
            set(obj.LinkHdl(n),varargin{:})
        end
        function setLabel(obj,n,varargin)
            set(obj.LabelHdl(n),varargin{:})
        end
        function moveBlockY(obj,n,dy)
            obj.LayerPos(n,[3,4])=obj.LayerPos(n,[3,4])-dy;
            set(obj.BlockHdl(n),'YData',obj.LayerPos(n,[3,3,4,4]));
            switch obj.LabelLocation
                case 'right',set(obj.LabelHdl(n),'Position',[obj.LayerPos(n,2),mean(obj.LayerPos(n,[3,4]))]);
                case 'left',set(obj.LabelHdl(n),'Position',[obj.LayerPos(n,1),mean(obj.LayerPos(n,[3,4]))]);
                case 'top',set(obj.LabelHdl(n),'Position',[mean(obj.LayerPos(n,[1,2])),obj.LayerPos(n,3)]);
                case 'center',set(obj.LabelHdl(n),'Position',[mean(obj.LayerPos(n,[1,2])),mean(obj.LayerPos(n,[3,4]))]);
                case 'bottom',set(obj.LabelHdl(n),'Position',[mean(obj.LayerPos(n,[1,2])),obj.LayerPos(n,4)]);
            end
            for i=1:obj.VN
                tSource=obj.SourceInd(i);
                tTarget=obj.TargetInd(i);
                if tSource==n||tTarget==n
                    tS1=sum(obj.AdjMat(tSource,1:(tTarget-1)))+obj.LayerPos(tSource,3);
                    tS2=sum(obj.AdjMat(tSource,1:tTarget))+obj.LayerPos(tSource,3);
                    tT1=sum(obj.AdjMat(1:(tSource-1),tTarget))+obj.LayerPos(tTarget,3);
                    tT2=sum(obj.AdjMat(1:tSource,tTarget))+obj.LayerPos(tTarget,3);
                    if isempty(tS1),tS1=0;end
                    if isempty(tT1),tT1=0;end
                    tX=[obj.LayerPos(tSource,1),obj.LayerPos(tSource,2),obj.LayerPos(tTarget,1),obj.LayerPos(tTarget,2)];
                    qX=linspace(obj.LayerPos(tSource,1),obj.LayerPos(tTarget,2),200);qT=linspace(0,1,50);
                    qY1=interp1(tX,[tS1,tS1,tT1,tT1],qX,'pchip');
                    qY2=interp1(tX,[tS2,tS2,tT2,tT2],qX,'pchip');
                    YY=qY1.*(qT'.*0+1)+(qY2-qY1).*(qT');
                    set(obj.LinkHdl(i),'YData',YY);
                end
            end
        end
    end
% Copyright (c) 2023, Zhaoxu Liu / slandarer
% =========================================================================
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer
% -------------------------------------------------------------------------
% Zhaoxu Liu / slandarer (2023). sankey plot 
% (https://www.mathworks.com/matlabcentral/fileexchange/128679-sankey-plot), 
% MATLAB Central File Exchange. 检索来源 2023/4/28.
end