classdef cquiver
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : hikari
    properties
        CM % colormap
        Parent
        % 修饰属性
        AutoScale
        AutoScaleFactor
        LineStyle,LineWidth
        MarkerSize,Marker
        MaxHeadSize
        Type='cquiver';
        % 数据属性
        UData,VData
        XData,YData
        UDataS,VDataS
        CQnorm0,CQnorm1,CQnorm2
        % 图形对象
        cqHdl
        cqPropHdl
    end
    methods
        function obj = cquiver(qHdl,CM)
            obj.AutoScale=qHdl.AutoScale;        
            if nargin<2,obj.CM=parula();else,obj.CM=CM;end
            obj.CM=flipud(obj.CM);
            obj.Parent=qHdl.Parent;
            hold(obj.Parent,'on');
            % 修饰属性复制
            obj.AutoScaleFactor=qHdl.AutoScaleFactor;
            obj.LineStyle=qHdl.LineStyle;
            obj.LineWidth=qHdl.LineWidth;
            obj.MarkerSize=qHdl.MarkerSize;
            obj.Marker=qHdl.Marker;
            obj.MaxHeadSize=qHdl.MaxHeadSize;
            % 数据属性复制
            obj.UData=qHdl.UData;obj.XData=qHdl.XData;
            obj.VData=qHdl.VData;obj.YData=qHdl.YData;
            % 伸缩因子计算
            obj.CQnorm0=sqrt(qHdl.UData.^2+qHdl.VData.^2);
            obj.CQnorm0=obj.CQnorm0(:);obj.CQnorm0=(obj.CQnorm0-min(obj.CQnorm0))./(max(obj.CQnorm0)-min(obj.CQnorm0));
            obj.CQnorm0(isnan(obj.CQnorm0))=0;
            obj.CQnorm1=norm([obj.XData(2,2)-obj.XData(1,1),obj.YData(2,2)-obj.YData(1,1)]);
            obj.CQnorm2=max(sqrt(qHdl.UData.^2+qHdl.VData.^2),[],[1,2]);
            % 伸缩数据计算
            obj.UDataS=obj.UData./obj.CQnorm2.*obj.CQnorm1.*obj.AutoScaleFactor;
            obj.VDataS=obj.VData./obj.CQnorm2.*obj.CQnorm1.*obj.AutoScaleFactor;
            % 颜色计算
            tx=(0:size(obj.CM,1)-1)./(size(obj.CM,1)-1);
            RData=reshape(interp1(tx,obj.CM(:,1),obj.CQnorm0,'linear'),size(obj.XData));
            GData=reshape(interp1(tx,obj.CM(:,2),obj.CQnorm0,'linear'),size(obj.XData));
            BData=reshape(interp1(tx,obj.CM(:,3),obj.CQnorm0,'linear'),size(obj.XData));
            % 构造每一个箭头对象属性
            for i=1:size(obj.XData,1)
                for j=1:size(obj.XData,2)
                    obj.cqPropHdl(i,j).XData=obj.XData(i,j);
                    obj.cqPropHdl(i,j).YData=obj.YData(i,j);
                    obj.cqPropHdl(i,j).UData=obj.UData(i,j);
                    obj.cqPropHdl(i,j).VData=obj.VData(i,j);
                    obj.cqPropHdl(i,j).UDataS=obj.UDataS(i,j);
                    obj.cqPropHdl(i,j).VDataS=obj.VDataS(i,j);
                    obj.cqPropHdl(i,j).RData=RData(i,j);
                    obj.cqPropHdl(i,j).GData=GData(i,j);
                    obj.cqPropHdl(i,j).BData=BData(i,j);
                end
            end
            % delete(qHdl);
              delete(qHdl);
        end
        function obj=draw(obj)
            if strcmp(obj.AutoScale,'on')
            obj.cqHdl=arrayfun(@(hdl) quiver(hdl.XData,hdl.YData,hdl.UDataS,hdl.VDataS,...
                'Color',[hdl.RData,hdl.GData,hdl.BData],'AutoScale','off','MaxHeadSize',3,...
                'LineWidth',obj.LineWidth,'LineStyle',obj.LineStyle,'MarkerSize',obj.MarkerSize,...
                'Marker',obj.Marker),obj.cqPropHdl);
            else
            obj.cqHdl=arrayfun(@(hdl) quiver(hdl.XData,hdl.YData,hdl.UData,hdl.VData,...
                'Color',[hdl.RData,hdl.GData,hdl.BData],'AutoScale','off','MaxHeadSize',3,...
                'LineWidth',obj.LineWidth,'LineStyle',obj.LineStyle,'MarkerSize',obj.MarkerSize,...
                'Marker',obj.Marker),obj.cqPropHdl);
            end
        end
    end
end