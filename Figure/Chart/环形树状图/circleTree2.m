classdef circleTree2
% @author : slandarer
% 公众号  : slandarer随笔 
% 知乎    : hikari

    properties
        ax,treeList
        ClassLine,ChildLine
        ClassScatter,MeanScatter
        LabelHdl0,LabelHdl1
    end

    methods
        function obj=circleTree2(treeList)
            obj.ax=gca;hold on;
            obj.treeList=treeList;         
        end

        function obj=draw(obj)
            % 坐标区域属性设置 ==============================================
            obj.ax=gca;hold on
            obj.ax.XLim=[-1,1];
            obj.ax.YLim=[-1,1];
            obj.ax.XTick=[];
            obj.ax.YTick=[];
            obj.ax.XColor='none';
            obj.ax.YColor='none';
            obj.ax.PlotBoxAspectRatio=[1,1,1];

            fig=obj.ax.Parent;
            if max(fig.Position(3:4))<600
                fig.Position(3:4)=1.8.*fig.Position(3:4);
                fig.Position(1:2)=fig.Position(1:2)./3;
            end
            % ax.LooseInset=[0,0,0,0];
            % 理顺层级 =====================================================
            classNameList=unique(obj.treeList(:,1));
            childrenList{length(classNameList)}=[];
            classSize(length(classNameList))=0;
            for i=1:length(classNameList)
                childrenList{i}=find(strcmp(classNameList{i},obj.treeList(:,1)));
                classSize(i)=length(childrenList{i});
            end
            % 开始绘图 =====================================================
            sepTheta=2/30/length(classSize);
            cumTheta=[0,28/30*cumsum(classSize)./sum(classSize)];
            colorList=[127,91,93;187,128,110;197,173,143;59,71,111;104,95,126;76,103,86;112,112,124;
                72,39,24;197,119,106;160,126,88;238,208,146]./255;
            colorList=[colorList;rand(length(classSize),3)];
            colorList=colorList(4:end,:);
            for i=1:length(classSize)
                thetaList=linspace(sepTheta*i+cumTheta(i),sepTheta*i+cumTheta(i+1),classSize(i)).*2.*pi;
                bX1=[];bY1=[];
                for j=1:classSize(i)
                    oX1=[cos(thetaList(j)),cos(thetaList(j)).*0.9,cos(mean(thetaList)).*0.7,cos(mean(thetaList)).*0.45];
                    oY1=[sin(thetaList(j)),sin(thetaList(j)).*0.9,sin(mean(thetaList)).*0.7,sin(mean(thetaList)).*0.45];
                    bXY1=bezierCurve([oX1',oY1'],200);
                    bX1=[bX1;bXY1(:,1);nan];
                    bY1=[bY1;bXY1(:,2);nan];
                    nameList1=obj.treeList(:,2);
                    nameList1=nameList1(childrenList{i});
                    rotation=thetaList(j)/pi*180;
                    if rotation>90&&rotation<270
                        rotation=rotation+180;
                        obj.LabelHdl1(i,j)=text(cos(thetaList(j)).*1.03,sin(thetaList(j)).*1.03,nameList1{j},'Rotation',rotation,'HorizontalAlignment','right');
                    else
                        obj.LabelHdl1(i,j)=text(cos(thetaList(j)).*1.03,sin(thetaList(j)).*1.03,nameList1{j},'Rotation',rotation);
                    end
                    
                end
                meanTheta=mean(thetaList);
                obj.ChildLine(i)=plot(bX1,bY1,'Color',[colorList(i,:),.4],'LineWidth',1.5);
                oX0=[cos(meanTheta).*0.46,cos(meanTheta).*0.44,0.05,0];
                oY0=[sin(meanTheta).*0.46,sin(meanTheta).*0.44,-0.15,0];
                bXY0=bezierCurve([oX0',oY0'],200);
                obj.ClassLine(i)=plot(bXY0(:,1),bXY0(:,2),'Color',[colorList(i,:),.8],'LineWidth',1.5);
                obj.ClassScatter(i)=scatter(cos(meanTheta).*0.45,sin(meanTheta).*0.45,'filled',...
                    'CData',colorList(i,:),'MarkerEdgeColor',[.4,.4,.4],'SizeData',60);
                rotation=meanTheta/pi*180;
                if rotation>90&&rotation<270
                    rotation=rotation+180;
                    obj.LabelHdl0(i)=text(cos(meanTheta).*0.48,sin(meanTheta).*0.48,classNameList{i},...
                        'Rotation',rotation,'HorizontalAlignment','right','FontSize',12,'VerticalAlignment','cap');
                else
                    obj.LabelHdl0(i)=text(cos(meanTheta).*0.48,sin(meanTheta).*0.48,classNameList{i},...
                        'Rotation',rotation,'FontSize',12,'VerticalAlignment','cap');
                end
            end
            obj.MeanScatter=scatter(0,0,'filled','CData',mean(colorList(1:length(classSize),:)),'MarkerEdgeColor',[.4,.4,.4],'SizeData',60);
            disp(char([64 97 117 116 104 111 114 32 58 32 115 108 97 110 100 97 114 101 114]))

            % 贝塞尔函数 ===================================================
            function pnts=bezierCurve(pnts,N)
                t=linspace(0,1,N);
                p=size(pnts,1)-1;
                coe1=factorial(p)./factorial(0:p)./factorial(p:-1:0);
                coe2=((t).^((0:p)')).*((1-t).^((p:-1:0)'));
                pnts=(pnts'*(coe1'.*coe2))';
            end
        end
        % 修改颜色函数 
        function obj=setColorN(obj,n,color)
            set(obj.ClassLine(n),'Color',[color,.8]);
            set(obj.ChildLine(n),'Color',[color,.4]);
            set(obj.ClassScatter(n),'MarkerFaceColor',color);
            set(obj.ClassScatter(n),'CData',color);

            tColorList=zeros(length(obj.ClassScatter),3);
            for i=1:length(obj.ClassScatter)
                tColorList(i,:)=get(obj.ClassScatter(i),'CData');
            end
            set(obj.MeanScatter,'MarkerFaceColor',mean(tColorList));
            set(obj.MeanScatter,'CData',mean(tColorList));
        end
        % 修改第一层文字属性
        function obj=setLable1(obj,varargin)
            for i=1:length(obj.LabelHdl0)
                set(obj.LabelHdl0(i),varargin{:});
            end
        end

        % 修改第二层文字属性
        function obj=setLable2(obj,varargin)
            for i=1:size(obj.LabelHdl1,1)
                for j=1:size(obj.LabelHdl1,2)
                    if obj.LabelHdl1(i,j)~=0
                    set(obj.LabelHdl1(i,j),varargin{:});
                    end
                end
            end
        end
    end
% @author : slandarer
% 公众号  : slandarer随笔 
% 知乎    : hikari

% Zhaoxu Liu (2022). Circular dendrogram 环形树状图 
% (https://www.mathworks.com/matlabcentral/fileexchange/118325-circular-dendrogram), 
% MATLAB Central File Exchange. 检索来源 2022/9/29.
end