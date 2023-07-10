%% ���Ե�Ƶ�źŵ�ƥ���˲�
clc;close all;clear all;

T=10e-6;                         %����
B=25e6;                          %�źŴ���
K=B/T;                           %��Ƶб��
Fs=200e6;Ts=1/Fs;                 %������
N=T/Ts;
t=linspace(-T/2,T/2,N);
St=exp(j*pi*K*t.^2);              %���Ե�Ƶ�ź�
Ht=exp(-j*pi*K*t.^2);             %ƥ���˲���
Sot=conv(St,Ht);                 %ƥ���˲�������Ե�Ƶ�ź�

figure;
subplot(211)
L=2*N-1;
t1=linspace(-T,T,L);
Z=abs(Sot);Z=Z/max(Z);            %��һ��
Z=20*log10(Z+1e-6);
Z1=abs(sinc(B.*t1));               %sinc����
Z1=20*log10(Z1+1e-6);
t1=t1*B;                                         
plot(t1,Z,t1,Z1,'r.');
axis([-15,15,-50,inf]);grid on;
legend('����','sinc');
xlabel('Time in sec \times\itB');
ylabel('����,dB');
title('ƥ���˲�������Ե�Ƶ�ź�');

subplot(212)                          %zoom
N0=3*Fs/B;
t2=-N0*Ts:Ts:N0*Ts;
t2=B*t2;
plot(t2,Z(N-N0:N+N0),t2,Z1(N-N0:N+N0),'r.');
axis([-inf,inf,-50,inf]);grid on;
set(gca,'Ytick',[-13.4,-4,0],'Xtick',[-3,-2,-1,-0.5,0,0.5,1,2,3]);
xlabel('Time in sec \times\itB');
ylabel('����,dB');
title('ƥ���˲�������Ե�Ƶ�ź�(Zoom)');
