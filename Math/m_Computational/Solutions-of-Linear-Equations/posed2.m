clear;clc;
x=[0:0.01:4.99];
y=x;
n=length(x);
k=zeros(n,n);
d=zeros(n+4,n);
b=zeros(n,n);
u=zeros(n,n);
g=zeros(n,1);
%求取矩阵
for i=1:n
    g(i)=(5.5-x(i))*exp(x(i))-0.5*exp(-x(i));
end
dg=zeros(n,1);
for i=1:n
    dg(i)=0.5*sin(10*x(i)+1)+cos(23*x(i)+2);
end
g1=g+dg;
% % % % % % % % % % % %  
f=exp(y);
% % % % % % % % % % 
for i=1:n
   for j=1:n
       if (x(i)>y(j))
           k(i,j)=exp((y(j)-x(i)));
       else
           k(i,j)=exp(x(i)-y(j));
       end
   end
end
% figure;imagesc(k);colorbar;title('K')

h=zeros(n,n);
a1=ones(n-2,1);
h1=diag(a1,-2);
a2=-4*ones(n-1,1);
h2=diag(a2,-1);
a3=6*ones(n,1);
h3=diag(a3);
a4=-4*ones(n-1,1);
h4=diag(a4,1);
a5=ones(n-2,1);
h5=diag(a5,2);
h=h1+h2+h3+h4+h5;
h(1,1)=1;h(1,2)=-2;
h(2,1)=-2;h(2,2)=5;

h(n-1,n-1)=5;h(n-1,n)=-2;
h(n,n-1)=-2;h(n,n)=1;

r=0.5;

u=inv(k'*k+r*h);
f1=u*k'*g;
subplot(1,2,1)
plot(f1*100,'r','linewidth',2);
legend('twomey改进',2)
subplot(1,2,2)
plot(f,'linewidth',2)
legend('真解',2)

