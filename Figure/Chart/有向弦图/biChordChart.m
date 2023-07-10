classdef biChordChart
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer
    properties
        ax
        arginList={'Label','Sep','Arrow','CData'}
        verMatlab   % MATLAB 版本: R2021a显示为2021,R2021b显示为2021.5
        dataMat     % 数值矩阵
        Label={}    % 标签文本
        % -----------------------------------------------------------
        squareHdl     % 绘制方块的图形对象矩阵
        nameHdl       % 绘制下方文本的图形对象矩阵
        chordMatHdl   % 绘制弦的图形对象矩阵
        thetaTickHdl  % 刻度句柄
        RTickHdl      % 轴线句柄

        thetaSet=[];
        Sep;Arrow;CData
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
            % 获取版本信息
            tver=version('-release');
            obj.verMatlab=str2double(tver(1:4))+(abs(tver(5))-abs('a'))/2;

            if obj.verMatlab<2017
                hold on
            else
                hold(obj.ax,'on')
            end
            obj.dataMat=varargin{1};varargin(1)=[];
            % 获取其他数据
            for i=1:2:(length(varargin)-1)
                tid=ismember(obj.arginList,varargin{i});
                if any(tid)
                obj.(obj.arginList{tid})=varargin{i+1};
                end
            end
            % 名称标签预设
            if isempty(obj.Label)||length(obj.Label)<size(obj.dataMat,1)
                for i=1:size(obj.dataMat,1)
                    obj.Label{i}=['C',num2str(i)];
                end
            end
            % 调整不合理间隙
            if obj.Sep>1/10
                obj.Sep=1/10;
            end
            % 调整颜色数量
            if size(obj.CData,1)<size(obj.dataMat,1)
                obj.CData=[obj.CData;rand([size(obj.dataMat,1),3]).*.5+ones([size(obj.dataMat,1),3]).*.5];
            end
            % 调整对角线
            for i=1:size(obj.dataMat,1)
                obj.dataMat(i,i)=abs(obj.dataMat(i,i));
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

            sepLen=(2*pi*obj.Sep)./numC;
            baseLen=2*pi*(1-obj.Sep);
            % 绘制方块
            for i=1:numC
                theta1=sepLen/2+sum(ratioC(1:i))*baseLen+(i-1)*sepLen;
                theta2=sepLen/2+sum(ratioC(1:i+1))*baseLen+(i-1)*sepLen;
                theta=linspace(theta1,theta2,100);
                X=cos(theta);Y=sin(theta);
                obj.squareHdl(i)=fill([1.05.*X,1.15.*X(end:-1:1)],[1.05.*Y,1.15.*Y(end:-1:1)],...
                    obj.CData(i,:),'EdgeColor','none');
                theta3=(theta1+theta2)/2;
                rotation=theta3/pi*180;
                if rotation>0&&rotation<180
                    obj.nameHdl(i)=text(cos(theta3).*1.28,sin(theta3).*1.28,obj.Label{i},'FontSize',14,'FontName','Arial',...
                    'HorizontalAlignment','center','Rotation',-(.5*pi-theta3)./pi.*180);
                else
                    obj.nameHdl(i)=text(cos(theta3).*1.28,sin(theta3).*1.28,obj.Label{i},'FontSize',14,'FontName','Arial',...
                    'HorizontalAlignment','center','Rotation',-(1.5*pi-theta3)./pi.*180);
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
                        theta1=theta_i_2+(theta_i_3-theta_i_2).*sum(ratio_i_1(1:j));
                        theta2=theta_i_2+(theta_i_3-theta_i_2).*sum(ratio_i_1(1:j+1));
                        theta3=theta_j_3+(theta_j_1-theta_j_3).*sum(ratio_j_2(1:i));
                        theta4=theta_j_3+(theta_j_1-theta_j_3).*sum(ratio_j_2(1:i+1));
                        tPnt1=[cos(theta1),sin(theta1)];
                        tPnt2=[cos(theta2),sin(theta2)];
                        tPnt3=[cos(theta3),sin(theta3)];
                        tPnt4=[cos(theta4),sin(theta4)];
                        obj.thetaSet=[obj.thetaSet;theta1;theta2;theta3;theta4];
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
                    else
                    end
                end
            end
            % 绘制刻度线
            tickX=[cos(obj.thetaSet).*1.17,cos(obj.thetaSet).*1.19,nan.*obj.thetaSet].';
            tickY=[sin(obj.thetaSet).*1.17,sin(obj.thetaSet).*1.19,nan.*obj.thetaSet].';
            obj.thetaTickHdl=plot(tickX(:),tickY(:),'Color',[0,0,0],'LineWidth',.8,'Visible','off');

            % 贝塞尔函数
            function pnts=bezierCurve(pnts,N)
                t=linspace(0,1,N);
                p=size(pnts,1)-1;
                coe1=factorial(p)./factorial(0:p)./factorial(p:-1:0);
                coe2=((t).^((0:p)')).*((1-t).^((p:-1:0)'));
                pnts=(pnts'*(coe1'.*coe2))';
            end
        end
        % -----------------------------------------------------------------
        % 方块属性设置
        function setSquareN(obj,n,varargin)
            set(obj.squareHdl(n),varargin{:});
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

        % -----------------------------------------------------------------
        % 刻度开关
        function tickState(obj,state)
            for i=1:size(obj.dataMat,1)
                set(obj.RTickHdl(i),'Visible',state);
            end
            set(obj.thetaTickHdl,'Visible',state);
        end
    end
end