num=[1];den=conv([1],conv([1,1],[0.6,1]));
sys1=tf(num,den);
[np,dp]=pade(2,3);%pade(T,N)用于绘制N阶传递函数中exp(-T*s)延迟的幅值及相角
sys=sys1*tf(np,dp);
rlocus(sys);title('时滞系统根轨迹图')