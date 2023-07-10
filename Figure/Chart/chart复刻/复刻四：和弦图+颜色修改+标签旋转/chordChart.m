classdef chordChart
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer
% -------------------------------------------------------------------------
% Zhaoxu Liu (2022). chord chart 弦图 
% (https://www.mathworks.com/matlabcentral/fileexchange/116550-chord-chart), 
% MATLAB Central File Exchange. 检索来源 2022/11/9.
%
% 使用示例：
% =========================================================================
% dataMat=[2 0 1 2 5 1 2;
%          3 5 1 4 2 0 1;
%          4 0 5 5 2 4 3];
% colName={'G1','G2','G3','G4','G5','G6','G7'};
% rowName={'S1','S2','S3'};
% 
% CC=chordChart(dataMat,'rowName',rowName,'colName',colName);
% CC=CC.draw()

    properties
        ax
        arginList={'colName','rowName','Sep'}
        verMatlab   % MATLAB 版本: R2021a显示为2021,R2021b显示为2021.5
        chordTable  % table数组
        dataMat     % 数值矩阵
        colName={}; % 列名称
        rowName={}; % 行名称
        thetaSetF
        thetaSetT
        % -----------------------------------------------------------
        squareFHdl  % 绘制下方方块的图形对象矩阵
        squareTHdl  % 绘制下上方方块的图形对象矩阵
        nameFHdl    % 绘制下方文本的图形对象矩阵
        nameTHdl    % 绘制上方文本的图形对象矩阵
        chordMatHdl % 绘制弦的图形对象矩阵
        thetaTickFHdl % 刻度句柄
        thetaTickTHdl % 刻度句柄
        RTickFHdl % 轴线句柄
        RTickTHdl % 轴线句柄

        Sep
    end

    methods
        function obj=chordChart(varargin)
            if isa(varargin{1},'matlab.graphics.axis.Axes')
                obj.ax=varargin{1};varargin(1)=[];
            else
                obj.ax=gca;
            end
            
            % 获取版本信息
            tver=version('-release');
            obj.verMatlab=str2double(tver(1:4))+(abs(tver(5))-abs('a'))/2;

            if obj.verMatlab<2017
                hold on
            else
                hold(obj.ax,'on')
            end

            
            obj.dataMat=varargin{1};varargin(1)=[];
            if isa(obj.dataMat,'table')
            obj.chordTable=obj.dataMat;
                if isempty(obj.chordTable.Properties.RowNames)
                    for i=1:size(obj.chordTable.Variables,1)
                        obj.rowName{i}=['R',num2str(i)];
                    end
                end
            else

            obj.Sep=1/40;
            % 获取其他数据
            for i=1:2:(length(varargin)-1)
                tid=ismember(obj.arginList,varargin{i});
                if any(tid)
                obj.(obj.arginList{tid})=varargin{i+1};
                end
            end
            tzerocell{1,size(obj.dataMat,2)}=zeros(size(obj.dataMat,1),1);
            for i=1:size(obj.dataMat,2)
                tzerocell{1,i}=zeros(size(obj.dataMat,1),1);
            end
            if isempty(obj.colName)
                for i=1:size(obj.dataMat,2)
                    obj.colName{i}=['C',num2str(i)];
                end
            end
            if isempty(obj.rowName)
                for i=1:size(obj.dataMat,1)
                    obj.rowName{i}=['R',num2str(i)];
                end
            end
            if obj.Sep>1/40
                obj.Sep=1/40;
            end


            % 创建table数组
            obj.chordTable=table(tzerocell{:});
            obj.chordTable.Variables=obj.dataMat;
            obj.chordTable.Properties.VariableNames=obj.colName;
            obj.chordTable.Properties.RowNames=obj.rowName;

            help chordChart
            end
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
                theta1=2*pi-pi*sep1/2-sum(ratioF(1:i))*baseLenF-(i-1)*sepLen;
                theta2=2*pi-pi*sep1/2-sum(ratioF(1:i+1))*baseLenF-(i-1)*sepLen;
                theta=linspace(theta1,theta2,100);
                X=cos(theta);Y=sin(theta);
                obj.squareFHdl(i)=fill([1.05.*X,1.15.*X(end:-1:1)],[1.05.*Y,1.15.*Y(end:-1:1)],...
                    tColor(1,:),'EdgeColor','none');
                theta3=(theta1+theta2)/2;
                obj.nameFHdl(i)=text(cos(theta3).*1.28,sin(theta3).*1.28,tDFrom{i},'FontSize',12,'FontName','Arial',...
                    'HorizontalAlignment','center','Rotation',-(1.5*pi-theta3)./pi.*180);
                obj.RTickFHdl(i)=plot(cos(theta).*1.17,sin(theta).*1.17,'Color',[0,0,0],'LineWidth',.8,'Visible','off');
            end
            % 绘制上方放块
            for j=1:sepNumT
                theta1=pi-pi*sep1/2-sum(ratioT(1:j))*baseLenT-(j-1)*sepLen;
                theta2=pi-pi*sep1/2-sum(ratioT(1:j+1))*baseLenT-(j-1)*sepLen;
                theta=linspace(theta1,theta2,100);
                X=cos(theta);Y=sin(theta);
                obj.squareTHdl(j)=fill([1.05.*X,1.15.*X(end:-1:1)],[1.05.*Y,1.15.*Y(end:-1:1)],...
                    tColor(2,:),'EdgeColor','none');
                theta3=(theta1+theta2)/2;
                obj.nameTHdl(j)=text(cos(theta3).*1.28,sin(theta3).*1.28,tDTo{j},'FontSize',12,'FontName','Arial',...
                    'HorizontalAlignment','center','Rotation',-(.5*pi-theta3)./pi.*180);
                obj.RTickTHdl(j)=plot(cos(theta).*1.17,sin(theta).*1.17,'Color',[0,0,0],'LineWidth',.8,'Visible','off');
            end

            colorFunc=colorFuncFactory(flipud(summer(50)));
            % 绘制弦

            for i=1:sepNumF
                for j=sepNumT:-1:1
                    theta1=2*pi-pi*sep1/2-sum(ratioF(1:i))*baseLenF-(i-1)*sepLen;
                    theta2=2*pi-pi*sep1/2-sum(ratioF(1:i+1))*baseLenF-(i-1)*sepLen;
                    theta3=pi-pi*sep1/2-sum(ratioT(1:j))*baseLenT-(j-1)*sepLen;
                    theta4=pi-pi*sep1/2-sum(ratioT(1:j+1))*baseLenT-(j-1)*sepLen;

                    tRowV=tDMat(i,:);tRowV=[0,tRowV(end:-1:1)./sum(tRowV)];
                    tColV=tDMat(:,j)';tColV=[0,tColV./sum(tColV)];       

                    % 贝塞尔曲线断点计算
                    theta5=(theta2-theta1).*sum(tRowV(1:(sepNumT+1-j)))+theta1;
                    theta6=(theta2-theta1).*sum(tRowV(1:(sepNumT+2-j)))+theta1;
                    theta7=(theta3-theta4).*sum(tColV(1:i))+theta4;
                    theta8=(theta3-theta4).*sum(tColV(1:i+1))+theta4;
                    tPnt1=[cos(theta5),sin(theta5)];
                    tPnt2=[cos(theta6),sin(theta6)];
                    tPnt3=[cos(theta7),sin(theta7)];
                    tPnt4=[cos(theta8),sin(theta8)];

                    if j==sepNumT,obj.thetaSetF(i,1)=theta5;end
                    obj.thetaSetF(i,j+1)=theta6;
                    if i==1,obj.thetaSetT(1,j)=theta7;end
                    obj.thetaSetT(i+1,j)=theta8;

                    % 计算曲线
                    tLine1=bezierCurve([tPnt1;0,0;tPnt3],200);
                    tLine2=bezierCurve([tPnt2;0,0;tPnt4],200);
                    tline3=[cos(linspace(theta6,theta5,100))',sin(linspace(theta6,theta5,100))'];
                    tline4=[cos(linspace(theta7,theta8,100))',sin(linspace(theta7,theta8,100))'];
                    obj.chordMatHdl(i,j)=fill([tLine1(:,1);tline4(:,1);tLine2(end:-1:1,1);tline3(:,1)],...
                         [tLine1(:,2);tline4(:,2);tLine2(end:-1:1,2);tline3(:,2)],...
                         colorFunc(tDMatUni(i,j)),'FaceAlpha',.3,'EdgeColor','none');
                    if tDMat(i,j)==0
                        set(obj.chordMatHdl(i,j),'Visible','off')
                    end     
                end

                % 绘制刻度线
                tX=[cos(obj.thetaSetF(i,:)).*1.17;cos(obj.thetaSetF(i,:)).*1.19;nan.*ones(1,sepNumT+1)];
                tY=[sin(obj.thetaSetF(i,:)).*1.17;sin(obj.thetaSetF(i,:)).*1.19;nan.*ones(1,sepNumT+1)];
                obj.thetaTickFHdl(i)=plot(tX(:),tY(:),'Color',[0,0,0],'LineWidth',.8,'Visible','off');
            end
            for j=1:sepNumT
                tX=[cos(obj.thetaSetT(:,j)').*1.17;cos(obj.thetaSetT(:,j)').*1.19;nan.*ones(1,sepNumF+1)];
                tY=[sin(obj.thetaSetT(:,j)').*1.17;sin(obj.thetaSetT(:,j)').*1.19;nan.*ones(1,sepNumF+1)];
                obj.thetaTickTHdl(j)=plot(tX(:),tY(:),'Color',[0,0,0],'LineWidth',.8,'Visible','off');
            end


            % 贝塞尔函数
            function pnts=bezierCurve(pnts,N)
                t=linspace(0,1,N);
                p=size(pnts,1)-1;
                coe1=factorial(p)./factorial(0:p)./factorial(p:-1:0);
                coe2=((t).^((0:p)')).*((1-t).^((p:-1:0)'));
                pnts=(pnts'*(coe1'.*coe2))';
            end

            % 渐变色句柄生成函数
            function colorFunc=colorFuncFactory(colorList)
                x=(0:size(colorList,1)-1)./(size(colorList,1)-1);
                y1=colorList(:,1);y2=colorList(:,2);y3=colorList(:,3);
                colorFunc=@(X)[interp1(x,y1,X,'linear')',interp1(x,y2,X,'linear')',interp1(x,y3,X,'linear')'];
            end
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
    end
% =========================================================================
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer
% -------------------------------------------------------------------------
% Zhaoxu Liu (2022). chord chart 弦图 
% (https://www.mathworks.com/matlabcentral/fileexchange/116550-chord-chart), 
% MATLAB Central File Exchange. 检索来源 2022/11/9.
end