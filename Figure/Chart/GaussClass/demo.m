% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : hikari
clc;clear;

% 构造三个符合高斯分布的点集并合并
PntSet1=mvnrnd([2 3],[1 0;0 2],500);
PntSet2=mvnrnd([6 7],[1 0;0 2],500);
PntSet3=mvnrnd([6 2],[1 0;0 1],500);
X=[PntSet1;PntSet2;PntSet3];

% 分类数量
K=4;

% 构造GMM模型
tic
[Mu,Sigma,Pi,Class]=gaussKMeans(X,K,'dis');
toc

% 配色
colorList=[0.4  0.76 0.65
           0.99 0.55 0.38 
           0.55 0.63 0.80
           0.23 0.49 0.71
           0.95 0.57 0.47
           0.94 0.65 0.12
           0.70 0.26 0.42
           0.86 0.82 0.11];

% -------------------------------------------------------------------------
% 绘制聚类情况
figure()
hold on
strSet{K}='';
for i=1:K
    scatter(X(Class==i,1),X(Class==i,2),80,'filled',...
        'LineWidth',1,'MarkerEdgeColor',[1 1 1]*.3,'MarkerFaceColor',colorList(i,:));
    strSet{i}=['pointSet',num2str(i)];
end
legend(gca,strSet{:})
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
ax.FontSize=13;
 
% -------------------------------------------------------------------------
% 绘制聚类区域及边界
figure()
hold on
% 构造细密网格
x1=min(X(:,1)):0.01:max(X(:,1));
x2=min(X(:,2)):0.01:max(X(:,2));
[x1G,x2G]=meshgrid(x1,x2);
XGrid=[x1G(:),x2G(:)];

% 检测每个格点属于哪一类
XV=zeros(size(XGrid,1),K);
for i=1:K
    tf=getGaussFunc(Mu(i,:),Sigma(:,:,i),Pi(i));
    XV(:,i)=tf(x1G(:),x2G(:));
end 
[~,idx2Region]=max(XV,[],2);

% 绘制聚类区域方法一
% gscatter(XGrid(:,1),XGrid(:,2),idx2Region,colorList,'..');

% 绘制聚类区域方法二
RGrid=zeros(size(x1G(:)));
GGrid=zeros(size(x1G(:)));
BGrid=zeros(size(x1G(:)));
for i=1:K
    RGrid(idx2Region==i)=colorList(i,1);
    GGrid(idx2Region==i)=colorList(i,2);
    BGrid(idx2Region==i)=colorList(i,3);
end
CGrid=[];
CGrid(:,:,1)=reshape(RGrid,size(x1G));
CGrid(:,:,2)=reshape(GGrid,size(x1G));
CGrid(:,:,3)=reshape(BGrid,size(x1G));
surf(x1G,x2G,zeros(size(x1G)),'CData',CGrid,'EdgeColor','none','FaceAlpha',.5)

% 绘制边缘线
contour(x1G,x2G,reshape(idx2Region,size(x1G)),1.5:1:K,...
    'LineWidth',1.5,'LineColor',[0,0,0],'LineStyle','--')


scatterSet=[];
strSet{K}='';
for i=1:K
    scatterSet(i)=scatter(Mu(i,1),Mu(i,2),80,'filled','o','MarkerFaceColor',...
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
ax.FontSize=13;