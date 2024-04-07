classdef STree < handle
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
        ax, Z, T, cutoff, CData, Parent, class, lineClass, hClass, H
        MaxClust    = 3; 
        Layout      = 'rectangular'; % 'rectangular'(default) / 'rounded' / 'slanted'
                                     % 'ellipse' / 'bezier' 
        Orientation = 'top';         % 'top'    -- Top to bottom
                                     % 'bottom'	-- Bottom to top
                                     % 'left'	-- Left to right
                                     % 'right'	-- Right to left
        oriXLim, oriYLim
        XLim, YLim, TLim = [0,0];
        ClustGap        = 'off';
        BranchColor     = 'off';
        BranchHighlight = 'off';
        Label           = 'on' ;
        LabelColor      = 'off'; % uncompleted
        ClassHighlight  = 'off';
        ClassLabel      = 'off';

        branchHdl   , sampleLabelHdl, classLabelHdl
        branchHLTHdl, sampleHLTHdl  , classHLTHdl
        SampleName  , ClassName     , WTick
        % 样本文本 类弧形内侧 类弧形外侧 类文本
        RTick = [1+1/40, 1.22, 1.27, 1.35];
        SampleFont = {'FontSize', 10, 'FontName', 'Times New Roman'};
        ClassFont = {'FontSize', 14, 'FontName', 'Times New Roman', 'FontWeight', 'bold'};

        lineSet, order, oriXSet, oriYSet, oriWSet, oriHSet, newXSet, newYSet, newWSet, newHSet
        branchHLTXSet, sampleHLTXSet, classHLTXSet
        branchHLTYSet, sampleHLTYSet, classHLTYSet
        branchHLTWSet, sampleHLTWSet, classHLTWSet
        branchHLTHSet, sampleHLTHSet, classHLTHSet
        arginList  = {'Parent', 'Layout', 'CData', 'XLim', 'YLim', 'TLim',...
            'SampleName', 'ClassName', 'Orientation', 'MaxClust', 'RTick',...
            'SampleFont', 'ClassFont', 'ClustGap', 'BranchColor', 'BranchHighlight',...
            'Label', 'LabelColor', 'ClassHighlight', 'ClassLabel'};
    end
