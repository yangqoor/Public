function x=sor(n)
% SORµü´ú·¨

A=H(n);b=ones(n,1);b=A*b;
D=diag(diag(A));L=D-tril(A);U=D-triu(A);
Bj=D^(-1)*(D-A);
rhoBj=max(abs(eig(Bj)));
w=2/(1+sqrt(1-(rhoBj)^2));
D1=(D-w*L)^(-1);

f=w*D1*b;
B=D1*((1-w)*D+w*U);
x=zeros(n,1);
a=0;
while 1,
    y=B*x+f;
    r=max(abs(y-x));
    x=y;
    a=a+1;
    if (r<=1e-7)+(a>10000),break;end;
end;
w
rho=max(abs(eig(B)))
a