%% 线性调频信号匹配滤波的频域实现
clc;close all;clear all;

T=10e-6;                            %脉宽
B=25e6;                             %带宽
K=B/T;                              %调频斜率
Fs=200e6;Ts=1/Fs;                     %采样率
N=T/Ts;
t=linspace(-T/2,T/2,N);
St=exp(j*pi*K*t.^2);                %线性调频信号
Ht=exp(-j*pi*K*t.^2);               %匹配滤波器
Sf = fft(St,2048);                   %变换至频域
Hf = fft(Ht,2048);
Sot = fftshift(ifft(Sf.*Hf));           %频域相乘后做IFFT

figure;
subplot(211)
plot(t,real(St));axis tight;
xlabel('时间/s','FontSize',12);ylabel('信号幅度','FontSize',12);
title('LFM输入信号','FontSize',12);

subplot(212)
t1=linspace(-T/2,T/2,2048);
plot(t1,db(abs(Sot)));axis tight;
xlabel('时间/s','FontSize',12);ylabel('信号幅度/dB','FontSize',12);
title('LFM脉压后的输出信号','FontSize',12);
