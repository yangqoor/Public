
clear;
close all
x1=0.1:0.01:0.18;
x2=[x1,0.2,0.21,0.23]';
y=[42,41.5,45,45.5,45,47.5,49,55,50,55,55.5,60.5]';
x=[ones(12,1),x2];
%作出数据的散点图
figure;
plot(x2,y,'+');
hold on
%回归分析
[b,bint,r,rint,stats]=regress(y,x);
b;bint;stats;
%预测及作回归线图
z=b(1)+b(2)*x2;
plot(x2,z,'-r');
legend('预测图','回归线图');
hold off
%作残差分析图
figure(2)
rcoplot(r,rint);
