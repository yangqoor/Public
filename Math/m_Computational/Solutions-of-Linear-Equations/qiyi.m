function qiyi(n)
L=1;
T=1;
h=1/n;%空间步长
dt=T/n;%时间步长
for j=1:n+1
   v(j)=(j*pi)^(-2);%特征值
end
for j=1:n+1
    t(j)=j*dt;%将时间离散
end
b=(t-(t).^3)/6;%右端项真解
delta=0;%扰动水平
q=length(b);
for i=1:q
   y(i)=b(i)*(1+(2*rand-1)*delta);
    %V(i)=V(i)+(2*rand-1)*delta;%对数据添加扰动
end
y;
W=zeros(n+1,1);
for j=1:n+1;
    V=((1/v(j))*(y*((2^(1/2))*sin(j*pi*t))')*(2^(1/2))*sin(j*pi*t))';
    W=W+V;
end
W%非正则化解
zhenjie=-t;%真解
alpha=1e+7;%正则化参数
A=zeros(n+1,1);
for j=1:n+1;
    Z=((v(j)/((v(j))^2+alpha))*(y*((2^(1/2))*sin(j*pi*t))')*(2^(1/2))*sin(j*pi*t))';
    A=A+Z;
end
A%正则化解
err1=norm(W-zhenjie')/norm(zhenjie')%非正则化解与真解的相对误差
err2=norm(A-zhenjie')/norm(zhenjie')%正则化解与真解的相对误差
plot(t,zhenjie,'+r')%真解的图像
hold on
plot(t,W)%非正则化解的图像 
hold on
plot(t,A,'og')%正则化解的图像
legend('真解','数值解','正则化解',1)
xlabel('t')
ylabel('x')
