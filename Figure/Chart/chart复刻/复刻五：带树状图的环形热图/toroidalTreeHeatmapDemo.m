% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer

% 随机生成数据
rng(5)
X=randn(100,80)+[(linspace(-1,2.5,100)').*ones(1,15),(linspace(.5,-.7,100)').*ones(1,15),...
                  (linspace(.1,-.7,100)').*ones(1,15),(linspace(.9,-.2,100)').*ones(1,15),...
                  (linspace(-.1,.7,100)').*ones(1,10),(linspace(-.9,-.2,100)').*ones(1,10)];
Y=randn(100,8)+[(linspace(-1,2.5,100)').*ones(1,2),(linspace(.5,-.7,100)').*ones(1,3),(linspace(-1,-2.5,100)').*ones(1,3)];
Data=corr(X,Y);

% 定义配色和颜色范围
CMap=parula();
CMap=slanCM(136);
CLim=[-1,1];

% 随便定义变量名
XName{80}=[];
for i=1:80
    XName{i}=['slan',num2str(i)];
end
YName{8}=[];
for i=1:8
    YName{i}=['var',num2str(i)];
end

% 角度范围
theta1=pi/4;
theta2=-3*pi/2;
% 半径范围
R1=1;
R2=2;

% 角度及半径预处理 ==========================================================
theta3=(theta2-theta1)./size(Data,1);
theta4=theta1+theta3/2;
theta5=theta2-theta3/2;
theta6=2.7*pi/8;
R3=(R2-R1)./size(Data,2);
R4=R1+R3/2;
R5=R2-R3/2;

% 开始绘图 =================================================================
fig=figure('Units','normalized','Position',[0,0,1,1]);
fig.Color=[1,1,1];
ax=axes(fig);hold on
% ax.Position=[0,0,1,1];
ax.XLim=[-2,2];
ax.YLim=[-2,2];
ax.DataAspectRatio=[1,1,1];
ax.XColor='none';
ax.YColor='none';

% 中心极坐标树状图
fig1=figure();
tree1=linkage(Data,'average');
[treeHdl1,~,order1]=dendrogram(tree1,0,'Orientation','top');
LineSet1=fig1.Children.Children;
maxY1=0;
for i=1:length(LineSet1)
    maxY1=max(max(LineSet1(i).YData),maxY1);
end
tS=linspace(0,1,50);
for i=1:length(LineSet1)
    tX=LineSet1(i).XData;
    tY=LineSet1(i).YData;
    tR=(maxY1-tY)./maxY1;
    tT=theta4+(theta5-theta4).*(tX-1)./(size(Data,1)-1);
    tR=[tR(1),tR(2).*ones(1,50),tR(4)];
    tT=[tT(1),tT(2)+tS.*(tT(3)-tT(2)),tT(4)];
    plot(ax,tR.*cos(tT),tR.*sin(tT),'Color','k','LineWidth',.7)
end
close(fig1)

% 绘制侧面树状图
fig2=figure();
tree2=linkage(Data.','average');
[treeHdl2,~,order2]=dendrogram(tree2,0,'Orientation','top');
LineSet2=fig2.Children.Children;
maxY2=0;
for i=1:length(LineSet2)
    maxY2=max(max(LineSet2(i).YData),maxY2);
end
tS=linspace(0,1,20);
for i=1:length(LineSet2)
    tX=LineSet2(i).XData;
    tY=LineSet2(i).YData;
    tR=R4+(R5-R4).*(tX-1)./(size(Data,2)-1);
    tT=theta6+(theta1-theta6).*(maxY2-tY)./maxY2;
    tR=[tR(1).*ones(1,20),tR(4).*ones(1,20)];
    tT=[tT(1)+(tT(2)-tT(1)).*tS,tT(3)+(tT(4)-tT(3)).*tS];
    plot(ax,tR.*cos(tT),tR.*sin(tT),'Color','k','LineWidth',.7)
end
close(fig2)


% 绘制环形热力图
x=linspace(CLim(1),CLim(2),size(CMap,1))';
y1=CMap(:,1);y2=CMap(:,2);y3=CMap(:,3);
colorFunc=@(X)[interp1(x,y1,X,'pchip'),interp1(x,y2,X,'pchip'),interp1(x,y3,X,'pchip')];
tS=linspace(0,1,50);
Data=Data(order1,:);
Data=Data(:,order2);
for i=1:size(Data,2)
    for j=1:size(Data,1)
        tX=[i-1,i]./size(Data,2);
        tY=[j-1,j]./size(Data,1);
        tX=tX+1;
        tY=theta1+(theta2-theta1).*tY;
        tR=[tX(1).*ones(1,50),tX(2).*ones(1,50)];
        tT=[tY(1)+(tY(2)-tY(1)).*tS,tY(2)+(tY(1)-tY(2)).*tS];
        fill(ax,tR.*cos(tT),tR.*sin(tT),colorFunc(Data(j,i)),'EdgeColor',[1,1,1],'LineWidth',.7)
    end
end

% 添加文本1
for i=1:length(order1)
    tT=theta4+(theta5-theta4).*(i-1)./(size(Data,1)-1);
    if tT>-pi/2
        text(ax,(1/30+2).*cos(tT),(1/30+2).*sin(tT),XName{order1(i)},...
        'FontSize',13,'FontName','Cambria','Rotation',tT./pi.*180);
    else
        text(ax,(1/30+2).*cos(tT),(1/30+2).*sin(tT),XName{order1(i)},...
        'FontSize',13,'FontName','Cambria','Rotation',tT./pi.*180+180,'HorizontalAlignment','right');
    end
end

% 添加文本2
for i=1:length(order2)
    text(ax,1/30,R4+(R5-R4).*(i-1)./(size(Data,2)-1),YName{order2(i)},...
        'FontSize',13,'FontName','Cambria');
end

% 添加colorbar
colormap(CMap)
clim(CLim)
cb=colorbar();
cb.Position(2)=2/5;
cb.Position(4)=1/5;
cb.Position(1)=8/10;
cb.Position(3)=1/80;
cb.FontName='Cambria';
cb.FontSize=12;

