numc=[8,6];denc=conv([1,0,0],conv([1,15],[1,6,10]));
[numc,denc]=cloop(numc,denc,-1);GC=tf(numc,denc)
%���㴫�ݺ���
numc=[8,6];denc=conv([1,0,0],conv([1,15],[1,6,10]));
figure(1);
step(numc,denc);
grid on
%���ƽ�Ծ��Ӧ����
figure(2);
bode(numc,denc);
grid on
%���Ʋ���ͼ
[Gm,Pm]=margin(GC)%���ȶ�ԣ������λԣ����