defualtAxes()
X=0:.01:pi*5;
Y=sin(X)+X./15;

hold on
plot(X,Y,'LineWidth',2)
Uy=1.2;Ly=0;% Uy：上面的辅助线y值，Ly：下面的辅助线y值
yline(Uy,'LineWidth',1,'LineStyle','--')
yline(Ly,'LineWidth',1,'LineStyle','--')


fillColor=[114,146,184]./255;% 填充颜色
UY=Y;UY(UY<Uy)=Uy;
fill(X,UY,fillColor,'EdgeColor','none','FaceAlpha',.9)
LY=Y;LY(LY>Ly)=Ly;
fill(X,LY,fillColor,'EdgeColor','none','FaceAlpha',.9)
