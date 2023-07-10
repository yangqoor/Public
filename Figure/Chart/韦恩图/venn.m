classdef venn
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : hikari

% 使用示例：
% =========================================================================
% X1=randi([1,500],[100,1]);
% X2=randi([1,500],[100,1]);
% X3=randi([1,500],[100,1]);
% X4=randi([1,500],[100,1]);
% X5=randi([1,500],[100,1]);
% X6=randi([1,500],[100,1]);
% X7=randi([1,500],[100,1]);
% XX={X1,X2,X3,X4,X5,X6,X7};
% 
% 
% VN=venn(XX{1:7});
% VN.draw();

    properties
        ax % 绘图坐标区域
        % -----------------------------------------------------------------
        linePnts
        labelSet={' ',' ',' ',' ',' ',' ',' '};
%         labels={'AAA','BBB','CCC','DDD','EEE','FFF','GGG'};
        labelPos
        % -----------------------------------------------------------------
        classNum    % 多边形数量
        dataList    % 数据列表
        pshapeHdl   % polyshape对象
        fillHdl     % fill绘制的半透明多边形
        textHdl     % 绘制文本的句柄
        labelHdl    % 绘制标签的句柄
    end

    methods
        function obj = venn(varargin)
            if isa(varargin{1},'matlab.graphics.axis.Axes')
                obj.ax=varargin{1};varargin(1)=[];
            else
                obj.ax=gca;
            end
            hold on
            obj.classNum=length(varargin);
            obj.dataList=varargin;

            % 获取mat文件中的线条数据
            obj.linePnts=load('LD.mat');
            obj.linePnts=obj.linePnts.lineData;

            % 初始定义标签位置
            obj.labelPos{2}=[-.38,.3;.38,.3];
            obj.labelPos{3}=[-.38,.3;-.38,-.4;.38,-.4];
            obj.labelPos{4}=[-.38,.2;.38,.2;-.15,.3;.15,.3];
            obj.labelPos{5}=[cos(linspace(2*pi/5,2*pi,5)+2*pi/5-pi/7).*.47;
                             sin(linspace(2*pi/5,2*pi,5)+2*pi/5-pi/7).*.47]';
            obj.labelPos{6}=[cos(linspace(2*pi/6,2*pi,6)+2*pi/3-pi/6).*.49;
                             sin(linspace(2*pi/6,2*pi,6)+2*pi/3-pi/6).*.49]';
            obj.labelPos{6}=obj.labelPos{6}+[0,+.09;-.01,-.04;0,+.015;0,-.1;0,0;0,-.015];
            obj.labelPos{7}=[cos(linspace(2*pi/7,2*pi,7)+2*pi/5-pi/7).*.47;
                             sin(linspace(2*pi/7,2*pi,7)+2*pi/5-pi/7).*.47]';
            help venn
        end

        function obj=draw(obj)
            warning off
            % 坐标区域修饰
            obj.ax.XLim=[-.5,.5];
            obj.ax.YLim=[-.5,.5];
            obj.ax.XTick=[];
            obj.ax.YTick=[];
            obj.ax.XColor='none';
            obj.ax.YColor='none';
            obj.ax.PlotBoxAspectRatio=[1,1,1];
            % 循环绘制半透明多边形
            tcolorList=lines(7);
            for i=1:obj.classNum
                tPData=obj.linePnts(obj.classNum).pnts{i};
                obj.pshapeHdl{i}=polyshape(tPData(:,1),tPData(:,2));
                obj.fillHdl(i)=fill(tPData(:,1),tPData(:,2),tcolorList(i,:),...
                    'FaceAlpha',.2,'LineWidth',1.5,'EdgeColor',tcolorList(i,:));
            end
            % 构造初始bool集合
            baseData=[];
            for i=1:obj.classNum
                baseData=[baseData;obj.dataList{i}(:)];
            end
            baseShpae=polyshape([-.5,-.5,.5,.5],[.5,-.5,-.5,.5]);
            pBool=abs(dec2bin((1:(2^obj.classNum-1))'))-48;
            % 循环绘制标签
            for i=1:obj.classNum
                tPos=obj.labelPos{obj.classNum};
                obj.labelHdl(i)=text(tPos(i,1),tPos(i,2),obj.labelSet{i},...
                    'HorizontalAlignment','center','FontName','Arial','FontSize',16);
            end
            % 循环计算数字位置
            for i=1:size(pBool,1)
                tShpae=baseShpae;
                tData=baseData;
                for j=1:size(pBool,2)
                    switch pBool(i,j)
                        case 1
                            tShpae=intersect(tShpae,obj.pshapeHdl{j});
                            tData=intersect(tData,obj.dataList{j});
                        case 0
                            tShpae=subtract(tShpae,obj.pshapeHdl{j});
                            tData=setdiff(tData,obj.dataList{j});
                    end                 
                end
                [cx,cy]=centroid(tShpae);
                obj.textHdl(i)=text(cx,cy,num2str(length(tData)),...
                    'HorizontalAlignment','center','FontName','Arial');
            end  
        end
        % =================================================================
        % 设置标签文本内容
        function obj=labels(obj,varargin)
            tlabel{length(varargin)}=' ';            
            for i=1:length(varargin)
                tlabel{i}=varargin{i};
            end
            obj.labelSet=tlabel;
        end
        % 批量设置多边形格式
        function setPatch(obj,varargin)
            for i=1:obj.classNum
                set(obj.fillHdl(i),varargin{:})
            end
        end
        % 单独设置多边形格式
        function setPatchN(obj,N,varargin)
            for i=1:obj.classNum
                set(obj.fillHdl(N),varargin{:})
            end
        end
        % 设置数值字体
        function setFont(obj,varargin)
            for i=1:length(obj.textHdl)
                set(obj.textHdl(i),varargin{:})
            end
        end
        % 设置标签字体
        function setLabel(obj,varargin)
            for i=1:length(obj.labelHdl)
                set(obj.labelHdl(i),varargin{:})
            end
        end
    end
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : hikari
end