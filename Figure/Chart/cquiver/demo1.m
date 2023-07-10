[X,Y]=meshgrid(-pi:pi/8:pi,-pi:pi/8:pi);
U=sin(Y);
V=cos(X);

q=quiver(X,Y,U,V,'LineWidth',1.2);
axis equal

cq=cquiver(q);
cq=cq.draw();


