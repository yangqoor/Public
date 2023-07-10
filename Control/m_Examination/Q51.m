num=[20];den=[1 4 3 0];
[numc,denc]=cloop(num,den,-1);
sys=tf(numc,denc)%求传递函数
[A1,B1,C1,D1]=tf2ss(num,den)%求状态空间
P=[-5,-2+j*2,-2-2*j];
K=acker(A1,B1,P)%状态反馈矩阵