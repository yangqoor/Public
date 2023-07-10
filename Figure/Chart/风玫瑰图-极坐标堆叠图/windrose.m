classdef windrose
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : hikari
%
% 使用实例：
% =========================================================================
% % 随机数据生成并拼成矩阵
% h1=randi([8,18],[1,35])+rand([1,35]);
% h2=randi([2,8],[1,35])+rand([1,35]);
% h3=randi([0,3],[1,35])+rand([1,35]);
% h=[h1;h2;h3];
% 
% wr=windrose(h);% 等同于 wr=windrose(h,[0,2*pi]);
% % wr=windrose(h,[0:5:30,31:1:59]./59.*2.*pi);
% wr=wr.draw();
% 
% wr.setStyle('LineWidth',1.2,'FaceAlpha',.8,'EdgeColor',[.2,.2,.2])
% wr.setLConf(4)
% 
% % 将第二层变成绿
% % wr.setColor([.1,.8,.1],2)
% % 将第一第二层变成黑色
% % wr.setColor([0,.2,0;0 0 .2],[1,3])
% 
% % 添加图例
% lgd=legend(wr.Children,'CLASS 1','CLASS 2','CLASS 3');
% lgd.Location='best';

    properties
        HSet       % mxn 大小数据，m组数据，每组n个柱
        ThetaSet   % 1x(n+1) 分隔角度
        histType   % 可初始化属性

        LConfHdl   % 下边界图形对象

        Parent
        Children
    end

    methods
        function obj=windrose(varargin)
            % 变量数据读取及传入
            if isa(varargin{1},'matlab.graphics.axis.PolarAxes')
                ax=varargin{1};varargin(1)=[];
            else
                ax=polaraxes(gcf);
            end
            hold on
            obj.Parent=ax;
            obj.HSet=varargin{1};varargin(1)=[];
            if ~isempty(varargin)&&isfloat(varargin{1})
                if length(varargin{1})==2
                    obj.ThetaSet=linspace(varargin{1}(1),varargin{1}(2),size(obj.HSet,2)+1);
                else
                    obj.ThetaSet=varargin{1};
                end
                varargin(1)=[];
            else
                obj.ThetaSet=linspace(0,2*pi,size(obj.HSet,2)+1);
            end
            obj.histType=varargin;
            
        end
        function obj=draw(obj) % 循环绘图
            tCoLorList=lines(size(obj.HSet,1));
            tHSet=cumsum(obj.HSet);

            for i=size(obj.HSet,1):-1:1
                obj.Children(i)=polarhistogram(obj.Parent,'BinEdges',...
                    obj.ThetaSet,'BinCounts',tHSet(i,:),'FaceAlpha',1,'FaceColor',tCoLorList(i,:),obj.histType{:});
            end
            % -------------------------------------------------------------
            % 绘制下边界圆形
            obj.LConfHdl=polarhistogram(obj.Parent,'BinEdges',linspace(0,2*pi,101),...
                'BinCounts',ones([1,100]),'FaceColor','none','FaceAlpha',1,'EdgeColor','none');
        end
% =========================================================================

        function setStyle(obj,varargin) % 设置属性
            for i=1:length(obj.Children)
                set(obj.Children(i),varargin{:});
            end
        end

        function setLConf(obj,LConf)% 设置下边界
            if strcmp(LConf,'none')
                obj.LConfHdl.FaceColor='none';
            else
                obj.LConfHdl.FaceColor=obj.Parent.Color;
                obj.LConfHdl.BinCounts=ones([1,100]).*LConf;
            end
        end

        function setColor(obj,colorList,n)% 颜色
            k=1;
            for i=n
                set(obj.Children(i),'FaceColor',colorList(k,:));
                k=k+1;
            end
        end
    end
end