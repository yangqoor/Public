syms u v;
r = @(u) 4 - 2*cos(u);
x = piecewise(u <= pi, -4*cos(u)*(1+sin(u)) - r(u)*cos(u)*cos(v),...
    u > pi, -4*cos(u)*(1+sin(u)) + r(u)*cos(v));
y = r(u)*sin(v);
z = piecewise(u <= pi, -14*sin(u) - r(u)*sin(u)*cos(v),...
    u > pi, -14*sin(u));
fsurf(x,y,z, [0 2*pi 0 2*pi]);
axis([-8,12,-8,12,-22,18])

axProjection3D('XYZ') 