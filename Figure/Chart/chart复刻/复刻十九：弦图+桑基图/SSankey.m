classdef SSankey < handle
% Copyright (c) 2023-2024, Zhaoxu Liu / slandarer
% =========================================================================
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer
% =========================================================================
% # update 2.0.0(2024-02-04)
% see natureSankeyDemo1.m
%
% + 层向右对齐(Align layers to the right)
%   try : obj.LayerOrder='reverse';
%
% + 单独调整每层间隙大小(Adjust the Sep size of each layer separately)
%   try : obj.Sep=[.2,.06,.05,.07,.07,.08,.15];
% =========================================================================
% # update 3.0.0(2024-04-15)
% see sankeyDemo9.m sankeyDemo10.m sankeyDemo11.m
% 
% + 通过邻接矩阵创建桑基图(Creating a Sankey diagram through adjacency matrix)
%   method 1 :
%     SK=SSankey([],[],[],'AdjMat',adjMat);
%   method 2 :
%     SK=SSankey([],[],[],'NodeList',nodeList,'AdjMat',adjMat)
%   method 3 :
%     SK=SSankey([],[],[]);
%     SK.AdjMat=adjMat;
% 
%   try : 
%     adjMat=zeros(10,10);
%     layerNum=[3,3,2,2];
%     layerInd=cumsum([0,layerNum]);
%     for i=1:length(layerInd)-2
%         adjMat(layerInd(i)+1:layerInd(i+1),layerInd(i+1)+1:layerInd(i+2))=randi([1,6],[layerNum([i,i+1])]);
%     end
%     disp(adjMat)
%     SK=SSankey([],[],[],'NodeList',nodeList,'AdjMat',adjMat);
%     SK.draw()
%
% + 每层情况可被设置(Each layer state can be set)
%   try : obj.Layer = [1,1,1, 2,2,2, 3,3, 4,4,...];
% 
% + 每个节点可在x方向上位移(Each node can be displaced in the x-direction)
%   try : obj.moveBlockX(n,dx)
% =========================================================================
% # update 3.1.0(2024-05-15)
% see sankeyDemo12.m sankeyDemo13.m
% + 为链接添加显示数值的文本(Display value labels for each link)
%   try : SK.ValueLabelLocation='left';
% =========================================================================
% # update 4.0.0(2024-05-17)
% see  sankeyDemo14.m sankeyDemo15.m
% + 增添节点及链接(Add node and link)
%   try : obj.addNode(name,layer)
%   try : obj.addLink(source,target,value)


    properties
        Source;Target;Value;
        SourceInd;TargetInd;
        Layer;LayerPos;MovePos;LayerOrder='normal';
        AdjMat;BoolMat;
        RenderingMethod='interp'   % 'left'/'right'/'interp'/'map'/'simple'
        LabelLocation='left'       % 'left'/'right'/'top'/'center'/'bottom'
        ValueLabelLocation='none'  % 'left'/'right'/'center'/'none'
        ValueLabelFormat=@(X)num2str(X);
        Align='center'             % 'up'/'down'/'center'
        BlockScale=0.05;           %  BlockScale>0 ! !
        Sep=0.05;                  %  Sep>=0 ! !
        NodeList={};
        ColorList=[[65,140,240;252,180,65;224,64,10;5,100,146;191,191,191;26,59,105;255,227,130;18,156,221;
                    202,107,75;0,92,219;243,210,136;80,99,129;241,185,168;224,131,10;120,147,190]./255;
                   [127,91,93;187,128,110;197,173,143;59,71,111;104,95,126;76,103,86;112,112,124;
                    72,39,24;197,119,106;160,126,88;238,208,146]./255];
        BlockHdl;LinkHdl;LabelHdl;ValueLabelHdl;ax;Parent;
        BN;LN;VN;TotalLen;SepLen;
        arginList={'RenderingMethod','LabelLocation','ValueLabelLocation','BlockScale','Layer'...
                   'Sep','Align','ColorList','Parent','NodeList','AdjMat'}
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
                if isempty(obj.Source)
                    if ~isempty(obj.AdjMat)
                        obj.NodeList=compose('node%d',1:size(obj.AdjMat,1));
                    end
                else
                    obj.NodeList=[obj.Source;obj.Target];
                    obj.NodeList=unique(obj.NodeList,'stable');
                end
            end
            obj.BN=length(obj.NodeList);
            if length(obj.NodeList)>size(obj.ColorList,1)
                obj.ColorList=[obj.ColorList;rand(length(obj.NodeList),3).*.7];
            end
            obj.MovePos=zeros(obj.BN,4);
            
            % obj.VN=length(obj.Value);
            % 坐标区域基础设置 ---------------------------------------------
            obj.ax.YDir='reverse';
            obj.ax.XColor='none';
            obj.ax.YColor='none';
        end
