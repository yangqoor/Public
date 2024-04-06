classdef STaylorDiag < handle
% Copyright (c) 2023, Zhaoxu Liu / slandarer
    properties
        STATS;  % STD RMSD and COR
        ax; TickLength=[.015,.008];
        % S-Axis means STD Axis
        SAxis; RAxis; CAxis;
        SGrid; RGrid; CGrid;
        SLabel; RLabel; CLabel;   
        STickLabelX; STickLabelY; RTickLabel; CTickLabel;
        % STD Tick and MinorTick
        STick; SMinorTick; STickValues; SMinorTickValues; SLim;
        %
        RTickValues; RLim;
        %
        CTick; CMinorTick; CLim = [0,1];
        CTickValues=[.1,.3,.5,.7,.9,.95,.99];
        CMinorTickValues=[.05,.15,.2,.25,.35,.4,.45,.55,.6,.65,.75,.8,.85,.91,.92,.93,.94,.96,.97,.98,1]; 
    end
    methods
        function obj = STaylorDiag(varargin)
            if isa(varargin{1},'matlab.graphics.axis.Axes')
                obj.ax = varargin{1}; varargin(1) = [];
            else
                obj.ax = gca;
            end
            obj.STATS = varargin{1};
            obj.ax.Parent.Color = [1,1,1];
            obj.ax.NextPlot = 'add';
            obj.ax.XGrid = 'off';
            obj.ax.YGrid = 'off';
            obj.ax.Box = 'off';
            obj.ax.DataAspectRatio = [1,1,1];
            % -------------------------------------------------------------
            obj.SLim = [0,max(obj.STATS(1,:)).*1.15];
            obj.ax.XLim = obj.SLim;
            obj.STickValues = obj.ax.XTick;
            obj.RLim = [0,max(obj.STATS(2,:)).*1.15];
            obj.ax.XLim = obj.RLim;
            obj.RTickValues = obj.ax.XTick;
            obj.RTickValues(1) = [];
            obj.ax.XLim = obj.SLim; obj.ax.YLim = obj.SLim;
            obj.SMinorTickValues = ...
                linspace(obj.STickValues(1),obj.STickValues(end),(length(obj.STickValues)-1).*5+1);
            obj.SMinorTickValues=setdiff(obj.SMinorTickValues,obj.STickValues);
            obj.CMinorTickValues=setdiff(obj.CMinorTickValues,obj.CTickValues);
            % -------------------------------------------------------------
            % STD Tick, MinorTick, Grid, TickLabel
            [tYTickX,tYTickY,tYTickMX,tYTickMY,tRGridX,tRGridY] = obj.getSValue();
            obj.SGrid = plot(obj.ax,tRGridX(:),tRGridY(:),'LineWidth',.5,'Color','k');
            obj.SAxis = plot(obj.ax,[0,0,obj.SLim(2)],[obj.SLim(2),0,0],'LineWidth',1.2,'Color','k');
            obj.STick = plot(obj.ax,[tYTickX(:);tYTickY(:)],[tYTickY(:);tYTickX(:)],'LineWidth',.8,'Color','k');
            obj.SMinorTick = plot(obj.ax,[tYTickMX(:);tYTickMY(:)],[tYTickMY(:);tYTickMX(:)],'LineWidth',.8,'Color','k');
            obj.STickLabelX = text(obj.ax,obj.STickValues,0.*obj.STickValues,string(obj.STickValues),...
                'FontName','Times New Roman','FontSize',13,'VerticalAlignment','top','HorizontalAlignment','center');
            obj.STickLabelY = text(obj.ax,0.*obj.STickValues(2:end),obj.STickValues(2:end),string(obj.STickValues(2:end))+" ",...
                'FontName','Times New Roman','FontSize',13,'VerticalAlignment','middle','HorizontalAlignment','right');
            obj.SLabel = text(obj.ax,obj.ax.YLabel.Position(1),obj.ax.YLabel.Position(2),'Standard Deviation',...
                'FontName','Times New Roman','FontSize',20,'VerticalAlignment','bottom','HorizontalAlignment','center','Rotation',90);
            obj.SGrid.Annotation.LegendInformation.IconDisplayStyle='off';
            obj.SAxis.Annotation.LegendInformation.IconDisplayStyle='off';
            obj.STick.Annotation.LegendInformation.IconDisplayStyle='off';
            obj.SMinorTick.Annotation.LegendInformation.IconDisplayStyle='off';
            % -------------------------------------------------------------
            % RMSD Grid TickLabel
            [tR2GridX,tR2GridY] = obj.getRValue();
            obj.RGrid = plot(obj.ax,tR2GridX(:),tR2GridY(:),'LineWidth',.5,'Color','k','LineStyle','--');
            obj.RTickLabel = text(obj.ax,cos(pi*5/6).*obj.RTickValues+obj.STATS(1,1),sin(pi*5/6).*obj.RTickValues,string(obj.RTickValues),...
                'FontName','Times New Roman','FontSize',13,'VerticalAlignment','bottom','HorizontalAlignment','center','Rotation',60);
            obj.RGrid.Annotation.LegendInformation.IconDisplayStyle='off';
            % -------------------------------------------------------------
            % RMSD^2 = STD_r^2 + STD_f^2 - 2*STD_r*STD_f*COR
            %
            %        STD_r^2 + STD_f^2 - RMSD^2
            % COR = ----------------------------
            %              2*STD_r*STD_f
            %
            [tCAxisX,tCAxisY,tTRMSD,tCTickX,tCTickY,tCTickMX,tCTickMY,tRMSDGridX,tRMSDGridY]=obj.getCValue();
            obj.CGrid = plot(obj.ax,tRMSDGridX(:),tRMSDGridY(:),'LineWidth',.5,'Color',[.8,.8,.8],'LineStyle','-');
            obj.CAxis = plot(obj.ax,tCAxisX,tCAxisY,'LineWidth',1.2,'Color','k');
            obj.CTick = plot(obj.ax,tCTickX(:),tCTickY(:),'LineWidth',.8,'Color','k');
            obj.CMinorTick = plot(obj.ax,tCTickMX(:),tCTickMY(:),'LineWidth',.8,'Color','k');
            for i=1:length(tTRMSD)
                obj.CTickLabel{i} = text(obj.ax,cos(tTRMSD(i)).*obj.SLim(2),sin(tTRMSD(i)).*obj.SLim(2)," "+string(obj.CTickValues(i)),...
                    'FontName','Times New Roman','FontSize',13,'VerticalAlignment','middle','HorizontalAlignment','left','Rotation',tTRMSD(i)./pi.*2.*90);
            end
            obj.CLabel = text(obj.ax,cos(pi/4).*(obj.SLim(2)-obj.ax.YLabel.Position(1)),...
                sin(pi/4).*(obj.SLim(2)-obj.ax.YLabel.Position(1)),'Correlation',...
                'FontName','Times New Roman','FontSize',20,'VerticalAlignment','bottom','HorizontalAlignment','center','Rotation',-45);
            obj.CGrid.Annotation.LegendInformation.IconDisplayStyle='off';
            obj.CAxis.Annotation.LegendInformation.IconDisplayStyle='off';
            obj.CTick.Annotation.LegendInformation.IconDisplayStyle='off';
            obj.CMinorTick.Annotation.LegendInformation.IconDisplayStyle='off';
            % -------------------------------------------------------------
            obj.ax.XColor = 'none';
            obj.ax.YColor = 'none';
        end
        % =================================================================
        function [tYTickX,tYTickY,tYTickMX,tYTickMY,tRGridX,tRGridY]=getSValue(obj)
            tTPi_2 = linspace(0,pi/2,200).';
            tYTickX = [0.*obj.STickValues;obj.STickValues.*0+obj.TickLength(1).*obj.SLim(2);nan.*obj.STickValues];
            tYTickY = [obj.STickValues;obj.STickValues;nan.*obj.STickValues];
            tYTickMX = [0.*obj.SMinorTickValues;obj.SMinorTickValues.*0+obj.TickLength(2).*obj.SLim(2);nan.*obj.SMinorTickValues];
            tYTickMY = [obj.SMinorTickValues;obj.SMinorTickValues;nan.*obj.SMinorTickValues];
            tRGridX = [obj.STickValues.*cos(repmat(tTPi_2,[1,length(obj.STickValues)]));nan.*obj.STickValues];
            tRGridY = [obj.STickValues.*sin(repmat(tTPi_2,[1,length(obj.STickValues)]));nan.*obj.STickValues];
        end
        function [tR2GridX,tR2GridY]=getRValue(obj)
            tTPi = linspace(0,pi,200).';
            tR2GridX = [obj.RTickValues.*cos(repmat(tTPi,[1,length(obj.RTickValues)]));nan.*obj.RTickValues]+obj.STATS(1,1);
            tR2GridY = [obj.RTickValues.*sin(repmat(tTPi,[1,length(obj.RTickValues)]));nan.*obj.RTickValues];
            tR2GridN = sqrt(tR2GridX.^2+tR2GridY.^2)>obj.SLim(2);
            tR2GridX(tR2GridN) = nan; tR2GridY(tR2GridN) = nan;
        end
        function [tCAxisX,tCAxisY,tTRMSD,tCTickX,tCTickY,tCTickMX,tCTickMY,tRMSDGridX,tRMSDGridY]=getCValue(obj)
            tTPi_2 = linspace(0,pi/2,200).';
            tCAxisX = cos(tTPi_2).*obj.SLim(2);
            tCAxisY = sin(tTPi_2).*obj.SLim(2);
            tRMSD = sqrt(2.*(obj.STATS(1,1).^2)-2.*(obj.STATS(1,1).^2).*obj.CTickValues);
            tTRMSD = asin(tRMSD./2./obj.STATS(1,1)).*2;
            tCTickX = [cos(tTRMSD).*obj.SLim(2);cos(tTRMSD).*obj.SLim(2).*(1-obj.TickLength(1));tTRMSD.*nan];
            tCTickY = [sin(tTRMSD).*obj.SLim(2);sin(tTRMSD).*obj.SLim(2).*(1-obj.TickLength(1));tTRMSD.*nan];
            tRMSDM = sqrt(2.*(obj.STATS(1,1).^2)-2.*(obj.STATS(1,1).^2).*obj.CMinorTickValues);
            tTRMSDM = asin(tRMSDM./2./obj.STATS(1,1)).*2;
            tCTickMX = [cos(tTRMSDM).*obj.SLim(2);cos(tTRMSDM).*obj.SLim(2).*(1-obj.TickLength(2));tTRMSDM.*nan];
            tCTickMY = [sin(tTRMSDM).*obj.SLim(2);sin(tTRMSDM).*obj.SLim(2).*(1-obj.TickLength(2));tTRMSDM.*nan];
            tRMSDGridX = [cos(tTRMSD).*obj.SLim(2);0.*tTRMSD;nan.*tTRMSD];
            tRMSDGridY = [sin(tTRMSD).*obj.SLim(2);0.*tTRMSD;nan.*tTRMSD];
        end
        % =================================================================
        function pltHdl=SPlot(obj,STD,~,COR,varargin)
            tTheta = acos(COR);
            pltHdl = plot(obj.ax,cos(tTheta).*STD,sin(tTheta).*STD,varargin{:},'LineStyle','none');
        end
        function txtHdl=SText(obj,STD,~,COR,varargin)
            tTheta = acos(COR);
            txtHdl = text(obj.ax,cos(tTheta).*STD,sin(tTheta).*STD,varargin{:});
        end
        % =================================================================
        function set(obj,target,varargin)
            if isa(varargin{1},'char')||isa(varargin{1},'string')
            switch target
                case {'SAxis','CAxis','SLabel','CLabel','STick','CTick','SMinorTick','CMinorTick','RTickLabel','SGrid','RGrid','CGrid'}
                    set(obj.(target),varargin{:});
                case 'STickLabelX'
                    set(obj.STickLabelX,varargin{:});
                case 'STickLabelY'
                    set(obj.STickLabelY,varargin{:});
                case 'CTickLabel'
                    for i=1:length(obj.CTickLabel)
                        set(obj.CTickLabel{i},varargin{:});
                    end
            end
            else
                oriRLim = obj.RLim;
                obj.(target) = varargin{1};
                obj.ax.XColor = 'k';
                obj.ax.YColor = 'k';
                if abs(obj.SLim(2)-obj.ax.XLim(2))>eps||abs(obj.RLim(2)-oriRLim(2))>eps
                    obj.ax.XLim = obj.SLim;
                    obj.STickValues = obj.ax.XTick;
                    obj.ax.XLim = obj.RLim;
                    obj.RTickValues = obj.ax.XTick;
                    obj.RTickValues(1) = [];
                    obj.ax.XLim = obj.SLim; obj.ax.YLim = obj.SLim;
                    obj.SMinorTickValues = ...
                        linspace(obj.STickValues(1),obj.STickValues(end),(length(obj.STickValues)-1).*5+1);
                end
                obj.(target) = varargin{1};
                obj.SMinorTickValues=setdiff(obj.SMinorTickValues,obj.STickValues);
                obj.CMinorTickValues=setdiff(obj.CMinorTickValues,obj.CTickValues);        
                %
                [tYTickX,tYTickY,tYTickMX,tYTickMY,tRGridX,tRGridY] = obj.getSValue();
                set(obj.SGrid,'XData',tRGridX(:),'YData',tRGridY(:));
                set(obj.SAxis,'XData',[0,0,obj.SLim(2)],'YData',[obj.SLim(2),0,0]);
                set(obj.STick,'XData',[tYTickX(:);tYTickY(:)],'YData',[tYTickY(:);tYTickX(:)]);
                set(obj.SMinorTick,'XData',[tYTickMX(:);tYTickMY(:)],'YData',[tYTickMY(:);tYTickMX(:)]);
                delete(obj.STickLabelX);delete(obj.STickLabelY);delete(obj.SLabel)
                obj.STickLabelX = text(obj.ax,obj.STickValues,0.*obj.STickValues,string(obj.STickValues),...
                    'FontName','Times New Roman','FontSize',13,'VerticalAlignment','top','HorizontalAlignment','center');
                obj.STickLabelY = text(obj.ax,0.*obj.STickValues(2:end),obj.STickValues(2:end),string(obj.STickValues(2:end))+" ",...
                    'FontName','Times New Roman','FontSize',13,'VerticalAlignment','middle','HorizontalAlignment','right');
                obj.SLabel = text(obj.ax,obj.ax.YLabel.Position(1),obj.ax.YLabel.Position(2),'Standard Deviation',...
                    'FontName','Times New Roman','FontSize',20,'VerticalAlignment','bottom','HorizontalAlignment','center','Rotation',90);
                %
                [tR2GridX,tR2GridY] = obj.getRValue();
                set(obj.RGrid,'XData',tR2GridX(:),'YData',tR2GridY(:));
                delete(obj.RTickLabel)
                obj.RTickLabel = text(obj.ax,cos(pi*5/6).*obj.RTickValues+obj.STATS(1,1),sin(pi*5/6).*obj.RTickValues,string(obj.RTickValues),...
                    'FontName','Times New Roman','FontSize',13,'VerticalAlignment','bottom','HorizontalAlignment','center','Rotation',60);
                %
                [tCAxisX,tCAxisY,tTRMSD,tCTickX,tCTickY,tCTickMX,tCTickMY,tRMSDGridX,tRMSDGridY]=obj.getCValue();
                set(obj.CGrid,'XData',tRMSDGridX(:),'YData',tRMSDGridY(:));
                set(obj.CAxis,'XData',tCAxisX,'YData',tCAxisY);
                set(obj.CTick,'XData',tCTickX(:),'YData',tCTickY(:));
                set(obj.CMinorTick,'XData',tCTickMX(:),'YData',tCTickMY(:));
                for i=length(obj.CTickLabel):-1:1
                    delete(obj.CTickLabel{i});
                end
                delete(obj.CLabel);
                for i=1:length(tTRMSD)
                    obj.CTickLabel{i} = text(obj.ax,cos(tTRMSD(i)).*obj.SLim(2),sin(tTRMSD(i)).*obj.SLim(2)," "+string(obj.CTickValues(i)),...
                        'FontName','Times New Roman','FontSize',13,'VerticalAlignment','middle','HorizontalAlignment','left','Rotation',tTRMSD(i)./pi.*2.*90);
                end
                obj.CLabel = text(obj.ax,cos(pi/4).*(obj.SLim(2)-obj.ax.YLabel.Position(1)),...
                    sin(pi/4).*(obj.SLim(2)-obj.ax.YLabel.Position(1)),'Correlation',...
                    'FontName','Times New Roman','FontSize',20,'VerticalAlignment','bottom','HorizontalAlignment','center','Rotation',-45);
                obj.ax.XColor = 'none';
                obj.ax.YColor = 'none';
            end
        end
    end
end