% kmeans demo
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
% 绘制散点图 ===============================================================
figure()
hold on
strSet{K}='';
for i=1:K
    scatter(X(idx==i,1),X(idx==i,2),80,'filled',...
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
ax.FontSize=11;