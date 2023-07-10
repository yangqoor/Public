classdef radarChart
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : hikari

    properties
        ax;arginList={'ClassName','PropName','Type'}
        XData;RTick=[];RLim=[];SepList=[1,1.2,1.5,2,2.5,3,4,5,6,8]
        Type='Line';
        PropNum;ClassNum
        ClassName={};
        PropName={};
        
        BC=[198,199,201;  38, 74, 96; 209, 80, 51; 241,174, 44; 12,13,15;
            102,194,165; 252,140, 98; 142,160,204; 231,138,195; 
            166,217, 83; 255,217, 48; 229,196,148; 179,179,179]./255;

        % 句柄
        ThetaTickHdl;RTickHdl;RLabelHdl;LgdHdl;PatchHdl;PropLabelHdl;BkgHdl
    end

    methods
        function obj=radarChart(varargin)
            if isa(varargin{1},'matlab.graphics.axis.Axes')
                obj.ax=varargin{1};varargin(1)=[];
            else
                obj.ax=gca;
            end
            % 获取版本信息
            tver=version('-release');
            verMatlab=str2double(tver(1:4))+(abs(tver(5))-abs('a'))/2;
            if verMatlab<2017
                hold on
            else
                hold(obj.ax,'on')
            end

            obj.XData=varargin{1};varargin(1)=[];
            obj.PropNum=size(obj.XData,2);
            obj.ClassNum=size(obj.XData,1);
            obj.RLim=[0,max(obj.XData,[],[1,2])];

            % 获取其他信息
            for i=1:2:(length(varargin)-1)
                tid=ismember(obj.arginList,varargin{i});
                if any(tid)
                obj.(obj.arginList{tid})=varargin{i+1};
                end
            end
            if isempty(obj.ClassName)
                for i=1:obj.ClassNum
                    obj.ClassName{i}=['class ',num2str(i)];
                end
            end
            if isempty(obj.PropName)
                for i=1:obj.PropNum
                    obj.PropName{i}=['prop ',num2str(i)];
                end
            end
            help radarChart
        end

        function obj=draw(obj)
            obj.ax.XLim=[-1,1];
            obj.ax.YLim=[-1,1];
            obj.ax.XTick=[];
            obj.ax.YTick=[];
            obj.ax.XColor='none';
            obj.ax.YColor='none';
            obj.ax.PlotBoxAspectRatio=[1,1,1];
            % 绘制背景圆形
            tt=linspace(0,2*pi,200);
            obj.BkgHdl=fill(cos(tt),sin(tt),[252,252,252]./255,'EdgeColor',[200,200,200]./255,'LineWidth',1);
            % 绘制Theta刻度线
            tn=linspace(0,2*pi,obj.PropNum+1);tn=tn(1:end-1);
            XTheta=[cos(tn);zeros([1,obj.PropNum]);nan([1,obj.PropNum])];
            YTheta=[sin(tn);zeros([1,obj.PropNum]);nan([1,obj.PropNum])];
            obj.ThetaTickHdl=plot(XTheta(:),YTheta(:),'Color',[200,200,200]./255,'LineWidth',1);
            % 绘制R刻度线
            if isempty(obj.RTick)
                dr=diff(obj.RLim);
                sepR=dr./3;
                multiE=ceil(log(sepR)/log(10));
                sepR=sepR.*10^(1-multiE);
                sepR=obj.SepList(find(sepR<obj.SepList,1)-1)./10^(1-multiE);

                sepNum=floor(dr./sepR);
                obj.RTick=obj.RLim(1)+(0:sepNum).*sepR;
                if obj.RTick(end)~=obj.RLim(2)
                    obj.RTick=[obj.RTick,obj.RLim];
                end
            end
            obj.RLim(obj.RLim<obj.RLim(1))=[];
            obj.RLim(obj.RLim>obj.RLim(2))=[];
            
            XR=cos(tt').*(obj.RTick-obj.RLim(1))./diff(obj.RLim);XR=[XR;nan([1,length(obj.RTick)])];
            YR=sin(tt').*(obj.RTick-obj.RLim(1))./diff(obj.RLim);YR=[YR;nan([1,length(obj.RTick)])];
            obj.RTickHdl=plot(XR(:),YR(:),'Color',[200,200,200]./255,'LineWidth',1.1,'LineStyle','--');

            % 绘制雷达图
            for i=1:size(obj.XData,1)
                XP=cos(tn).*(obj.XData(i,:)-obj.RLim(1))./diff(obj.RLim);
                YP=sin(tn).*(obj.XData(i,:)-obj.RLim(1))./diff(obj.RLim);
                switch obj.Type
                    case 'Line'
                        obj.PatchHdl(i)=plot([XP,XP(1)],[YP,YP(1)],...
                            'Color',obj.BC(mod(i-1,size(obj.BC,1))+1,:),'Marker','o',...
                            'LineWidth',1.8,'MarkerFaceColor',obj.BC(mod(i-1,size(obj.BC,1))+1,:));
                    case 'Patch'
                        obj.PatchHdl(i)=patch(XP,YP,obj.BC(mod(i-1,size(obj.BC,1))+1,:),...
                            'EdgeColor',obj.BC(mod(i-1,size(obj.BC,1))+1,:),'FaceAlpha',.2,...
                            'LineWidth',1.8);

                end
            end

            % 绘制R标签文本
            tnr=(tn(1)+tn(2))/2;
            for i=1:length(obj.RTick)
                obj.RLabelHdl(i)=text(cos(tnr).*(obj.RTick(i)-obj.RLim(1))./diff(obj.RLim),...
                                      sin(tnr).*(obj.RTick(i)-obj.RLim(1))./diff(obj.RLim),...
                                      sprintf('%.2f',obj.RTick(i)),'FontName','Arial','FontSize',11);
            end

            % 绘制属性标签
            for i=1:obj.PropNum
                obj.PropLabelHdl(i)=text(cos(tn(i)).*1.1,sin(tn(i)).*1.1,obj.PropName{i},...
                    'FontSize',12,'HorizontalAlignment','center');
            end

        end
% =========================================================================
        function obj=setBkg(obj,varargin)
            set(obj.BkgHdl,varargin{:})
        end

        % 绘制图例
        function obj=legend(obj)
            obj.LgdHdl=legend([obj.PatchHdl],obj.ClassName,'FontSize',12,'Location','best');
        end
        % 设置图例属性
        function obj=setLegend(obj,varargin)
            set(obj.LgdHdl,varargin{:})
        end

        % 设置标签
        function obj=setPropLabel(obj,varargin)
            for i=1:obj.PropNum
                set(obj.PropLabelHdl(i),varargin{:})
            end
        end
        function obj=setRLabel(obj,varargin)
            for i=1:length(obj.RLabelHdl)
                set(obj.RLabelHdl(i),varargin{:})
            end
        end

        % 设置轴
        function obj=setRTick(obj,varargin)
            set(obj.RTickHdl,varargin{:})
        end
        function obj=setThetaTick(obj,varargin)
            set(obj.ThetaTickHdl,varargin{:})
        end

        % 设置patch属性
        function obj=setPatchN(obj,N,varargin)
            set(obj.PatchHdl(N),varargin{:})
        end
    end
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : hikari
end