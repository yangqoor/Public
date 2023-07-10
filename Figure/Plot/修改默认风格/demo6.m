X=linspace(0,4*pi,50)';
Y=[0.5*cos(X),2*cos(X)];
[xb,yb]=stairs(X,Y);

plot(xb,yb)