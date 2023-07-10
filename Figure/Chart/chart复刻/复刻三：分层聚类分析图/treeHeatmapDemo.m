% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer

% 随机生成数据
rng(1)
X=randn(20,20)+[(linspace(-1,2.5,20)').*ones(1,8),(linspace(.5,-.7,20)').*ones(1,5),(linspace(.9,-.2,20)').*ones(1,7)];
Y=X;
X=randn(20,15)+[(linspace(-1,2.5,20)').*ones(1,4),(linspace(.5,-.7,20)').*ones(1,5),(linspace(.9,-.2,20)').*ones(1,6)];
% 计算数据相关性系数
Data=corr(X,Y);

% 输入行列名称
colName={'FREM2','ALDH9A1','RBL1','AP2A2','HNRNPK','ATP1A1','ARPC3','SMG5','RPS27A',...
          'RAB8A','SPARC','DDX3X','EEF1D','EEF1B2','RPS11','RPL13','RPL34','GCN1','FGG','CCT3'};
rowName=colName;
rowName={'A1','A2','A3','A4','A5','A6','A7','A8','A9','A10','A11','A12','A13','A14','A15'};


% =========================================================================
% 获取数据矩阵大小
[rows,cols]=size(Data);
fig=figure('Position',[500,200,800,750],'Name','slandarer','Color',[1,1,1]);

% 坐标区域创建 =============================================================
% 热图坐标区域
placeMat=zeros(7,8);placeMat(2:7,2:7)=1;
axMain=subplot(7,8,find(placeMat'));
axMain.XLim=[1,cols]+[-.5,.5];
axMain.YLim=[1,rows]+[-.5,.5];
axMain.YAxisLocation='right';
axMain.YDir='reverse';
axMain.XTick=1:cols;
axMain.YTick=1:rows;
hold on
% 树状图坐标区域
axTree1=subplot(7,8,(1:6).*8+1);
axTree1.Position(3)=axTree1.Position(3)+axTree1.Position(1)*4/5;
axTree1.Position(1)=axTree1.Position(1)/5;
axTree1.Position(3)=(axMain.Position(1)-axTree1.Position(1)-axTree1.Position(3))*4/5+axTree1.Position(3);
hold on
axTree2=subplot(7,8,2:7);
axTree2.Position(2)=axMain.Position(2)+axMain.Position(4)+(axTree2.Position(2)-axMain.Position(2)-axMain.Position(4))/5;
axTree2.Position(4)=axTree2.Position(4)+(1-axTree2.Position(2)-axTree2.Position(4))*4/5;
hold on
% colorbar坐标区域
axBar=subplot(7,8,(1:7).*8);
axBar.Position(1)=1/2;
axBar.Position(3)=.92/2;
axBar.Position(2)=axMain.Position(2)+axMain.Position(4)/2;
axBar.Position(4)=axMain.Position(2)+axMain.Position(4)-axBar.Position(2);
axBar.Color='none';
axBar.XColor='none';
axBar.YColor='none';
uistack(axBar,'bottom')
CM=colorbar;
hold on
% 图像绘制 =================================================================
% 绘制左侧树状图
tree1=linkage(Data,'average');
[treeHdl1,~,order1]=dendrogram(tree1,0,'Orientation','left');
% 设置树状图颜色
set(treeHdl1,'Color',[0,0,0]);
set(treeHdl1,'LineWidth',1);
tempFig=treeHdl1(1).Parent.Parent;
% 坐标区域二次修饰
axTree1=copyAxes(tempFig,1,axTree1);
axTree1.XColor='none';
axTree1.YColor='none';
axTree1.YDir='reverse';
axTree1.XTick=[];
axTree1.YTick=[];
axTree1.YLim=[1,rows]+[-.5,.5];
delete(tempFig)

% 绘制上方树状图
tree2=linkage(Data.','average');
[treeHdl2,~,order2]=dendrogram(tree2,0,'Orientation','top');
set(treeHdl2,'Color',[0,0,0]);
set(treeHdl2,'LineWidth',1);
tempFig=treeHdl2(1).Parent.Parent;
axTree2=copyAxes(tempFig,1,axTree2);
axTree2.XColor='none';
axTree2.YColor='none';
axTree2.XTick=[];
axTree2.YTick=[];
axTree2.XLim=[1,cols]+[-.5,.5];
delete(tempFig)
% 绘制中央热图
Data=Data(order1,:);
Data=Data(:,order2);
imagesc(axMain,Data)
axMain.XTickLabel=colName(order2);
axMain.YTickLabel=rowName(order1);
% 绘制白线
LineX=repmat([[1,cols]+[-.5,.5],nan],[rows+1,1]).';
LineY=repmat((.5:1:(rows+.5)).',[1,3]).';
plot(axMain,LineX(:),LineY(:),'Color','w','LineWidth',1);
LineY=repmat([[1,rows]+[-.5,.5],nan],[cols+1,1]).';
LineX=repmat((.5:1:(cols+.5)).',[1,3]).';
plot(axMain,LineX(:),LineY(:),'Color','w','LineWidth',1);
% 调整colorbar
baseCM={[189, 53, 70;255,255,255; 97, 97, 97]./255,...
    [13,135,169;255,255,255;239,139,14]./255,...
    [ 28,127,119;255,255,255;204,157, 80]./255,...
    [130,130,255;255,255,255;255,133,133]./255,...
    [209,58,78;253,203,121;254,254,189;198,230,156;63,150,181]./255,...
    [243,166, 72;255,255,255;133,121,176]./255};
Cmap=baseCM{5};
Ci=1:size(Cmap,1);Cq=linspace(1,size(Cmap,1),200);% 插值到200行
Cmap=[interp1(Ci,Cmap(:,1),Cq,'linear')',...
     interp1(Ci,Cmap(:,2),Cq,'linear')',...
     interp1(Ci,Cmap(:,3),Cq,'linear')'];
colormap(Cmap)
clim([min(min(Data)),max(max(Data))])



% 工具函数 =================================================================
% 复制坐标区域全部图形对象
function axbag=copyAxes(fig,k,newAx)
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer
% 
% 此段代码解析详见公众号 slandarer随笔 文章：
%《MATLAB | 如何复制figure图窗任意axes的全部信息？》
% https://mp.weixin.qq.com/s/3i8C78pv6Ok1cmEZYPMyWg
classList(length(fig.Children))=true;
for n=1:length(fig.Children)
    classList(n)=isa(fig.Children(n),'matlab.graphics.axis.Axes');
end
isaaxes=find(classList);
oriAx=fig.Children(isaaxes(end-k+1));
if isaaxes(end-k+1)-1<1||isa(fig.Children(isaaxes(end-k+1)-1),'matlab.graphics.axis.Axes')
    oriLgd=[];
else
    oriLgd=fig.Children(isaaxes(end-k+1)-1);
end
axbag=copyobj([oriAx,oriLgd],newAx.Parent);
axbag(1).Position=newAx.Position;
delete(newAx)
end 

