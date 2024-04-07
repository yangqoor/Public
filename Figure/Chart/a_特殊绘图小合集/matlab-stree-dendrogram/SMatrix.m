classdef SMatrix < handle
% Copyright (c) 2024, Zhaoxu Liu / slandarer
% =========================================================================
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer
% -------------------------------------------------------------------------
% Zhaoxu Liu / slandarer (2024). STree dendrogram 
% (https://www.mathworks.com/matlabcentral/fileexchange/160048-stree-dendrogram), 
% MATLAB Central File Exchange.
    properties
        ax, H, XLim, YLim, TLim = [0,0] 
        oriXLim, oriYLim, XSet, YSet, Colormap, Parent, sInd
        LeftLabelFont = {'FontSize', 10, 'FontName', 'Times New Roman'}
        RightLabelFont = {'FontSize', 10, 'FontName', 'Times New Roman'}
        TopLabelFont = {'FontSize', 10, 'FontName', 'Times New Roman'}
        BottomLabelFont = {'FontSize', 10, 'FontName', 'Times New Roman'}
        RowOrder, RowClass, RowName
        ColOrder, ColClass, ColName

        heatmapHdl 

        maxH, ClustGap = 'off';
        XTick, YTick

        TopLabel     =  'off'
        BottomLabel  =  'on' 
        LeftLabel    =  'on' 
        RightLabel   =  'off'
        topLabelHdl, bottomLabelHdl, leftLabelHdl, rightLabelHdl

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

        arginList = {'Parent', 'Layout', 'Colormap', 'XLim', 'YLim', 'TLim',...
            'RowName', 'ColName', 'Font', 'Parent',...
            'RowOrder', 'RowClass', 'RowName', 'ColOrder', 'ColClass', 'ColName',...
            'TopLabelFont' , 'BottomLabelFont', 'LeftLabelFont', 'RightLabelFont',...
            'ClustGap'};

    end

    methods
        function obj = SMatrix(varargin)
            % 获取基本数据 -------------------------------------------------
            if isa(varargin{1}, 'matlab.graphics.axis.Axes')
                obj.ax = varargin{1}; varargin(1) = [];
            else  
            end
            obj.H = varargin{1}; varargin(1) = [];
            % 获取其他信息 -------------------------------------------------
            for i = 1:2:(length(varargin)-1)
                tid = ismember(obj.arginList, varargin{i});
                if any(tid)
                obj.(obj.arginList{tid}) = varargin{i+1};
                end
            end
            if isempty(obj.ax) && (~isempty(obj.Parent)), obj.ax=obj.Parent; end
            if isempty(obj.ax), obj.ax=gca; end
            obj.maxH=max(max(abs(obj.H)));
            % 设置配色 ----------------------------------------------------
            if isempty(obj.Colormap)
                if any(any(obj.H<0))
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
            % 分类情况 -----------------------------------------------------
            if isempty(obj.RowClass), obj.RowClass = ones(1, size(obj.H, 1)); end
            if isempty(obj.ColClass), obj.ColClass = ones(1, size(obj.H, 2)); end
            if isempty(obj.RowOrder), obj.RowOrder = 1:size(obj.H, 1); end
            if isempty(obj.ColOrder), obj.ColOrder = 1:size(obj.H, 2); end
            if isempty(obj.RowName), obj.RowName = compose('row%d', 1:size(obj.H, 1)); end
            if isempty(obj.ColName), obj.ColName = compose('col%d', 1:size(obj.H, 2)); end
        end

        function draw(obj)
            obj.ax.NextPlot = 'add';
            % 配色设置 -----------------------------------------------------
            colormap(obj.ax, obj.Colormap)
            colorbar(obj.ax)
            if any(any(obj.H < 0))
                try caxis(obj.ax, obj.maxH.*[-1,1]), catch, end
                try clim(obj.ax, obj.maxH.*[-1,1]), catch, end
            else
                try caxis(obj.ax, obj.maxH.*[0,1]), catch,end
                try clim(obj.ax, obj.maxH.*[0,1]), catch,end
            end
            % 原始X,Y范围获取 ----------------------------------------------
            gapRow = find(diff(obj.RowClass)~=0)+.5;
            gapCol = find(diff(obj.ColClass)~=0)+.5;
            obj.XSet = 1:size(obj.H, 2);
            obj.YSet = 1:size(obj.H, 1);
            if strcmpi(obj.ClustGap, 'on')
                for i = length(gapRow):-1:1
                    obj.YSet(obj.YSet>gapRow(i)) = obj.YSet(obj.YSet>gapRow(i))+1;
                end
                for i = length(gapCol):-1:1
                    obj.XSet(obj.XSet>gapCol(i)) = obj.XSet(obj.XSet>gapCol(i))+1;
                end
            end
            if abs(obj.TLim(1)-obj.TLim(2)) < eps
                obj.XTick = [obj.XSet(1)-.75, obj.XSet, obj.XSet(end)+.75]; 
                obj.YTick = [obj.YSet(1)-.75, obj.YSet, obj.YSet(end)+.75];
            else
                obj.XTick = [obj.XSet(1)-.75, obj.XSet, obj.XSet(end)+.75];
                obj.YTick = [obj.YSet(1)-.5, obj.YSet, obj.YSet(end)+.5];
            end
            if strcmp(obj.ClustGap,'on')
                gap = 1;
            else
                gap = .5;
            end
            obj.oriXLim = [1 - gap, max(max(obj.XSet)) + gap];
            obj.oriYLim = [1 - gap, max(max(obj.YSet)) + gap];
            if isempty(obj.XLim), obj.XLim = obj.oriXLim; end
            if isempty(obj.YLim), obj.YLim = obj.oriYLim; end
            % 坐标放缩 -----------------------------------------------------
            obj.sInd = reshape(1: size(obj.H, 2)*size(obj.H, 1), size(obj.H));
            baseX = [linspace(-1,1,30), ones(1,30), linspace(1,-1,30), -ones(1,30)].*.5;
            baseY = [-ones(1,30), linspace(-1,1,30), ones(1,30), linspace(1,-1,30)].*.5;
            [obj.XSet, obj.YSet] = meshgrid(obj.XSet, obj.YSet);
            obj.XSet = obj.XSet(:) + baseX;
            obj.YSet = obj.YSet(:) + baseY;
            obj.XSet = (obj.XSet - obj.oriXLim(1))./diff(obj.oriXLim).*diff(obj.XLim) + obj.XLim(1);
            obj.YSet = (obj.YSet - obj.oriYLim(1))./diff(obj.oriYLim).*diff(obj.YLim) + obj.YLim(1);
            obj.XTick = (obj.XTick - obj.oriXLim(1))./diff(obj.oriXLim).*diff(obj.XLim) + obj.XLim(1);
            obj.YTick = (obj.YTick - obj.oriYLim(1))./diff(obj.oriYLim).*diff(obj.YLim) + obj.YLim(1);
            % 坐标旋转 -----------------------------------------------------
            [XTick_B, YTick_B] = rotate(obj.XTick(2:end-1), obj.YTick(1) + obj.XTick(2:end-1).*0, obj.YLim, obj.TLim);
            [XTick_T, YTick_T] = rotate(obj.XTick(2:end-1), obj.YTick(end) + obj.XTick(2:end-1).*0, obj.YLim, obj.TLim);
            [XTick_L, YTick_L] = rotate(obj.XTick(1) + obj.YTick(2:end-1).*0, obj.YTick(2:end-1), obj.YLim, obj.TLim);
            [XTick_R, YTick_R] = rotate(obj.XTick(end) + obj.YTick(2:end-1).*0, obj.YTick(2:end-1), obj.YLim, obj.TLim);
            [obj.XSet, obj.YSet] = rotate(obj.XSet, obj.YSet, obj.YLim, obj.TLim);
            
            function [X2,Y2] = rotate(X1,Y1,YLim,TLim)
                if abs(TLim(1)-TLim(2)) < eps
                    rotateMat = [cos(TLim(1)), -sin(TLim(1));
                                 sin(TLim(1)),  cos(TLim(1))];
                    tXYSet = rotateMat*[X1(:).'; Y1(:).'];
                    X2 = reshape(tXYSet(1,:), size(X1,1), []);
                    Y2 = reshape(tXYSet(2,:), size(Y1,1), []);
                else
                    tTSet = (Y1 - YLim(1))./diff(YLim).*diff(TLim) + TLim(1);
                    tRSet = X1;
                    X2 = cos(tTSet).*tRSet;
                    Y2 = sin(tTSet).*tRSet;
                end
            end
            if obj.TLim(1) ~= 0 || obj.TLim(2) ~= 0
                obj.ax.DataAspectRatio = [1,1,1];
            end

            % 图形绘制 -----------------------------------------------------
            HH = obj.H(obj.RowOrder, obj.ColOrder);
            for i = 1:size(obj.XSet,1)
                obj.heatmapHdl{i} = fill(obj.ax, obj.XSet(i,:), obj.YSet(i,:), HH(i == obj.sInd),'EdgeColor','w','LineWidth',.5);
            end
            if abs(obj.TLim(1)-obj.TLim(2)) < eps
                tT = obj.TLim(1)/pi*180;
                for i = 1:length(XTick_B)
                    if mod(tT,360)>45 && mod(tT,360)<225
                        obj.bottomLabelHdl{i}=text(obj.ax, XTick_B(i), YTick_B(i), [obj.ColName{obj.ColOrder(i)}], 'FontSize', 12,...
                        'Rotation', tT+45+180, 'HorizontalAlignment', 'left', obj.BottomLabelFont{:});
                    else
                        obj.bottomLabelHdl{i}=text(obj.ax, XTick_B(i), YTick_B(i), [obj.ColName{obj.ColOrder(i)}], 'FontSize', 12,...
                        'Rotation', 45+tT, 'HorizontalAlignment', 'right', obj.BottomLabelFont{:});
                    end
                end
                for i = 1:length(XTick_T)
                    if mod(tT,360)>45 && mod(tT,360)<225
                        obj.topLabelHdl{i}=text(obj.ax, XTick_T(i), YTick_T(i), [obj.ColName{obj.ColOrder(i)}], 'FontSize', 12,...
                        'Rotation', tT+45+180, 'HorizontalAlignment', 'right', obj.TopLabelFont{:});
                    else
                        obj.topLabelHdl{i}=text(obj.ax, XTick_T(i), YTick_T(i), [obj.ColName{obj.ColOrder(i)}], 'FontSize', 12,...
                        'Rotation', 45+tT, 'HorizontalAlignment', 'left', obj.TopLabelFont{:});
                    end
                end
                for i = 1:length(XTick_L)
                    if mod(tT,360)>90 && mod(tT,360)<270
                        obj.leftLabelHdl{i}=text(obj.ax, XTick_L(i), YTick_L(i), [obj.RowName{obj.RowOrder(i)}], 'FontSize', 12,...
                        'Rotation', tT+180, 'HorizontalAlignment', 'left', obj.LeftLabelFont{:});
                    else
                        obj.leftLabelHdl{i}=text(obj.ax, XTick_L(i), YTick_L(i), [obj.RowName{obj.RowOrder(i)}], 'FontSize', 12,...
                        'Rotation', tT, 'HorizontalAlignment', 'right', obj.LeftLabelFont{:});
                    end
                end
                for i = 1:length(XTick_R)
                    if mod(tT,360)>90 && mod(tT,360)<270
                        obj.rightLabelHdl{i}=text(obj.ax, XTick_R(i), YTick_R(i), [obj.RowName{obj.RowOrder(i)}], 'FontSize', 12,...
                        'Rotation', tT+180, 'HorizontalAlignment', 'right', obj.RightLabelFont{:});
                    else
                        obj.rightLabelHdl{i}=text(obj.ax, XTick_R(i), YTick_R(i), [obj.RowName{obj.RowOrder(i)}], 'FontSize', 12,...
                        'Rotation', tT, 'HorizontalAlignment', 'left', obj.RightLabelFont{:});
                    end
                end
            else
                tT1 = obj.TLim(1)/pi*180;
                tT2 = obj.TLim(2)/pi*180;
                for i = 1:length(XTick_B)
                    if mod(tT1,360)>180
                        obj.bottomLabelHdl{i}=text(obj.ax, XTick_B(i), YTick_B(i), [' ',obj.ColName{obj.ColOrder(i)},' '], 'FontSize', 12,...
                        'Rotation', tT1+90, 'HorizontalAlignment', 'right', obj.BottomLabelFont{:});
                    else
                        obj.bottomLabelHdl{i}=text(obj.ax, XTick_B(i), YTick_B(i), [' ',obj.ColName{obj.ColOrder(i)},' '], 'FontSize', 12,...
                        'Rotation', tT1-90, 'HorizontalAlignment', 'left', obj.BottomLabelFont{:});
                    end
                end
                for i = 1:length(XTick_T)
                    if mod(tT2,360)>180
                        obj.topLabelHdl{i}=text(obj.ax, XTick_T(i), YTick_T(i), [' ',obj.ColName{obj.ColOrder(i)},' '], 'FontSize', 12,...
                        'Rotation', tT2+90, 'HorizontalAlignment', 'left', obj.TopLabelFont{:});
                    else
                        obj.topLabelHdl{i}=text(obj.ax, XTick_T(i), YTick_T(i), [' ',obj.ColName{obj.ColOrder(i)},' '], 'FontSize', 12,...
                        'Rotation', tT2-90, 'HorizontalAlignment', 'right', obj.TopLabelFont{:});
                    end
                end
                tT = (obj.YTick(2:end-1) - obj.YLim(1))./diff(obj.YLim).*diff(obj.TLim) + obj.TLim(1);
                tT = tT./pi.*180;
                RR = obj.XTick(end);
                RL = obj.XTick(1);
                for i = 1:length(tT)
                    if mod(tT(i),360)<90 || mod(tT(i),360)>270
                        obj.leftLabelHdl{i} = text(obj.ax, RL.*cos(tT(i)*pi/180), RL.*sin(tT(i)*pi/180), [obj.RowName{obj.RowOrder(i)}],...
                            'FontSize', 12, 'Rotation', tT(i), 'HorizontalAlignment', 'right', obj.LeftLabelFont{:});
                    else
                        obj.leftLabelHdl{i} = text(obj.ax, RL.*cos(tT(i)*pi/180), RL.*sin(tT(i)*pi/180), [obj.RowName{obj.RowOrder(i)}],...
                            'FontSize', 12, 'Rotation', tT(i)+180, obj.LeftLabelFont{:});
                    end
                end
                for i = 1:length(tT)
                    if mod(tT(i),360)<90 || mod(tT(i),360)>270
                        obj.rightLabelHdl{i} = text(obj.ax, RR.*cos(tT(i)*pi/180), RR.*sin(tT(i)*pi/180), [obj.RowName{obj.RowOrder(i)}],...
                            'FontSize', 12, 'Rotation', tT(i), obj.RightLabelFont{:});
                    else
                        obj.rightLabelHdl{i} = text(obj.ax, RR.*cos(tT(i)*pi/180), RR.*sin(tT(i)*pi/180), [obj.RowName{obj.RowOrder(i)}],...
                            'FontSize', 12, 'Rotation', tT(i)+180, 'HorizontalAlignment', 'right', obj.RightLabelFont{:});
                    end
                end
            end

            if strcmpi(obj.TopLabel,'off'),for i = 1:length(obj.topLabelHdl), set(obj.topLabelHdl{i}, 'Visible', 'off'); end, end
            if strcmpi(obj.BottomLabel,'off'),for i = 1:length(obj.bottomLabelHdl), set(obj.bottomLabelHdl{i}, 'Visible', 'off'); end, end
            if strcmpi(obj.LeftLabel,'off'),for i = 1:length(obj.leftLabelHdl), set(obj.leftLabelHdl{i}, 'Visible', 'off'); end, end
            if strcmpi(obj.RightLabel,'off'),for i = 1:length(obj.rightLabelHdl), set(obj.rightLabelHdl{i}, 'Visible', 'off'); end, end
        end
    end
% Copyright (c) 2024, Zhaoxu Liu / slandarer
% =========================================================================
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer
% -------------------------------------------------------------------------
% Zhaoxu Liu / slandarer (2024). STree dendrogram 
% (https://www.mathworks.com/matlabcentral/fileexchange/160048-stree-dendrogram), 
% MATLAB Central File Exchange.
end