clc;
clear;
A=[0 1;0 0];B=[0;1];C=[1 0];D=[0];
sys=ss(A,B,C,D)

control=ctrb(A,B)
if rank(control)==2
    disp('系统是完全可控的！');
else
    disp('系统是完全不可控的！');
end

s=[1 0;0 1];observe=[s;s*A]
R=4;Q=[1 0;0 1];[K,P,E]=lqr(A,B,Q,R)

A_new=A-B*K;
sys_new=ss(A_new,B,C,D)
[numt,dent]=ss2tf(A_new,B,C,D,1)
[z,p,k]=tf2zp(numt,dent)