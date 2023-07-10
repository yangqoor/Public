function xdot=lorenz63(t,x)
sigma=10.0;b=8.0/3;r=28.0;
xdot=[sigma*(x(2)-x(1))
r*x(1)-x(1)*x(3)-x(2)
x(1)*x(2)-b*x(3)];