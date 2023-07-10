type='tight';
[X,Y,Z]=peaks;

% 坐标区域块 1
tsubplot(2,3,1,type)
contour(X,Y,Z,15)

% 占据两行两列的坐标区域块
tsubplot(2,3,[2,3,5,6],type)
contourf(X,Y,Z,15)

% 坐标区域块 3
tsubplot(2,3,4,type)
imagesc(Z)