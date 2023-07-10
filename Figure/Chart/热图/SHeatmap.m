classdef SHeatmap
% =========================================================================
% Format
% -------------------------------------------------------------------------
% sq    : 方形(默认)
% pie   : 饼图
% circ  : 圆形
% oval  : 椭圆形
% hex   : 六边形
% asq   : 自带调整大小的方形
% acirc : 自带调整大小的圆形
% =========================================================================
% @author : slandarer
% 公众号  : slandarer随笔 
% -------------------------------------------------------------------------
% Zhaoxu Liu / slandarer (2023). special heatmap 
% (https://www.mathworks.com/matlabcentral/fileexchange/125520-special-heatmap), 
% MATLAB Central File Exchange. 检索来源 2023/3/1.
% -------------------------------------------------------------------------

    properties
        ax,arginList={'Format'}
        Format='sq'  % sq    : 方形(默认)
                     % pie   : 饼图
                     % circ  : 圆形
                     % oval  : 椭圆形
                     % hex   : 六边形
                     % asq   : 自带调整大小的方形
                     % acirc : 自带调整大小的圆形
        Data
        dfColor1=[0.9686    0.9882    0.9412;    0.9454    0.9791    0.9199;    0.9221    0.9700    0.8987;    0.8988    0.9609    0.8774;
                  0.8759    0.9519    0.8560;    0.8557    0.9438    0.8338;    0.8354    0.9357    0.8115;    0.8152    0.9276    0.7892;
                  0.7909    0.9180    0.7685;    0.7545    0.9039    0.7523;    0.7180    0.8897    0.7361;    0.6816    0.8755    0.7199;
                  0.6417    0.8602    0.7155;    0.5962    0.8430    0.7307;    0.5507    0.8258    0.7459;    0.5051    0.8086    0.7610;
                  0.4596    0.7873    0.7762;    0.4140    0.7620    0.7914;    0.3685    0.7367    0.8066;    0.3230    0.7114    0.8218;
                  0.2837    0.6773    0.8142;    0.2483    0.6378    0.7929;    0.2129    0.5984    0.7717;    0.1775    0.5589    0.7504;
                  0.1421    0.5217    0.7314;    0.1066    0.4853    0.7132;    0.0712    0.4488    0.6950;    0.0358    0.4124    0.6768;
                  0.0314    0.3724    0.6364;    0.0314    0.3319    0.5929;    0.0314    0.2915    0.5494;    0.0314    0.2510    0.5059]
        dfColor2=[0.6196    0.0039    0.2588;    0.6892    0.0811    0.2753;    0.7588    0.1583    0.2917;    0.8283    0.2354    0.3082;
                  0.8706    0.2966    0.2961;    0.9098    0.3561    0.2810;    0.9490    0.4156    0.2658;    0.9660    0.4932    0.2931;
                  0.9774    0.5755    0.3311;    0.9887    0.6577    0.3690;    0.9930    0.7266    0.4176;    0.9943    0.7899    0.4707;
                  0.9956    0.8531    0.5238;    0.9968    0.9020    0.5846;    0.9981    0.9412    0.6503;    0.9994    0.9804    0.7161;
                  0.9842    0.9937    0.7244;    0.9526    0.9810    0.6750;    0.9209    0.9684    0.6257;    0.8721    0.9486    0.6022;
                  0.7975    0.9183    0.6173;    0.7228    0.8879    0.6325;    0.6444    0.8564    0.6435;    0.5571    0.8223    0.6448;
                  0.4698    0.7881    0.6460;    0.3868    0.7461    0.6531;    0.3211    0.6727    0.6835;    0.2553    0.5994    0.7139;
                  0.2016    0.5261    0.7378;    0.2573    0.4540    0.7036;    0.3130    0.3819    0.6694;    0.3686    0.3098    0.6353]
        Colormap;maxV
        patchHdl;boxHdl;pieHdl;textHdl
    end
    methods
        function obj=SHeatmap(Data,varargin)
            obj.Data=Data;
            obj.maxV=max(max(abs(obj.Data)));
            % 获取其他数据
            disp(char([64 97 117 116 104 111 114 32 58 32,...
                 115 108 97 110 100 97 114 101 114]))
            for i=1:2:(length(varargin)-1)
                tid=ismember(obj.arginList,varargin{i});
                if any(tid)
                    obj.(obj.arginList{tid})=varargin{i+1};
                end
            end
            % 设置配色
            if any(any(obj.Data<0))
                obj.Colormap=obj.dfColor2;
                % tX=linspace(0,1,size(obj.Colormap,1));
                % tXi=linspace(0,1,256);
                % tR=interp1(tX,obj.Colormap(:,1),tXi);
                % tG=interp1(tX,obj.Colormap(:,2),tXi);
                % tB=interp1(tX,obj.Colormap(:,3),tXi);
                % obj.Colormap=[tR(:),tG(:),tB(:)];
            else
                obj.Colormap=obj.dfColor1(end:-1:1,:);
            end
        end
        function obj=draw(obj)
            obj.ax=gca;hold on;box on
            obj.ax.FontName='Times New Roman';
            obj.ax.FontSize=12;
            obj.ax.LineWidth=.8;
            obj.ax.XLim=[.5,size(obj.Data,2)+.5];
            obj.ax.YLim=[.5,size(obj.Data,1)+.5];
            obj.ax.YDir='reverse';
            obj.ax.TickDir='out';
            obj.ax.TickLength=[0.002,0.002];
            obj.ax.DataAspectRatio=[1,1,1];
            obj.ax.YTick=1:size(obj.Data,1);
            obj.ax.XTick=1:size(obj.Data,2);
            colormap(obj.Colormap)
            colorbar

            if any(any(obj.Data<0))
                try caxis(obj.maxV.*[-1,1]),catch,end
                try clim(obj.maxV.*[-1,1]),catch,end
            else
                try caxis(obj.maxV.*[0,1]),catch,end
                try clim(obj.maxV.*[0,1]),catch,end
            end

            % 调整初始界面大小
            fig=obj.ax.Parent;
            fig.Color=[1,1,1];
            if max(fig.Position(3:4))<600
                fig.Position(3:4)=[1.6,1.8].*fig.Position(3:4);
                fig.Position(1:2)=fig.Position(1:2)./4;
            end

            bX1=repmat([.5,size(obj.Data,2)+.5,nan],[size(obj.Data,1)+1,1])';
            bY1=repmat((.5:1:(size(obj.Data,1)+.5))',[1,3])';
            bX2=repmat((.5:1:(size(obj.Data,2)+.5))',[1,3])';
            bY2=repmat([.5,size(obj.Data,1)+.5,nan],[size(obj.Data,2)+1,1])';
            obj.boxHdl=plot([bX1(:);bX2(:)],[bY1(:);bY2(:)],'LineWidth',.8,'Color',[1,1,1].*.85);
            if isequal(obj.Format,'sq')
                set(obj.boxHdl,'Color',[1,1,1,0])
            end

            
            baseT=linspace(0,2*pi,200);
            hexT=linspace(0,2*pi,7);
            thetaMat=[1,-1;1,1].*sqrt(2)./2;

            for row=1:size(obj.Data,1)
                for col=1:size(obj.Data,2)    
                    if isnan(obj.Data(row,col))
                        obj.patchHdl(row,col)=fill([-.5,.5,.5,-.5].*.98+col,[-.5,-.5,.5,.5].*.98+row,[.8,.8,.8],'EdgeColor','none');
                        obj.pieHdl(row,col)=fill([0,0,0,0],[0,0,0,0],[0,0,0]);
                        obj.textHdl(row,col)=text(col,row,'×','FontName','Times New Roman','HorizontalAlignment','center','FontSize',20);
                    else
                        tRatio=abs(obj.Data(row,col))./obj.maxV;
                        switch obj.Format
                            case 'sq'
                                obj.patchHdl(row,col)=fill([-.5,.5,.5,-.5].*.98+col,[-.5,-.5,.5,.5].*.98+row,...
                                    obj.Data(row,col),'EdgeColor','none');
                            case 'asq'
                                obj.patchHdl(row,col)=fill([-.5,.5,.5,-.5].*.98.*tRatio+col,[-.5,-.5,.5,.5].*.98.*tRatio+row,...
                                    obj.Data(row,col),'EdgeColor','none');
                            case 'pie'
                                baseCircX=cos(baseT).*.92.*.5;
                                baseCircY=sin(baseT).*.92.*.5;
                                obj.pieHdl(row,col)=fill(baseCircX+col,baseCircY+row,...
                                    [1,1,1],'EdgeColor',[1,1,1].*.3,'LineWidth',.8);
                                baseTheta=linspace(pi/2,pi/2+obj.Data(row,col)./obj.maxV.*2.*pi,200);
                                basePieX=[0,cos(baseTheta).*.92.*.5];
                                basePieY=[0,sin(baseTheta).*.92.*.5];
                                obj.patchHdl(row,col)=fill(basePieX+col,-basePieY+row,...
                                    obj.Data(row,col),'EdgeColor',[1,1,1].*.3,'lineWidth',.8);
                            case 'circ'
                                baseCircX=cos(baseT).*.92.*.5;
                                baseCircY=sin(baseT).*.92.*.5;
                                obj.patchHdl(row,col)=fill(baseCircX+col,baseCircY+row,...
                                    obj.Data(row,col),'EdgeColor','none','lineWidth',.8);
                            case 'acirc'
                                baseCircX=cos(baseT).*.92.*.5;
                                baseCircY=sin(baseT).*.92.*.5;
                                obj.patchHdl(row,col)=fill(baseCircX.*tRatio+col,baseCircY.*tRatio+row,...
                                    obj.Data(row,col),'EdgeColor','none','lineWidth',.8);
                            case 'oval'
                                tValue=obj.Data(row,col)./obj.maxV;
                                baseA=1+(tValue<=0).*tValue;
                                baseB=1-(tValue>=0).*tValue;
                                baseOvalX=cos(baseT).*.98.*.5.*baseA;
                                baseOvalY=sin(baseT).*.98.*.5.*baseB;
                                baseOvalXY=thetaMat*[baseOvalX;baseOvalY];
                                obj.patchHdl(row,col)=fill(baseOvalXY(1,:)+col,-baseOvalXY(2,:)+row,...
                                    obj.Data(row,col),'EdgeColor',[1,1,1].*.3,'lineWidth',.8);
                            case 'hex'
                                obj.patchHdl(row,col)=fill(cos(hexT).*.5.*.98.*tRatio+col,sin(hexT).*.5.*.98.*tRatio+row,...
                                    obj.Data(row,col),'EdgeColor',[1,1,1].*.3,'lineWidth',.8);
                        end
                        obj.textHdl(row,col)=text(col,row,sprintf('%.2f',obj.Data(row,col)),'FontName','Times New Roman','HorizontalAlignment','center','Visible','off');
                    end
                end
            end
        end
        % 修饰文本
        function setText(obj,varargin)
            graymap=mean(get(obj.ax,'Colormap'),2);
            climit=get(obj.ax,'CLim');
            for row=1:size(obj.Data,1)
                for col=1:size(obj.Data,2)     
                    set(obj.textHdl(row,col),'Visible','on','Color',...
                        [1,1,1].*(interp1(linspace(climit(1),climit(2),size(graymap,1)),graymap,obj.Data(row,col))<.5),varargin{:})
                end
            end
        end
        function setTextMN(obj,m,n,varargin)
            set(obj.textHdl(m,n),varargin{:})
        end
        % 设置图形样式
        function setPatch(obj,varargin)
            for row=1:size(obj.Data,1)
                for col=1:size(obj.Data,2)   
                    if ~isnan(obj.Data(row,col))
                    set(obj.patchHdl(row,col),varargin{:})
                    if isequal(obj.Format,'pie')
                    set(obj.pieHdl(row,col),varargin{:})  
                    end
                    end
                end
            end
        end
        function setPatchMN(obj,m,n,varargin)
            set(obj.patchHdl(m,n),varargin{:})
            if isequal(obj.Format,'pie')
                set(obj.pieHdl(m,n),varargin{:})
            end
        end
        % 设置框样式
        function setBox(obj,varargin)
            set(obj.boxHdl,varargin{:})
        end
    end
% =========================================================================
% @author : slandarer
% 公众号  : slandarer随笔 
% -------------------------------------------------------------------------
% Zhaoxu Liu / slandarer (2023). special heatmap 
% (https://www.mathworks.com/matlabcentral/fileexchange/125520-special-heatmap), 
% MATLAB Central File Exchange. 检索来源 2023/3/1.
% -------------------------------------------------------------------------
end