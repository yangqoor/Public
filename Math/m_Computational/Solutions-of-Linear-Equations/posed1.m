clear;clc;
x=[0:0.01:4.99];
y=x;
n=length(x);
k=zeros(n,n);
d=zeros(n+4,n);
b=zeros(n,n);
u=zeros(n,n);
g=zeros(n,1);
dg=zeros(n,1);
%求取矩阵

for i=1:n
    g(i)=(5.5-x(i))*exp(x(i))-0.5*exp(-x(i));
end
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
K=inv(k);

d(1,1:n)=-K(1,1:n);
d(2,1:n)=0;
for i=1:n
    for j=1:n
        d(i+2,j)=K(i,j);
    end
end
d(n+3,1:n)=0;
d(n+4,1:n)=-K(n,1:n);




for i=3:n+2
    for j=1:n  
        b(i-2,j)=d(i-2,j)+4*d(i-1,j)+6*d(i,j)-4*d(i+1,j)+d(i+2,j);
    end
end
        
r=10.5;
u=inv(k+r*b);
fs=u*g;
f1=u*g1;
plot(fs*100,'g');
hold on
plot(f,'r')
hold on 
plot(f1*100,'b')
legend('没有误差数据反演','原始数据','有误差数据')
title('phollips')        










% 误差dg
dg=zeros(n,1);
for i=1:n
dg(i)=0.5*sin(10*x(i)+1)+cos(23*x(i)+2);
end
figure(3);plot(dg);
 g1=g+dg;
% 求取f
f1=zeros(n,1);
f=zeros(n,1);
f=inv(k)*g;
f1=inv(k)*g1;
% 
% 
% 
% figure(1);plot(f(2:n-1),'r')
% hold on
% f2=exp(y)*0.01;
% stem(f2(2:n-1));
% figure(2);plot(f1(2:n-1),'r')
% hold on
% plot(f2(2:n-1),'.');
% 
