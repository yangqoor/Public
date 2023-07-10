classdef shadowHist
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : hikari

% 使用示例：
% =========================================================================
% y=[2 2 3 2 5; 2 5 6 2 5; 9 8 9 2 5];
% 
% SH=shadowHist(y,'ShadowType',{'/','\','.','x','|'});
% SH=SH.draw();

    properties
        ax         % 绘图坐标区域
        YData      % 数值矩阵
        shadowTypeList={'\','/','_','|','+','x','.','w','k','g'}
        shadowType % 阴影类型
        otherProp  % 其他初始属性

        oriBarHdl  % 原始图形句柄
        newBarHdl
        pshapeHdl  % polyshape图形句柄
        groupNum   % 组数  
        classNum   % 类数
        YEndMat    % 末端y值
        maxY       % 最大Y值   
        minY=0     % 最小Y值
        diffY      % Y值之差
        BarW       % 宽度
        YSep1      % linspace(obj.minY,obj.maxY+.02.*obj.diffY,obj.lineNum)
        YSep2
        XMean      % 每组柱状图每个柱子的中心位置
        lineNum=90 % 阴影基础线数量

        XYRate
        SHLegend
        oriLegend
    end

    methods
        function obj=shadowHist(varargin)
            % 基础属性设置
            if isa(varargin{1},'matlab.graphics.axis.Axes')
                obj.ax=varargin{1};varargin(1)=[];
            else
                obj.ax=gca;
            end
            hold(obj.ax,'on');
            obj.YData=varargin{1};varargin(1)=[];
            if any(strcmpi('shadowType',varargin))
                tind=find(strcmpi('shadowType',varargin));
                obj.shadowType=varargin{tind+1};
                varargin([tind,tind+1])=[];
            else
                obj.shadowType=obj.shadowTypeList;
            end
            obj.otherProp=varargin;
            help shadowHist
        end

        function obj=draw(obj)
            % 基础绘图
            obj.oriBarHdl=bar(obj.ax,obj.YData,obj.otherProp{:},'Tag','barBox');
            obj.XYRate=diff(obj.ax.YLim)./diff(obj.ax.XLim);
            % 更多属性获取
            obj.YEndMat=zeros([length(obj.oriBarHdl),length(obj.oriBarHdl(1).XData)]);
            for i=1:length(obj.oriBarHdl)
                obj.YEndMat(i,:)=obj.oriBarHdl(i).YEndPoints;
            end
            obj.maxY=max(obj.YEndMat,[],[1,2]);
            obj.minY=min(0,min(obj.YEndMat,[],[1,2]));
            obj.diffY=obj.maxY-obj.minY;


            obj.classNum=length(obj.oriBarHdl);
            obj.groupNum=length(obj.oriBarHdl(1).XData);

            % 计算柱状图宽度和位置
            % obj.XMean=linspace(-obj.classNum+1,obj.classNum-1,obj.classNum)./(3+2*obj.classNum);
            for i=1:obj.classNum
                obj.XMean(i)=obj.oriBarHdl(i).XEndPoints(1)-1;
            end
            tXMean=[obj.XMean,1];obj.BarW=(tXMean(2)-tXMean(1))./2.*obj.oriBarHdl(1).BarWidth;
            if strcmp(obj.oriBarHdl(1).BarLayout,'stacked')
                obj.BarW=1./2.*obj.oriBarHdl(1).BarWidth;
            end
            YY1=linspace(obj.minY,obj.maxY+.02.*obj.diffY,obj.lineNum)';
            YY2=linspace(obj.minY-.02.*obj.diffY,obj.maxY,obj.lineNum)';
            obj.YSep1=YY1(1)-YY2(2);obj.YSep2=YY1(2)-YY1(1);

            % 循环绘制阴影
            for i=1:obj.classNum
                obj.oriBarHdl(i).FaceColor='none';
                obj.oriBarHdl(i).LineWidth=.8;
                if strcmp(obj.oriBarHdl(1).BarLayout,'stacked')
                    obj.oriBarHdl(i).LineWidth=.8;
                end
                tType=mod(i-1,length(obj.shadowType))+1;
                switch obj.shadowType{tType}
                    case 'w',obj.oriBarHdl(i).FaceColor=[1,1,1];
                    case 'k',obj.oriBarHdl(i).FaceColor=[0,0,0];
                    case 'g',obj.oriBarHdl(i).FaceColor=[.5,.5,.5];
                end
                for j=1:obj.groupNum
                    tX=[-1,1,1,-1].*obj.BarW+obj.XMean(i)+j;
                    tY=[obj.oriBarHdl(i).YEndPoints(j)-obj.oriBarHdl(i).YData(j),...
                        obj.oriBarHdl(i).YEndPoints(j)-obj.oriBarHdl(i).YData(j),...
                        obj.oriBarHdl(i).YEndPoints(j),...
                        obj.oriBarHdl(i).YEndPoints(j)];    
                    tPolyPhape=polyshape(tX,tY);
                    switch obj.shadowType{tType}
                        case '\'
                            XX1=-1.2.*ones([obj.lineNum,1]).*obj.BarW+obj.XMean(i)+j;
                            XX2=1.2.*ones([obj.lineNum,1]).*obj.BarW+obj.XMean(i)+j;
                            YY1=linspace(obj.minY,obj.maxY+.02.*obj.diffY,obj.lineNum)';
                            YY2=linspace(obj.minY-.02.*obj.diffY,obj.maxY,obj.lineNum)';
                            tXX=zeros([3,obj.lineNum]);tYY=zeros([3,obj.lineNum]);
                            for k=1:obj.lineNum
                                [in,~]=intersect(tPolyPhape,[XX1(k),YY1(k);XX2(k),YY2(k)]);
                                if ~isempty(in)
                                    tXX(:,k)=[in(1,1);in(end,1);nan];
                                    tYY(:,k)=[in(1,2);in(end,2);nan];
                                else
                                    tXX(:,k)=[nan;nan;nan];
                                    tYY(:,k)=[nan;nan;nan];
                                end
                            end
                            plot(tXX(:),tYY(:),'Color',[0,0,0],'LineWidth',.5,'Tag','barShadow')
                        case '/'
                            XX1=-1.2.*ones([obj.lineNum,1]).*obj.BarW+obj.XMean(i)+j;
                            XX2=1.2.*ones([obj.lineNum,1]).*obj.BarW+obj.XMean(i)+j;
                            YY1=linspace(obj.minY-.02.*obj.diffY,obj.maxY,obj.lineNum)';
                            YY2=linspace(obj.minY,obj.maxY+.02.*obj.diffY,obj.lineNum)';
                            tXX=zeros([3,obj.lineNum]);tYY=zeros([3,obj.lineNum]);
                            for k=1:obj.lineNum
                                [in,~]=intersect(tPolyPhape,[XX1(k),YY1(k);XX2(k),YY2(k)]);
                                if ~isempty(in)
                                    tXX(:,k)=[in(1,1);in(end,1);nan];
                                    tYY(:,k)=[in(1,2);in(end,2);nan];
                                else
                                    tXX(:,k)=[nan;nan;nan];
                                    tYY(:,k)=[nan;nan;nan];
                                end
                            end
                            plot(tXX(:),tYY(:),'Color',[0,0,0],'LineWidth',.5,'Tag','barShadow')
                        case '_'
                            tXX=[tX(1),tX(2),nan];
                            tYY=linspace(obj.minY-.02.*obj.diffY,obj.maxY+.02.*obj.diffY,obj.lineNum)';
                            tYY(tYY>=max(tY))=[];tYY(tYY<=min(tY))=[];
                            tXX=repmat(tXX,[length(tYY),1])';
                            tYY=repmat(tYY,[1,size(tXX,1)])';
                            plot(tXX(:),tYY(:),'Color',[0,0,0],'LineWidth',.5,'Tag','barShadow')
                        case '|'
                            tXX=linspace(tX(1),tX(2),5);
                            if strcmp(obj.oriBarHdl(1).BarLayout,'stacked')
                                tXX=linspace(tX(1),tX(2),9);
                            end
                            tXX=tXX(2:end-1);
                            tYY=[tY(2),tY(3),nan]';
                            tXX=repmat(tXX,[length(tYY),1]);
                            tYY=repmat(tYY,[1,size(tXX,2)]);
                            plot(tXX(:),tYY(:),'Color',[0,0,0],'LineWidth',.5,'Tag','barShadow')
                        case '+'
                            tXX=[tX(1),tX(2),nan];
                            tYY=linspace(obj.minY-.02.*obj.diffY,obj.maxY+.02.*obj.diffY,obj.lineNum)';
                            tYY(tYY>=max(tY))=[];tYY(tYY<=min(tY))=[];
                            tXX1=repmat(tXX,[length(tYY),1])';
                            tYY1=repmat(tYY,[1,size(tXX1,1)])';   
                            tXX=linspace(tX(1),tX(2),5);
                            if strcmp(obj.oriBarHdl(1).BarLayout,'stacked')
                                tXX=linspace(tX(1),tX(2),9);
                            end
                            tXX=tXX(2:end-1);
                            tYY=[tY(2),tY(3),nan]';
                            tXX2=repmat(tXX,[length(tYY),1]);
                            tYY2=repmat(tYY,[1,size(tXX2,2)]);
                            plot([tXX1(:);nan;tXX2(:)],[tYY1(:);nan;tYY2(:)],'Color',[0,0,0],'LineWidth',.5,'Tag','barShadow')
                        case 'x'
                            XX1=-1.2.*ones([obj.lineNum,1]).*obj.BarW+obj.XMean(i)+j;
                            XX2=1.2.*ones([obj.lineNum,1]).*obj.BarW+obj.XMean(i)+j;
                            YY1=linspace(obj.minY-obj.BarW.*2.4.*obj.XYRate,obj.maxY,obj.lineNum)';
                            YY2=YY1+obj.BarW.*2.4.*obj.XYRate;
                            tXX=zeros([3,obj.lineNum]);tYY=zeros([3,obj.lineNum]);
                            for k=1:obj.lineNum
                                [in,~]=intersect(tPolyPhape,[XX1(k),YY1(k);XX2(k),YY2(k)]);
                                if ~isempty(in)
                                    tXX(:,k)=[in(1,1);in(end,1);nan];
                                    tYY(:,k)=[in(1,2);in(end,2);nan];
                                else
                                    tXX(:,k)=[nan;nan;nan];
                                    tYY(:,k)=[nan;nan;nan];
                                end
                            end;tXX1=tXX(:);tYY1=tYY(:);
                            YY1=linspace(obj.minY,obj.maxY+obj.BarW.*2.4.*obj.XYRate,obj.lineNum)';
                            YY2=YY1-obj.BarW.*2.4.*obj.XYRate;
                            tXX=zeros([3,obj.lineNum]);tYY=zeros([3,obj.lineNum]);
                            for k=1:obj.lineNum
                                [in,~]=intersect(tPolyPhape,[XX1(k),YY1(k);XX2(k),YY2(k)]);
                                if ~isempty(in)
                                    tXX(:,k)=[in(1,1);in(end,1);nan];
                                    tYY(:,k)=[in(1,2);in(end,2);nan];
                                else
                                    tXX(:,k)=[nan;nan;nan];
                                    tYY(:,k)=[nan;nan;nan];
                                end
                            end;tXX2=tXX(:);tYY2=tYY(:);    
                            plot([tXX1(:);nan;tXX2(:)],[tYY1(:);nan;tYY2(:)],'Color',[0,0,0],'LineWidth',.5,'Tag','barShadow')
                        case '.'
                            tXX=linspace(tX(1)+obj.BarW./4,tX(2)-obj.BarW./4,3);
                            if strcmp(obj.oriBarHdl(1).BarLayout,'stacked')
                                tXX=linspace(tX(1)+obj.BarW./8,tX(2)-obj.BarW./8,9);
                            end
                            tYY=linspace(obj.minY-.02.*obj.diffY,obj.maxY+.02.*obj.diffY,obj.lineNum)';
                            tYY(tYY>=max(tY))=[];tYY(tYY<=min(tY))=[];
                            tXX=repmat(tXX,[length(tYY),1]);
                            tYY=repmat(tYY,[1,size(tXX,2)]);
                            scatter(tXX(:),tYY(:),2,'filled','o','MarkerEdgeColor','none','MarkerFaceColor',[0,0,0],'Tag','barShadow')
                    end
                end
            end            
        end

        function obj=legend(obj,cellStr,varargin)
            obj.newBarHdl=bar(obj.ax,obj.YData,obj.otherProp{:},'FaceColor','none','EdgeColor','none');
            obj.oriLegend=legend(obj.newBarHdl,cellStr,varargin{:});
            obj.oriLegend.AutoUpdate='off';
            obj.oriLegend.Box='off';
            obj.ax.XLim=obj.ax.XLim;
            obj.ax.YLim=obj.ax.YLim;

            tXYMin=(obj.oriLegend.Position(1:2)-obj.ax.Position(1:2))./obj.ax.Position(3:4).*[diff(obj.ax.XLim),diff(obj.ax.YLim)]+[obj.ax.XLim(1),obj.ax.YLim(1)];
            tXYMax=(obj.oriLegend.Position(1:2)+obj.oriLegend.Position(3:4)-obj.ax.Position(1:2))./obj.ax.Position(3:4).*[diff(obj.ax.XLim),diff(obj.ax.YLim)]+[obj.ax.XLim(1),obj.ax.YLim(1)];
            boxHdl=fill([tXYMin(1),tXYMax(1),tXYMax(1),tXYMin(1)],[tXYMin(2),tXYMin(2),tXYMax(2),tXYMax(2)],[1,1,1],'Tag','lgdBox');
            

            for n=1:length((obj.oriBarHdl))
                ttType=mod(n-1,length(obj.shadowType))+1;
                squareHdl(n)=fill([0,0,0],[0,0,0],[1,1,1],'EdgeColor',[0,0,0],'LineWidth',.7,'Tag','barBox');
                if strcmp(obj.shadowType{ttType},'.')
                    lgdLineHdl(n)=scatter(0,0,2,'filled','o','MarkerEdgeColor','none','MarkerFaceColor',[0,0,0],'Tag','barShadow');
                else
                    lgdLineHdl(n)=plot(0,0,'Color',[0,0,0],'LineWidth',.5,'Tag','barBox','Tag','barShadow');
                end
            end
            moveLgd()
            set(obj.ax.Parent,'WindowButtonMotionFcn',@moveLgd);
            function moveLgd(~,~)
            XYMin=(obj.oriLegend.Position(1:2)-obj.ax.Position(1:2))./obj.ax.Position(3:4).*[diff(obj.ax.XLim),diff(obj.ax.YLim)]+[obj.ax.XLim(1),obj.ax.YLim(1)];
            XYMax=(obj.oriLegend.Position(1:2)+obj.oriLegend.Position(3:4)-obj.ax.Position(1:2))./obj.ax.Position(3:4).*[diff(obj.ax.XLim),diff(obj.ax.YLim)]+[obj.ax.XLim(1),obj.ax.YLim(1)];
            boxHdl.XData=[XYMin(1),XYMax(1),XYMax(1),XYMin(1)];
            boxHdl.YData=[XYMin(2),XYMin(2),XYMax(2),XYMax(2)];
            Y=XYMin(2)+(XYMax(2)-XYMin(2)).*linspace(1/length(obj.newBarHdl)/2+1/50,1-1/length(obj.newBarHdl)/2-1/50,length(obj.newBarHdl));
            obj.XYRate=diff(obj.ax.YLim)./diff(obj.ax.XLim);

            PBA=obj.ax.PlotBoxAspectRatio(2)./obj.ax.PlotBoxAspectRatio(1)./0.7896;
            Y=fliplr(Y);
            for i=1:length((obj.oriBarHdl))    
                tX=XYMin(1)+(XYMax(2)-XYMin(2))./2./length(obj.newBarHdl).*[1/10,1.18,1.18,1/10].*(PBA./obj.XYRate.*3);
                tY=Y(i)+0.75.*[-1,-1,1,1].*(XYMax(2)-XYMin(2))./2./length(obj.newBarHdl);
                squareHdl(i).XData=tX;
                squareHdl(i).YData=tY;
                tPolyPhape=polyshape(tX,tY);
                tType=mod(i-1,length(obj.shadowType))+1;
                switch obj.shadowType{tType}
                    case '\'
                        XX1=ones([51,1]).*(tX(1)-.2.*(tX(2)-tX(1)));
                        XX2=ones([51,1]).*(tX(2)+.2.*(tX(2)-tX(1)));
                        YY1=((-25:1:25).*obj.YSep2+obj.YSep1+Y(i))';
                        YY2=((-25:1:25).*obj.YSep2-obj.YSep1+Y(i))';
                        tXX=zeros([3,obj.lineNum]);tYY=zeros([3,obj.lineNum]);
                        for k=1:51
                            [in,~]=intersect(tPolyPhape,[XX1(k),YY1(k);XX2(k),YY2(k)]);
                            if ~isempty(in)
                                tXX(:,k)=[in(1,1);in(end,1);nan];
                                tYY(:,k)=[in(1,2);in(end,2);nan];
                            else
                                tXX(:,k)=[nan;nan;nan];
                                tYY(:,k)=[nan;nan;nan];
                            end
                        end
                        lgdLineHdl(i).XData=tXX(:)';
                        lgdLineHdl(i).YData=tYY(:)';
                    case '/'
                        XX1=ones([51,1]).*(tX(1)-.2.*(tX(2)-tX(1)));
                        XX2=ones([51,1]).*(tX(2)+.2.*(tX(2)-tX(1)));
                        YY1=((-25:1:25).*obj.YSep2-obj.YSep1+Y(i))';
                        YY2=((-25:1:25).*obj.YSep2+obj.YSep1+Y(i))';
                        tXX=zeros([3,obj.lineNum]);tYY=zeros([3,obj.lineNum]);
                        for k=1:51
                            [in,~]=intersect(tPolyPhape,[XX1(k),YY1(k);XX2(k),YY2(k)]);
                            if ~isempty(in)
                                tXX(:,k)=[in(1,1);in(end,1);nan];
                                tYY(:,k)=[in(1,2);in(end,2);nan];
                            else
                                tXX(:,k)=[nan;nan;nan];
                                tYY(:,k)=[nan;nan;nan];
                            end
                        end
                        lgdLineHdl(i).XData=tXX(:);
                        lgdLineHdl(i).YData=tYY(:);
                    case '_'
                        tXX=[tX(1),tX(2),nan];
                        tYY=linspace(tY(2),tY(3),5)';tYY=tYY(2:4);
                        tXX=repmat(tXX,[length(tYY),1])';
                        tYY=repmat(tYY,[1,size(tXX,1)])';
                        lgdLineHdl(i).XData=tXX(:);
                        lgdLineHdl(i).YData=tYY(:);
                    case '|'
                        tXX=linspace(tX(1),tX(2),11);tXX=tXX(2:end-1);
                        tYY=[tY(2),tY(3),nan]';
                        tXX=repmat(tXX,[length(tYY),1]);
                        tYY=repmat(tYY,[1,size(tXX,2)]);
                        lgdLineHdl(i).XData=tXX(:);
                        lgdLineHdl(i).YData=tYY(:);
                    case '+'
                        tXX=[tX(1),tX(2),nan];
                        tYY=linspace(tY(2),tY(3),5)';tYY=tYY(2:4);
                        tXX1=repmat(tXX,[length(tYY),1])';
                        tYY1=repmat(tYY,[1,size(tXX1,1)])';
                        tXX=linspace(tX(1),tX(2),11);tXX=tXX(2:end-1);
                        tYY=[tY(2),tY(3),nan]';
                        tXX2=repmat(tXX,[length(tYY),1]);
                        tYY2=repmat(tYY,[1,size(tXX2,2)]);
                        lgdLineHdl(i).XData=[tXX1(:);nan;tXX2(:)];
                        lgdLineHdl(i).YData=[tYY1(:);nan;tYY2(:)];
                    case 'x'
                        XX1=ones([51,1]).*(tX(1)-.2.*(tX(2)-tX(1)));
                        XX2=ones([51,1]).*(tX(2)+.2.*(tX(2)-tX(1)));
                        YY1=((-25:1:25).*obj.YSep2-obj.YSep1+Y(i))';
                        YY2=YY1+(tX(2)-tX(1)+.4.*(tX(2)-tX(1))).*obj.XYRate;
                        tXX=zeros([3,51]);tYY=zeros([3,51]);
                        for k=1:51
                            [in,~]=intersect(tPolyPhape,[XX1(k),YY1(k);XX2(k),YY2(k)]);
                            if ~isempty(in)
                                tXX(:,k)=[in(1,1);in(end,1);nan];
                                tYY(:,k)=[in(1,2);in(end,2);nan];
                            else
                                tXX(:,k)=[nan;nan;nan];
                                tYY(:,k)=[nan;nan;nan];
                            end
                        end;tXX1=tXX(:);tYY1=tYY(:);
                        YY2=((-25:1:25).*obj.YSep2-obj.YSep1+Y(i))';
                        YY1=YY2+(tX(2)-tX(1)+.4.*(tX(2)-tX(1))).*obj.XYRate;  
                        tXX=zeros([3,51]);tYY=zeros([3,51]);
                        for k=1:51
                            [in,~]=intersect(tPolyPhape,[XX1(k),YY1(k);XX2(k),YY2(k)]);
                            if ~isempty(in)
                                tXX(:,k)=[in(1,1);in(end,1);nan];
                                tYY(:,k)=[in(1,2);in(end,2);nan];
                            else
                                tXX(:,k)=[nan;nan;nan];
                                tYY(:,k)=[nan;nan;nan];
                            end
                        end;tXX2=tXX(:);tYY2=tYY(:);
                        lgdLineHdl(i).XData=[tXX1(:);nan;tXX2(:)];
                        lgdLineHdl(i).YData=[tYY1(:);nan;tYY2(:)];
                    case '.'
                        tXX=linspace(tX(1),tX(2),9);
                        tYY=linspace(tY(2)+(tY(3)-tY(2))/6,tY(3)-(tY(3)-tY(2))/6,3)';
                        tXX(1)=[];tXX(end)=[];
                        tXX=repmat(tXX,[length(tYY),1]);
                        tYY=repmat(tYY,[1,size(tXX,2)]);
                        lgdLineHdl(i).XData=tXX(:);
                        lgdLineHdl(i).YData=tYY(:);
                    case 'w'
                        squareHdl(i).FaceColor=[1,1,1];
                    case 'k'
                        squareHdl(i).FaceColor=[0,0,0];
                    case 'g'
                        squareHdl(i).FaceColor=[.5,.5,.5];
                end
            end
            end
        end
    end
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : hikari
end