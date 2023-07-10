clc;
clear all;
A=[0 2 0 0;0 1 -2 0;0 0 3 1;1 0 0 0];
 B=[2;1;0;0];
 C=[0 1 0 0];
 D=0;
 [num,den]=ss2tf(A,B,C,D);%构建函数
 [z,p]=tf2zp(num,den);%提取零极点
%（第一问）判断稳定性
ss=find(real(p) > 0);  
tt=length(ss);  
if(tt > 0)  
    disp('系统不稳定')  
else
    disp('系统稳定')  
end 
%判断最小相位
xx=find(real(z) > 0);  
yy=length(xx);  
if(yy>0)  
    disp('系统不是最小相位系统')  
else  
    disp('系统是最小相位系统')  
end 
%（第二问）判断可控性
T1=ctrb(A,B)
R1=rank(T1)
if R1==4 
     disp('系统完全可控')
    [Ac2,Bc2,Cc2,Dc2]=ss2ss(A,B,C,D,inv(T1))
    To2=inv(T1)
else
    disp('系统不可控')
end
T2=obsv(A,C)
R2=rank(T2)
if R2==4
    disp('系统完全可观测')
    [Ao1,Bo1,Co1,Do1]=ss2ss(A,B,C,D,T2)
    To1=inv(T2)
else
     disp('系统不可观测')
end
