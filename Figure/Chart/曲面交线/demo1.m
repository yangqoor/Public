% 显函数绘制曲面交线
[X,Y]=meshgrid(-2:.1:2);
Z1=5-2.*X-1.5.*Y;
Z2=X.^2+Y.^2;
% 绘制曲面
surf(X,Y,Z1,'EdgeColor','none','FaceAlpha',0.5,'FaceColor',[82,124,179]./255)
hold on
surf(X,Y,Z2,'EdgeColor','none','FaceAlpha',0.5,'FaceColor',[169,64,71]./255)
% 求出交线数值解并绘图
Z3=Z1-Z2;
CXY=contour3(X,Y,Z3,[0,0],'Visible','off');
CX=CXY(1,2:end);
CY=CXY(2,2:end);
% 以下两种方式均可，用任意显函数均可
plot3(CX,CY,5-2.*CX-1.5.*CY,'LineWidth',2,'Color',[0,0,0])
% plot3(CX,CY,CX.^2+CY.^2,'LineWidth',2,'Color',[0,0,0])
view(60,14) 