function x=D1IAA_1text(y,K)
M=length(y);
k=0:K-1;
m=0:M-1;
A=exp(j*2*pi*m.'*k/K);
s=ones(K,1);
p=s.^2;
P=diag(p);
inter=15;
for t=1:inter
    R=A.*P.*A';
    Q=A.'/R;
    Q_1=Q.*A;
    x1=(Q*y)./Q_1;
    p=x1.^2
    P=diag(p);
end
x=abs(x1);

