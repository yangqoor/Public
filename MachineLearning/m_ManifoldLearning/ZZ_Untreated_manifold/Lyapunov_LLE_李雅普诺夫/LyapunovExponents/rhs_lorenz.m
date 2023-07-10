function dydx=rhs_lorenz(t,y)
b = 8/3; sigma = 10; r = 28;
n=3;
%   Integrate phase point (y(1)=x, y(2)=y, y(3)=z)
dydx(1,1)=sigma*(y(2,1)-y(1,1));
dydx(2,1)=r*y(1,1)-y(1,1)*y(3,1)-y(2,1);
dydx(3,1)=y(1,1)*y(2,1)-b*y(3,1);
%   Integrate tangent vectors with Jacobian (first component myin, second
%   component myin+1, third component myin+2, for myin =4,7,10);
%   for Lorenz the Jacobian is   |-sigma   sigma    0|
%                                | (r-z)    -1     -x|
%                                |   y       x     -b|
myin=n+1:n:n*(n+1);
dydx(myin,1)=-sigma*y(myin)+sigma*y(myin+1,1);
dydx(myin+1,1)=(r-y(3,1))*y(myin,1)-y(myin+1,1)-y(1,1)*y(myin+2,1);
dydx(myin+2,1)=y(2,1)*y(myin,1)+y(1,1)*y(myin+1,1)-b*y(myin+2,1);


