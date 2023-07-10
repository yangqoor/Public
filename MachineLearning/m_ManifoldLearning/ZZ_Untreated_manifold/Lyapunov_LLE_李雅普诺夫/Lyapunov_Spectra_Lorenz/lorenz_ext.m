function f=lorenz_ext(t,X)
SIGMA = 10; R = 28; BETA = 8/3;
x=X(1); y=X(2); z=X(3);

Q= [X(4), X(7), X(10);
    X(5), X(8), X(11);
    X(6), X(9), X(12)];
f=zeros(9,1);
f(1)=SIGMA*(y-x); f(2)=-x*z+R*x-y; f(3)=x*y-BETA*z;

Jac=[-SIGMA,SIGMA,0; R-z,-1,-x; y, x,-BETA];

f(4:12)=Jac*Q;