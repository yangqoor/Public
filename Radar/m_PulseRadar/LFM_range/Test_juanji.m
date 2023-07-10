% 线性调频信号的卷积功能测试（匹配）
clc;
clear all;
close all;

B = 10e6;
fr = 10e3;  % 脉冲重复频率
Tr = 1 / fr;
fs = 2 * B; % 采样频率
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
xlabel('Frequency /MHz'); ylabel('Magnitude'); title('基带频谱');
subplot(222), plot(freq, abs(xk1));
xlabel('Frequency /MHz'); ylabel('Magnitude'); title('基带延迟频谱');
subplot(223), plot(freq, abs(hk));
xlabel('Frequency /MHz'); ylabel('Magnitude'); title('匹配频谱');
subplot(224), plot(freq, abs(Yk));
xlabel('Frequency /MHz'); ylabel('Magnitude'); title('匹配滤波后频谱');

yn1 = conv(xn1, hn);
figure();
subplot(211), plot(abs(yn));
title('FFT后');
subplot(212), plot(abs(yn1));
title('卷积');
