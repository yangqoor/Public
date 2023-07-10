clc;clear all;close all;
A=[0 0 -909.0909 0;0 0 333.3333 -333.3333;558 -558 0 0;1 0 0 0]
B=[909.0909;0;0;0]
P=[-1+j*sqrt(3) -1-j*sqrt(3) -5 -5]
L=acker(A,B,P)
sys_new=ss(A-B*L,eye(4),eye(4),eye(4))

t=0:0.1:20
X=initial(sys_new,[0;0;0;1],t)
x1=[1,0,0,0]*X';x2=[0,1,0,0]*X';x3=[0,0,1,0]*X';x4=[0,0,0,1]*X'
subplot(4,1,1)

plot(t,x1);grid
title('零输入响应')
ylabel('状态变量x1')
subplot(4,1,2)

plot(t,x2);grid
ylabel('状态变量x2')
subplot(4,1,3)

plot(t,x3);grid
title('时间/秒')
ylabel('状态变量x3')
subplot(4,1,4)

plot(t,x4);grid
title('时间/秒')
ylabel('状态变量x4')
