%% ���Ե�Ƶ�źŵĲ���
clc;close all;clear all;

T = 10e-6;                          %����
B = 25e6;                           %�źŴ���
K = B/T;                            %��Ƶб��
Fs = 2*B;Ts = 1/Fs;                 %����Ƶ�ʼ��������
N = T/Ts;
t = linspace(-T/2,T/2,N);
f0=10e6;                            %�ز�Ƶ��
St = exp(1j*pi*K*t.^2+1j*2*pi*f0*t);            %�������Ե�Ƶ�ź�

figure;
subplot(211)
plot(t*1e6,St);
xlabel('Time in u sec');
title('���Ե�Ƶ�ź�');
grid on;axis tight;
subplot(212)
freq = linspace(-Fs/2,Fs/2,N);
plot(freq*1e-6,fftshift(abs(fft(St))));
xlabel('Frequency in MHz');
title('���Ե�Ƶ�źŵķ�Ƶ����');
grid on;axis tight;
