function dydt = a_matr1(t,U)
N=150;
y=1*linspace(0,pi,N)';m=length(y);h=y(2)-y(1);
B=-2*diag(ones(m,1))+diag(ones(m-1,1),1)+diag(ones(m-1,1),-1);
A=[zeros(m) eye(m);-B/h^2 zeros(m)];
dydt=A*U;