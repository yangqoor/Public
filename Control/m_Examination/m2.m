clc;
clear all;
A=[0 2 0 0;0 1 -2 0;0 0 3 1;1 0 0 0];
 B=[2;1;0;0];
 C=[0 1 0 0];
 D=0;
 [num,den]=ss2tf(A,B,C,D);%��������
 [z,p]=tf2zp(num,den);%��ȡ�㼫��
%����һ�ʣ��ж��ȶ���
ss=find(real(p) > 0);  
tt=length(ss);  
if(tt > 0)  
    disp('ϵͳ���ȶ�')  
else
    disp('ϵͳ�ȶ�')  
end 
%�ж���С��λ
xx=find(real(z) > 0);  
yy=length(xx);  
if(yy>0)  
    disp('ϵͳ������С��λϵͳ')  
else  
    disp('ϵͳ����С��λϵͳ')  
end 
%���ڶ��ʣ��жϿɿ���
T1=ctrb(A,B)
R1=rank(T1)
if R1==4 
     disp('ϵͳ��ȫ�ɿ�')
    [Ac2,Bc2,Cc2,Dc2]=ss2ss(A,B,C,D,inv(T1))
    To2=inv(T1)
else
    disp('ϵͳ���ɿ�')
end
T2=obsv(A,C)
R2=rank(T2)
if R2==4
    disp('ϵͳ��ȫ�ɹ۲�')
    [Ao1,Bo1,Co1,Do1]=ss2ss(A,B,C,D,T2)
    To1=inv(T2)
else
     disp('ϵͳ���ɹ۲�')
end
