function x=cg(n)
% CG·¨

A=H(n);b=ones(n,1);b=A*b;
x=zeros(n,1);
r=b-A*x;p=r;
a=0;
t=p'*A*p;
c=sum(r.*r);
while (abs(t)>1e-128)*(abs(c)>1e-128),
    alpha=sum(r.*r)/t;
    x=x+alpha*p;
    r=r-alpha*A*p;
    beta=sum(r.*r)/c;
    p=r+beta*p;
    a=a+1;
    if a>20000,break;end;
    t=p'*A*p;
    c=sum(r.*r);
end;
a