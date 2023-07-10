clc;
clear;
close all;
%%参数
fc = 10e9;                      %载波频率
Tp = 10e-6;                     %脉冲宽度
B = 10e6;                       %信号带宽
fs = 1e8;                       %采样率
R = 3000;                       %初始采样距离
Kr = B / Tp;                    %线性调频斜率
c = 3e8;                        %光速
%%发射信号  参考信号
t = 0:1 / fs:Tp + 2 * R / c;
N = length(t);
f = -fs / 2:fs / (N - 1):fs / 2;
refer = rectpuls(t - Tp / 2, Tp) .* exp(1i * pi * Kr * (t - Tp / 2).^2);
s = t * c / 2;
Refer = (fft(refer)); %参考信号的傅里叶变换
figure(1)
plot(s, real(refer));
grid;
title('参考信号的实部');
figure(2)
plot(s, imag(refer));
grid;
title('参考信号的虚部');
figure(3)
%plot(f,abs(Refer));
plot(f, abs(fftshift(Refer)));
grid;
title('参考信号的频谱');

%%回波信号
tao = 2 * R / c;
s_back = rectpuls(t - tao - Tp / 2, Tp) .* exp(1i * pi * Kr * (t - tao - Tp / 2).^2) .* exp(-1i * 2 * pi * fc * tao);

%%脉冲压缩

S_back = fft(s_back); %回波信号的傅里叶变换
S1 = abs(ifft(S_back .* conj(Refer)));
S = S1 / max(S1);
S = 20 * log10(S);

figure(4)
plot(s, real(s_back));
grid;
title('回波信号的实部');
figure(5)
plot(s, imag(s_back));
grid;
title('回波信号的虚部');
figure(6)
plot(f, abs(fftshift(S_back)));
grid;
title('回波信号的频谱');
figure(7)
plot(s, S);
title('脉压后的时域波形');
axis([2500 3500 -100 0]);
