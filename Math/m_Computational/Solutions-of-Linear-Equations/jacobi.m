function x=jacobi(n)
% Jacobiµü´ú·¨

A=H(n);b=ones(n,1);b=A*b;
D=diag(diag(A));D1=D^(-1);

f=D1*b;
B=D1*(D-A);
x=zeros(n,1);
a=0;
while 1
    y=B*x+f;
    r=max(abs(y-x));
    x=y;
    a=a+1;
    if (r<=1e-4)+(a>10000),break;end
end
rho=max(abs(eig(B)))
a