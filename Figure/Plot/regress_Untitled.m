
clear;
close all
x1=0.1:0.01:0.18;
x2=[x1,0.2,0.21,0.23]';
y=[42,41.5,45,45.5,45,47.5,49,55,50,55,55.5,60.5]';
x=[ones(12,1),x2];
%�������ݵ�ɢ��ͼ
figure;
plot(x2,y,'+');
hold on
%�ع����
[b,bint,r,rint,stats]=regress(y,x);
b;bint;stats;
%Ԥ�⼰���ع���ͼ
z=b(1)+b(2)*x2;
plot(x2,z,'-r');
legend('Ԥ��ͼ','�ع���ͼ');
hold off
%���в����ͼ
figure(2)
rcoplot(r,rint);