% 构造函数 =================================================================
    methods
        function obj = STree(varargin)
            % 获取基本数据 -------------------------------------------------
            if isa(varargin{1}, 'matlab.graphics.axis.Axes')
                obj.ax = varargin{1}; varargin(1) = [];
            else  
            end
            obj.Z = varargin{1}; varargin(1) = [];
            % 获取其他信息 -------------------------------------------------
            for i = 1:2:(length(varargin)-1)
                tid = ismember(obj.arginList, varargin{i});
                if any(tid)
                obj.(obj.arginList{tid}) = varargin{i+1};
                end
            end
            if isempty(obj.ax) && (~isempty(obj.Parent)), obj.ax=obj.Parent; end
            if isempty(obj.ax), obj.ax=gca; end
            % 基础配色 -----------------------------------------------------
            if isempty(obj.CData)
                colorList = [204    61    36
                             243   197    88
                             109   174   144
                              48   180   204
                               0    79   122]./255;
                N = size(colorList, 1);
                colorList = colorList(mod((1:obj.MaxClust)-1, N)+1,:);
                colorList = colorList.*(.9.^(floor(((1:obj.MaxClust)-1)./N).'));
                obj.CData = colorList;
            end
            % 基础命名 -----------------------------------------------------
            if isempty(obj.SampleName)
                obj.SampleName = compose('slan%d', 1:(size(obj.Z,1)+10));
                obj.ClassName = compose('Class-%c', 64 + (1:obj.MaxClust));
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
        function draw(obj)
            obj.ax.NextPlot = 'add';
            % 各类数据准备 =================================================
            % 数据处理、绘制树状图、提取图形、关闭图窗 ------------------------
            tempFigure = figure();
            N = obj.MaxClust;
            obj.T = cluster(obj.Z, 'maxclust', N);
            obj.cutoff = median([obj.Z(end-(N-1),3), obj.Z(end-(N-2),3)]);
            
            [obj.lineSet, ~, obj.order] = dendrogram(obj.Z, 0, 'Orientation', obj.Orientation);
            obj.oriXSet = reshape([obj.lineSet(:).XData], 4, []).';
            obj.oriYSet = reshape([obj.lineSet(:).YData], 4, []).';
            if strcmpi(obj.Orientation, 'top') || strcmpi(obj.Orientation, 'bottom') 
                obj.oriWSet = obj.oriXSet; obj.oriHSet = obj.oriYSet;
            else
                obj.oriWSet = obj.oriYSet; obj.oriHSet = obj.oriXSet;
            end
            obj.class = obj.T(obj.order);
            close(tempFigure)
            % 计算高亮高度 -------------------------------------------------
            WSet = [obj.oriWSet(:,1:2); obj.oriWSet(:,3:4)];
            HSet = [obj.oriHSet(:,1:2); obj.oriHSet(:,3:4)];
            BSet = (HSet(:,1)-obj.cutoff).*(HSet(:,2)-obj.cutoff)<0;
            obj.H = (HSet(BSet,1)+HSet(BSet,2))./2;
            obj.hClass = obj.class(round(WSet(BSet,1)));
            
            % 预生成树枝配色 -----------------------------------------------
            obj.lineClass = all(obj.oriHSet < obj.cutoff,2).*obj.class(round((obj.oriWSet(:,2)+obj.oriWSet(:,3))./2));
            % 生成间隙 -----------------------------------------------------
            gap = find(diff(obj.class)~=0)+.5;
            obj.WTick = 1:length(obj.class);
            if strcmpi(obj.ClustGap, 'on')
                for i = length(gap):-1:1
                    obj.oriWSet(obj.oriWSet>gap(i)) = obj.oriWSet(obj.oriWSet>gap(i))+1;
                    obj.WTick(obj.WTick>gap(i)) = obj.WTick(obj.WTick>gap(i))+1;
                end
            end

            obj.newWSet = [];
            obj.newHSet = [];
            % 修改树枝形状 =================================================
            switch obj.Layout
                case 'rectangular'
                    for i = 1:size(obj.oriWSet,1)
                        obj.newWSet(i,:) = [linspace(obj.oriWSet(i,1), obj.oriWSet(i,2), 30),...
                                            linspace(obj.oriWSet(i,2), obj.oriWSet(i,3), 30),...
                                            linspace(obj.oriWSet(i,3), obj.oriWSet(i,4), 30)];
                        obj.newHSet(i,:) = [linspace(obj.oriHSet(i,1), obj.oriHSet(i,2), 30),...
                                            linspace(obj.oriHSet(i,2), obj.oriHSet(i,3), 30),...
                                            linspace(obj.oriHSet(i,3), obj.oriHSet(i,4), 30)];
                    end
                case 'rounded'  
                    tX = [-1.*ones(1,15),...
                          cos(linspace(pi,pi/2,20)).*.3-.7,...
                          linspace(-.7,.7,15),...
                          cos(linspace(pi/2,0,20)).*.3+.7,...
                          1.*ones(1,15)];
                    tY = [linspace(0,.7,15),...
                          sin(linspace(pi,pi/2,20)).*.3+.7,...
                          1.*ones(1,15),...
                          sin(linspace(pi/2,0,20)).*.3+.7,...
                          linspace(.7,0,15)];
                    obj.newWSet = [obj.oriWSet(:,1),...
                        tX.*(obj.oriWSet(:,4)-obj.oriWSet(:,1))./2 + (obj.oriWSet(:,4)+obj.oriWSet(:,1))./2,...
                        obj.oriWSet(:,4)];
                    obj.newHSet = [obj.oriHSet(:,1),...
                        tY.*(obj.oriHSet(:,2)-max(obj.oriHSet(:,[1,4]), [], 2)) + max(obj.oriHSet(:,[1,4]), [], 2),...
                        obj.oriHSet(:,4)];
                case 'slanted'
                    for i = 1:size(obj.oriWSet,1)
                        tWId = obj.Z(:,1:2) == (i+length(obj.class)); tW1 = [];
                        if all(tWId(:,1) == 0) && all(tWId(:,2) == 0)
                            tW = mean(obj.oriWSet(i,2:3));
                        elseif all(tWId(:,1) == 0)
                            tW1 = obj.oriWSet(tWId(:,2),1);
                            tW2 = obj.oriWSet(tWId(:,2),4);
                        elseif all(tWId(:,2) == 0)
                            tW1 = obj.oriWSet(tWId(:,1),1);
                            tW2 = obj.oriWSet(tWId(:,1),4);
                        end
                        if ~isempty(tW1)
                        if abs(tW1 - mean(obj.oriWSet(i,2:3))) > abs(tW2 - mean(obj.oriWSet(i,2:3)))
                            tW = tW2;
                        else
                            tW = tW1;
                        end
                        end
                        obj.newWSet(i,:) = [linspace(obj.oriWSet(i,1), tW, 30),...
                                            linspace(tW, obj.oriWSet(i,4), 30)];
                        obj.newHSet(i,:) = [linspace(obj.oriHSet(i,1), mean(obj.oriHSet(i,2:3)), 30),...
                                            linspace(mean(obj.oriHSet(i,2:3)), obj.oriHSet(i,4), 30)];
                    end
                case 'ellipse'
                    tT = linspace(pi,0,30);
                    t01 = linspace(0,1,25);
                    obj.newWSet = [obj.oriWSet(:,1).*ones(1,25),...
                        cos(tT).*(obj.oriWSet(:,4)-obj.oriWSet(:,1))./2 + (obj.oriWSet(:,4)+obj.oriWSet(:,1))./2,...
                        obj.oriWSet(:,4).*ones(1,25)];
                    obj.newHSet = [obj.oriHSet(:,1) + t01.*(max(obj.oriHSet(:,[1,4]), [], 2) - obj.oriHSet(:,1)),...
                        sin(tT).*(obj.oriHSet(:,2)-max(obj.oriHSet(:,[1,4]), [], 2)) + max(obj.oriHSet(:,[1,4]), [], 2),...
                        max(obj.oriHSet(:,[1,4]), [], 2) + t01.*(obj.oriHSet(:,4) - max(obj.oriHSet(:,[1,4]), [], 2))];
                case 'bezier'
                    obj.newWSet = zeros(size(obj.oriWSet,1), 60);
                    obj.newHSet = zeros(size(obj.oriHSet,1), 60);
                    for i = 1:size(obj.oriHSet,1)
                        pntsL = [obj.oriWSet(i,[1,2]),...
                                 mean(obj.oriWSet(i,[2,3]));
                                 obj.oriHSet(i,[1,2]),...
                                 obj.oriHSet(i,2)].';
                        pntsR = [mean(obj.oriWSet(i,[2,3])),...
                                 obj.oriWSet(i,[3,4]); 
                                 obj.oriHSet(i,[3,3]),...
                                 obj.oriHSet(i,4)].';
                        pntsL = bezierCurve(pntsL, 30);
                        pntsR = bezierCurve(pntsR, 30);
                        obj.newWSet(i,:) = [pntsL(:,1).', pntsR(:,1).'];
                        obj.newHSet(i,:) = [pntsL(:,2).', pntsR(:,2).'];
                    end
            end
            % 高亮区域计算 -------------------------------------------------
            classNum = unique(obj.class, 'stable');
            for i = 1:obj.MaxClust
                tX = [obj.WTick(find(obj.class == classNum(i), 1, 'first')) - .5,...
                      obj.WTick(find(obj.class == classNum(i), 1, 'last')) + .5];
                obj.branchHLTWSet(i,:) = [linspace(tX(1), tX(2), 50), tX(2).*ones(1,50),...
                                          linspace(tX(2), tX(1), 50), tX(1).*ones(1,50)];
                obj.branchHLTHSet(i,:) = [obj.H(classNum(i) == obj.hClass).*ones(1,50),...
                                          linspace(obj.H(classNum(i) == obj.hClass), 0, 50),...
                                          zeros(1,50),...
                                          linspace(0, obj.H(classNum(i) == obj.hClass), 50)];
                obj.classHLTWSet(i,:) = [linspace(tX(1), tX(2), 50), tX(2).*ones(1,50),...
                                         linspace(tX(2), tX(1), 50), tX(1).*ones(1,50)];
                maxH = max(max(obj.oriHSet));
                minH = min(min(obj.oriHSet));
                diffH = maxH - minH;
                obj.classHLTHSet(i,:) = [-diffH.*(obj.RTick(2)-1).*ones(1,50),...
                                          linspace(-diffH.*(obj.RTick(2)-1), -diffH.*(obj.RTick(3)-1), 50),...
                                         -diffH.*(obj.RTick(3)-1).*ones(1,50),...
                                          linspace(-diffH.*(obj.RTick(3)-1), -diffH.*(obj.RTick(2)-1), 50)];
            end


            % 数据转换 =====================================================
            if  strcmpi(obj.Orientation, 'left') 
                maxH = max(max(obj.newHSet));
                obj.newHSet = maxH - obj.newHSet;
                obj.branchHLTHSet = maxH - obj.branchHLTHSet;
                obj.classHLTHSet = maxH - obj.classHLTHSet;
            elseif strcmpi(obj.Orientation, 'bottom')
                obj.newHSet =  - obj.newHSet;
                obj.branchHLTHSet =  - obj.branchHLTHSet;
                obj.classHLTHSet =  - obj.classHLTHSet;
            end
            if strcmpi(obj.Orientation, 'top') || strcmpi(obj.Orientation, 'bottom') 
                obj.newXSet = obj.newWSet; obj.newYSet = obj.newHSet;
                obj.branchHLTXSet = obj.branchHLTWSet; obj.branchHLTYSet = obj.branchHLTHSet;
                obj.classHLTXSet = obj.classHLTWSet; obj.classHLTYSet = obj.classHLTHSet;
            else
                obj.newXSet = obj.newHSet; obj.newYSet = obj.newWSet;
                obj.branchHLTXSet = obj.branchHLTHSet; obj.branchHLTYSet = obj.branchHLTWSet;
                obj.classHLTXSet = obj.classHLTHSet; obj.classHLTYSet = obj.classHLTWSet;
            end
            % 原始X,Y范围获取 ----------------------------------------------
            if strcmp(obj.ClustGap,'on')
                gap = 1;
            else
                gap = .5;
            end
            if strcmpi(obj.Orientation, 'top') || strcmpi(obj.Orientation, 'bottom') 
                obj.oriXLim = [min(min(obj.newXSet)) - gap, max(max(obj.newXSet)) + gap];
                obj.oriYLim = [min(min(obj.newYSet)), max(max(obj.newYSet))];
            else
                obj.oriXLim = [min(min(obj.newXSet)), max(max(obj.newXSet))];
                obj.oriYLim = [min(min(obj.newYSet)) - gap, max(max(obj.newYSet)) + gap];
            end
            % X,Y范围调整 --------------------------------------------------
            if ~isempty(obj.XLim)
                obj.newXSet = (obj.newXSet - obj.oriXLim(1))./diff(obj.oriXLim).*diff(obj.XLim) + obj.XLim(1);
                obj.branchHLTXSet = (obj.branchHLTXSet - obj.oriXLim(1))./diff(obj.oriXLim).*diff(obj.XLim) + obj.XLim(1);
                obj.classHLTXSet = (obj.classHLTXSet - obj.oriXLim(1))./diff(obj.oriXLim).*diff(obj.XLim) + obj.XLim(1);
            else
                obj.XLim = obj.oriXLim;
            end
            if ~isempty(obj.YLim)
                obj.newYSet = (obj.newYSet - obj.oriYLim(1))./diff(obj.oriYLim).*diff(obj.YLim) + obj.YLim(1);
                obj.branchHLTYSet = (obj.branchHLTYSet - obj.oriYLim(1))./diff(obj.oriYLim).*diff(obj.YLim) + obj.YLim(1);
                obj.classHLTYSet = (obj.classHLTYSet - obj.oriYLim(1))./diff(obj.oriYLim).*diff(obj.YLim) + obj.YLim(1);
            else
                obj.YLim = obj.oriYLim;
            end
            % 旋转 --------------------------------------------------------
            if abs(obj.TLim(1)-obj.TLim(2)) < eps
                rotateMat = [cos(obj.TLim(1)), -sin(obj.TLim(1));
                             sin(obj.TLim(1)),  cos(obj.TLim(1))];
                % 旋转树枝
                tNewXYSet = rotateMat*[obj.newXSet(:).'; obj.newYSet(:).'];
                obj.newXSet = reshape(tNewXYSet(1,:), size(obj.newXSet,1), []);
                obj.newYSet = reshape(tNewXYSet(2,:), size(obj.newYSet,1), []);
                % 旋转树枝高亮
                tBranchHLTXYSet = rotateMat*[obj.branchHLTXSet(:).'; obj.branchHLTYSet(:).'];
                obj.branchHLTXSet = reshape(tBranchHLTXYSet(1,:), size(obj.branchHLTXSet,1), []);
                obj.branchHLTYSet = reshape(tBranchHLTXYSet(2,:), size(obj.branchHLTYSet,1), []);
                % 旋转类高亮
                tClassHLTXYSet = rotateMat*[obj.classHLTXSet(:).'; obj.classHLTYSet(:).'];
                obj.classHLTXSet = reshape(tClassHLTXYSet(1,:), size(obj.classHLTXSet,1), []);
                obj.classHLTYSet = reshape(tClassHLTXYSet(2,:), size(obj.classHLTYSet,1), []);
            else
                % 旋转树枝
                tNewTSet = (obj.newYSet - obj.YLim(1))./diff(obj.YLim).*diff(obj.TLim) + obj.TLim(1);
                tNewRSet = obj.newXSet;
                obj.newXSet = cos(tNewTSet).*tNewRSet;
                obj.newYSet = sin(tNewTSet).*tNewRSet;
                % 旋转树枝高亮
                tBranchHLTTSet = (obj.branchHLTYSet - obj.YLim(1))./diff(obj.YLim).*diff(obj.TLim) + obj.TLim(1);
                tBranchHLTRSet = obj.branchHLTXSet;
                obj.branchHLTXSet = cos(tBranchHLTTSet).*tBranchHLTRSet;
                obj.branchHLTYSet = sin(tBranchHLTTSet).*tBranchHLTRSet;
                % 旋转类高亮
                tClassHLTTSet = (obj.classHLTYSet - obj.YLim(1))./diff(obj.YLim).*diff(obj.TLim) + obj.TLim(1);
                tClassHLTRSet = obj.classHLTXSet;
                obj.classHLTXSet = cos(tClassHLTTSet).*tClassHLTRSet;
                obj.classHLTYSet = sin(tClassHLTTSet).*tClassHLTRSet;
            end
            if obj.TLim(1) ~= 0 || obj.TLim(2) ~= 0
                obj.ax.DataAspectRatio = [1,1,1];
            end


            % 图形重绘 =====================================================
            % 绘制树枝 -----------------------------------------------------
            colorList = [obj.CData];
            if strcmpi(obj.BranchColor, 'off')
                colorList = colorList.*0;
            end
            for i = 1:obj.MaxClust
                obj.branchHdl{i} = plot(obj.ax, obj.newXSet(classNum(i) == obj.lineClass,:).',...
                    obj.newYSet(classNum(i) == obj.lineClass,:).', 'Color', colorList(i,:), 'LineWidth', .8);
            end
            obj.branchHdl{obj.MaxClust+1} = plot(obj.ax, obj.newXSet(0 == obj.lineClass,:).',...
                obj.newYSet(0 == obj.lineClass,:).', 'Color', [0,0,0], 'LineWidth', .7);
            % 绘制树枝高亮 -------------------------------------------------
            for i = 1:obj.MaxClust
                obj.branchHLTHdl{i}=fill(obj.ax, obj.branchHLTXSet(i,:), obj.branchHLTYSet(i,:), obj.CData(i,:), 'EdgeColor', 'none', 'FaceAlpha', .25);
            end
            if strcmpi(obj.BranchHighlight,'off')
                for i = 1:obj.MaxClust
                    set(obj.branchHLTHdl{i},'Visible','off');
                end
            end
            % 绘制类高亮 ---------------------------------------------------
            for i = 1:obj.MaxClust
                obj.classHLTHdl{i}=fill(obj.ax, obj.classHLTXSet(i,:), obj.classHLTYSet(i,:), obj.CData(i,:), 'EdgeColor', 'none', 'FaceAlpha', .9);
            end
            if strcmpi(obj.ClassHighlight,'off')
                for i = 1:obj.MaxClust
                    set(obj.classHLTHdl{i},'Visible','off');
                end
            end
            % 绘制样本标签 -------------------------------------------------
            if abs(obj.TLim(1)-obj.TLim(2)) < eps
                rotateMat = [cos(obj.TLim(1)), -sin(obj.TLim(1));
                             sin(obj.TLim(1)),  cos(obj.TLim(1))];
                switch obj.Orientation
                    case 'left'
                        tY = (obj.WTick - obj.oriYLim(1))./diff(obj.oriYLim).*diff(obj.YLim) + obj.YLim(1);
                        tX = ones(size(tY)).*abs(diff(obj.XLim)).*(obj.RTick(1)-1) + obj.XLim(2);
                        tXY = rotateMat*[tX;tY];
                        tT = obj.TLim(1)/pi*180;
                        if mod(tT,360)>90 && mod(tT,360)<270
                            for i = 1:length(tX)
                                obj.sampleLabelHdl{i} = text(obj.ax, tXY(1,i), tXY(2,i), obj.SampleName{obj.order(i)},...
                                    'FontSize', 12, 'Rotation', tT-180, 'HorizontalAlignment', 'right', obj.SampleFont{:});
                            end
                        else
                            for i = 1:length(tX)
                                obj.sampleLabelHdl{i} = text(obj.ax, tXY(1,i), tXY(2,i), obj.SampleName{obj.order(i)},...
                                    'FontSize', 12, 'Rotation', tT, obj.SampleFont{:});
                            end
                        end
                        for i = 1:obj.MaxClust
                            tY = (mean(obj.WTick(obj.class == classNum(i))) - obj.oriYLim(1))./diff(obj.oriYLim).*diff(obj.YLim) + obj.YLim(1);
                            tX = abs(diff(obj.XLim)).*(obj.RTick(4)-1) + obj.XLim(2);
                            tXY = rotateMat*[tX;tY];
                            if mod(tT,360)>180 && mod(tT,360)<360
                                obj.classLabelHdl{i} = text(obj.ax, tXY(1), tXY(2), obj.ClassName{i},...
                                    'FontSize', 12, 'Rotation', tT+180-90, 'Color', colorList(i,:), 'HorizontalAlignment', 'center', obj.ClassFont{:});
                            else
                                obj.classLabelHdl{i} = text(obj.ax, tXY(1), tXY(2), obj.ClassName{i},...
                                    'FontSize', 12, 'Rotation', tT-90, 'Color', colorList(i,:), 'HorizontalAlignment', 'center', obj.ClassFont{:});
                            end
                        end

                    % -----------------------------------------------------    
                    case 'right'
                        tY = (obj.WTick - obj.oriYLim(1))./diff(obj.oriYLim).*diff(obj.YLim) + obj.YLim(1);
                        tX = - ones(size(tY)).*abs(diff(obj.XLim)).*(obj.RTick(1)-1) + obj.XLim(1);
                        tXY = rotateMat*[tX;tY];
                        tT = obj.TLim(1)/pi*180;
                        if mod(tT,360)>90 && mod(tT,360)<270
                            for i = 1:length(tX)
                                obj.sampleLabelHdl{i} = text(obj.ax, tXY(1,i), tXY(2,i), obj.SampleName{obj.order(i)},...
                                    'FontSize', 12, 'Rotation', tT-180, obj.SampleFont{:});
                            end
                        else
                            for i = 1:length(tX)
                                obj.sampleLabelHdl{i} = text(obj.ax, tXY(1,i), tXY(2,i), obj.SampleName{obj.order(i)},...
                                    'FontSize', 12, 'Rotation', tT, 'HorizontalAlignment', 'right', obj.SampleFont{:});
                            end
                        end
                        for i = 1:obj.MaxClust
                            tY = (mean(obj.WTick(obj.class == classNum(i))) - obj.oriYLim(1))./diff(obj.oriYLim).*diff(obj.YLim) + obj.YLim(1);
                            tX = - abs(diff(obj.XLim)).*(obj.RTick(4)-1) + obj.XLim(1);
                            tXY = rotateMat*[tX;tY];
                            if mod(tT,360)>180 && mod(tT,360)<360
                                obj.classLabelHdl{i} = text(obj.ax, tXY(1), tXY(2), obj.ClassName{i},...
                                    'FontSize', 12, 'Rotation', tT+180-90, 'Color', colorList(i,:), 'HorizontalAlignment', 'center', obj.ClassFont{:});
                            else
                                obj.classLabelHdl{i} = text(obj.ax, tXY(1), tXY(2), obj.ClassName{i},...
                                    'FontSize', 12, 'Rotation', tT-90, 'Color', colorList(i,:), 'HorizontalAlignment', 'center', obj.ClassFont{:});
                            end
                        end

                    % -----------------------------------------------------
                    case 'top'
                        tX = (obj.WTick - obj.oriXLim(1))./diff(obj.oriXLim).*diff(obj.XLim) + obj.XLim(1);
                        tY = - ones(size(tX)).*abs(diff(obj.YLim)).*(obj.RTick(1)-1) + obj.YLim(1);
                        tXY = rotateMat*[tX;tY];
                        tT = obj.TLim(1)/pi*180;
                        if mod(tT,360)>180 && mod(tT,360)<360
                            for i = 1:length(tX)
                                obj.sampleLabelHdl{i} = text(obj.ax, tXY(1,i), tXY(2,i), obj.SampleName{obj.order(i)},...
                                    'FontSize', 12, 'Rotation', tT-90-180, 'HorizontalAlignment', 'right',obj.SampleFont{:});
                            end
                        else
                            for i = 1:length(tX)
                                obj.sampleLabelHdl{i} = text(obj.ax, tXY(1,i), tXY(2,i), obj.SampleName{obj.order(i)},...
                                    'FontSize', 12, 'Rotation', tT-90, obj.SampleFont{:});
                            end
                        end
                        for i = 1:obj.MaxClust
                            tX = (mean(obj.WTick(obj.class == classNum(i))) - obj.oriXLim(1))./diff(obj.oriXLim).*diff(obj.XLim) + obj.XLim(1);
                            tY = - abs(diff(obj.YLim)).*(obj.RTick(4)-1) + obj.YLim(1);
                            tXY = rotateMat*[tX;tY];
                            if mod(tT,360)>90 && mod(tT,360)<270
                                obj.classLabelHdl{i} = text(obj.ax, tXY(1), tXY(2), obj.ClassName{i},...
                                    'FontSize', 12, 'Rotation', tT+180, 'Color', colorList(i,:), 'HorizontalAlignment', 'center', obj.ClassFont{:});
                            else
                                obj.classLabelHdl{i} = text(obj.ax, tXY(1), tXY(2), obj.ClassName{i},...
                                    'FontSize', 12, 'Rotation', tT, 'Color', colorList(i,:), 'HorizontalAlignment', 'center', obj.ClassFont{:});
                            end
                        end

                    % -----------------------------------------------------
                    case 'bottom'
                        tX = (obj.WTick - obj.oriXLim(1))./diff(obj.oriXLim).*diff(obj.XLim) + obj.XLim(1);
                        tY = ones(size(tX)).*abs(diff(obj.YLim)).*(obj.RTick(1)-1) + obj.YLim(2);
                        tXY = rotateMat*[tX;tY];
                        tT = obj.TLim(2)/pi*180;
                        if mod(tT,360)>180 && mod(tT,360)<360
                            for i = 1:length(tX)
                                obj.sampleLabelHdl{i} = text(obj.ax, tXY(1,i), tXY(2,i), obj.SampleName{obj.order(i)},...
                                    'FontSize', 12, 'Rotation', tT-90-180, obj.SampleFont{:});
                            end
                        else
                            for i = 1:length(tX)
                                obj.sampleLabelHdl{i} = text(obj.ax, tXY(1,i), tXY(2,i), obj.SampleName{obj.order(i)},...
                                    'FontSize', 12, 'Rotation', tT-90, 'HorizontalAlignment', 'right', obj.SampleFont{:});
                            end
                        end
                        for i = 1:obj.MaxClust
                            tX = (mean(obj.WTick(obj.class == classNum(i))) - obj.oriXLim(1))./diff(obj.oriXLim).*diff(obj.XLim) + obj.XLim(1);
                            tY = abs(diff(obj.YLim)).*(obj.RTick(4)-1) + obj.YLim(2);
                            tXY = rotateMat*[tX;tY];
                            if mod(tT,360)>90 && mod(tT,360)<270
                                obj.classLabelHdl{i} = text(obj.ax, tXY(1), tXY(2), obj.ClassName{i},...
                                    'FontSize', 12, 'Rotation', tT+180, 'Color', colorList(i,:), 'HorizontalAlignment', 'center', obj.ClassFont{:});
                            else
                                obj.classLabelHdl{i} = text(obj.ax, tXY(1), tXY(2), obj.ClassName{i},...
                                    'FontSize', 12, 'Rotation', tT, 'Color', colorList(i,:), 'HorizontalAlignment', 'center', obj.ClassFont{:});
                            end
                        end
                end



            % =============================================================
            else
                rotateMat1 = [cos(obj.TLim(1)), -sin(obj.TLim(1));
                              sin(obj.TLim(1)),  cos(obj.TLim(1))];
                rotateMat2 = [cos(obj.TLim(2)), -sin(obj.TLim(2));
                              sin(obj.TLim(2)),  cos(obj.TLim(2))];
                tT3 = obj.TLim(1) - diff(obj.TLim).*(obj.RTick(4)-1);
                tT4 = obj.TLim(2) + diff(obj.TLim).*(obj.RTick(4)-1);
                rotateMat3 = [cos(tT3), -sin(tT3);
                              sin(tT3),  cos(tT3)];
                rotateMat4 = [cos(tT4), -sin(tT4);
                              sin(tT4),  cos(tT4)];
                tT3 = tT3/pi*180;
                tT4 = tT4/pi*180;
                switch obj.Orientation
                    case 'left'
                        tT = (obj.WTick - obj.oriYLim(1))./diff(obj.oriYLim).*diff(obj.TLim) + obj.TLim(1);
                        tT = tT./pi.*180;
                        tR = ones(size(tT)).*abs(diff(obj.XLim)).*(obj.RTick(1)-1) + obj.XLim(2);
                        for i = 1:length(tT)
                            if mod(tT(i),360)<90 || mod(tT(i),360)>270
                                obj.sampleLabelHdl{i} = text(obj.ax, tR(i).*cos(tT(i)*pi/180), tR(i).*sin(tT(i)*pi/180), obj.SampleName{obj.order(i)},...
                                    'FontSize', 12, 'Rotation', tT(i), obj.SampleFont{:});
                            else
                                obj.sampleLabelHdl{i} = text(obj.ax, tR(i).*cos(tT(i)*pi/180), tR(i).*sin(tT(i)*pi/180), obj.SampleName{obj.order(i)},...
                                    'FontSize', 12, 'Rotation', tT(i)+180, 'HorizontalAlignment', 'right', obj.SampleFont{:});
                            end
                        end
                        for i = 1:obj.MaxClust
                            tT = (mean(obj.WTick(obj.class == classNum(i))) - obj.oriYLim(1))./diff(obj.oriYLim).*diff(obj.TLim) + obj.TLim(1);
                            tT = tT./pi.*180;
                            tR = abs(diff(obj.XLim)).*(obj.RTick(4)-1) + obj.XLim(2);
                            if mod(tT,360)<180
                                obj.classLabelHdl{i} = text(obj.ax, tR.*cos(tT*pi/180), tR.*sin(tT*pi/180), obj.ClassName{i},...
                                    'FontSize', 12, 'Rotation', tT-90, 'Color', colorList(i,:), 'HorizontalAlignment', 'center', obj.ClassFont{:});
                            else
                                obj.classLabelHdl{i} = text(obj.ax, tR.*cos(tT*pi/180), tR.*sin(tT*pi/180), obj.ClassName{i},...
                                    'FontSize', 12, 'Rotation', tT+90, 'Color', colorList(i,:), 'HorizontalAlignment', 'center', obj.ClassFont{:});
                            end
                        end

                    % -----------------------------------------------------
                    case 'right'
                        tT = (obj.WTick - obj.oriYLim(1))./diff(obj.oriYLim).*diff(obj.TLim) + obj.TLim(1);
                        tT = tT./pi.*180;
                        tR = - ones(size(tT)).*abs(diff(obj.XLim)).*(obj.RTick(1)-1) + obj.XLim(1);
                        for i = 1:length(tT)
                            if mod(tT(i),360)<90 || mod(tT(i),360)>270
                                obj.sampleLabelHdl{i} = text(obj.ax, tR(i).*cos(tT(i)*pi/180), tR(i).*sin(tT(i)*pi/180), obj.SampleName{obj.order(i)},...
                                    'FontSize', 12, 'Rotation', tT(i), 'HorizontalAlignment', 'right', obj.SampleFont{:});
                            else
                                obj.sampleLabelHdl{i} = text(obj.ax, tR(i).*cos(tT(i)*pi/180), tR(i).*sin(tT(i)*pi/180), obj.SampleName{obj.order(i)},...
                                    'FontSize', 12, 'Rotation', tT(i)+180, obj.SampleFont{:});
                            end
                        end
                        for i = 1:obj.MaxClust
                            tT = (mean(obj.WTick(obj.class == classNum(i))) - obj.oriYLim(1))./diff(obj.oriYLim).*diff(obj.TLim) + obj.TLim(1);
                            tT = tT./pi.*180;
                            tR = - abs(diff(obj.XLim)).*(obj.RTick(4)-1) + obj.XLim(1);
                            if mod(tT,360)<180
                                obj.classLabelHdl{i} = text(obj.ax, tR.*cos(tT*pi/180), tR.*sin(tT*pi/180), obj.ClassName{i},...
                                    'FontSize', 12, 'Rotation', tT-90, 'Color', colorList(i,:), 'HorizontalAlignment', 'center', obj.ClassFont{:});
                            else
                                obj.classLabelHdl{i} = text(obj.ax, tR.*cos(tT*pi/180), tR.*sin(tT*pi/180), obj.ClassName{i},...
                                    'FontSize', 12, 'Rotation', tT+90, 'Color', colorList(i,:), 'HorizontalAlignment', 'center', obj.ClassFont{:});
                            end
                        end

                    % -----------------------------------------------------
                    case 'top'
                        tX = (obj.WTick - obj.oriXLim(1))./diff(obj.oriXLim).*diff(obj.XLim) + obj.XLim(1);
                        tY = - ones(size(tX)).*abs(diff(obj.YLim)).*(obj.RTick(1)-1);
                        tXY = rotateMat1*[tX;tY];
                        tT = obj.TLim(1)/pi*180;
                        if mod(tT,360)>180 && mod(tT,360)<360
                            for i = 1:length(tX)
                                obj.sampleLabelHdl{i} = text(obj.ax, tXY(1,i), tXY(2,i), obj.SampleName{obj.order(i)},...
                                    'FontSize', 12, 'Rotation', tT-90-180, 'HorizontalAlignment', 'right',obj.SampleFont{:});
                            end
                        else
                            for i = 1:length(tX)
                                obj.sampleLabelHdl{i} = text(obj.ax, tXY(1,i), tXY(2,i), obj.SampleName{obj.order(i)},...
                                    'FontSize', 12, 'Rotation', tT-90, obj.SampleFont{:});
                            end
                        end
                        for i = 1:obj.MaxClust
                            tX = (mean(obj.WTick(obj.class == classNum(i))) - obj.oriXLim(1))./diff(obj.oriXLim).*diff(obj.XLim) + obj.XLim(1);
                            tY = 0;
                            tXY = rotateMat3*[tX;tY];
                            if mod(tT3,360)>90 && mod(tT3,360)<270
                                obj.classLabelHdl{i} = text(obj.ax, tXY(1), tXY(2), obj.ClassName{i},...
                                    'FontSize', 12, 'Rotation', tT3+180, 'Color', colorList(i,:), 'HorizontalAlignment', 'center', obj.ClassFont{:});
                            else
                                obj.classLabelHdl{i} = text(obj.ax, tXY(1), tXY(2), obj.ClassName{i},...
                                    'FontSize', 12, 'Rotation', tT3, 'Color', colorList(i,:), 'HorizontalAlignment', 'center', obj.ClassFont{:});
                            end
                        end

                    % -----------------------------------------------------
                    case 'bottom'
                        abs(diff(obj.YLim))
                        tX = (obj.WTick - obj.oriXLim(1))./diff(obj.oriXLim).*diff(obj.XLim) + obj.XLim(1);
                        tY = ones(size(tX)).*abs(diff(obj.YLim)).*(obj.RTick(1)-1);
                        tXY = rotateMat2*[tX;tY];
                        tT = obj.TLim(2)/pi*180;
                        if mod(tT,360)>180 && mod(tT,360)<360
                            for i = 1:length(tX)
                                obj.sampleLabelHdl{i} = text(obj.ax, tXY(1,i), tXY(2,i), obj.SampleName{obj.order(i)},...
                                    'FontSize', 12, 'Rotation', tT-90-180, obj.SampleFont{:});
                            end
                        else
                            for i = 1:length(tX)
                                obj.sampleLabelHdl{i} = text(obj.ax, tXY(1,i), tXY(2,i), obj.SampleName{obj.order(i)},...
                                    'FontSize', 12, 'Rotation', tT-90, 'HorizontalAlignment', 'right', obj.SampleFont{:});
                            end
                        end
                        for i = 1:obj.MaxClust
                            tX = (mean(obj.WTick(obj.class == classNum(i))) - obj.oriXLim(1))./diff(obj.oriXLim).*diff(obj.XLim) + obj.XLim(1);
                            tY = 0;
                            tXY = rotateMat4*[tX;tY];
                            if mod(tT4,360)>90 && mod(tT4,360)<270
                                obj.classLabelHdl{i} = text(obj.ax, tXY(1), tXY(2), obj.ClassName{i},...
                                    'FontSize', 12, 'Rotation', tT4+180, 'Color', colorList(i,:), 'HorizontalAlignment', 'center', obj.ClassFont{:});
                            else
                                obj.classLabelHdl{i} = text(obj.ax, tXY(1), tXY(2), obj.ClassName{i},...
                                    'FontSize', 12, 'Rotation', tT4, 'Color', colorList(i,:), 'HorizontalAlignment', 'center', obj.ClassFont{:});
                            end
                        end
                end
            end
            if strcmpi(obj.ClassLabel, 'off')
                for i = 1:obj.MaxClust
                    set(obj.classLabelHdl{i}, 'Visible', 'off');
                end
            end
            if strcmpi(obj.Label, 'off')
                for i = 1:length(obj.sampleLabelHdl)
                    set(obj.sampleLabelHdl{i}, 'Visible', 'off')
                end
            end
            axis tight
            % 部分功能函数 -------------------------------------------------
            function pnts=bezierCurve(pnts,N)
                t=linspace(0,1,N);
                p=size(pnts,1)-1;
                coe1=factorial(p)./factorial(0:p)./factorial(p:-1:0);
                coe2=((t).^((0:p)')).*((1-t).^((p:-1:0)'));
                pnts=(pnts'*(coe1'.*coe2))';
            end
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