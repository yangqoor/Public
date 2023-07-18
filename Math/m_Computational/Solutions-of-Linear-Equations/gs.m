function x=gs(n)
% GSµü´ú·¨

A=H(n);b=ones(n,1);b=A*b;
D1=(tril(A))^(-1);

f=D1*b;
B=eye(n,n)-D1*A;
x=zeros(n,1);
a=0;
while 1,
    y=B*x+f;
    r=max(abs(y-x));
    x=y;
    a=a+1;
    if (r<=1e-7)+(a>30000),break;end;
end;
rho=max(abs(eig(B)))
a