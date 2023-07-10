%% ���Ե�Ƶ�ź�ƥ���˲���Ƶ��ʵ��
clc;close all;clear all;

T=10e-6;                            %����
B=25e6;                             %����
K=B/T;                              %��Ƶб��
Fs=200e6;Ts=1/Fs;                     %������
N=T/Ts;
t=linspace(-T/2,T/2,N);
St=exp(j*pi*K*t.^2);                %���Ե�Ƶ�ź�
Ht=exp(-j*pi*K*t.^2);               %ƥ���˲���
Sf = fft(St,2048);                   %�任��Ƶ��
Hf = fft(Ht,2048);
Sot = fftshift(ifft(Sf.*Hf));           %Ƶ����˺���IFFT

figure;
subplot(211)
plot(t,real(St));axis tight;
xlabel('ʱ��/s','FontSize',12);ylabel('�źŷ���','FontSize',12);
title('LFM�����ź�','FontSize',12);

subplot(212)
t1=linspace(-T/2,T/2,2048);
plot(t1,db(abs(Sot)));axis tight;
xlabel('ʱ��/s','FontSize',12);ylabel('�źŷ���/dB','FontSize',12);
title('LFM��ѹ�������ź�','FontSize',12);
