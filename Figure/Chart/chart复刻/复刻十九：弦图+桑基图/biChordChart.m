classdef biChordChart < handle
% Copyright (c) 2022-2025, Zhaoxu Liu / slandarer
% =========================================================================
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer
% -------------------------------------------------------------------------
% Zhaoxu Liu / slandarer (2024). Digraph chord chart 有向弦图 
% (https://www.mathworks.com/matlabcentral/fileexchange/121043-digraph-chord-chart), 
% MATLAB Central File Exchange. 检索来源 2024/3/31.
%
% =========================================================================
% 使用示例(demo)：
% -------------------------------------------------------------------------
% dataMat = randi([0,8], [6,6]);
% 
% BCC = biChordChart(dataMat, 'Arrow','on');
% BCC = BCC.draw();
% 
% % 添加刻度
% BCC.tickState('on')
% 
% % 修改字体，字号及颜色
% BCC.setFont('FontName','Cambria', 'FontSize',17)
% =========================================================================
% 版本更新(version update)：
% -------------------------------------------------------------------------
% # version 1.1.0
% + 增添了可调节标签半径的属性'LRadius'
%   Added attribute 'LRadius' with adjustable Label radius
% + 增添了可调节标签旋转的属性'LRotate'及函数 `labelRatato`(demo3)
%   Added attribute 'LRotate' and function `labelRatato` with adjustable Label rotate(demo3)
% + 可使用函数`tickLabelState`显示刻度标签(demo4)
%   Use function `tickLabelState` to display tick labels(demo4)
% -------------------------------------------------------------------------
% # version 2.0.0
% + 新增两种标志刻度的方法
%   Added 2 methods to adjust ticks
%   try : CC = chordChart(..., 'TickMode','auto', ...)
%
%   + 'value'  : default
% 
%   + 'auto'   : 当有刻度离得很近的时候，绘制斜线将其距离拉远       
%                When there are scales that are very close, draw a diagonal line
%                to distance them further apart
%   + 'linear' : 均匀的绘制刻度线
%                Draw tick marks evenly
%
%   Properties related to linear scales        
%   % 刻度的设置要在draw()之前
%   % the setting of tick should before draw()
%   % 刻度的紧密程度，数值越高刻度线数量越多
%   % The compact degree of ticks, The higher the value, the more scales there are
%   BCC.linearTickCompactDegree = 2;
%   % 是否开启次刻度线
%   % Minor ticks 'on'/'off'
%   BCC.linearMinorTick = 'on';
% -------------------------------------------------------------------------
% # version 3.0.0
% + 可使用`SSqRatio`属性调整弦末端弧形块占比
%   The 'SSqRatio' attribute can be used to adjust 
%   the ratio of arc-shaped blocks at the end of the chord 
% + 新增辅助属性`OSqRatio`用来调整原本弧形块占比 (demo11)
%   The 'OSqRatio' attribute can be used to adjust
%   the ratio of original arc-shaped blocks(demo11)
% + 新增辅助属性`Rotation`用来整体旋转图形
%   The 'Rotation' attribute is used to rotate the entire shape(demo11)
%   当`Rotation`为数组时，可设置每一个弧形块所处角度
%   When `Rotation` is an array, it allows the setting of the angle for
%   each arc-shaped blocks(demo10)


    properties
        ax
        arginList={'Label','Sep','Arrow','CData','LRadius','LRotate',...
            'SSqRatio','OSqRatio','Rotation','TickMode'}
        dataMat     % 数值矩阵
        Label={}    % 标签文本
        % -----------------------------------------------------------
        squareHdl     % 绘制方块的图形对象矩阵
        squareFMatHdl % 流入拆分矩阵
        squareTMatHdl % 流入拆分矩阵

        nameHdl       % 绘制文本的图形对象矩阵
        chordMatHdl   % 绘制弦的图形对象矩阵
        thetaTickHdl  % 刻度句柄
        RTickHdl      % 轴线句柄
        TickMode = 'value' % 'value'/'auto'/'linear'
        thetaTickLabelHdl

        thetaSet=[];meanThetaSet;rotationSet;thetaFullSet
        Sep;Arrow;CData;LRadius=1.28;LRotate='off';SSqRatio=0;OSqRatio=1;Rotation=0;
        linearTickSep, linearTickCompactDegree = 3.5, linearMinorTick = 'off';
    end

    methods
        function obj=biChordChart(varargin)
            obj.Sep=1/10;
            obj.Arrow='off';
            obj.CData=[127,91,93;187,128,110;197,173,143;59,71,111;104,95,126;76,103,86;112,112,124;
                72,39,24;197,119,106;160,126,88;238,208,146]./255;
            if isa(varargin{1},'matlab.graphics.axis.Axes')
                obj.ax=varargin{1};varargin(1)=[];
            else
                obj.ax=gca;
            end  
            obj.ax.NextPlot='add';
            obj.dataMat=varargin{1};varargin(1)=[];
            % 获取其他数据
            for i=1:2:(length(varargin)-1)
                tid=ismember(lower(obj.arginList), lower(varargin{i}));
                if any(tid)
                obj.(obj.arginList{tid})=varargin{i+1};
                end
            end
            % 名称标签预设
            if isempty(obj.Label)||length(obj.Label)<size(obj.dataMat,1)
                obj.Label = compose('C%d', 1:size(obj.dataMat, 1));
            end
            % 调整不合理间隙
            if obj.Sep>1/2
                obj.Sep=1/2;
            end
            % 调整颜色数量
            if size(obj.CData,1)<size(obj.dataMat,1)
                obj.CData=[obj.CData;rand([size(obj.dataMat,1),3]).*.5+ones([size(obj.dataMat,1),3]).*.5];
            end
            % 调整对角线
            for i=1:size(obj.dataMat,1)
                obj.dataMat(i,i)=abs(obj.dataMat(i,i));
            end
            % 调整标签间距
            if obj.LRadius>2||obj.LRadius<1.2
                obj.LRadius=1.28;
            end
            help biChordChart
        end

        function obj=draw(obj)
            obj.ax.XLim=[-1.38,1.38];
            obj.ax.YLim=[-1.38,1.38];
            obj.ax.XTick=[];
            obj.ax.YTick=[];
            obj.ax.XColor='none';
            obj.ax.YColor='none';
            obj.ax.PlotBoxAspectRatio=[1,1,1];
            % 计算比例
            numC=size(obj.dataMat,1);
            ratioC1=sum(abs(obj.dataMat),2)./sum(sum(abs(obj.dataMat)));
            ratioC2=sum(abs(obj.dataMat),1)./sum(sum(abs(obj.dataMat)));
            ratioC=(ratioC1'+ratioC2)./2;
            ratioC=[0,ratioC];

            % version 2.0.0 更新部分
            obj.linearTickSep = obj.getTick(sum(sum(obj.dataMat))./(size(obj.dataMat,1)+size(obj.dataMat,2)).*2, obj.linearTickCompactDegree);

            sepLen=(2*pi*obj.Sep)./numC;
            baseLen=2*pi*(1-obj.Sep);

            if length(obj.Rotation) < 2
                obj.Rotation = repmat(obj.Rotation, [numC,1]);
            end

            % 绘制方块
            for i=1:numC
                theta1=sepLen/2+sum(ratioC(1:i))*baseLen+(i-1)*sepLen + obj.Rotation(i);
                theta2=sepLen/2+sum(ratioC(1:i+1))*baseLen+(i-1)*sepLen + obj.Rotation(i);
                diffTheta(i) = theta2 - theta1;
                if abs(obj.Rotation(1) - obj.Rotation(2))>eps
                    theta1=obj.Rotation(i) - diffTheta(i)/2;
                    theta2=obj.Rotation(i) + diffTheta(i)/2;
                end
                theta=linspace(theta1,theta2,100);
                X=cos(theta);Y=sin(theta);
                obj.squareHdl(i)=fill([(1.15-.1*obj.OSqRatio).*X,1.15.*X(end:-1:1)],[(1.15-.1*obj.OSqRatio).*Y,1.15.*Y(end:-1:1)],...
                    obj.CData(i,:),'EdgeColor','none');
                theta3=mod((theta1+theta2)/2,2*pi);
                obj.meanThetaSet(i)=theta3;
                rotation=theta3/pi*180;
                if rotation>0&&rotation<180
                    obj.nameHdl(i)=text(cos(theta3).*obj.LRadius,sin(theta3).*obj.LRadius,obj.Label{i},'FontSize',14,'FontName','Arial',...
                    'HorizontalAlignment','center','Rotation',-(.5*pi-theta3)./pi.*180,'Tag','BiChordLabel');
                    obj.rotationSet(i)=-(.5*pi-theta3)./pi.*180;
                else
                    obj.nameHdl(i)=text(cos(theta3).*obj.LRadius,sin(theta3).*obj.LRadius,obj.Label{i},'FontSize',14,'FontName','Arial',...
                    'HorizontalAlignment','center','Rotation',-(1.5*pi-theta3)./pi.*180,'Tag','BiChordLabel');
                    obj.rotationSet(i)=-(1.5*pi-theta3)./pi.*180;
                end
                obj.RTickHdl(i)=plot(cos(theta).*1.17,sin(theta).*1.17,'Color',[0,0,0],'LineWidth',.8,'Visible','off');
            end

            for i=1:numC
                for j=1:numC
                    theta_i_1=sepLen/2+sum(ratioC(1:i))*baseLen+(i-1)*sepLen;
                    theta_i_2=sepLen/2+sum(ratioC(1:i+1))*baseLen+(i-1)*sepLen;
                    theta_i_3=theta_i_1+(theta_i_2-theta_i_1).*sum(abs(obj.dataMat(:,i)))./(sum(abs(obj.dataMat(:,i)))+sum(abs(obj.dataMat(i,:))));

                    theta_j_1=sepLen/2+sum(ratioC(1:j))*baseLen+(j-1)*sepLen;
                    theta_j_2=sepLen/2+sum(ratioC(1:j+1))*baseLen+(j-1)*sepLen;
                    theta_j_3=theta_j_1+(theta_j_2-theta_j_1).*sum(abs(obj.dataMat(:,j)))./(sum(abs(obj.dataMat(:,j)))+sum(abs(obj.dataMat(j,:))));

                    ratio_i_1=obj.dataMat(i,:);ratio_i_1=[0,ratio_i_1./sum(ratio_i_1)];
                    ratio_j_2=obj.dataMat(:,j)';ratio_j_2=[0,ratio_j_2./sum(ratio_j_2)];
                    if true
                        theta1=theta_i_2+(theta_i_3-theta_i_2).*sum(ratio_i_1(1:j))  + obj.Rotation(i);
                        theta2=theta_i_2+(theta_i_3-theta_i_2).*sum(ratio_i_1(1:j+1))  + obj.Rotation(i);
                        theta3=theta_j_3+(theta_j_1-theta_j_3).*sum(ratio_j_2(1:i))  + obj.Rotation(j);
                        theta4=theta_j_3+(theta_j_1-theta_j_3).*sum(ratio_j_2(1:i+1))  + obj.Rotation(j);
                        if abs(obj.Rotation(1) - obj.Rotation(2))>eps
                            theta1=theta1 - diffTheta(i)/2 - theta_i_1;
                            theta2=theta2 - diffTheta(i)/2 - theta_i_1;
                            theta3=theta3 - diffTheta(j)/2 - theta_j_1;
                            theta4=theta4 - diffTheta(j)/2 - theta_j_1;
                        end


                        tPnt1=[cos(theta1),sin(theta1)];
                        tPnt2=[cos(theta2),sin(theta2)];
                        tPnt3=[cos(theta3),sin(theta3)];
                        tPnt4=[cos(theta4),sin(theta4)];
                        obj.thetaFullSet{i}(j)=theta1;
                        obj.thetaFullSet{i}(j+1)=theta2;
                        obj.thetaFullSet{j}(i+numC)=theta3;
                        obj.thetaFullSet{j}(i+numC+1)=theta4;

                        if strcmp(obj.Arrow,'off')
                            % 计算贝塞尔曲线
                            tLine1=bezierCurve([tPnt1;0,0;tPnt4],200);
                            tLine2=bezierCurve([tPnt2;0,0;tPnt3],200);
                            tline3=[cos(linspace(theta2,theta1,100))',sin(linspace(theta2,theta1,100))'];
                            tline4=[cos(linspace(theta4,theta3,100))',sin(linspace(theta4,theta3,100))'];
                        else
                            % 计算贝塞尔曲线
                            tLine1=bezierCurve([tPnt1;0,0;tPnt4.*.96],200);
                            tLine2=bezierCurve([tPnt2;0,0;tPnt3.*.96],200);
                            tline3=[cos(linspace(theta2,theta1,100))',sin(linspace(theta2,theta1,100))'];
                            tline4=[cos(theta4).*.96,sin(theta4).*.96;
                                cos(theta3/2+theta4/2).*.99,sin(theta3/2+theta4/2).*.99;
                                cos(theta3).*.96,sin(theta3).*.96];
                        end
                        obj.chordMatHdl(i,j)=fill([tLine1(:,1);tline4(:,1);tLine2(end:-1:1,1);tline3(:,1)],...
                            [tLine1(:,2);tline4(:,2);tLine2(end:-1:1,2);tline3(:,2)],...
                            obj.CData(i,:),'FaceAlpha',.3,'EdgeColor','none');
                        XF=cos(linspace(theta1,theta2,100));YF=sin(linspace(theta1,theta2,100));
                        XT=cos(linspace(theta3,theta4,100));YT=sin(linspace(theta3,theta4,100));
                        obj.squareFMatHdl(i,j)=fill([1.05.*XF,(1.05+obj.SSqRatio*.1).*XF(end:-1:1)],[1.05.*YF,(1.05+obj.SSqRatio*.1).*YF(end:-1:1)],...
                            obj.CData(j,:),'EdgeColor','none');
                        obj.squareTMatHdl(i,j)=fill([1.05.*XT,(1.05+obj.SSqRatio*.1).*XT(end:-1:1)],[1.05.*YT,(1.05+obj.SSqRatio*.1).*YT(end:-1:1)],...
                            obj.CData(i,:),'EdgeColor','none');
                    else
                    end
                end
            end
            for i = 1:numC
                tTFS = obj.thetaFullSet{i};
                isNANListF{i} = isnan(tTFS);
                obj.thetaFullSet{i} = tTFS(~isNANListF{i});
            end
            % #############################################################
            % version 2.0.0 更新部分
            % 绘制刻度线
            for i = 1:numC
                [obj.thetaFullSet{i}, uniListF{i}] = unique(obj.thetaFullSet{i}, 'stable');
            end
            switch lower(obj.TickMode)
                case 'value'
                    tickX = [cos([obj.thetaFullSet{:}]).*1.17; cos([obj.thetaFullSet{:}]).*1.19; nan.*[obj.thetaFullSet{:}]];
                    tickY = [sin([obj.thetaFullSet{:}]).*1.17; sin([obj.thetaFullSet{:}]).*1.19; nan.*[obj.thetaFullSet{:}]];
                case 'auto'
                    for i = 1:numC
                        tTFS0{i} = obj.thetaFullSet{i};
                        for k = 1:3
                            tTFS1{i} = obj.thetaFullSet{i};
                            tTFSA = abs(diff(tTFS1{i}));
                            tTFSB = [inf, tTFSA] < mean(tTFSA)/2 | [tTFSA, inf] < mean(tTFSA)/2;
                            tTFS2 = linspace(tTFS1{i}(1), tTFS1{i}(end), length(tTFS1{i}));
                            tTFSC = tTFS1{i}; tTFSC(tTFSB) = tTFS2(tTFSB);
                            tTFSC(tTFSC > tTFS1{i} + pi/30) = tTFS1{i}(tTFSC > tTFS1{i} + pi/30) + pi/30;
                            tTFSC(tTFSC < tTFS1{i} - pi/30) = tTFS1{i}(tTFSC < tTFS1{i} - pi/30) - pi/30;
                            obj.thetaFullSet{i} = sort((2.*tTFS1{i} + tTFSC)./3, 'descend');
                        end
                    end
                    
                    tickX = [cos([tTFS0{:}]).*1.17; cos([tTFS0{:}]).*(1.17 + 1/3*.02); cos([obj.thetaFullSet{:}]).*(1.17 + 2/3*.02); cos([obj.thetaFullSet{:}]).*1.19; nan.*[obj.thetaFullSet{:}]];
                    tickY = [sin([tTFS0{:}]).*1.17; sin([tTFS0{:}]).*(1.17 + 1/3*.02); sin([obj.thetaFullSet{:}]).*(1.17 + 2/3*.02); sin([obj.thetaFullSet{:}]).*1.19; nan.*[obj.thetaFullSet{:}]];
                case 'linear'
                    for i = 1:numC
                        tTFS = obj.thetaFullSet{i};
                        obj.thetaFullSet{i} = (tTFS(end) - tTFS(1))./(sum(obj.dataMat(i,:)) + sum(obj.dataMat(:,i))).*(0:obj.linearTickSep:(sum(obj.dataMat(i,:)) + sum(obj.dataMat(:,i)))) + tTFS(1);
                        tMTFS{i} = (tTFS(end) - tTFS(1))./(sum(obj.dataMat(i,:)) + sum(obj.dataMat(:,i))).*(0:obj.linearTickSep/5:(sum(obj.dataMat(i,:)) + sum(obj.dataMat(:,i)))) + tTFS(1);
                    end
                    if strcmp(obj.linearMinorTick, 'on')
                        tickX = [cos([tMTFS{:}]).*1.17, cos([obj.thetaFullSet{:}]).*1.17; cos([tMTFS{:}]).*1.18, cos([obj.thetaFullSet{:}]).*1.19; nan.*[[obj.thetaFullSet{:}],[tMTFS{:}]]];
                        tickY = [sin([tMTFS{:}]).*1.17, sin([obj.thetaFullSet{:}]).*1.17; sin([tMTFS{:}]).*1.18, sin([obj.thetaFullSet{:}]).*1.19; nan.*[[obj.thetaFullSet{:}],[tMTFS{:}]]];
                    else
                        tickX = [cos([obj.thetaFullSet{:}]).*1.17; cos([obj.thetaFullSet{:}]).*1.19; nan.*[obj.thetaFullSet{:}]];
                        tickY = [sin([obj.thetaFullSet{:}]).*1.17; sin([obj.thetaFullSet{:}]).*1.19; nan.*[obj.thetaFullSet{:}]];
                    end
            end
            obj.thetaTickHdl = plot(tickX(:),tickY(:), 'Color',[0,0,0], 'LineWidth',.8, 'Visible','off');
            % #############################################################


            % version 1.1.0 更新部分
            for i=1:numC          
                if strcmpi(obj.TickMode,'linear')
                    cumsumV=0:obj.linearTickSep:(sum(obj.dataMat(i,:)) + sum(obj.dataMat(:,i)));
                else
                    cumsumV=[0,cumsum([obj.dataMat(i,:),obj.dataMat(:,i).'])];
                    cumsumV=cumsumV(~isNANListF{i});
                    cumsumV=cumsumV(uniListF{i});
                end
                for j=1:length(obj.thetaFullSet{i})
                    rotation=mod(obj.thetaFullSet{i}(j)/pi*180,360);
                    if ~isnan(obj.thetaFullSet{i}(j))
                    if rotation>90&&rotation<270
                        rotation=rotation+180;
                        obj.thetaTickLabelHdl(i,j)=text(cos(obj.thetaFullSet{i}(j)).*1.2,sin(obj.thetaFullSet{i}(j)).*1.2,num2str(cumsumV(j)),...
                            'Rotation',rotation,'HorizontalAlignment','right','FontSize',9,'FontName','Arial','Visible','off','UserData',cumsumV(j));
                    else
                        obj.thetaTickLabelHdl(i,j)=text(cos(obj.thetaFullSet{i}(j)).*1.2,sin(obj.thetaFullSet{i}(j)).*1.2,num2str(cumsumV(j)),...
                            'Rotation',rotation,'FontSize',9,'FontName','Arial','Visible','off','UserData',cumsumV(j));
                    end
                    end
                end
            end

            % 贝塞尔函数
            function pnts=bezierCurve(pnts,N)
                t=linspace(0,1,N);
                p=size(pnts,1)-1;
                coe1=factorial(p)./factorial(0:p)./factorial(p:-1:0);
                coe2=((t).^((0:p)')).*((1-t).^((p:-1:0)'));
                pnts=(pnts'*(coe1'.*coe2))';
            end

            obj.labelRotate(obj.LRotate)
        end
        % -----------------------------------------------------------------
        % 方块属性设置
        function setSquareN(obj,n,varargin)
            set(obj.squareHdl(n),varargin{:});
        end
        % 单独设置每一个弦末端方块
        function setEachSquareT_Prop(obj,m,n,varargin)
            set(obj.squareTMatHdl(m,n),'Visible','on',varargin{:})
        end
        function setEachSquareF_Prop(obj,m,n,varargin)
            set(obj.squareFMatHdl(m,n),'Visible','on',varargin{:})
        end
        % -----------------------------------------------------------------
        % 批量弦属性设置
        function setChordN(obj,n,varargin)
            for i=n
                for j=1:size(obj.dataMat,2)
                    set(obj.chordMatHdl(i,j),varargin{:});
                end
            end
        end
        % -----------------------------------------------------------------
        % 单独弦属性设置
        function setChordMN(obj,m,n,varargin)
            set(obj.chordMatHdl(m,n),varargin{:});
        end
        % -----------------------------------------------------------------
        % 字体设置
        function setFont(obj,varargin)
            for i=1:size(obj.dataMat,1)
                set(obj.nameHdl(i),varargin{:});
            end
        end
        function setTickFont(obj,varargin)
            for m=1:length(obj.thetaFullSet)
                for n=1:length(obj.thetaFullSet{m})
                    if obj.thetaTickLabelHdl(m,n)
                        set(obj.thetaTickLabelHdl(m,n),varargin{:})
                    end
                end
            end
        end
        % version 1.1.0 更新部分
        % 标签文字距离设置
        function obj=setLabelRadius(obj,Radius)
            obj.LRadius=Radius;
            for i=1:size(obj.dataMat,1)
                set(obj.nameHdl(i),'Position',[cos(obj.meanThetaSet(i)),sin(obj.meanThetaSet(i))].*obj.LRadius);
            end
        end
        % version 1.1.0 更新部分
        % 标签旋转状态设置
        function labelRotate(obj,Rotate)
            obj.LRotate=Rotate;
            for i=1:size(obj.dataMat,1)
                set(obj.nameHdl(i),'HorizontalAlignment','center','Rotation',obj.rotationSet(i))
            end
            if isequal(obj.LRotate,'on')
            textHdl=findobj(obj.ax,'Tag','BiChordLabel');
            for i=1:length(textHdl)
                if textHdl(i).Rotation<-90
                    textHdl(i).Rotation=textHdl(i).Rotation+180;
                end
                switch true
                    case textHdl(i).Rotation<0&&textHdl(i).Position(2)>0
                        textHdl(i).Rotation=textHdl(i).Rotation+90;
                        textHdl(i).HorizontalAlignment='left';
                    case textHdl(i).Rotation>=0&&textHdl(i).Position(2)>0
                        textHdl(i).Rotation=textHdl(i).Rotation-90;
                        textHdl(i).HorizontalAlignment='right';
                    case textHdl(i).Rotation<0&&textHdl(i).Position(2)<=0
                        textHdl(i).Rotation=textHdl(i).Rotation+90;
                        textHdl(i).HorizontalAlignment='right';
                    case textHdl(i).Rotation>=0&&textHdl(i).Position(2)<=0
                        textHdl(i).Rotation=textHdl(i).Rotation-90;
                        textHdl(i).HorizontalAlignment='left';
                end
            end
            end
        end
        % -----------------------------------------------------------------
        % 刻度开关
        function tickState(obj,state)
            for i=1:size(obj.dataMat,1)
                set(obj.RTickHdl(i),'Visible',state);
            end
            set(obj.thetaTickHdl,'Visible',state);
        end
        % version 1.1.0 更新部分
        function tickLabelState(obj,state)
            for m=1:length(obj.thetaFullSet)
                for n=1:length(obj.thetaFullSet{m})
                    if obj.thetaTickLabelHdl(m,n)
                    if ~(n<length(obj.thetaFullSet{m})&&abs(obj.thetaFullSet{m}(n)-obj.thetaFullSet{m}(n+1))<eps)
                    set(obj.thetaTickLabelHdl(m,n),'Visible',state)
                    end
                    end
                end
            end
        end
        function setTickLabelFormat(obj,func)
            for m=1:length(obj.thetaFullSet)
                for n=1:length(obj.thetaFullSet{m})
                    if obj.thetaTickLabelHdl(m,n)
                    tStr=func(get(obj.thetaTickLabelHdl(m,n),'UserData'));
                    set(obj.thetaTickLabelHdl(m,n),'String',tStr)
                    end
                end
            end
        end
        % -----------------------------------------------------------------
        % 功能函数
        function tXS = getTick(~, Len, N)
            tXS = Len / N;
            tXN = ceil(log(tXS) / log(10));
            tXS = round(round(tXS / 10^(tXN-2)) / 5) * 5 * 10^(tXN-2);
        end
    end
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer
% -------------------------------------------------------------------------
% Zhaoxu Liu / slandarer (2024). Digraph chord chart 有向弦图 
% (https://www.mathworks.com/matlabcentral/fileexchange/121043-digraph-chord-chart), 
% MATLAB Central File Exchange. 检索来源 2024/3/31.
end
