classdef circleTree3
% @author : slandarer
% 公众号  : slandarer随笔 
% 知乎    : hikari

    properties
        ax,treeList
        ClassLine,ChildLine1,ChildLine2
        MeanScatter,ClassScatter1,ClassScatter2
        LabelHdl0,LabelHdl1,LabelHdl2
    end

    methods
        function obj = circleTree3(treeList)
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
            
            childNameList1{length(classNameList)}={[]};
            childrenList2{length(classNameList)}={[]};
            for i=1:length(classNameList)
                tList=obj.treeList(:,2);
                tList=tList(strcmp(classNameList{i},obj.treeList(:,1)));
                childNameList1{i}=unique(tList);
            end

            for i=1:length(classNameList)
                for j=1:length(childNameList1{i})
                    tchildNameList=childNameList1{i};
                    tbool1=strcmp(classNameList{i},obj.treeList(:,1));
                    tbool2=strcmp(tchildNameList{j},obj.treeList(:,2));
                    childrenList2{i,j}=find(tbool1&tbool2);
                    classSize(i,j)=length(childrenList2{i,j});
                end
            end
            cumSize=classSize';
            colSize=cumSize(cumSize~=0)';
            cumSize=cumsum(colSize);

            % 开始绘图 =====================================================
            sepTheta=2/30/length(cumSize);
            cumTheta=[0,28/30.*cumSize./cumSize(end)];
            colorList=[127,91,93;187,128,110;197,173,143;59,71,111;104,95,126;76,103,86;112,112,124;
                72,39,24;197,119,106;160,126,88;238,208,146]./255;
            colorList=[colorList;rand(length(classSize),3)];
            colorList=colorList(4:end,:);
            n=1;
            for i=1:length(classNameList)
                meanThetaList=[];
                for j=1:length(childNameList1{i})
                    thetaList=linspace(sepTheta*n+cumTheta(n),sepTheta*n+cumTheta(n+1),classSize(i,j)).*2.*pi;
                    bX2=[];bY2=[];
                    for k=1:classSize(i,j)
                        oX2=[cos(thetaList(k)),cos(thetaList(k)).*0.95,cos(mean(thetaList)).*0.9,cos(mean(thetaList)).*0.7];
                        oY2=[sin(thetaList(k)),sin(thetaList(k)).*0.95,sin(mean(thetaList)).*0.9,sin(mean(thetaList)).*0.7];
                        bXY2=bezierCurve([oX2',oY2'],200);
                        bX2=[bX2;bXY2(:,1);nan];
                        bY2=[bY2;bXY2(:,2);nan]; 
                    end
                    obj.ChildLine2(i,j)=plot(bX2,bY2,'Color',[colorList(i,:),.4],'LineWidth',1.1);
                    meanThetaList=[meanThetaList,mean(thetaList)];
                    

                    tchildNameList=childNameList1{i};
                    rotation=mean(thetaList)/pi*180;
                    if rotation>90&&rotation<270
                        rotation=rotation+180;
                        obj.LabelHdl1(n)=text(cos(mean(thetaList)).*0.7,sin(mean(thetaList)).*0.7,tchildNameList{j},...
                            'Rotation',rotation,'HorizontalAlignment','right','FontSize',11,'VerticalAlignment','bottom');
                    else
                        obj.LabelHdl1(n)=text(cos(mean(thetaList)).*0.7,sin(mean(thetaList)).*0.7,tchildNameList{j},...
                            'Rotation',rotation,'FontSize',11,'VerticalAlignment','cap');
                    end
                    if classSize(i,j)<sum(classSize(i,:))/20
                        set(obj.LabelHdl1(n),'Visible','off');
                    end

                    n=n+1;
                end
                obj.ClassScatter2(i)=scatter(cos(meanThetaList).*0.7,sin(meanThetaList).*0.7,'filled',...
                    'CData',colorList(i,:),'MarkerEdgeColor',[.4,.4,.4],'SizeData',20);
                bX1=[];bY1=[];
                for m=1:length(meanThetaList)
                    oX1=[cos(meanThetaList(m)).*0.7,cos(meanThetaList(m)).*0.65,cos(mean(meanThetaList)).*0.5,cos(mean(meanThetaList)).*0.35];
                    oY1=[sin(meanThetaList(m)).*0.7,sin(meanThetaList(m)).*0.65,sin(mean(meanThetaList)).*0.5,sin(mean(meanThetaList)).*0.35];
                    bXY1=bezierCurve([oX1',oY1'],200);
                    bX1=[bX1;bXY1(:,1);nan];
                    bY1=[bY1;bXY1(:,2);nan];
                end
                obj.ChildLine1(i)=plot(bX1,bY1,'Color',[colorList(i,:),.5],'LineWidth',1.2);
                meanTheta=mean(meanThetaList);
                oX0=[cos(meanTheta).*0.35,cos(meanTheta).*0.32,0.05,0];
                oY0=[sin(meanTheta).*0.35,sin(meanTheta).*0.32,-0.15,0];
                bXY0=bezierCurve([oX0',oY0'],200);
                obj.ClassLine(i)=plot(bXY0(:,1),bXY0(:,2),'Color',[colorList(i,:),.7],'LineWidth',1.4);
                obj.ClassScatter1(i)=scatter(cos(meanTheta).*0.35,sin(meanTheta).*0.35,'filled',...
                    'CData',colorList(i,:),'MarkerEdgeColor',[.4,.4,.4],'SizeData',40);
                rotation=meanTheta/pi*180;
                if rotation>90&&rotation<270
                    rotation=rotation+180;
                    obj.LabelHdl0(i)=text(cos(meanTheta).*0.35,sin(meanTheta).*0.35,classNameList{i},...
                        'Rotation',rotation,'HorizontalAlignment','right','FontSize',12,'VerticalAlignment','bottom');
                else
                    obj.LabelHdl0(i)=text(cos(meanTheta).*0.35,sin(meanTheta).*0.35,classNameList{i},...
                        'Rotation',rotation,'FontSize',12,'VerticalAlignment','cap');
                end
            end
            obj.MeanScatter=scatter(0,0,'filled','CData',mean(colorList(1:length(classNameList),:)),'MarkerEdgeColor',[.4,.4,.4],'SizeData',60);
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
            set(obj.ChildLine1(n),'Color',[color,.4]);
            for i=1:length(obj.ChildLine2(n,:))
                if obj.ChildLine2(n,i)~=0
                    set(obj.ChildLine2(n,i),'Color',[color,.4]);
                end
            end
            set(obj.ClassScatter1(n),'MarkerFaceColor',color);
            set(obj.ClassScatter2(n),'CData',color);

            tColorList=zeros(length(obj.ClassScatter1),3);
            for i=1:length(obj.ClassScatter1)
                tColorList(i,:)=get(obj.ClassScatter1(i),'CData');
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