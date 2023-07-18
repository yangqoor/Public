function x=gauss(n)
% GaussÏûÔª·¨

A=H(n);b=ones(n,1);b=A*b;
A=[A,b];
for k=1:n,
    for i=k+1:n,
        l=A(i,k)/A(k,k);
        for j=k+1:n+1,
            A(i,j)=A(i,j)-l*A(k,j);
        end;
    end;
end;

for i=n:-1:1,
    if i==n,
        x(i)=A(n,n+1)/A(n,n);
    else,
        a=0;
        for j=i+1:n,
            a=a+A(i,j)*x(j);
        end;
        x(i)=(A(i,n+1)-a)/A(i,i);
    end;
end;
x=x';