%�󴫵ݺ���
num1=[1];den1=[0.5 1];
num2=[1];den2=[1 2 2];
num3=[1];den3=[1 1];
[numc,denc]=feedback(num2,den2,num3,den3);
[nums,dens]=series(num1,den1,numc,denc);
[numt,dent]=cloop(nums,dens,-2);
G=tf(numt,dent)

%����㼫������
[z,p,k]=tf2zp(numt,dent)

%����ϵͳ���㼫��ͼ
figure(1);
G1=zpk(G);
z=G1.z;p=G1.p;Z=z{:};P=p{:};k=G1.k;
pzmap(G);pzmap(G1);
grid

%����ϵͳ���ο�˹������
figure(2);
nyquist(G);
grid

%״̬�ռ�ģ�� 
[A,B,C,D]=tf2ss(numt,dent)