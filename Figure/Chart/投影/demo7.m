xt = @(t) exp(-t/10).*sin(5*t);
yt = @(t) exp(-t/10).*cos(5*t);
zt = @(t) t;
fplot3(xt,yt,zt,[-10 10],'LineWidth',2)
hold on

[X,Y,Z] = peaks(30);
surf(X,Y,Z)
axis([-5,5,-5,5,-8,8])
axProjection3D('XYZ')