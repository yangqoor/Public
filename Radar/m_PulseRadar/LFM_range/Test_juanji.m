% ���Ե�Ƶ�źŵľ�����ܲ��ԣ�ƥ�䣩
clc;
clear all;
close all;

B = 10e6;
fr = 10e3;  % �����ظ�Ƶ��
Tr = 1 / fr;
fs = 2 * B; % ����Ƶ��
ts = 1 / fs;
Tp = Tr / 4;
Kt = B / Tp;
tao = 0 * Tr / 8;

t = 0:ts:Tr - ts;
xn = exp(1i * pi * Kt * (t - Tp / 2).^2) .* rectpuls(t - Tp / 2, Tp);
xn1 = exp(1i * pi * Kt * (t - Tp / 2 - tao).^2) .* rectpuls(t - Tp / 2 - tao, Tp);
hn = exp(-1i * pi * Kt * (t - Tp / 2).^2) .* rectpuls(t - Tp / 2, Tp);

% t=-Tp/2:ts:Tr-Tp/2-ts;
% xn=exp(1i*pi*Kt*t.^2).*rectpuls(t,Tp);
% xn1=exp(1i*pi*Kt*(t-tao).^2).*rectpuls(t-tao,Tp);
% hn=exp(-1i*pi*Kt*t.^2).*rectpuls(t,Tp);

figure();
xk = fftshift(fft(xn));
xk1 = fftshift(fft(xn1));
hk = fftshift(fft(hn));
Yk = xk1 .* hk;
yn = ifft(Yk);
freq = (-fs / 2:fs / length(xk):fs / 2 - fs / length(xk)) / 1e6;
subplot(221), plot(freq, abs(xk));
xlabel('Frequency /MHz'); ylabel('Magnitude'); title('����Ƶ��');
subplot(222), plot(freq, abs(xk1));
xlabel('Frequency /MHz'); ylabel('Magnitude'); title('�����ӳ�Ƶ��');
subplot(223), plot(freq, abs(hk));
xlabel('Frequency /MHz'); ylabel('Magnitude'); title('ƥ��Ƶ��');
subplot(224), plot(freq, abs(Yk));
xlabel('Frequency /MHz'); ylabel('Magnitude'); title('ƥ���˲���Ƶ��');

yn1 = conv(xn1, hn);
figure();
subplot(211), plot(abs(yn));
title('FFT��');
subplot(212), plot(abs(yn1));
title('���');
