classdef shadowPie
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : hikari

    properties
        ax,XData,num

        shadowTypeList={'\','/','_','|','+','x','.','w','k','g'}
        shadowType % 阴影类型
        otherProp  % 其他初始属性

        oriPieHdl  % 原始图形句柄
        newPieHdl
        pshapeHdl  % polyshape图形句柄
        lineNum=85 % 阴影基础线数量

        oriLegend;XYRate;nonePieHdl

        lL_X1;lL_X2;cL_X1;cL_X2;hL_X1;hL_X2;XMesh;YMesh
    end

    methods
        function obj=shadowPie(varargin)
            % 基础属性设置
            obj.XData=varargin{1};varargin(1)=[];
            if any(strcmpi('shadowType',varargin))
                tind=find(strcmpi('shadowType',varargin));
                obj.shadowType=varargin{tind+1};
                varargin([tind,tind+1])=[];
            else
                obj.shadowType=obj.shadowTypeList;
            end
            if any(strcmpi('lineNum',varargin))
                tind=find(strcmpi('lineNum',varargin));
                obj.lineNum=varargin{tind+1};
                varargin([tind,tind+1])=[];
            end
            obj.otherProp=varargin;
            obj.num=length(obj.XData);
            help shadowPie
        end

        function obj=draw(obj)
            % 基础绘图
            obj.oriPieHdl=pie(obj.XData,obj.otherProp{:});
            obj.ax=gca;hold(obj.ax,'on');


            % 一些基础线
            obj.lL_X1=linspace(-1.5-6,1.5,obj.lineNum);
            obj.lL_X2=linspace(-1.5,1.5+6,obj.lineNum);

            obj.cL_X1=linspace(-1.5-3,1.5,obj.lineNum);
            obj.cL_X2=linspace(-1.5,1.5+3,obj.lineNum);

            obj.hL_X1=linspace(-1.5,1.5,obj.lineNum);
            obj.hL_X2=linspace(-1.5,1.5,obj.lineNum);

            [obj.XMesh,obj.YMesh]=meshgrid(linspace(-1.5,1.5,obj.lineNum));

            n=1;
            for i=1:length(obj.oriPieHdl)
                if isa(obj.oriPieHdl(i),'matlab.graphics.primitive.Patch')
                    obj.newPieHdl(n)=obj.oriPieHdl(i);
                    obj.oriPieHdl(i).Tag='pieBox';
                    n=n+1;
                else
                    obj.oriPieHdl(i).Tag='pieText';
                end
            end

            n=1;
            for i=1:length(obj.oriPieHdl)
                if isa(obj.oriPieHdl(i),'matlab.graphics.primitive.Patch')
                    obj.oriPieHdl(i).FaceColor=[1,1,1];
                    obj.oriPieHdl(i).LineWidth=.8;
                    tPolyPhape=polyshape(obj.oriPieHdl(i).XData,obj.oriPieHdl(i).YData);
                    tType=mod(n-1,length(obj.shadowType))+1;
                    switch obj.shadowType{tType}
                        case '\'
                            tXX=zeros([3,obj.lineNum]);tYY=zeros([3,obj.lineNum]);
                            for k=1:obj.lineNum
                                [in,~]=intersect(tPolyPhape,[obj.lL_X1(k),1.5;obj.lL_X2(k),-1.5]);
                                if ~isempty(in)
                                    tXX(:,k)=[in(1,1);in(end,1);nan];
                                    tYY(:,k)=[in(1,2);in(end,2);nan];
                                else
                                    tXX(:,k)=[nan;nan;nan];
                                    tYY(:,k)=[nan;nan;nan];
                                end     
                            end
                            plot(tXX(:),tYY(:),'Color',[0,0,0],'LineWidth',.5,'Tag','pieShadow')
                        case '/'
                            tXX=zeros([3,obj.lineNum]);tYY=zeros([3,obj.lineNum]);
                            for k=1:obj.lineNum
                                [in,~]=intersect(tPolyPhape,[obj.lL_X1(k),-1.5;obj.lL_X2(k),1.5]);
                                if ~isempty(in)
                                    tXX(:,k)=[in(1,1);in(end,1);nan];
                                    tYY(:,k)=[in(1,2);in(end,2);nan];
                                else
                                    tXX(:,k)=[nan;nan;nan];
                                    tYY(:,k)=[nan;nan;nan];
                                end     
                            end
                            plot(tXX(:),tYY(:),'Color',[0,0,0],'LineWidth',.5,'Tag','pieShadow')
                        case '_'
                            tXX=zeros([3,obj.lineNum]);tYY=zeros([3,obj.lineNum]);
                            for k=1:obj.lineNum
                                [in,~]=intersect(tPolyPhape,[-1.5,obj.hL_X1(k);1.5,obj.hL_X2(k)]);
                                if ~isempty(in)
                                    tXX(:,k)=[in(1,1);in(end,1);nan];
                                    tYY(:,k)=[in(1,2);in(end,2);nan];
                                else
                                    tXX(:,k)=[nan;nan;nan];
                                    tYY(:,k)=[nan;nan;nan];
                                end     
                            end
                            plot(tXX(:),tYY(:),'Color',[0,0,0],'LineWidth',.5,'Tag','pieShadow')
                        case '|'
                            tXX=zeros([3,obj.lineNum]);tYY=zeros([3,obj.lineNum]);
                            for k=1:obj.lineNum
                                [in,~]=intersect(tPolyPhape,[obj.hL_X1(k),-1.5;obj.hL_X2(k),1.5]);
                                if ~isempty(in)
                                    tXX(:,k)=[in(1,1);in(end,1);nan];
                                    tYY(:,k)=[in(1,2);in(end,2);nan];
                                else
                                    tXX(:,k)=[nan;nan;nan];
                                    tYY(:,k)=[nan;nan;nan];
                                end     
                            end
                            plot(tXX(:),tYY(:),'Color',[0,0,0],'LineWidth',.5,'Tag','pieShadow')
                        case '+'
                            tXX1=zeros([3,obj.lineNum]);tYY1=zeros([3,obj.lineNum]);
                            for k=1:obj.lineNum
                                [in,~]=intersect(tPolyPhape,[-1.5,obj.hL_X1(k);1.5,obj.hL_X2(k)]);
                                if ~isempty(in)
                                    tXX1(:,k)=[in(1,1);in(end,1);nan];
                                    tYY1(:,k)=[in(1,2);in(end,2);nan];
                                else
                                    tXX1(:,k)=[nan;nan;nan];
                                    tYY1(:,k)=[nan;nan;nan];
                                end     
                            end
                            tXX2=zeros([3,obj.lineNum]);tYY2=zeros([3,obj.lineNum]);
                            for k=1:obj.lineNum
                                [in,~]=intersect(tPolyPhape,[obj.hL_X1(k),-1.5;obj.hL_X2(k),1.5]);
                                if ~isempty(in)
                                    tXX2(:,k)=[in(1,1);in(end,1);nan];
                                    tYY2(:,k)=[in(1,2);in(end,2);nan];
                                else
                                    tXX2(:,k)=[nan;nan;nan];
                                    tYY2(:,k)=[nan;nan;nan];
                                end     
                            end
                            plot([tXX1(:);nan;tXX2(:)],[tYY1(:);nan;tYY2(:)],'Color',[0,0,0],'LineWidth',.5,'Tag','pieShadow')
                        case 'x'
                            tXX1=zeros([3,obj.lineNum]);tYY1=zeros([3,obj.lineNum]);
                            for k=1:obj.lineNum
                                [in,~]=intersect(tPolyPhape,[obj.cL_X1(k),1.5;obj.cL_X2(k),-1.5]);
                                if ~isempty(in)
                                    tXX1(:,k)=[in(1,1);in(end,1);nan];
                                    tYY1(:,k)=[in(1,2);in(end,2);nan];
                                else
                                    tXX1(:,k)=[nan;nan;nan];
                                    tYY1(:,k)=[nan;nan;nan];
                                end     
                            end
                            tXX2=zeros([3,obj.lineNum]);tYY2=zeros([3,obj.lineNum]);
                            for k=1:obj.lineNum
                                [in,~]=intersect(tPolyPhape,[obj.cL_X1(k),-1.5;obj.cL_X2(k),1.5]);
                                if ~isempty(in)
                                    tXX2(:,k)=[in(1,1);in(end,1);nan];
                                    tYY2(:,k)=[in(1,2);in(end,2);nan];
                                else
                                    tXX2(:,k)=[nan;nan;nan];
                                    tYY2(:,k)=[nan;nan;nan];
                                end     
                            end
                            plot([tXX1(:);nan;tXX2(:)],[tYY1(:);nan;tYY2(:)],'Color',[0,0,0],'LineWidth',.5,'Tag','pieShadow')
                        case '.'
                             tXX=obj.XMesh(:);tYY=obj.YMesh(:);
                             tbool=isinterior(tPolyPhape,tXX(:),tYY(:));
                             scatter(tXX(tbool),tYY(tbool),2,'filled','o','MarkerEdgeColor','none','MarkerFaceColor',[0,0,0],'Tag','pieShadow')
                        case 'w'
                            obj.oriPieHdl(i).FaceColor=[1,1,1];
                        case 'k' 
                            obj.oriPieHdl(i).FaceColor=[0,0,0];
                        case 'g'
                            obj.oriPieHdl(i).FaceColor=[.5,.5,.5];
                    end
                    n=n+1;
                end
            end
        end
        function obj=legend(obj,cellStr,varargin)
            obj.nonePieHdl=pie(obj.XData,obj.otherProp{:});
            nn=1;
            for n=1:length(obj.nonePieHdl)
                if isa(obj.nonePieHdl(n),'matlab.graphics.primitive.Patch')
                    obj.nonePieHdl(n).FaceColor='none';
                    obj.nonePieHdl(n).EdgeColor='none';
                    newNonePieHdl(nn)=obj.nonePieHdl(n);
                    nn=nn+1;
                else
                    obj.nonePieHdl(n).Visible='off';
                end
            end
            obj.oriLegend=legend(newNonePieHdl,cellStr,varargin{:});
            obj.oriLegend.AutoUpdate='off';
            obj.oriLegend.Box='off';
            obj.ax.XLim=obj.ax.XLim;
            obj.ax.YLim=obj.ax.YLim;

            % 框重定位
            tlgdPos=obj.oriLegend.Position;
            taxPos=obj.ax.Position;
            taxXLim=obj.ax.XLim;
            taxYLim=obj.ax.YLim;
            tfigRate=obj.ax.Parent.Position(3:4);
            tfigRate=tfigRate.*taxPos(3:4);tfigRate=tfigRate./min(tfigRate);
            taxXLim=taxXLim.*tfigRate(1);
            taxYLim=taxYLim.*tfigRate(2);

            tXYMin=(tlgdPos(1:2)-taxPos(1:2))./taxPos(3:4).*[diff(taxXLim),diff(taxYLim)]+[taxXLim(1),taxYLim(1)];
            tXYMax=(tlgdPos(1:2)+tlgdPos(3:4)-taxPos(1:2))./taxPos(3:4).*[diff(taxXLim),diff(taxYLim)]+[taxXLim(1),taxYLim(1)];
            boxHdl=fill([tXYMin(1),tXYMax(1),tXYMax(1),tXYMin(1)],[tXYMin(2),tXYMin(2),tXYMax(2),tXYMax(2)],[1,1,1],'Tag','lgdBox');

            for n=1:length((obj.newPieHdl))
                ttType=mod(n-1,length(obj.shadowType))+1;
                squareHdl(n)=fill([0,0,0],[0,0,0],[1,1,1],'EdgeColor',[0,0,0],'LineWidth',.7,'Tag','pieBox');
                if strcmp(obj.shadowType{ttType},'.')
                    lgdLineHdl(n)=scatter(0,0,2,'filled','o','MarkerEdgeColor','none','MarkerFaceColor',[0,0,0],'Tag','pieShadow');
                else
                    lgdLineHdl(n)=plot(0,0,'Color',[0,0,0],'LineWidth',.5,'Tag','barBox','Tag','pieShadow');
                end
            end
            moveLgd()
            set(obj.ax.Parent,'WindowButtonMotionFcn',@moveLgd);
            function moveLgd(~,~)
                % 框重定位
                lgdPos=obj.oriLegend.Position;
                axPos=obj.ax.Position;
                axXLim=obj.ax.XLim;
                axYLim=obj.ax.YLim;
                figRate=obj.ax.Parent.Position(3:4);
                figRate=figRate.*axPos(3:4);figRate=figRate./min(figRate);
                axXLim=axXLim.*figRate(1);
                axYLim=axYLim.*figRate(2);

                XYMin=(lgdPos(1:2)-axPos(1:2))./axPos(3:4).*[diff(axXLim),diff(axYLim)]+[axXLim(1),axYLim(1)];
                XYMax=(lgdPos(1:2)+lgdPos(3:4)-axPos(1:2))./axPos(3:4).*[diff(axXLim),diff(axYLim)]+[axXLim(1),axYLim(1)];
                boxHdl.XData=[XYMin(1),XYMax(1),XYMax(1),XYMin(1)];
                boxHdl.YData=[XYMin(2),XYMin(2),XYMax(2),XYMax(2)];

                Y=XYMin(2)+(XYMax(2)-XYMin(2)).*linspace(1/length(obj.newPieHdl)/2+1/50,1-1/length(obj.newPieHdl)/2-1/50,length(obj.newPieHdl));
                obj.XYRate=diff(obj.ax.YLim)./diff(obj.ax.XLim);

                PBA=obj.ax.PlotBoxAspectRatio(2)./obj.ax.PlotBoxAspectRatio(1)./0.7896;
                Y=fliplr(Y);
                for i=1:length((obj.newPieHdl))
                    tX=XYMin(1)+(XYMax(2)-XYMin(2))./2./length(obj.newPieHdl).*[1/10,.95,.95,1/10].*(PBA./obj.XYRate.*3);
                    tY=Y(i)+0.75.*[-1,-1,1,1].*(XYMax(2)-XYMin(2))./2./length(obj.newPieHdl);
                    squareHdl(i).XData=tX;
                    squareHdl(i).YData=tY;

                    tPolyPhape=polyshape(tX,tY);
                    tType=mod(i-1,length(obj.shadowType))+1;

                    switch obj.shadowType{tType}
                        case '\'
                            tXX=zeros([3,obj.lineNum]);tYY=zeros([3,obj.lineNum]);
                            for k=1:obj.lineNum
                                [in,~]=intersect(tPolyPhape,[obj.lL_X1(k),1.5;obj.lL_X2(k),-1.5]);
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
                        case '/'
                            tXX=zeros([3,obj.lineNum]);tYY=zeros([3,obj.lineNum]);
                            for k=1:obj.lineNum
                                [in,~]=intersect(tPolyPhape,[obj.lL_X1(k),-1.5;obj.lL_X2(k),1.5]);
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
                            tXX=zeros([3,obj.lineNum]);tYY=zeros([3,obj.lineNum]);
                            for k=1:obj.lineNum
                                [in,~]=intersect(tPolyPhape,[-1.5,obj.hL_X1(k);1.5,obj.hL_X2(k)]);
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
                        case '|'
                            tXX=zeros([3,obj.lineNum]);tYY=zeros([3,obj.lineNum]);
                            for k=1:obj.lineNum
                                [in,~]=intersect(tPolyPhape,[obj.hL_X1(k),-1.5;obj.hL_X2(k),1.5]);
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
                        case '+'
                            tXX1=zeros([3,obj.lineNum]);tYY1=zeros([3,obj.lineNum]);
                            for k=1:obj.lineNum
                                [in,~]=intersect(tPolyPhape,[-1.5,obj.hL_X1(k);1.5,obj.hL_X2(k)]);
                                if ~isempty(in)
                                    tXX1(:,k)=[in(1,1);in(end,1);nan];
                                    tYY1(:,k)=[in(1,2);in(end,2);nan];
                                else
                                    tXX1(:,k)=[nan;nan;nan];
                                    tYY1(:,k)=[nan;nan;nan];
                                end
                            end
                            tXX2=zeros([3,obj.lineNum]);tYY2=zeros([3,obj.lineNum]);
                            for k=1:obj.lineNum
                                [in,~]=intersect(tPolyPhape,[obj.hL_X1(k),-1.5;obj.hL_X2(k),1.5]);
                                if ~isempty(in)
                                    tXX2(:,k)=[in(1,1);in(end,1);nan];
                                    tYY2(:,k)=[in(1,2);in(end,2);nan];
                                else
                                    tXX2(:,k)=[nan;nan;nan];
                                    tYY2(:,k)=[nan;nan;nan];
                                end
                            end
                            lgdLineHdl(i).XData=[tXX1(:);nan;tXX2(:)];
                            lgdLineHdl(i).YData=[tYY1(:);nan;tYY2(:)];
                        case 'x'
                            tXX1=zeros([3,obj.lineNum]);tYY1=zeros([3,obj.lineNum]);
                            for k=1:obj.lineNum
                                [in,~]=intersect(tPolyPhape,[obj.cL_X1(k),1.5;obj.cL_X2(k),-1.5]);
                                if ~isempty(in)
                                    tXX1(:,k)=[in(1,1);in(end,1);nan];
                                    tYY1(:,k)=[in(1,2);in(end,2);nan];
                                else
                                    tXX1(:,k)=[nan;nan;nan];
                                    tYY1(:,k)=[nan;nan;nan];
                                end
                            end
                            tXX2=zeros([3,obj.lineNum]);tYY2=zeros([3,obj.lineNum]);
                            for k=1:obj.lineNum
                                [in,~]=intersect(tPolyPhape,[obj.cL_X1(k),-1.5;obj.cL_X2(k),1.5]);
                                if ~isempty(in)
                                    tXX2(:,k)=[in(1,1);in(end,1);nan];
                                    tYY2(:,k)=[in(1,2);in(end,2);nan];
                                else
                                    tXX2(:,k)=[nan;nan;nan];
                                    tYY2(:,k)=[nan;nan;nan];
                                end
                            end
                            lgdLineHdl(i).XData=[tXX1(:);nan;tXX2(:)];
                            lgdLineHdl(i).YData=[tYY1(:);nan;tYY2(:)];
                        case '.'
                            tXX=obj.XMesh(:);tYY=obj.YMesh(:);
                            tbool=isinterior(tPolyPhape,tXX(:),tYY(:));
                            lgdLineHdl(i).XData=tXX(tbool);
                            lgdLineHdl(i).YData=tYY(tbool);
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
end