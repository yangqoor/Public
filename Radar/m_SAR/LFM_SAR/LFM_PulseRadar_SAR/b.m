clear;
close all;
clc;
%%参数
fc = 10e9;               %载波频率
Tp = 10e-6;              %脉冲宽度
B = 10e6;                %信号带宽
fs = 1e8;                %采样率
R = 3000;                %初始采样距离
c = 3e8;                 %光速
PRT = 100e-6;            %脉冲重复周期
N = 64;                  %总脉冲个数
v = 60;                  %目标运动速度

%%
ta0 = 2 * R / c;         %快时间时延
Kr = B / Tp;             %线性调频斜率
t = 0:1 / fs:Tp + ta0;   %时域范围
M = length(t);

for k = 1:64
    ta = 2 * (R - (k - 1) * PRT * v) / c;
    s_back = rectpuls(t - ta - Tp / 2, Tp) .* exp(1j * pi * Kr * (t - Tp / 2 - ta).^2) .* exp(-1j * 2 * pi * fc * ta);
    refer = rectpuls(t - Tp / 2, Tp) .* exp(1j * pi * Kr * (t - Tp / 2).^2);
    S1 = fft(s_back);
    S2 = fft(refer);
    S = S1 .* conj(S2);
    s1(k, :) = ifft(S); %压缩后的回波信号
    s(k, :) = s1(k, :) / max(s1(k, :)); %归一化
    s(k, :) = db(s(k, :));
    [maxvalue, maxposition] = max(s(k, :)); %距离向压缩后最大值的所在的列
end

for m = 1:M
    F_S(:, m) = fftshift(abs(fft(s1(:, m))));
end

[maxvalue, max_v] = max(F_S(:, maxposition)); %所在行
%测速
fd = (max_v - 33) / PRT / N; %多普频率
V_fd = fd * c / 2 / fc
%%测速度范围
fd_max = 1 / PRT / 2;
v_max = fd_max * c / 2 / fc
%%测精度
det_fd = 1 / PRT / 64;
det_v = det_fd * c / 2 / fc
figure
mesh(t * c / 2, linspace(-75, 75, 64), abs(F_S));
title('二维距离多普勤平面图');
range_nonoise = maxposition * c / 2 / fs;
disp(['目标回波无噪声时最大值法测的距离为:', num2str(range_nonoise), 'm']);
disp(['目标回波无噪声时最大值法测的速度为:', num2str(V_fd), 'm/s']);
