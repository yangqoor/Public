%���⣺��֪ĳ�������������������ź�Ϊx(t)=20*sin(25*2*pi*t+pi/3)+15*sin(200*2*pi*t+pi/2)+10*sin(220*2*pi*t+pi/2)+8*sin(240*2*pi*t+pi/2),����20*sin(25*2*pi*t
%+pi/3)Ϊ�����źţ�����Ϊ�����źš�����������ʱ��Ϊt=4�룬����Ƶ��Ϊ500Hz�������һ�������˲������˳������źţ�����˲�����źš�

%��һ����ȷ������ָ�꣬����������˲���
Wp=100*2*pi;%ͨ����ֹ��Ƶ��
Wst=200*2*pi;%�����ֹ��Ƶ��
det1=2;%ͨ�����˥��
det2=15;%�����С˥��
Fs=500;
%����ָ������
% Wp=Fs*2*tan(Wp/Fs/2);%ͨ����ֹ��Ƶ��
% Wst=Fs*2*tan(Wst/Fs/2);%�����ֹ��Ƶ��

[N,Wc]=buttord(Wp,Wst,det1,det2,'s');%������ָ����������˹ģ�ͣ�������˲�������N��3dB��ֹ��Ƶ��
[Z,P,K]=buttap(N);%�������ΪN�Ľ�ֹ��Ƶ��Ϊ1������˹�˲���ϵͳ�������õ������㼫��ģ��
[Bap,Aap]=zp2tf(Z,P,K);%����ֹ��Ƶ��Ϊ1���㼫��ģ��ת��Ϊ����ʽģ��
[b,a]=lp2lp(Bap,Aap,Wc);%������ֹ��Ƶ��Ϊ1�Ĵ��ݺ���ת��Ϊ��������Ҫ�Ľ�ֹƵ��ΪWc��ϵͳ����

[bz,az]=bilinear(b,a,Fs);%���ݲ���Ƶ�ʣ�����˫���Ա任������ģ���ͨ�˲���ת��Ϊ���ֵ�ͨ�˲���
[H,W]=freqz(bz,az);

figure
plot(W*Fs/(2*pi),abs(H),'k');%������ƺõ��˲����ķ�����Ӧ�������Ƿ�����Ҫ��
grid
xlabel('Ƶ��/Hz');
ylabel('������Ӧ');

%�ڶ���������ģ���ź�x(t)�����������Ϊ�����ź�x(n)��
t=4;
Num=t*Fs;
nt=[0:1/Fs:(Num-1)*1/Fs];
Xn=20*sin(25*2*pi*nt+pi/3)+15*sin(200*2*pi*nt+pi/2)+10*sin(220*2*pi*nt+pi/2)+8*sin(240*2*pi*nt+pi/2);
FXn=fft(Xn);%���������ź�x(n)��Ƶ�ף�
figure
subplot(2,2,1);
plot(nt(1:200),Xn(1:200),'r-');
xlabel('ʱ��/s');
ylabel('����');
grid
title('�����ź�x(n)');
subplot(2,2,2);
plot((0:Num/2-1)*(1/t),2*1/Num*abs(FXn(1:Num/2)),'r-');
% plot((0:Num-1)*(1/t),2*1/Num*abs(FXn(1:Num)));
grid
xlabel('Ƶ��/Hz');
ylabel('����');
title('�����ź�Ƶ��X(jw)');

%���������������ź������˲�������������ź�Yn
%%%%%%����һ����ʱ�����þ��������Yn=Xn���h(n)��
% [hn,tt]=impz(bz,az,100,Fs);%��������Ӧh(n)��Ҳ������hn=filter(bz,az,[1 zeros(1,99)]);
% Yn=conv(Xn,hn');%Xn���h(n)�ĳ���ΪNum+100-1;Ҳ����ֱ���ã�Yn=filter(bz,az,Xn);

%%%%%%������������Ƶ����˷��õ�Yn��Ƶ�ף�FYn=FXn*H(ejw);�ٶ�FYn�渵��Ҷ�任�õ�Yn
Hh=[H' zeros(1,Num-512)];%Ҳ������Hh=fft(hn)��
FYn=FXn.*Hh;%Ƶ����˷��õ�Yn��Ƶ��FYn;
Yn=ifft(FYn);%��FYn�渵��Ҷ�任�õ�Yn

%%%%%%������������ֱ��һ��ʵ��[bz,az]�����˲�������������ź�Yn��
%ֱ��һ��[bz,az]�����˲���:Yn(n)=bz(1)*Xn(n)+bz(2)*Xn(n-1)+bz(3)*Xn(n-2)+bz(4)*Xn(n-3)-(az(2)*Yn(n-1)+az(3)*Yn(n-2)+az(4)*Yn(n-3))
% Yn=zeros(1,Num);
% Yn(1)=bz(1)*Xn(1);
% Yn(2)=bz(1)*Xn(2)+bz(2)*Xn(1)-az(2)*Yn(1);
% Yn(3)=bz(1)*Xn(3)+bz(2)*Xn(2)+bz(3)*Xn(1)-az(2)*Yn(2)-az(3)*Yn(1);
for n=4:2000
    Yn(n)=bz(1)*Xn(n)+bz(2)*Xn(n-1)+bz(3)*Xn(n-2)+bz(4)*Xn(n-3)-(az(2)*Yn(n-1)+az(3)*Yn(n-2)+az(4)*Yn(n-3));
end

subplot(2,2,3);
plot((1:200)/Fs,Yn(1:200),'r');
xlabel('ʱ��/s');
ylabel('����');
grid
title('�����ź�y(n)');

FYn=fft(Yn);%���������ź�Yn��Ƶ�ף�
length=size(Yn,2);
subplot(2,2,4);
plot((0:round(length/2)-1)*1/(length/Fs),2*1/length*abs(FYn(1:round(length/2))),'r');
xlabel('Ƶ��/Hz');
ylabel('����');
grid
title('����ź�Ƶ��Y(jw)');