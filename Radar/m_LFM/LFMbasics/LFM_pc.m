%% 线性调频信号的匹配滤波
clc;close all;clear all;

T=10e-6;                         %脉宽
B=25e6;                          %信号带宽
K=B/T;                           %调频斜率
Fs=200e6;Ts=1/Fs;                 %采样率
N=T/Ts;
t=linspace(-T/2,T/2,N);
St=exp(j*pi*K*t.^2);              %线性调频信号
Ht=exp(-j*pi*K*t.^2);             %匹配滤波器
Sot=conv(St,Ht);                 %匹配滤波后的线性调频信号

figure;
subplot(211)
L=2*N-1;
t1=linspace(-T,T,L);
Z=abs(Sot);Z=Z/max(Z);            %归一化
Z=20*log10(Z+1e-6);
Z1=abs(sinc(B.*t1));               %sinc函数
Z1=20*log10(Z1+1e-6);
t1=t1*B;                                         
plot(t1,Z,t1,Z1,'r.');
axis([-15,15,-50,inf]);grid on;
legend('仿真','sinc');
xlabel('Time in sec \times\itB');
ylabel('幅度,dB');
title('匹配滤波后的线性调频信号');

subplot(212)                          %zoom
N0=3*Fs/B;
t2=-N0*Ts:Ts:N0*Ts;
t2=B*t2;
plot(t2,Z(N-N0:N+N0),t2,Z1(N-N0:N+N0),'r.');
axis([-inf,inf,-50,inf]);grid on;
set(gca,'Ytick',[-13.4,-4,0],'Xtick',[-3,-2,-1,-0.5,0,0.5,1,2,3]);
xlabel('Time in sec \times\itB');
ylabel('幅度,dB');
title('匹配滤波后的线性调频信号(Zoom)');
