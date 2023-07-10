% 加hamming窗后脉压
clc; close all; clear

T = 10e-6;
B = 60e6;
c = 3e8;
fs = 100e6;
ts = 1 / fs;
k = B / T;
N = T / ts;
t = linspace(-T / 2, T / 2, N);
s1 = exp(j * pi * k * t.^2);

figure(1);
subplot(2, 2, 1);
plot(t * 1e6, real(s1));
xlabel('time in u second');
title('real part');
subplot(2, 2, 2);
plot(t * 1e6, imag(s1));
xlabel('time in u second');
title('image part');
subplot(2, 2, 3);
plot(t * 1e6, abs(s1));
xlabel('time');
title('包络');
subplot(2, 2, 4);
plot(phase(s1));
xlabel('time');
title('相位');

NFFT = 2048;
n = 0:NFFT - 1;
padd = exp(j * pi * n / 2);
s2 = fftshift(fft(s1, NFFT) .* padd);
mag = abs(s2) * 2 / NFFT;
f = n * fs / NFFT;
figure(2);
subplot(2, 2, 1);
plot(f, mag);
subplot(2, 2, 2);
plot(f, phase(s2));
subplot(2, 2, 3);
plot(f, real(s2));
subplot(2, 2, 4);
plot(f, imag(s2));

%echo
sr1 = [s1, zeros(1, 100)];
sr2 = [zeros(1, 100), s1];
echo = sr1 + sr2;

figure(3)
subplot(3, 1, 1);
plot(real(sr1));
subplot(3, 1, 2);
plot(real(sr2));
subplot(3, 1, 3);
plot(real(echo));

figure(6)
y4 = fftshift(fft(echo, NFFT));
plot(abs(y4));

% h=hamming(length(echo));%汉明窗生成
% Nfft=2048;
% y2=fft(echo,Nfft);
% y3=fft(echo.*h',Nfft);%加汉明窗
%
%
% %不加窗进行脉冲压缩
% output1=fftshift(ifft((y2.*conj(fft(s1,Nfft))),Nfft));
% output1=output1(525:(length(echo)+524))/max(output1);
%
%
% %加汉明窗后进行脉冲压缩
% output2=fftshift(ifft((y3.*conj(fft(s1,Nfft))),Nfft));
% output2=output2(525:(length(echo)+524))/max(output2);
%
% figure(4)
% subplot(4,1,1);
% plot(real(output1));title('未加窗脉压结果');
% %xlabel('时间（s）');  ylabel('dB');
% grid on;
% subplot(4,1,2);
% plot(real(output2));title('加汉明窗脉压结果');
% %xlabel('时间（s）');  ylabel('dB');
% grid on;
% %对数坐标，幅度转为dB单位
%
% subplot(4,1,3);
% plot(20*log(abs(output1)));
% %axis([4.6*10^(-5) 5.4*10^(-5) -130 0]);
% title('不加窗后脉压结果');
% %xlabel('时间（s）'); ylabel('dB');
% grid on;
% subplot(4,1,4);
% plot(20*log(abs(output2)));
% %axis([4.6*10^(-5) 5.4*10^(-5) -130 0]);
% title('加hamming窗后脉压结果');
% %xlabel('时间（s）'); ylabel('dB');
% grid on;

h = [zeros(424, 1); hamming(1200); zeros(424, 1)]; %汉明窗生成
Nfft = 2048;
y2 = fft(echo, Nfft);
y3 = fft(echo, Nfft); %加汉明窗

%不加窗进行脉冲压缩
output1 = fftshift(ifft(y2 .* conj(fft(s1, Nfft)), Nfft));
output1 = output1(525:(length(echo) + 524)) / max(output1);

%加汉明窗后进行脉冲压缩
output2 = fftshift(ifft((y3 .* conj(fft(s1, Nfft)) .* fftshift(h')), Nfft));
output2 = output2(525:(length(echo) + 524)) / max(output2);

figure(4)
subplot(4, 1, 1);
plot(abs(output1)); title('未加窗脉压结果');
%xlabel('时间（s）');  ylabel('dB');
grid on;
subplot(4, 1, 2);
plot(abs(output2)); title('加汉明窗脉压结果');
%xlabel('时间（s）');  ylabel('dB');
grid on;
%对数坐标，幅度转为dB单位
subplot(4, 1, 3);
plot(20 * log(abs(output1)));
%axis([4.6*10^(-5) 5.4*10^(-5) -130 0]);
title('不加窗后脉压结果');
xlabel('时间（s）'); ylabel('dB');
grid on;
subplot(4, 1, 4);
plot(20 * log(abs(output2)));
%axis([4.6*10^(-5) 5.4*10^(-5) -130 0]);
title('加hamming窗后脉压结果');
xlabel('时间（s）'); ylabel('dB');
grid on;

y = fftshift(fft(output2, Nfft));
figure(5)
plot(abs(y));
