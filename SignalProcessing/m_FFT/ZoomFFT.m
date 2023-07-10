clear;
close all;
clc;
fs = 1000;                              %采样频率
N  = 2048;                              %傅里叶变换点数
D  = 50;                                %细化倍数
M  = 200;                               %滤波器阶数

t  = (0:N * D + 2 * M) / fs;            %时间轴
x  = 4 * sin(2 * pi * 166.4 * t) + 2 * sin(2 * pi * 165 * t + pi / 6) ...
    +0.6 * randn(1, N * D + 2 * M + 1); %信号

xf = fft(x, N);                         %傅里叶变换
xf = abs(xf(1:N / 2)) / N * 2;
subplot(211);
plot((0:N / 2 - 1) * fs / N, xf);
axis([163.5 169 0 4])
grid on
xlabel('f/Hz'); ylabel('Amplitude')
title('直接进行傅里叶变换结果')

fe = 167;                               %中心频率
k = 1:M;
w = 0.5 + 0.5 * cos(pi * k / M);        %Hanning函数
fl = max(fe - fs / (4 * D), -fs / 2.2); %频率下限
fh = min(fe + fs / (4 * D), fs / 2.2);  %频率上限

yf = D * fl;
df = fs / D / N;                        %分辨率
f = fl:df:fl + (N / 2 - 1) * df;
xz = zeros(1, N / 2);
wl = 2 * pi * fl / fs;                  %归一化角频率
wh = 2 * pi * fh / fs;
hr(1) = (wl - wh) / pi;
hr(2:M + 1) = (sin(wl * k) - sin(wh * k)) ./ (pi * k) .* w;
hi(1) = 0;
hi(2:M + 1) = (cos(wl * k) - cos(wh * k)) ./ (pi * k) .* w;

p = 0:N - 1;
w = 0.5 - 0.5 * cos(2 * pi * p / N);
xrz = zeros(1, N / 2);
xiz = zeros(1, N / 2);
L = 10; %循环次数

for i = 1:L

    for k = 1:N
        kk = (k - 1) * D + M;
        xrz(k) = x(kk + 1) * hr(1) + sum(hr(2:M + 1) .* (x(kk + 2:kk + M + 1) + x(kk:-1:kk - M + 1)));
        xiz(k) = x(kk + 1) * hi(1) + sum(hi(2:M + 1) .* (x(kk + 2:kk + M + 1) - x(kk:-1:kk - M + 1)));
    end

    xzt = (xrz + 1j * xiz) .* exp(-1j * 2 * pi * (0:N - 1) * yf / fs);
    xzt = xzt .* w;
    xzt = xzt - sum(xzt) / N;
    xzt = fft(xzt);
    xz = xz + (abs(xzt(1:N / 2)) / N * 2).^2;
end

xz = (xz ./ L).^0.5;
subplot(212);
plot(f, xz);
axis([163.5 169 0 4])
grid on
xlabel('f(Hz)'); ylabel('Amplitude')
title('Zoom-FFT细化后的频谱')
