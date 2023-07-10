hold on
axis equal
grid on
X=0:1:1023;
Y=0:1:1023;
[gridX,gridY]=meshgrid(X,Y);
FishPatternFcn=@(x,y)mod(abs(x.*sin(sqrt(x))+y.*sin(sqrt(y))).*pi./1024,1);
contour(gridX,gridY,FishPatternFcn(gridX,gridY),[0.7,0.7])
