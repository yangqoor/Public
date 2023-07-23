A=rand(100,100);
x=ones(100,1);
y=A*x;
noise=randn(100,1)*0.05;
yd=y+noise;

iter=100;

alpha1=1/min(abs(eig(A)));
alpha=0.0001;
x0=A'*y*alpha;
err=zeros(1,100);
for k=1:500
    x1=x0+alpha*A'*(yd-A*x0);
    
    err(k)=sum((x-x1).^2);
    
    x0=x1;
end

plot(err);
figure;
plot(diff(err));