clc;clear all;close all;
A=[0,1,0;0,0,1;-1,-5,-6]
B=[0;0;1]
P=[-2+j*4,-2-4*j,-10]
K=acker(A,B,P)
sys_new=ss(A-B*K,eye(3),eye(3),eye(3))
t=0:0.1:4
X=initial(sys_new,[1;0;0],t)
x1=[1,0,0]*X';x2=[0,1,0]*X';x3=[0,0,1]*X';
subplot(3,1,1)

plot(t,x1);grid
title('零输入响应')
ylabel('状态变量x1')
subplot(3,1,2)

plot(t,x2);grid
ylabel('状态变量x2')
subplot(3,1,3)

plot(t,x3);grid
title('时间/秒')
ylabel('状态变量x3')
