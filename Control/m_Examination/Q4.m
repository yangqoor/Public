num=[1];den=conv([1],conv([1,1],[0.6,1]));
sys1=tf(num,den);
[np,dp]=pade(2,3);%pade(T,N)���ڻ���N�״��ݺ�����exp(-T*s)�ӳٵķ�ֵ�����
sys=sys1*tf(np,dp);
rlocus(sys);title('ʱ��ϵͳ���켣ͼ')