set(gca,'CameraPosition',[2 2 2])
hold on
grid on
[x,t]=meshgrid((0:24)./24,(0:0.5:575)./575.*20.*pi+4*pi);
p=(pi/2)*exp(-t./(8*pi));
change=sin(15*t)/150;
u=1-(1-mod(3.6*t,2*pi)./pi).^4./2+change;
y=2*(x.^2-x).^2.*sin(p);

r=u.*(x.*sin(p)+y.*cos(p));
h=u.*(x.*cos(p)-y.*sin(p));

surface(r.*cos(t),r.*sin(t),h,'EdgeAlpha',0.1,...
    'EdgeColor',[0 0 0],'FaceColor','interp')

axProjection3D('XYZ') 
