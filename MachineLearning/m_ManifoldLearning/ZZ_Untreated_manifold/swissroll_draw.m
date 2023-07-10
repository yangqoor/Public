% x=(-8:0.01:8);
% y=(-8:0.01:8);
% [xx,yy]=meshgrid(x,y);
% zz=sin(sqrt(xx.^2+yy.^2))./sqrt(xx.^2+yy.^2);
% mesh(xx,yy,zz)
tt0 = (3*pi/2)*(1+2*[0:0.02:1]); hh = [0:0.125:1]*30;
xx= (tt0.*cos(tt0))'*ones(size(hh));
yy= ones(size(tt0))'*hh;
zz= (tt0.*sin(tt0))'*ones(size(hh));
cc= tt0'*ones(size(hh));
subplot; cla;
surf(xx,yy,zz,cc);