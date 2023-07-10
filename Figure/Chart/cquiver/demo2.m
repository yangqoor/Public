[X,Y]=meshgrid(0:6,0:6);
U=0.25*X;
V=0.5*Y;
q=quiver(X,Y,U,V,0);
% q=quiver(X,Y,U,V,'AutoScale','off');

cq=cquiver(q,jet());
cq=cq.draw();