% 绘图函数 =================================================================
        function draw(obj)      
            % 生成整体邻接矩阵 ---------------------------------------------
            obj.getAdjMat()
            % help SSankey
            obj.BoolMat=abs(obj.AdjMat)>0;
            if any(any(obj.BoolMat+obj.BoolMat.'==2))
                warning('Currently, bidirectional flow sankey diagram plotting is not supported.')
            end
            obj.VN=sum(sum(obj.BoolMat));
            % 计算每个对象位于的层、每层方块长度、每个方块位置 ----------------
            if isempty(obj.Layer)
                obj.getLayer()
            end
            obj.getLayerPos()
            % 绘制连接 -----------------------------------------------------
            for i=1:obj.VN
                obj.drawLink(i)
            end
            % 绘制方块 -----------------------------------------------------
            for i=1:obj.BN
                drawNode(obj,i)
            end
            % -------------------------------------------------------------
            axis tight;
        end
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
        function setValueLabel(obj,n,varargin)
            set(obj.ValueLabelHdl(n),varargin{:})
        end
% =========================================================================
        function addLink(obj,S,T,V)
            obj.getAdjMat()
            if isempty(obj.BlockHdl)
                obj.AdjMat(S,T)=obj.AdjMat(S,T)+abs(V);
            else
                if obj.AdjMat(S,T)==0
                    obj.AdjMat(S,T)=obj.AdjMat(S,T)+abs(V);
                    obj.getLayerPos()
                    [M,N]=find(obj.AdjMat~=0);
                    obj.drawLink(find(M==S&N==T))
                else
                    obj.AdjMat(S,T)=obj.AdjMat(S,T)+abs(V);
                    obj.getLayerPos()
                end
                % disp(obj.AdjMat)
                obj.refresh()
            end
        end
        function addNode(obj,name,layer)
            obj.getAdjMat()
            obj.AdjMat(end+1,:)=0;obj.AdjMat(:,end+1)=0;
            if nargin<2
                obj.NodeList{end+1}=compose('node%d',size(obj.AdjMat,1));
            else
                obj.NodeList{end+1}=name;
            end
            obj.BN=length(obj.NodeList);
            obj.BoolMat=abs(obj.AdjMat)>0;
            if any(any(obj.BoolMat+obj.BoolMat.'==2))
                warning('Currently, bidirectional flow sankey diagram plotting is not supported.')
            end
            obj.VN=sum(sum(obj.BoolMat));
            if isempty(obj.Layer)
                obj.getLayer()
                if nargin<3,obj.Layer(end)=max(obj.Layer);else,obj.Layer(end)=layer;end
            else
                if nargin<3,obj.Layer(end+1)=max(obj.Layer);else,obj.Layer(end+1)=layer;end
            end
            obj.ColorList(end+1,:)=rand(1,3).*.7;
            obj.MovePos(end+1,:)=0;
            % -------------------------------------------------------------
            if isempty(obj.BlockHdl)
            else
                obj.getLayerPos()
                obj.drawNode(length(obj.NodeList))
                N=find(obj.Layer==obj.Layer(end));
                for n=1:length(N)
                    obj.moveBlock(N(n))
                end
            end
        end
% =========================================================================
        function refresh(obj)
            tLayerPos=obj.MovePos+obj.LayerPos;
            obj.BoolMat=abs(obj.AdjMat)>0;
            if any(any(obj.BoolMat+obj.BoolMat.'==2))
                warning('Currently, bidirectional flow sankey diagram plotting is not supported.')
            end
            obj.VN=sum(sum(obj.BoolMat));
            for n=1:obj.BN
                set(obj.BlockHdl(n),'XData',tLayerPos(n,[1,2,2,1]));
                set(obj.BlockHdl(n),'YData',tLayerPos(n,[3,3,4,4]));
                switch obj.LabelLocation
                    case 'right',set(obj.LabelHdl(n),'Position',[tLayerPos(n,2),mean(tLayerPos(n,[3,4]))]);
                    case 'left',set(obj.LabelHdl(n),'Position',[tLayerPos(n,1),mean(tLayerPos(n,[3,4]))]);
                    case 'top',set(obj.LabelHdl(n),'Position',[mean(tLayerPos(n,[1,2])),tLayerPos(n,3)]);
                    case 'center',set(obj.LabelHdl(n),'Position',[mean(tLayerPos(n,[1,2])),mean(tLayerPos(n,[3,4]))]);
                    case 'bottom',set(obj.LabelHdl(n),'Position',[mean(tLayerPos(n,[1,2])),tLayerPos(n,4)]);
                end
            end
            [obj.SourceInd,obj.TargetInd]=find(obj.AdjMat~=0);
            for n=1:obj.VN
                tSource=obj.SourceInd(n);
                tTarget=obj.TargetInd(n);
                tS1=sum(obj.AdjMat(tSource,1:(tTarget-1)))+tLayerPos(tSource,3);
                tS2=sum(obj.AdjMat(tSource,1:tTarget))+tLayerPos(tSource,3);
                tT1=sum(obj.AdjMat(1:(tSource-1),tTarget))+tLayerPos(tTarget,3);
                tT2=sum(obj.AdjMat(1:tSource,tTarget))+tLayerPos(tTarget,3);
                if isempty(tS1),tS1=0;end
                if isempty(tT1),tT1=0;end
                tX=[tLayerPos(tSource,1),tLayerPos(tSource,2),tLayerPos(tTarget,1),tLayerPos(tTarget,2)];
                qX=linspace(tLayerPos(tSource,1),tLayerPos(tTarget,2),200);qT=linspace(0,1,50);
                qY1=interp1(tX,[tS1,tS1,tT1,tT1],qX,'pchip');
                qY2=interp1(tX,[tS2,tS2,tT2,tT2],qX,'pchip');
                YY=qY1.*(qT'.*0+1)+(qY2-qY1).*(qT');
                set(obj.LinkHdl(n),'YData',YY,'XData',qX);
                set(obj.ValueLabelHdl(n),'String',[' ',obj.ValueLabelFormat(obj.AdjMat(obj.SourceInd(n),obj.TargetInd(n)))])
                switch obj.ValueLabelLocation
                    case 'left'
                        set(obj.ValueLabelHdl(n),'Position',[tLayerPos(tSource,2),tS1/2+tS2/2]);
                    case 'right'
                        set(obj.ValueLabelHdl(n),'Position',[tLayerPos(tTarget,1),tT1/2+tT2/2]);
                    case 'center'
                        set(obj.ValueLabelHdl(n),'Position',[tLayerPos(tSource,2)/2+tLayerPos(tTarget,1)/2,tS1/4+tS2/4+tT1/4+tT2/4]);
                    case 'none'
                        set(obj.ValueLabelHdl(n),'Position',[tLayerPos(tSource,2),tS1/2+tS2/2]);
                end
            end
        end
        function drawLink(obj,n)
            % 绘制连接 -----------------------------------------------------
            [obj.SourceInd,obj.TargetInd]=find(obj.AdjMat~=0);
            tSource=obj.SourceInd(n);
            tTarget=obj.TargetInd(n);
            tS1=sum(obj.AdjMat(tSource,1:(tTarget-1)))+obj.LayerPos(tSource,3);
            tS2=sum(obj.AdjMat(tSource,1:tTarget))+obj.LayerPos(tSource,3);
            tT1=sum(obj.AdjMat(1:(tSource-1),tTarget))+obj.LayerPos(tTarget,3);
            tT2=sum(obj.AdjMat(1:tSource,tTarget))+obj.LayerPos(tTarget,3);
            if isempty(tS1),tS1=0;end
            if isempty(tT1),tT1=0;end
            tX=[obj.LayerPos(tSource,1),obj.LayerPos(tSource,2),obj.LayerPos(tTarget,1),obj.LayerPos(tTarget,2)];
            if abs(tX(1)-tX(3))<eps
                warning('Currently, flow between the same layer is not supported.')
            end
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
                    MeshC=MeshC(:,:,1).*obj.Value{n};
                case 'simple'
                    MeshC(:,:,1)=MeshC(:,:,1).*.6;
                    MeshC(:,:,2)=MeshC(:,:,2).*.6;
                    MeshC(:,:,3)=MeshC(:,:,3).*.6;
            end
            tLinkHdl=surf(obj.ax,XX,YY,XX.*0,'EdgeColor','none','FaceAlpha',.3,'CData',MeshC);
            obj.LinkHdl=[obj.LinkHdl(1:n-1),tLinkHdl,obj.LinkHdl(n:end)];
            switch obj.ValueLabelLocation
                case 'left'
                    tValueLabelHdl=text(obj.LayerPos(tSource,2),tS1/2+tS2/2,[' ',obj.ValueLabelFormat(obj.AdjMat(obj.SourceInd(n),obj.TargetInd(n)))],...
                        'FontSize',12,'FontName','Times New Roman','HorizontalAlignment','left');
                case 'right'
                    tValueLabelHdl=text(obj.LayerPos(tTarget,1),tT1/2+tT2/2,[obj.ValueLabelFormat(obj.AdjMat(obj.SourceInd(n),obj.TargetInd(n))),' '],...
                        'FontSize',12,'FontName','Times New Roman','HorizontalAlignment','right');
                case 'center'
                    tValueLabelHdl=text(obj.LayerPos(tSource,2)/2+obj.LayerPos(tTarget,1)/2,tS1/4+tS2/4+tT1/4+tT2/4,obj.ValueLabelFormat(obj.AdjMat(obj.SourceInd(n),obj.TargetInd(n))),...
                        'FontSize',12,'FontName','Times New Roman','HorizontalAlignment','center');
                case 'none'
                    tValueLabelHdl=text(obj.LayerPos(tSource,2),tS1/2+tS2/2,[' ',obj.ValueLabelFormat(obj.AdjMat(obj.SourceInd(n),obj.TargetInd(n)))],...
                        'FontSize',12,'FontName','Times New Roman','HorizontalAlignment','left', 'Visible','off');
            end
            obj.ValueLabelHdl=[obj.ValueLabelHdl(1:n-1),tValueLabelHdl,obj.ValueLabelHdl(n:end)];
        end
        function drawNode(obj,n)
            % 绘制方块 -----------------------------------------------------
            obj.BlockHdl(n)=fill(obj.ax,obj.LayerPos(n,[1,2,2,1]),...
                obj.LayerPos(n,[3,3,4,4]),obj.ColorList(n,:),'EdgeColor','none');
            % 绘制文本 -----------------------------------------------------
            switch obj.LabelLocation
                case 'right'
                    obj.LabelHdl(n)=text(obj.ax,obj.LayerPos(n,2),mean(obj.LayerPos(n,[3,4])),...
                        [' ',obj.NodeList{n}],'FontSize',15,'FontName','Times New Roman','HorizontalAlignment','left');
                case 'left'
                    obj.LabelHdl(n)=text(obj.ax,obj.LayerPos(n,1),mean(obj.LayerPos(n,[3,4])),...
                        [obj.NodeList{n},' '],'FontSize',15,'FontName','Times New Roman','HorizontalAlignment','right');
                case 'top'
                    obj.LabelHdl(n)=text(obj.ax,mean(obj.LayerPos(n,[1,2])),obj.LayerPos(n,3),...
                        obj.NodeList{n},'FontSize',15,'FontName','Times New Roman','HorizontalAlignment','center','VerticalAlignment','bottom');
                case 'center'
                    obj.LabelHdl(n)=text(obj.ax,mean(obj.LayerPos(n,[1,2])),mean(obj.LayerPos(n,[3,4])),...
                        obj.NodeList{n},'FontSize',15,'FontName','Times New Roman','HorizontalAlignment','center');
                case 'bottom'
                    obj.LabelHdl(n)=text(obj.ax,mean(obj.LayerPos(n,[1,2])),obj.LayerPos(n,4),...
                        obj.NodeList{n},'FontSize',15,'FontName','Times New Roman','HorizontalAlignment','center','VerticalAlignment','top');
            end
        end
% =========================================================================
        function getAdjMat(obj)
            if isempty(obj.AdjMat)
                obj.AdjMat=zeros(obj.BN,obj.BN);
                for i=1:length(obj.Source)
                    obj.SourceInd(i)=find(strcmp(obj.Source{i},obj.NodeList));
                    obj.TargetInd(i)=find(strcmp(obj.Target{i},obj.NodeList));
                    obj.AdjMat(obj.SourceInd(i),obj.TargetInd(i))=obj.Value{i};
                end
            end
        end
        function getLayer(obj)
            if strcmp(obj.LayerOrder,'normal')
                obj.Layer=zeros(obj.BN,1);
                obj.Layer(sum(obj.BoolMat,1)==0)=1;
                startMat=diag(obj.Layer);
                for i=1:(obj.BN-1)
                    tLayer=(sum(startMat*obj.BoolMat^i,1)>0).*(i+1);
                    obj.Layer=max([obj.Layer,tLayer'],[],2);
                end
            else
                obj.Layer=zeros(obj.BN,1);
                obj.Layer(sum(obj.BoolMat,2)==0)=-1;
                startMat=diag(obj.Layer);
                for i=1:(obj.BN-1)
                    tLayer=(sum(startMat*(obj.BoolMat.')^i,1)<0).*(-i-1);
                    obj.Layer=min([obj.Layer,tLayer'],[],2);
                end
                obj.Layer=obj.Layer-min(obj.Layer)+1;
            end
        end
        function getLayerPos(obj)
            obj.Layer=obj.Layer(:);
            obj.LN=max(obj.Layer);
            obj.TotalLen=max([sum(obj.AdjMat,1).',sum(obj.AdjMat,2)],[],2);
            obj.TotalLen(obj.TotalLen==0)=mean(obj.TotalLen)/2;
            obj.SepLen=max(obj.TotalLen).*obj.Sep;
            obj.LayerPos=zeros(obj.BN,4);
            for i=1:obj.LN
                tBlockInd=find(obj.Layer==i);
                tBlockLen=[0;cumsum(obj.TotalLen(tBlockInd))];
                tY1=tBlockLen(1:end-1)+(0:length(tBlockInd)-1).'.*obj.SepLen(min(i,length(obj.Sep)));
                tY2=tBlockLen(2:end)+(0:length(tBlockInd)-1).'.*obj.SepLen(min(i,length(obj.Sep)));
                obj.LayerPos(tBlockInd,3)=tY1;
                obj.LayerPos(tBlockInd,4)=tY2;
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
        end
% =========================================================================
        function moveBlock(obj,n)
            tLayerPos=obj.MovePos+obj.LayerPos;
            set(obj.BlockHdl(n),'XData',tLayerPos(n,[1,2,2,1]));
            set(obj.BlockHdl(n),'YData',tLayerPos(n,[3,3,4,4]));
            switch obj.LabelLocation
                case 'right',set(obj.LabelHdl(n),'Position',[tLayerPos(n,2),mean(tLayerPos(n,[3,4]))]);
                case 'left',set(obj.LabelHdl(n),'Position',[tLayerPos(n,1),mean(tLayerPos(n,[3,4]))]);
                case 'top',set(obj.LabelHdl(n),'Position',[mean(tLayerPos(n,[1,2])),tLayerPos(n,3)]);
                case 'center',set(obj.LabelHdl(n),'Position',[mean(tLayerPos(n,[1,2])),mean(tLayerPos(n,[3,4]))]);
                case 'bottom',set(obj.LabelHdl(n),'Position',[mean(tLayerPos(n,[1,2])),tLayerPos(n,4)]);
            end
            for i=1:obj.VN
                tSource=obj.SourceInd(i);
                tTarget=obj.TargetInd(i);
                if tSource==n||tTarget==n
                    tS1=sum(obj.AdjMat(tSource,1:(tTarget-1)))+tLayerPos(tSource,3);
                    tS2=sum(obj.AdjMat(tSource,1:tTarget))+tLayerPos(tSource,3);
                    tT1=sum(obj.AdjMat(1:(tSource-1),tTarget))+tLayerPos(tTarget,3);
                    tT2=sum(obj.AdjMat(1:tSource,tTarget))+tLayerPos(tTarget,3);
                    if isempty(tS1),tS1=0;end
                    if isempty(tT1),tT1=0;end
                    tX=[tLayerPos(tSource,1),tLayerPos(tSource,2),tLayerPos(tTarget,1),tLayerPos(tTarget,2)];
                    qX=linspace(tLayerPos(tSource,1),tLayerPos(tTarget,2),200);qT=linspace(0,1,50);
                    qY1=interp1(tX,[tS1,tS1,tT1,tT1],qX,'pchip');
                    qY2=interp1(tX,[tS2,tS2,tT2,tT2],qX,'pchip');
                    YY=qY1.*(qT'.*0+1)+(qY2-qY1).*(qT');
                    set(obj.LinkHdl(i),'YData',YY,'XData',qX);
                    switch obj.ValueLabelLocation
                        case 'left'
                            set(obj.ValueLabelHdl(i),'Position',[tLayerPos(tSource,2),tS1/2+tS2/2]);
                        case 'right'
                            set(obj.ValueLabelHdl(i),'Position',[tLayerPos(tTarget,1),tT1/2+tT2/2]);
                        case 'center'
                             set(obj.ValueLabelHdl(i),'Position',[tLayerPos(tSource,2)/2+tLayerPos(tTarget,1)/2,tS1/4+tS2/4+tT1/4+tT2/4]);
                        case 'none'
                            set(obj.ValueLabelHdl(i),'Position',[tLayerPos(tSource,2),tS1/2+tS2/2]);
                    end
                end
            end
        end
        function moveBlockX(obj,n,dx)
            obj.MovePos(n,[1,2])=obj.MovePos(n,[1,2])+dx;
            obj.moveBlock(n)
        end
        function moveBlockY(obj,n,dy)
            obj.MovePos(n,[3,4])=obj.MovePos(n,[3,4])-dy;
            obj.moveBlock(n)
        end
    end
% Copyright (c) 2023-2024, Zhaoxu Liu / slandarer
% =========================================================================
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer
% -------------------------------------------------------------------------
end