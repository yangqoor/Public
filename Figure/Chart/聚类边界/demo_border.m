% kmeans Region demo
% rng(1)
PntSet1=mvnrnd([2 3],[1 0;0 2],500);
PntSet2=mvnrnd([6 7],[1 0;0 2],500);
PntSet3=mvnrnd([6 2],[1 0;0 1],500); 
X=[PntSet1;PntSet2;PntSet3];

% kmeans聚类
K=3;
[idx,C]=kmeans(X,K);
% 配色
colorList=[0.4  0.76 0.65
           0.99 0.55 0.38 
           0.55 0.63 0.80
           0.23 0.49 0.71
           0.94 0.65 0.12
           0.70 0.26 0.42
           0.86 0.82 0.11];

% 绘制更强的边界 ===========================================================
x1=min(X(:,1)):0.01:max(X(:,1));
x2=min(X(:,2)):0.01:max(X(:,2));
[x1G,x2G]=meshgrid(x1,x2);
XGrid=[x1G(:),x2G(:)];

% 计算到聚类中心的范数的四次方
XV=zeros(size(XGrid,1),K);
for i=1:K
    XV(:,i)=sum((XGrid-C(i,:)).^2,2).^2;
end 

% 绘制第二类区域及边界
gamma=[100,200,600,1500];
for g=1:4
    subplot(2,2,g)
    hold on
    [~,idx2Region2]=min(XV,[],2);
    Len=length(idx2Region2);

    minXV=XV(sub2ind(size(XV),(1:Len)',idx2Region2))+gamma(g);
    tXV=XV;tXV(sub2ind(size(XV),(1:Len)',idx2Region2))=inf;

    tBool=all((tXV-minXV)>0,2);
    idx2Region2(~tBool)=K+1;


    % 绘制聚类区域方法二
    RGrid=zeros(size(x1G(:)));
    GGrid=zeros(size(x1G(:)));
    BGrid=zeros(size(x1G(:)));
    for i=1:K+1
        RGrid(idx2Region2==i)=colorList(i,1);
        GGrid(idx2Region2==i)=colorList(i,2);
        BGrid(idx2Region2==i)=colorList(i,3);
    end
    CGrid=[];
    CGrid(:,:,1)=reshape(RGrid,size(x1G));
    CGrid(:,:,2)=reshape(GGrid,size(x1G));
    CGrid(:,:,3)=reshape(BGrid,size(x1G));
    surf(x1G,x2G,zeros(size(x1G)),'CData',CGrid,'EdgeColor','none','FaceAlpha',.5)


    % 绘制边缘线
    contour(x1G,x2G,reshape(idx2Region2,size(x1G)),1.5:1:(K+1),...
        'LineWidth',1.5,'LineColor',[0,0,0],'LineStyle','--')

    scatterSet=[];
    strSet{K}='';
    for i=1:K
        scatterSet(i)=scatter(C(i,1),C(i,2),80,'filled','o','MarkerFaceColor',...
            colorList(i,:),'MarkerEdgeColor',[0,0,0],'LineWidth',1,'LineWidth',1.9);
        strSet{i}=['Cluster center ',num2str(i)];
    end
    % 添加图例
    legend(scatterSet,strSet{:})
    % 坐标区域修饰
    ax=gca;
    ax.LineWidth=1.4;
    ax.Box='on';
    ax.TickDir='in';
    ax.XMinorTick='on';
    ax.YMinorTick='on';
    ax.XGrid='on';
    ax.YGrid='on';
    ax.GridLineStyle='--';
    ax.XColor=[.3,.3,.3];
    ax.YColor=[.3,.3,.3];
    ax.FontWeight='bold';
    ax.FontName='Cambria';
    ax.FontSize=11;

    title(['\gamma=',num2str(gamma(g))],'FontWeight','bold')
end