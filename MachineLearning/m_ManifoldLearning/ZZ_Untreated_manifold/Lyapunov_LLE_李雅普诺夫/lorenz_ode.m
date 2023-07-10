%    Lorenz system:
%        dx/dt = sigma*(y - x)     = f1
%        dy/dt = r*x - y - x*z = f2
%        dz/dt = x*y - b*z     = f3
%
%    The Jacobian of system: 
%        | -sigma  sigma  0 |
%    J = |   r-z    -1   -x |
%        |    y      x   -b |
%
%    Then, the variational equation has a form:
% 
%    F = J*Y
%    where Y is a square matrix with the same dimension as J.
%    Corresponding m-file:
function f=lorenz_ode(t,X)

SIGMA = 10.0; 
R = 28.0; 
BETA = 8.0/3;

%An example given by A. Wolf for verification
% SIGMA = 16.0; 
% R = 45.92; 
% BETA = 4.0;

x=X(1); y=X(2); z=X(3);
%Y的三个列向量为相互正交的单位向量
Y= [X(4), X(7), X(10);
    X(5), X(8), X(11);
    X(6), X(9), X(12)];

%输出向量的初始化
f=zeros(12,1);
f(1)=SIGMA*(y-x); 
f(2)=-x*z+R*x-y; 
f(3)=x*y-BETA*z;

%Lorenz系统的Jacobi矩阵
Jac=[-SIGMA,SIGMA,0; 
    R-z,-1,-x; 
    y, x,-BETA];

f(4:12)=Jac*Y;