classdef chordChart < handle
% Copyright (c) 2022-2025, Zhaoxu Liu / slandarer
% =========================================================================
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer
% -------------------------------------------------------------------------
% Zhaoxu Liu / slandarer (2024). chord chart 弦图 
% (https://www.mathworks.com/matlabcentral/fileexchange/116550-chord-chart), 
% MATLAB Central File Exchange. 检索来源 2024/3/31.
% =========================================================================
% 使用示例：
% -------------------------------------------------------------------------
% dataMat=[2 0 1 2 5 1 2;
%          3 5 1 4 2 0 1;
%          4 0 5 5 2 4 3];
% colName={'G1','G2','G3','G4','G5','G6','G7'};
% rowName={'S1','S2','S3'};
% 
% CC=chordChart(dataMat,'rowName',rowName,'colName',colName);
% CC=CC.draw()
% =========================================================================
% 版本更新：
% -------------------------------------------------------------------------
% # version 1.5.0
% + 修复了老版本 sum(....,[1,2])的bug
%   Fixed the bug of the old version(sum(....,[1,2]))
% + 增添了可调节方块间距的属性'Sep'
%   Added attribute 'Sep' with adjustable square spacing
% + 增添demo3 旋转标签角度示例(demo3)
%   demo3 is added to show how to rotate the label(demo3)
% -------------------------------------------------------------------------
% # version 1.7.0
% + 增添了可调节标签半径的属性'LRadius'
%   Added attribute 'LRadius' with adjustable Label radius
% + 增添了可调节标签旋转的属性'LRotate'及函数 `labelRatato`(demo3)
%   Added attribute 'LRotate' and function `labelRatato` with adjustable Label rotate(demo3)
% + 可直接使用`colormap`函数调整颜色(demo4)
%   Colors can be adjusted directly using the function `colormap`(demo4)
% + 可使用函数`tickLabelState`显示刻度标签(demo5)
%   Use function `tickLabelState` to display tick labels(demo5)
% -------------------------------------------------------------------------
% # version 2.1.0
% + 修复了老版本部分标签错误旋转的bug
%   Fixed a bug with incorrect rotation of some labels in older versions
% + 单独设置每一个弦末端方块(demo8)
%   Set individual end blocks for each chord(demo8)
%   Use obj.setEachSquareF_Prop 
%   or  obj.setEachSquareT_Prop
%   F means from (blocks below)
%   T means to   (blocks above)
% -------------------------------------------------------------------------
% # version 2.2.0
% + 可使用`SSqRatio`属性调整弦末端弧形块占比
%   The 'SSqRatio' attribute can be used to adjust 
%   the ratio of arc-shaped blocks at the end of the chord 
% -------------------------------------------------------------------------
% # version 3.0.0
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
% # version 3.1.0
% + 新增辅助属性`OSqRatio`用来调整原本弧形块占比 (demo9)
%   The 'OSqRatio' attribute can be used to adjust
%   the ratio of original arc-shaped blocks(demo9)
% + 新增辅助属性`Rotation`用来整体旋转图形
%   The 'Rotation' attribute is used to rotate the entire shape(demo12)


    properties
        ax
        arginList={'colName','rowName','Sep','LRadius','LRotate','SSqRatio','OSqRatio','Rotation','TickMode'}
        chordTable  % table数组
        dataMat     % 数值矩阵
        colName={}; % 列名称
        rowName={}; % 行名称
        thetaSetF;meanThetaSetF;rotationF
        thetaSetT;meanThetaSetT;rotationT
        % -----------------------------------------------------------
        squareFHdl  % 绘制下方方块的图形对象矩阵
        squareTHdl  % 绘制下上方方块的图形对象矩阵
        squareFMatHdl % 流入拆分矩阵
        squareTMatHdl % 流入拆分矩阵

        nameFHdl    % 绘制下方文本的图形对象矩阵
        nameTHdl    % 绘制上方文本的图形对象矩阵
        chordMatHdl % 绘制弦的图形对象矩阵
        TickMode = 'value' % 'value'/'auto'/'linear'
        thetaTickFHdl % 刻度句柄
        thetaTickTHdl % 刻度句柄
        RTickFHdl % 轴线句柄
        RTickTHdl % 轴线句柄
        thetaTickLabelFHdl
        thetaTickLabelTHdl

        Sep;LRadius=1.28;LRotate='off';SSqRatio=1;OSqRatio=1;Rotation=0;
        linearTickSep, linearTickCompactDegree = 2.5, linearMinorTick = 'off';
    end

    methods
        function obj=chordChart(varargin)
            if isa(varargin{1},'matlab.graphics.axis.Axes')
                obj.ax=varargin{1};varargin(1)=[];
            else
                obj.ax=gca;
            end
            obj.ax.NextPlot='add';

            
            obj.dataMat=varargin{1};varargin(1)=[];
            obj.Sep=1/40;

            for i=1:2:(length(varargin)-1)
                tid=ismember(lower(obj.arginList),lower(varargin{i}));
                if any(tid)
                    obj.(obj.arginList{tid})=varargin{i+1};
                end
            end


            if isa(obj.dataMat,'table')
            obj.chordTable=obj.dataMat;
            obj.dataMat = obj.chordTable.Variables;
                if isempty(obj.chordTable.Properties.RowNames)
                    for i=1:size(obj.chordTable.Variables,1)
                        obj.rowName{i}=['R',num2str(i)];
                    end
                end
            else

            % tzerocell{1,size(obj.dataMat,2)}=zeros(size(obj.dataMat,1),1);
            % for i=1:size(obj.dataMat,2)
            %     tzerocell{1,i}=zeros(size(obj.dataMat,1),1);
            % end
            if isempty(obj.colName)
                obj.colName = compose('C%d', 1:size(obj.dataMat, 2));
            end
            if isempty(obj.rowName)
  
                obj.rowName = compose('R%d', 1:size(obj.dataMat, 1));
            end
            % 创建table数组
            % obj.chordTable=table(tzerocell{:});
            obj.chordTable.Variables=obj.dataMat;
            obj.chordTable.Properties.VariableNames=obj.colName;
            obj.chordTable.Properties.RowNames=obj.rowName;

            end

            if obj.Sep>1/40
                obj.Sep=1/40;
            end
            if obj.LRadius>2||obj.LRadius<1.2
                obj.LRadius=1.28;
            end
            
            help chordChart
        end

        function obj=draw(obj)
            obj.ax.XLim=[-1.38,1.38];
            obj.ax.YLim=[-1.38,1.38];
            obj.ax.XTick=[];
            obj.ax.YTick=[];
            obj.ax.XColor='none';
            obj.ax.YColor='none';
            obj.ax.PlotBoxAspectRatio=[1,1,1];

            % 计算绘图所用数值
            tDMat=obj.chordTable.Variables;
            tDFrom=obj.chordTable.Properties.RowNames;
            tDTo=obj.chordTable.Properties.VariableNames;
            obj.linearTickSep = obj.getTick(sum(sum(tDMat))./(size(tDMat,1) + size(tDMat,2)).*2, obj.linearTickCompactDegree);

            tDMatUni=tDMat-min(min(tDMat));
            tDMatUni=tDMatUni./max(max(tDMatUni));

            sep1=1/20;
            sep2=obj.Sep;

            ratioF=sum(tDMat,2)./sum(sum(tDMat));
            ratioF=[0,ratioF'];
            ratioT=[0,sum(tDMat,1)./sum(sum(tDMat))];

            sepNumF=size(tDMat,1);
            sepNumT=size(tDMat,2);

            sepLen=pi*(1-2*sep1)*sep2;
            baseLenF=(pi*(1-sep1)-(sepNumF-1)*sepLen);
            baseLenT=(pi*(1-sep1)-(sepNumT-1)*sepLen);
            tColor=[61 96 137;76 103 86]./255;
            % 绘制下方方块
            for i=1:sepNumF
                theta1=2*pi-pi*sep1/2-sum(ratioF(1:i))*baseLenF-(i-1)*sepLen + obj.Rotation;
                theta2=2*pi-pi*sep1/2-sum(ratioF(1:i+1))*baseLenF-(i-1)*sepLen + obj.Rotation;
                theta=linspace(theta1,theta2,100);
                X=cos(theta);Y=sin(theta);
                obj.squareFHdl(i)=fill([(1.15-.1*obj.OSqRatio).*X,1.15.*X(end:-1:1)],[(1.15-.1*obj.OSqRatio).*Y,1.15.*Y(end:-1:1)],...
                    tColor(1,:),'EdgeColor','none');
                theta3=mod((theta1+theta2)/2,2*pi);
                obj.meanThetaSetF(i)=theta3;
                rotation=mod(theta3/pi*180,360);
                if rotation>0&&rotation<180
                    obj.nameFHdl(i)=text(cos(theta3).*obj.LRadius,sin(theta3).*obj.LRadius,tDFrom{i},'FontSize',12,'FontName','Arial',...
                    'HorizontalAlignment','center','Rotation',-(.5*pi-theta3)./pi.*180,'Tag','ChordLabel');
                    obj.rotationF(i)=-(.5*pi-theta3)./pi.*180;
                else
                    obj.nameFHdl(i)=text(cos(theta3).*obj.LRadius,sin(theta3).*obj.LRadius,tDFrom{i},'FontSize',12,'FontName','Arial',...
                    'HorizontalAlignment','center','Rotation',-(1.5*pi-theta3)./pi.*180,'Tag','ChordLabel');
                    obj.rotationF(i)=-(1.5*pi-theta3)./pi.*180;
                end
                obj.RTickFHdl(i)=plot(cos(theta).*1.17,sin(theta).*1.17,'Color',[0,0,0],'LineWidth',.8,'Visible','off');
            end
            % 绘制上方方块
            for j=1:sepNumT
                theta1=pi-pi*sep1/2-sum(ratioT(1:j))*baseLenT-(j-1)*sepLen + obj.Rotation;
                theta2=pi-pi*sep1/2-sum(ratioT(1:j+1))*baseLenT-(j-1)*sepLen + obj.Rotation;
                theta=linspace(theta1,theta2,100);
                X=cos(theta);Y=sin(theta);
                obj.squareTHdl(j)=fill([(1.15-.1*obj.OSqRatio).*X,1.15.*X(end:-1:1)],[(1.15-.1*obj.OSqRatio).*Y,1.15.*Y(end:-1:1)],...
                    tColor(2,:),'EdgeColor','none');
                theta3=mod((theta1+theta2)/2,2*pi);
                obj.meanThetaSetT(j)=theta3;
                rotation=theta3/pi*180;
                if rotation>0&&rotation<180
                    obj.nameTHdl(j)=text(cos(theta3).*obj.LRadius,sin(theta3).*obj.LRadius,tDTo{j},'FontSize',12,'FontName','Arial',...
                    'HorizontalAlignment','center','Rotation',-(.5*pi-theta3)./pi.*180,'Tag','ChordLabel');
                    obj.rotationT(j)=-(.5*pi-theta3)./pi.*180;
                else
                    obj.nameTHdl(j)=text(cos(theta3).*obj.LRadius,sin(theta3).*obj.LRadius,tDTo{j},'FontSize',12,'FontName','Arial',...
                    'HorizontalAlignment','center','Rotation',-(1.5*pi-theta3)./pi.*180,'Tag','ChordLabel');
                    obj.rotationT(j)=-(1.5*pi-theta3)./pi.*180;
                end
                obj.RTickTHdl(j)=plot(cos(theta).*1.17,sin(theta).*1.17,'Color',[0,0,0],'LineWidth',.8,'Visible','off');
            end

            % version 1.7.0 更新部分
            % colorFunc=colorFuncFactory(flipud(summer(50)));
            colormap(obj.ax,flipud(summer(50)))
            try clim([0,1]),catch,end
            try caxis([0,1]),catch,end
            % 绘制弦
            for i=1:sepNumF
                for j=sepNumT:-1:1
                    theta1=2*pi-pi*sep1/2-sum(ratioF(1:i))*baseLenF-(i-1)*sepLen + obj.Rotation;
                    theta2=2*pi-pi*sep1/2-sum(ratioF(1:i+1))*baseLenF-(i-1)*sepLen + obj.Rotation;

                    theta3=pi-pi*sep1/2-sum(ratioT(1:j))*baseLenT-(j-1)*sepLen + obj.Rotation;
                    theta4=pi-pi*sep1/2-sum(ratioT(1:j+1))*baseLenT-(j-1)*sepLen + obj.Rotation;

                    tRowV=tDMat(i,:);tRowV=[0,tRowV(end:-1:1)./sum(tRowV)];
                    tColV=tDMat(:,j)';tColV=[0,tColV./sum(tColV)];       

                    % 贝塞尔曲线断点计算
                    theta5=(theta2-theta1).*sum(tRowV(1:(sepNumT+1-j)))+theta1;
                    theta6=(theta2-theta1).*sum(tRowV(1:(sepNumT+2-j)))+theta1;
                    theta=linspace(theta5,theta6,100);
                    X=cos(theta);Y=sin(theta);
                    obj.squareFMatHdl(i,j)=fill([1.05.*X,(1.05+obj.SSqRatio*.1).*X(end:-1:1)],[1.05.*Y,(1.05+obj.SSqRatio*.1).*Y(end:-1:1)],...
                        tColor(2,:),'EdgeColor','none','Visible','off');

                    theta7=(theta3-theta4).*sum(tColV(1:i))+theta4;
                    theta8=(theta3-theta4).*sum(tColV(1:i+1))+theta4;
                    theta=linspace(theta7,theta8,100);
                    X=cos(theta);Y=sin(theta);
                    obj.squareTMatHdl(i,j)=fill([1.05.*X,(1.05+obj.SSqRatio*.1).*X(end:-1:1)],[1.05.*Y,(1.05+obj.SSqRatio*.1).*Y(end:-1:1)],...
                        tColor(2,:),'EdgeColor','none','Visible','off');

                    tPnt1=[cos(theta5),sin(theta5)];
                    tPnt2=[cos(theta6),sin(theta6)];
                    tPnt3=[cos(theta7),sin(theta7)];
                    tPnt4=[cos(theta8),sin(theta8)];

                    if ~strcmpi(obj.TickMode, 'linear')
                            if j==sepNumT,obj.thetaSetF{i}(1)=theta5;end
                            obj.thetaSetF{i}(j+1)=theta6;
                            if i==1,obj.thetaSetT{j}(1)=theta7;end
                            obj.thetaSetT{j}(i+1)=theta8;
                    end

                    % 计算曲线
                    tLine1=bezierCurve([tPnt1;0,0;tPnt3],200);
                    tLine2=bezierCurve([tPnt2;0,0;tPnt4],200);
                    tline3=[cos(linspace(theta6,theta5,100))',sin(linspace(theta6,theta5,100))'];
                    tline4=[cos(linspace(theta7,theta8,100))',sin(linspace(theta7,theta8,100))'];
                    obj.chordMatHdl(i,j)=fill([tLine1(:,1);tline4(:,1);tLine2(end:-1:1,1);tline3(:,1)],...
                         [tLine1(:,2);tline4(:,2);tLine2(end:-1:1,2);tline3(:,2)],...
                         tDMatUni(i,j),'FaceAlpha',.3,'EdgeColor','none');
                    if tDMat(i,j)==0
                        set(obj.chordMatHdl(i,j),'Visible','off')
                    end     
                end
            end

            % #############################################################
            for i=1:sepNumF
                switch lower(obj.TickMode)
                    case 'value'
                        obj.thetaSetF{i}(2:end)=obj.thetaSetF{i}(end:-1:2);
                        [obj.thetaSetF{i}, uniListF{i}] = unique(obj.thetaSetF{i}, 'stable');
                        tX=[cos(obj.thetaSetF{i}).*1.17;cos(obj.thetaSetF{i}).*1.19;nan.*ones(1,length(obj.thetaSetF{i}))];
                        tY=[sin(obj.thetaSetF{i}).*1.17;sin(obj.thetaSetF{i}).*1.19;nan.*ones(1,length(obj.thetaSetF{i}))];
                    case 'auto'
                        obj.thetaSetF{i}(2:end)=obj.thetaSetF{i}(end:-1:2); 
                        [obj.thetaSetF{i}, uniListF{i}] = unique(obj.thetaSetF{i}, 'stable');
                        tTSF0 = obj.thetaSetF{i};
                        for k = 1:3
                            tTSF1 = obj.thetaSetF{i};
                            tTSFA = abs(diff(tTSF1));
                            tTSFB = [inf,tTSFA] < mean(tTSFA)/2 | [tTSFA, inf] < mean(tTSFA)/2;
                            tTSF2 = linspace(tTSF1(1), tTSF1(end), length(tTSF1));
                            tTSFC = tTSF1; tTSFC(tTSFB) = tTSF2(tTSFB);
                            tTSFC(tTSFC > tTSF1 + pi/30) = tTSF1(tTSFC > tTSF1 + pi/30) + pi/30;
                            tTSFC(tTSFC < tTSF1 - pi/30) = tTSF1(tTSFC < tTSF1 - pi/30) - pi/30;
                            obj.thetaSetF{i} = sort((2.*tTSF1 + tTSFC)./3, 'descend');
                        end
                        tX=[cos(tTSF0).*1.17; cos(tTSF0).*(1.17 + 1/3*.02); cos(obj.thetaSetF{i}).*(1.17 + 2/3*.02); cos(obj.thetaSetF{i}).*1.19;nan.*ones(1,length(obj.thetaSetF{i}))];
                        tY=[sin(tTSF0).*1.17; sin(tTSF0).*(1.17 + 1/3*.02); sin(obj.thetaSetF{i}).*(1.17 + 2/3*.02); sin(obj.thetaSetF{i}).*1.19;nan.*ones(1,length(obj.thetaSetF{i}))];
                    case 'linear'
                        theta1=2*pi-pi*sep1/2-sum(ratioF(1:i))*baseLenF-(i-1)*sepLen;
                        theta2=2*pi-pi*sep1/2-sum(ratioF(1:i+1))*baseLenF-(i-1)*sepLen;
                        obj.thetaSetF{i} = (theta2 - theta1)./sum(tDMat(i,:)).*(0:obj.linearTickSep:sum(tDMat(i,:))) + theta1;
                        if strcmp(obj.linearMinorTick, 'on')
                            tMTSF = (theta2 - theta1)./sum(tDMat(i,:)).*(0:(obj.linearTickSep/5):sum(tDMat(i,:))) + theta1;
                            tX = [cos(tMTSF).*1.17, cos(obj.thetaSetF{i}).*1.17; cos(tMTSF).*1.18, cos(obj.thetaSetF{i}).*1.19;nan.*ones(1,length([tMTSF, obj.thetaSetF{i}]))];
                            tY = [sin(tMTSF).*1.17, sin(obj.thetaSetF{i}).*1.17; sin(tMTSF).*1.18, sin(obj.thetaSetF{i}).*1.19;nan.*ones(1,length([tMTSF, obj.thetaSetF{i}]))];
                        else
                            tX = [cos(obj.thetaSetF{i}).*1.17;cos(obj.thetaSetF{i}).*1.19;nan.*ones(1,length(obj.thetaSetF{i}))];
                            tY = [sin(obj.thetaSetF{i}).*1.17;sin(obj.thetaSetF{i}).*1.19;nan.*ones(1,length(obj.thetaSetF{i}))];
                        end
                end
                obj.thetaTickFHdl(i)=plot(tX(:),tY(:),'Color',[0,0,0],'LineWidth',.8,'Visible','off');
            end
            for j=1:sepNumT
                switch lower(obj.TickMode)
                    case 'value'
                        obj.thetaSetT{j}(1:end)=obj.thetaSetT{j}(end:-1:1);
                        [obj.thetaSetT{j}, uniListT{j}] = unique(obj.thetaSetT{j}, 'stable');
                        tX=[cos(obj.thetaSetT{j}).*1.17;cos(obj.thetaSetT{j}).*1.19;nan.*ones(1,length(obj.thetaSetT{j}))];
                        tY=[sin(obj.thetaSetT{j}).*1.17;sin(obj.thetaSetT{j}).*1.19;nan.*ones(1,length(obj.thetaSetT{j}))];
                    case 'auto'
                        obj.thetaSetT{j}(1:end)=obj.thetaSetT{j}(end:-1:1);
                        [obj.thetaSetT{j}, uniListT{j}] = unique(obj.thetaSetT{j}, 'stable');
                        tTST0 = obj.thetaSetT{j};
                        for k = 1:3
                            tTST1 = obj.thetaSetT{j};
                            tTSTA = abs(diff(tTST1));
                            tTSTB = [inf,tTSTA] < mean(tTSTA)/2 | [tTSTA, inf] < mean(tTSTA)/2;
                            tTST2 = linspace(tTST1(1), tTST1(end), length(tTST1));
                            tTSTC = tTST1; tTSTC(tTSTB) = tTST2(tTSTB);
                            tTSTC(tTSTC > tTST1 + pi/30) = tTST1(tTSTC > tTST1 + pi/30) + pi/30;
                            tTSTC(tTSTC < tTST1 - pi/30) = tTST1(tTSTC < tTST1 - pi/30) - pi/30;
                            obj.thetaSetT{j} = (2.*tTST1 + tTSTC)./3;
                        end
                        tX=[cos(tTST0).*1.17; cos(tTST0).*(1.17 + 1/3*.02); cos(obj.thetaSetT{j}).*(1.17 + 2/3*.02); cos(obj.thetaSetT{j}).*1.19;nan.*ones(1,length(obj.thetaSetT{j}))];
                        tY=[sin(tTST0).*1.17; sin(tTST0).*(1.17 + 1/3*.02); sin(obj.thetaSetT{j}).*(1.17 + 2/3*.02); sin(obj.thetaSetT{j}).*1.19;nan.*ones(1,length(obj.thetaSetT{j}))];
                    case 'linear'
                        theta3=pi-pi*sep1/2-sum(ratioT(1:j))*baseLenT-(j-1)*sepLen;
                        theta4=pi-pi*sep1/2-sum(ratioT(1:j+1))*baseLenT-(j-1)*sepLen;
                        obj.thetaSetT{j} = (theta4 - theta3)./sum(tDMat(:,j)).*(0:obj.linearTickSep:sum(tDMat(:,j))) + theta3;
                        if strcmp(obj.linearMinorTick, 'on')
                            tMTST = (theta4 - theta3)./sum(tDMat(:,j)).*(0:(obj.linearTickSep/5):sum(tDMat(:,j))) + theta3;
                            tX = [cos(tMTST).*1.17, cos(obj.thetaSetT{j}).*1.17; cos(tMTST).*1.18, cos(obj.thetaSetT{j}).*1.19; nan.*ones(1,length([tMTST,obj.thetaSetT{j}]))];
                            tY = [sin(tMTST).*1.17, sin(obj.thetaSetT{j}).*1.17; sin(tMTST).*1.18, sin(obj.thetaSetT{j}).*1.19; nan.*ones(1,length([tMTST,obj.thetaSetT{j}]))];
                        else
                            tX = [cos(obj.thetaSetT{j}).*1.17;cos(obj.thetaSetT{j}).*1.19;nan.*ones(1,length(obj.thetaSetT{j}))];
                            tY = [sin(obj.thetaSetT{j}).*1.17;sin(obj.thetaSetT{j}).*1.19;nan.*ones(1,length(obj.thetaSetT{j}))];
                        end
                end
                obj.thetaTickTHdl(j)=plot(tX(:),tY(:),'Color',[0,0,0],'LineWidth',.8,'Visible','off');
            end
            % #############################################################

            % version 1.7.0 更新部分
            obj.labelRotate(obj.LRotate)

            % version 3.0.0 更新部分
            for m=1:length(obj.thetaSetF)              
                if strcmpi(obj.TickMode,'linear')
                    cumsumV=0:obj.linearTickSep:sum(tDMat(m,:));
                else
                    cumsumV=[0,cumsum(obj.dataMat(m,end:-1:1))];
                    cumsumV=cumsumV(uniListF{m});
                end
                for n=1:length(obj.thetaSetF{m})
                    rotation=obj.thetaSetF{m}(n)/pi*180;
                    if rotation>90&&rotation<270
                        rotation=rotation+180;
                        obj.thetaTickLabelFHdl(m,n)=text(cos(obj.thetaSetF{m}(n)).*1.2,sin(obj.thetaSetF{m}(n)).*1.2,num2str(cumsumV(n)),...
                            'Rotation',rotation,'HorizontalAlignment','right','FontSize',9,'FontName','Arial','Visible','off','UserData',cumsumV(n));
                    else
                        obj.thetaTickLabelFHdl(m,n)=text(cos(obj.thetaSetF{m}(n)).*1.2,sin(obj.thetaSetF{m}(n)).*1.2,num2str(cumsumV(n)),...
                            'Rotation',rotation,'FontSize',9,'FontName','Arial','Visible','off','UserData',cumsumV(n));
                    end
                end
            end
            for m=1:length(obj.thetaSetT)        
                if strcmpi(obj.TickMode,'linear')
                    cumsumV=0:obj.linearTickSep:sum(tDMat(:,m));
                else
                    cumsumV=[0,cumsum(obj.dataMat(end:-1:1,m)).'];
                    cumsumV=cumsumV(uniListT{m});
                end
                for n=1:length(obj.thetaSetT{m})
                    rotation=obj.thetaSetT{m}(n)/pi*180;
                    if rotation>90&&rotation<270
                        rotation=rotation+180;
                        obj.thetaTickLabelTHdl(m,n)=text(cos(obj.thetaSetT{m}(n)).*1.2,sin(obj.thetaSetT{m}(n)).*1.2,num2str(cumsumV(n)),...
                            'Rotation',rotation,'HorizontalAlignment','right','FontSize',9,'FontName','Arial','Visible','off','UserData',cumsumV(n));
                    else
                        obj.thetaTickLabelTHdl(m,n)=text(cos(obj.thetaSetT{m}(n)).*1.2,sin(obj.thetaSetT{m}(n)).*1.2,num2str(cumsumV(n)),...
                            'Rotation',rotation,'FontSize',9,'FontName','Arial','Visible','off','UserData',cumsumV(n));
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

            % version 1.7.0 删除部分
            % 渐变色句柄生成函数
            % function colorFunc=colorFuncFactory(colorList)
            %     x=(0:size(colorList,1)-1)./(size(colorList,1)-1);
            %     y1=colorList(:,1);y2=colorList(:,2);y3=colorList(:,3);
            %     colorFunc=@(X)[interp1(x,y1,X,'linear')',interp1(x,y2,X,'linear')',interp1(x,y3,X,'linear')'];
            % end
        end
        % =================================================================
        % 批量弦属性设置
        function setChordProp(obj,varargin)
            tDMat=obj.chordTable.Variables;
            for i=1:size(tDMat,1)
                for j=1:size(tDMat,2)
                    set(obj.chordMatHdl(i,j),varargin{:});
                end
            end
        end
        % 单独弦属性设置
        function setChordMN(obj,m,n,varargin)
            set(obj.chordMatHdl(m,n),varargin{:});
        end
        % 根据colormap映射颜色
        function setChordColorByMap(obj,colorList)
            tDMat=obj.chordTable.Variables;
            tDMatUni=tDMat-min(min(tDMat));
            tDMatUni=tDMatUni./max(max(tDMatUni));

            colorFunc=colorFuncFactory(colorList);
            for i=1:size(tDMat,1)
                for j=1:size(tDMat,2)
                    set(obj.chordMatHdl(i,j),'FaceColor',colorFunc(tDMatUni(i,j)));
                end
            end
            % 渐变色句柄生成函数
            function colorFunc=colorFuncFactory(colorList)
                x=(0:size(colorList,1)-1)./(size(colorList,1)-1);
                y1=colorList(:,1);y2=colorList(:,2);y3=colorList(:,3);
                colorFunc=@(X)[interp1(x,y1,X,'linear')',interp1(x,y2,X,'linear')',interp1(x,y3,X,'linear')'];
            end
        end


        % -----------------------------------------------------------------
        % 批量上方方块属性设置
        function setSquareT_Prop(obj,varargin)
            tDMat=obj.chordTable.Variables;
            for j=1:size(tDMat,2)
                set(obj.squareTHdl(j),varargin{:});
            end
        end
        % 单独上方方块属性设置
        function setSquareT_N(obj,n,varargin)
            set(obj.squareTHdl(n),varargin{:});
        end

        % version 2.1.0 更新
        % 单独设置每一个弦末端方块
        function setEachSquareT_Prop(obj,m,n,varargin)
            set(obj.squareTMatHdl(m,n),'Visible','on',varargin{:})
        end
        function setEachSquareF_Prop(obj,m,n,varargin)
            set(obj.squareFMatHdl(m,n),'Visible','on',varargin{:})
        end


        % 批量下方方块属性设置
        function setSquareF_Prop(obj,varargin)
            tDMat=obj.chordTable.Variables;
            for i=1:size(tDMat,1)
                set(obj.squareFHdl(i),varargin{:});
            end
        end
        % 单独上方方块属性设置
        function setSquareF_N(obj,n,varargin)
            set(obj.squareFHdl(n),varargin{:});
        end
        % -----------------------------------------------------------------
        % 字体设置
        function setFont(obj,varargin)
            tDMat=obj.chordTable.Variables;
            for i=1:size(tDMat,1)
                set(obj.nameFHdl(i),varargin{:});
            end
            for j=1:size(tDMat,2)
                set(obj.nameTHdl(j),varargin{:});
            end 
        end
        function setTickFont(obj,varargin)
            for m=1:length(obj.thetaSetF)
                for n=1:length(obj.thetaSetF{m})
                    set(obj.thetaTickLabelFHdl(m,n),varargin{:})
                end
            end
            for m=1:length(obj.thetaSetT)
                for n=1:length(obj.thetaSetT{m})
                    set(obj.thetaTickLabelTHdl(m,n),varargin{:})
                end
            end
        end
        % version 1.7.0 更新部分
        % 标签文字距离设置
        function obj=setLabelRadius(obj,Radius)
            obj.LRadius=Radius;
            for i=1:length(obj.meanThetaSetF)
                set(obj.nameFHdl(i),'Position',[cos(obj.meanThetaSetF(i)),sin(obj.meanThetaSetF(i))].*obj.LRadius);
            end
            for j=1:length(obj.meanThetaSetT)
                set(obj.nameTHdl(j),'Position',[cos(obj.meanThetaSetT(j)),sin(obj.meanThetaSetT(j))].*obj.LRadius);
            end
        end
        % version 1.7.0 更新部分
        % 标签旋转状态设置
        function labelRotate(obj,Rotate)
            obj.LRotate=Rotate;
            for i=1:length(obj.meanThetaSetF)
                set(obj.nameFHdl(i),'Rotation',obj.rotationF(i),'HorizontalAlignment','center');
            end
            for j=1:length(obj.meanThetaSetT)
                set(obj.nameTHdl(j),'Rotation',obj.rotationT(j),'HorizontalAlignment','center');
            end
            if isequal(obj.LRotate,'on')
            textHdl=findobj(gca,'Tag','ChordLabel');
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
            tDMat=obj.chordTable.Variables;
            for i=1:size(tDMat,1)
                set(obj.thetaTickFHdl(i),'Visible',state);
                set(obj.RTickFHdl(i),'Visible',state);
            end
            for j=1:size(tDMat,2)
                set(obj.thetaTickTHdl(j),'Visible',state);
                set(obj.RTickTHdl(j),'Visible',state);
            end          
        end
        function tickLabelState(obj,state)
            for m=1:length(obj.thetaSetF)
                for n=1:length(obj.thetaSetF{m})
                    set(obj.thetaTickLabelFHdl(m,n),'Visible',state)
                end
            end
            for m=1:length(obj.thetaSetT)
                for n=1:length(obj.thetaSetT{m})
                    set(obj.thetaTickLabelTHdl(m,n),'Visible',state)
                end
            end
        end
        function setTickLabelFormat(obj,func)
            for m=1:length(obj.thetaSetF)
                for n=1:length(obj.thetaSetF{m})
                    tStr=func(get(obj.thetaTickLabelFHdl(m,n),'UserData'));
                    set(obj.thetaTickLabelFHdl(m,n),'String',tStr)
                end
            end
            for m=1:length(obj.thetaSetT)
                for n=1:length(obj.thetaSetT{m})
                    tStr=func(get(obj.thetaTickLabelTHdl(m,n),'UserData'));
                    set(obj.thetaTickLabelTHdl(m,n),'String',tStr)
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
% =========================================================================
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer
% -------------------------------------------------------------------------
% Zhaoxu Liu / slandarer (2024). chord chart 弦图 
% (https://www.mathworks.com/matlabcentral/fileexchange/116550-chord-chart), 
% MATLAB Central File Exchange. 检索来源 2024/3/31.
end