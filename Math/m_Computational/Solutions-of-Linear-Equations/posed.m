clear;clc;
x=[0:0.01:4.99];
y=x;
n=length(x);
k=zeros(n,n);
%求取矩阵
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

%求取g向量
g=zeros(n,1);
for i=1:n
    g(i)=(5.5-x(i))*exp(x(i))-0.5*exp(-x(i));
end
% figure; plot(g);

%误差dg
dg=zeros(n,1);
for i=1:n
dg(i)=0.5*sin(10*x(i)+1)+cos(23*x(i)+2);
end
% figure(3);plot(dg);
 g1=g+dg;
%求取f
f1=zeros(n,1);
f=zeros(n,1);
f=inv(k)*g;
f1=inv(k)*g+inv(k)*dg;



figure(1);subplot(1,2,1)
plot(f(2:n-1)*100,'r','linewidth',2)
legend('g/k')
f2=exp(y);
subplot(1,2,2)
plot(f2(2:n-1));
legend('exp(y)')

figure(2);
plot(f1(2:n-1),'r')
hold on
plot(f2(2:n-1)/100,'.');
title('不适定')
legend('inv(k)*(g+dg)','exp(y)')

